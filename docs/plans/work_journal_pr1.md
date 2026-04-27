# 업무일지(WorkJournal) PR1 구현 계획 — MVP

**확정 결정 (2026-04-27)**
- D1 = A: WorkJournal을 WorkPlan과 별도 모델로 신설
- D2 = B: 태그는 `acts-as-taggable-on` gem 사용
- D3 = 수용: 8개 기능을 4개 PR로 분할

**PR1 범위 (이 문서)**
모델 + 마이그레이션 + 기본 CRUD + Markdown 렌더 + 캘린더 뷰

**PR2 (후속, 별도 문서)**: 필터/검색 + 태그 활성화
**PR3**: 템플릿 + Draft 자동저장 (Stimulus + Turbo)
**PR4**: 통계 대시보드 (`Queries::WorkJournalStats`)

---

## 1. 데이터 모델

### 마이그레이션
`db/migrate/YYYYMMDDHHMMSS_create_work_journals.rb`

```ruby
class CreateWorkJournals < ActiveRecord::Migration[8.1]
  def change
    create_table :work_journals do |t|
      t.references :user, null: false, foreign_key: true
      t.string  :title,           null: false, limit: 200
      t.text    :content,         null: false
      t.string  :content_format,  null: false, default: "markdown"
      t.integer :category,        null: false, default: 0
      t.integer :status,          null: false, default: 0
      t.integer :progress,        null: false, default: 0
      t.date    :work_date,       null: false
      t.boolean :is_draft,        null: false, default: false  # PR3에서 활성화
      t.timestamps
    end

    add_index :work_journals, [:user_id, :work_date]
    add_index :work_journals, [:user_id, :status]
    add_index :work_journals, [:user_id, :category]
    add_index :work_journals, [:user_id, :is_draft]
  end
end
```

**인덱스 근거**: 캘린더 월별 조회, 진행중 필터, 카테고리 통계, draft 분리 조회.
PR2 태그 인덱스는 `acts-as-taggable-on` 마이그레이션이 자체 생성.

### 모델
`app/models/work_journal.rb`

```ruby
class WorkJournal < ApplicationRecord
  belongs_to :user

  CATEGORIES = { task: 0, meeting: 1, planning: 2, issue: 3, etc: 4 }.freeze
  STATUSES   = { in_progress: 0, completed: 1, on_hold: 2 }.freeze
  FORMATS    = %w[markdown html].freeze

  enum :category, CATEGORIES
  enum :status,   STATUSES

  validates :title,          presence: true, length: { maximum: 200 }
  validates :content,        presence: true
  validates :content_format, inclusion: { in: FORMATS }
  validates :work_date,      presence: true
  validates :progress,       numericality: { only_integer: true, in: 0..100 }

  scope :for_month, ->(year, month) {
    start_date = Date.new(year.to_i, month.to_i, 1)
    where(work_date: start_date..start_date.end_of_month)
  }

  scope :recent, -> { order(work_date: :desc, created_at: :desc) }
end
```

**설계 메모**
- `enum`은 integer-backed (Rails 8 `enum :category, {...}` 신문법, 2번째 인자 hash)
- `is_draft` 컬럼은 PR1에 마이그레이션만 추가 (스키마 변경 1번으로 끝내기 위함). 폼/컨트롤러 분기는 PR3에서.
- 태그 컬럼/관계는 PR2에서 `acts-as-taggable-on` 설치 후 추가 (해당 gem이 자체 마이그레이션 제공).

---

## 2. 라우팅

`config/routes.rb` — 기존 `work_plans` 아래 추가

```ruby
resources :work_journals
```

PR4 통계용 `collection do; get :stats; end` 는 PR4에서 추가.

---

## 3. 컨트롤러

`app/controllers/work_journals_controller.rb` — work_plans_controller 패턴 그대로

```ruby
class WorkJournalsController < ApplicationController
  before_action :set_work_journal, only: %i[show edit update destroy]
  before_action :authorize_work_journal!, only: %i[show edit update destroy]

  def index
    year  = params[:year]&.to_i  || Date.today.year
    month = params[:month]&.to_i || Date.today.month
    @calendar_date = Date.new(year, month, 1)
    journals = Current.session.user.work_journals.for_month(year, month)
    @journals_by_date = journals.group_by(&:work_date)
  rescue Date::Error
    redirect_to work_journals_path
  end

  def show; end

  def new
    @work_journal = WorkJournal.new(
      work_date: parse_date_param || Date.today,
      content_format: "markdown",
      status: :in_progress,
      category: :task,
      progress: 0
    )
  end

  def create
    @work_journal = Current.session.user.work_journals.new(work_journal_params)
    if @work_journal.save
      redirect_to work_journals_path, notice: "업무일지가 등록되었습니다."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @work_journal.update(work_journal_params)
      redirect_to work_journal_path(@work_journal), notice: "업무일지가 수정되었습니다."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @work_journal.destroy
    redirect_to work_journals_path, notice: "업무일지가 삭제되었습니다."
  end

  private

  def set_work_journal
    @work_journal = WorkJournal.find(params[:id])
  end

  def authorize_work_journal!
    redirect_to work_journals_path, alert: "권한이 없습니다." \
      unless Current.session.user == @work_journal.user
  end

  def parse_date_param
    Date.parse(params[:date]) if params[:date].present?
  rescue Date::Error
    nil
  end

  def work_journal_params
    params.require(:work_journal).permit(
      :title, :content, :content_format,
      :category, :status, :progress, :work_date
    )
  end
end
```

**일관성 메모**
- 인라인 `authorize_*!` 유지 (Pundit 미도입 — 기존 패턴 따름)
- `Current.session.user.work_journals` 통한 스코프 강제 (인가 + 조회 동시)

---

## 4. 뷰

work_plans 뷰 구조를 그대로 따름 (`_form`, `index`, `new`, `edit`, `show`).

### 폼 핵심 (`app/views/work_journals/_form.html.erb` 발췌)

```erb
<%= form_with(model: work_journal, local: true) do |f| %>
  <%= f.text_field :title, required: true, placeholder: "한 줄 요약" %>
  <%= f.date_field :work_date, required: true %>

  <%= f.select :category, WorkJournal.categories.keys.map { |k| [t("work_journals.category.#{k}"), k] } %>
  <%= f.select :status,   WorkJournal.statuses.keys.map { |k| [t("work_journals.status.#{k}"), k] } %>

  <%= f.range_field :progress, min: 0, max: 100, step: 5,
        data: { controller: "progress-bar", progress_bar_target: "input" } %>
  <span data-progress-bar-target="output">0%</span>

  <%= f.text_area :content, required: true, rows: 12,
        placeholder: "Markdown 지원" %>
  <%= f.hidden_field :content_format, value: "markdown" %>
<% end %>
```

### Show 뷰 — Markdown 렌더
```erb
<div class="prose">
  <%= render_markdown(@work_journal.content) %>
</div>
```
→ `ApplicationHelper#render_markdown` 재사용 (이미 sanitize 정책 통일됨).

### Index — 캘린더
work_plans/index.html.erb의 캘린더 그리드 그대로 차용. 날짜 셀에 일지 카드 스택.

### Stimulus controller
`app/javascript/controllers/progress_bar_controller.js` — 슬라이더 값 표시 (10줄 이내).

---

## 5. i18n

`config/locales/ko.yml` 신규 키
```yaml
ko:
  work_journals:
    category:
      task: "작업"
      meeting: "회의"
      planning: "기획"
      issue: "이슈 해결"
      etc: "기타"
    status:
      in_progress: "진행 중"
      completed: "완료"
      on_hold: "보류 중"
```

---

## 6. User 모델 변경

`app/models/user.rb` — 1줄 추가
```ruby
has_many :work_journals, dependent: :destroy
```

---

## 7. 네비게이션

`app/views/layouts/_header.html.erb` (혹은 동일 역할 partial) — 기존 메뉴 옆에 "업무일지" 링크 추가.

---

## 8. 테스트 (Minitest)

### `test/models/work_journal_test.rb`
```ruby
require "test_helper"

class WorkJournalTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @valid_attrs = {
      title: "API 작업",
      content: "## 진행\n- 인증 모듈 완료",
      content_format: "markdown",
      category: :task,
      status: :in_progress,
      progress: 50,
      work_date: Date.today
    }
  end

  test "valid with required fields" do
    j = @user.work_journals.new(@valid_attrs)
    assert j.valid?
  end

  test "title required and limited to 200" do
    j = @user.work_journals.new(@valid_attrs.merge(title: ""))
    assert_not j.valid?
    j.title = "x" * 201
    assert_not j.valid?
  end

  test "progress must be 0..100 integer" do
    [-1, 101, 50.5].each do |bad|
      j = @user.work_journals.new(@valid_attrs.merge(progress: bad))
      assert_not j.valid?, "expected progress=#{bad} invalid"
    end
  end

  test "content_format inclusion" do
    j = @user.work_journals.new(@valid_attrs.merge(content_format: "rtf"))
    assert_not j.valid?
  end

  test "category and status enums" do
    j = @user.work_journals.create!(@valid_attrs)
    assert_equal "task", j.category
    j.update!(status: :completed)
    assert j.completed?
  end

  test "for_month scope returns only that month" do
    @user.work_journals.create!(@valid_attrs.merge(work_date: Date.new(2026,4,15)))
    @user.work_journals.create!(@valid_attrs.merge(work_date: Date.new(2026,5,1)))
    result = @user.work_journals.for_month(2026, 4)
    assert_equal 1, result.count
  end

  test "for_month boundary: last second of month included, first of next excluded" do
    @user.work_journals.create!(@valid_attrs.merge(work_date: Date.new(2026,4,30)))
    @user.work_journals.create!(@valid_attrs.merge(work_date: Date.new(2026,5,1)))
    result = @user.work_journals.for_month(2026, 4).pluck(:work_date)
    assert_includes result, Date.new(2026,4,30)
    assert_not_includes result, Date.new(2026,5,1)
  end
end
```

### `test/controllers/work_journals_controller_test.rb`
- index 인증 필요, 로그인 후 200
- create 성공/실패
- update 권한 (다른 유저 일지 → redirect + alert)
- destroy 권한
- new 시 `?date=2026-04-27` 파라미터 → `work_date` 프리필
- new 시 잘못된 날짜 파라미터 → fallback 동작

### `test/system/work_journals_test.rb` (Capybara)
- 작성 → 캘린더 노출 → 클릭 → 수정 풀 플로우
- Markdown XSS 차단: `<script>alert(1)</script>` 입력 시 렌더에서 실행 안 됨
- 진행률 슬라이더 0/50/100 변경 후 저장값 일치

### Fixtures
`test/fixtures/work_journals.yml` — 최소 2건 (다른 유저 권한 테스트용)

---

## 9. 작업 순서 (병렬화)

```
Lane A (직렬, 시작점):
  1. 마이그레이션 작성 + db:migrate
  2. 모델 + User 관계 + Minitest 모델 테스트

Lane A 완료 후 → Lane B + Lane C 병렬 가능:
  Lane B: 컨트롤러 + 컨트롤러 테스트 + 라우트
  Lane C: 뷰 (_form, index, show, new, edit) + i18n + Stimulus

병합 후:
  3. 시스템 테스트 + 네비게이션 링크 추가
  4. RuboCop -A
  5. 전체 테스트 실행 (bin/rails test)
```

---

## 10. 검증 체크리스트 (PR 머지 전)

- [ ] `bin/rails db:migrate` 성공
- [ ] `bin/rails test` 전부 green
- [ ] `bundle exec rubocop -A` clean
- [ ] `bin/brakeman --no-pager` no new warnings
- [ ] 수동: 일지 작성 → 캘린더 → 수정 → 삭제 풀 플로우
- [ ] 수동: 다른 유저 ID로 URL 직접 접근 → redirect 확인
- [ ] 수동: Markdown 코드블록/표/링크 렌더 정상
- [ ] 인덱스 4개 schema.rb에 반영 확인

---

## 11. NOT in PR1 (의도적 제외)

- 검색/필터 폼 → PR2
- 태그 입력 + 자동완성 → PR2 (gem 설치 포함)
- 템플릿 적용 → PR3
- Draft 자동저장 (Turbo Stream debounce) → PR3
- 통계 대시보드 + Query 객체 → PR4
- Memo `search` 스코프 OR/AND 버그 수정 → 별도 PR (회귀 테스트 포함)
- Pundit 정책 통일 → 별도 리팩토링 PR
- HWPX/PDF 내보내기 → 백로그

---

## 12. 회귀 위험

- WorkPlan과 메뉴 충돌: 헤더 partial에 두 메뉴 공존 시 UX 혼동 가능. PR1에서 라벨 명확화 필요 ("작업계획서" vs "업무일지").
- 마이그레이션 4개 인덱스: SQLite 단일 노드라 락 시간 무시 가능. 프로덕션 데이터 0건이면 즉시 적용 안전.

---

## 13. 예상 디프 규모

- 신규 파일: 12 (마이그레이션 1, 모델 1, 컨트롤러 1, 뷰 5, 헬퍼 1 옵션, i18n 1, Stimulus 1, 테스트 3, 픽스쳐 1)
- 수정 파일: 3 (routes.rb, user.rb, _header partial)
- 신규 라인: ~400 (테스트 포함)
- 신규 클래스: 1 (WorkJournal)

복잡도 임계치 (8 파일 / 2 클래스) 안에 들어옴. ✅
