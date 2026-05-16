# PB동호회 참가 사이트 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** PBPlayground Rails 8 앱을 PB동호회 운동 참가 플랫폼으로 리모델링한다.

**Architecture:** 기존 User/인증 레이어를 유지하면서 Club, ClubMembership, GameSession, Participation 4개 도메인 모델을 추가한다. Participation 생성 로직은 서비스 객체(Participations::CreateService)에서 정원/대기열을 처리한다. 권한은 기존 Pundit 패턴을 따른다.

**Tech Stack:** Rails 8.1, SQLite3, Minitest (fixtures), Pundit, Hotwire (Turbo), Tailwind CSS 4

---

## 파일 구조 맵

### 새로 생성

- `db/migrate/TIMESTAMP_add_pb_fields_to_users.rb`
- `db/migrate/TIMESTAMP_create_clubs.rb`
- `db/migrate/TIMESTAMP_create_club_memberships.rb`
- `db/migrate/TIMESTAMP_create_game_sessions.rb`
- `db/migrate/TIMESTAMP_create_participations.rb`
- `app/models/club.rb`, `club_membership.rb`, `game_session.rb`, `participation.rb`
- `app/policies/club_policy.rb`, `club_membership_policy.rb`, `game_session_policy.rb`, `participation_policy.rb`, `admin/club_policy.rb`
- `app/services/participations/create_service.rb`, `cancel_service.rb`
- `app/controllers/clubs_controller.rb`, `club_memberships_controller.rb`, `game_sessions_controller.rb`, `participations_controller.rb`, `my/participations_controller.rb`, `admin/clubs_controller.rb`
- `app/views/clubs/`, `game_sessions/`, `participations/`, `my/participations/`, `admin/clubs/`

### 수정

- `app/models/user.rb` — PB 전용 enum/fields 추가
- `config/routes.rb` — 새 routes 추가
- `app/views/layouts/` — 네비게이션 메뉴 재구성
- `app/views/admin/dashboards/index.html.erb` — Club 승인 현황 추가
- `test/fixtures/users.yml` — 새 필드 반영

---

## Task 1: User 프로필 PB 필드 추가

**Files:**
- Create: `db/migrate/TIMESTAMP_add_pb_fields_to_users.rb`
- Modify: `app/models/user.rb`
- Test: `test/models/user_test.rb`

- [ ] **Step 1: 마이그레이션 생성**

```bash
bin/rails g migration AddPbFieldsToUsers display_name:string sport_level:integer age_group:integer gender:integer region:string
```

- [ ] **Step 2: 마이그레이션 파일 편집**

생성된 파일에서 각 컬럼에 default 값 추가:

```ruby
class AddPbFieldsToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :display_name, :string
    add_column :users, :sport_level,  :integer, default: 0, null: false
    add_column :users, :age_group,    :integer, default: 0, null: false
    add_column :users, :gender,       :integer, default: 0, null: false
    add_column :users, :region,       :string
  end
end
```

- [ ] **Step 3: 테스트 작성 (RED)**

`test/models/user_test.rb` 에 추가:

```ruby
test "sport_level enum values are defined" do
  assert User.sport_levels.keys == %w[beginner intermediate advanced pro]
end

test "age_group enum values are defined" do
  assert User.age_groups.keys == %w[twenties thirties forties fifties sixties_plus]
end

test "gender enum values are defined" do
  assert User.genders.keys == %w[unspecified male female other]
end
```

- [ ] **Step 4: 테스트 실행 (실패 확인)**

```bash
bin/rails test test/models/user_test.rb
```

Expected: FAIL — "undefined method `sport_levels'"

- [ ] **Step 5: User 모델에 enum 추가**

`app/models/user.rb` 에서 `enum :role` 라인 아래에 추가:

```ruby
enum :sport_level, { beginner: 0, intermediate: 1, advanced: 2, pro: 3 }, default: :beginner
enum :age_group,   { twenties: 0, thirties: 1, forties: 2, fifties: 3, sixties_plus: 4 }, default: :twenties
enum :gender,      { unspecified: 0, male: 1, female: 2, other: 3 }, default: :unspecified
```

- [ ] **Step 6: 마이그레이션 실행**

```bash
bin/rails db:migrate
```

- [ ] **Step 7: 테스트 실행 (GREEN)**

```bash
bin/rails test test/models/user_test.rb
```

Expected: PASS

- [ ] **Step 8: fixtures 업데이트**

`test/fixtures/users.yml` 의 모든 유저 항목에 추가:

```yaml
sport_level: 0
age_group: 0
gender: 0
```

- [ ] **Step 9: Commit**

```bash
git add db/migrate/*_add_pb_fields_to_users.rb app/models/user.rb test/models/user_test.rb test/fixtures/users.yml db/schema.rb
git commit -m "feat: User 모델에 PB 프로필 필드 추가 (sport_level, age_group, gender, region)"
```

---

## Task 2: Club 모델 + Pundit Policy

**Files:**
- Create: `db/migrate/TIMESTAMP_create_clubs.rb`
- Create: `app/models/club.rb`
- Create: `app/policies/club_policy.rb`
- Create: `test/models/club_test.rb`
- Create: `test/fixtures/clubs.yml`

- [ ] **Step 1: 마이그레이션 생성**

```bash
bin/rails g migration CreateClubs name:string description:text owner_id:integer status:integer
```

- [ ] **Step 2: 마이그레이션 파일 편집**

```ruby
class CreateClubs < ActiveRecord::Migration[8.1]
  def change
    create_table :clubs do |t|
      t.string  :name,        null: false
      t.text    :description
      t.integer :owner_id,    null: false
      t.integer :status,      null: false, default: 0
      t.timestamps
    end
    add_index :clubs, :name, unique: true
    add_index :clubs, :owner_id
    add_index :clubs, :status
    add_foreign_key :clubs, :users, column: :owner_id
  end
end
```

- [ ] **Step 3: 테스트 작성 (RED)**

`test/models/club_test.rb` 신규 생성:

```ruby
require "test_helper"

class ClubTest < ActiveSupport::TestCase
  def setup
    @owner = users(:one)
    @club  = Club.new(name: "서울클럽", owner: @owner)
  end

  test "valid with name and owner" do
    assert @club.valid?
  end

  test "invalid without name" do
    @club.name = nil
    assert_not @club.valid?
    assert_includes @club.errors[:name], "can't be blank"
  end

  test "name must be unique" do
    @club.save!
    dup = Club.new(name: "서울클럽", owner: @owner)
    assert_not dup.valid?
  end

  test "default status is pending" do
    assert @club.pending?
  end

  test "status enum includes pending approved suspended" do
    assert Club.statuses.keys == %w[pending approved suspended]
  end
end
```

- [ ] **Step 4: 테스트 실행 (실패 확인)**

```bash
bin/rails test test/models/club_test.rb
```

Expected: FAIL — "uninitialized constant Club"

- [ ] **Step 5: Club 모델 생성**

`app/models/club.rb` 신규 생성:

```ruby
class Club < ApplicationRecord
  belongs_to :owner, class_name: "User"
  has_many :club_memberships, dependent: :destroy
  has_many :members, through: :club_memberships, source: :user
  has_many :game_sessions, dependent: :destroy

  enum :status, { pending: 0, approved: 1, suspended: 2 }, default: :pending

  normalizes :name, with: ->(n) { n.strip }

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :owner, presence: true
end
```

- [ ] **Step 6: 마이그레이션 실행**

```bash
bin/rails db:migrate
```

- [ ] **Step 7: Fixture 생성**

`test/fixtures/clubs.yml` 신규 생성:

```yaml
approved_club:
  name: "서울동호회"
  description: "서울 지역 동호회"
  owner: one
  status: 1

pending_club:
  name: "신규동호회"
  description: "승인 대기 중"
  owner: one
  status: 0
```

- [ ] **Step 8: 테스트 실행 (GREEN)**

```bash
bin/rails test test/models/club_test.rb
```

Expected: PASS

- [ ] **Step 9: ClubPolicy 생성**

`app/policies/club_policy.rb` 신규 생성:

```ruby
class ClubPolicy < ApplicationPolicy
  def index?  = true
  def show?   = record.approved?
  def new?    = user.present?
  def create? = user.present?
  def update? = user.present? && (user == record.owner || user.admin?)
  def edit?   = update?
  def destroy? = user.admin?

  class Scope < ApplicationPolicy::Scope
    def resolve
      user&.admin? ? scope.all : scope.approved
    end
  end
end
```

- [ ] **Step 10: Commit**

```bash
git add db/migrate/*_create_clubs.rb app/models/club.rb app/policies/club_policy.rb test/models/club_test.rb test/fixtures/clubs.yml db/schema.rb
git commit -m "feat: Club 모델 + Pundit policy 추가"
```

---

## Task 3: ClubMembership 모델

**Files:**
- Create: `db/migrate/TIMESTAMP_create_club_memberships.rb`
- Create: `app/models/club_membership.rb`
- Create: `app/policies/club_membership_policy.rb`
- Create: `test/models/club_membership_test.rb`
- Create: `test/fixtures/club_memberships.yml`

- [ ] **Step 1: 마이그레이션 생성**

```bash
bin/rails g migration CreateClubMemberships club_id:integer user_id:integer role:integer status:integer
```

- [ ] **Step 2: 마이그레이션 파일 편집**

```ruby
class CreateClubMemberships < ActiveRecord::Migration[8.1]
  def change
    create_table :club_memberships do |t|
      t.integer :club_id, null: false
      t.integer :user_id, null: false
      t.integer :role,    null: false, default: 0
      t.integer :status,  null: false, default: 0
      t.timestamps
    end
    add_index :club_memberships, [:club_id, :user_id], unique: true
    add_index :club_memberships, :club_id
    add_index :club_memberships, :user_id
    add_foreign_key :club_memberships, :clubs
    add_foreign_key :club_memberships, :users
  end
end
```

- [ ] **Step 3: 테스트 작성 (RED)**

`test/models/club_membership_test.rb` 신규 생성:

```ruby
require "test_helper"

class ClubMembershipTest < ActiveSupport::TestCase
  def setup
    @club = clubs(:approved_club)
    @user = users(:one)
  end

  test "valid with club and user" do
    membership = ClubMembership.new(club: @club, user: @user)
    assert membership.valid?
  end

  test "cannot join same club twice" do
    ClubMembership.create!(club: @club, user: @user)
    dup = ClubMembership.new(club: @club, user: @user)
    assert_not dup.valid?
  end

  test "default role is member and status is pending" do
    m = ClubMembership.new(club: @club, user: @user)
    assert m.member?
    assert m.pending?
  end
end
```

- [ ] **Step 4: 테스트 실행 (실패 확인)**

```bash
bin/rails test test/models/club_membership_test.rb
```

Expected: FAIL

- [ ] **Step 5: ClubMembership 모델 생성**

`app/models/club_membership.rb` 신규 생성:

```ruby
class ClubMembership < ApplicationRecord
  belongs_to :club
  belongs_to :user

  enum :role,   { member: 0, manager: 1 }, default: :member
  enum :status, { pending: 0, approved: 1, rejected: 2 }, default: :pending

  validates :club_id, uniqueness: { scope: :user_id, message: "이미 가입 신청한 동호회입니다." }
end
```

- [ ] **Step 6: User 모델에 관계 추가**

`app/models/user.rb` 에 추가:

```ruby
has_many :club_memberships, dependent: :destroy
has_many :clubs_as_member, through: :club_memberships, source: :club
```

- [ ] **Step 7: 마이그레이션 실행**

```bash
bin/rails db:migrate
```

- [ ] **Step 8: Fixture 생성**

`test/fixtures/club_memberships.yml` 신규 생성:

```yaml
manager_membership:
  club: approved_club
  user: one
  role: 1
  status: 1
```

- [ ] **Step 9: 테스트 실행 (GREEN)**

```bash
bin/rails test test/models/club_membership_test.rb
```

Expected: PASS

- [ ] **Step 10: ClubMembershipPolicy 생성**

`app/policies/club_membership_policy.rb` 신규 생성:

```ruby
class ClubMembershipPolicy < ApplicationPolicy
  def create? = user.present?

  def update?
    return false unless user.present?
    my_membership = user.club_memberships.find_by(club: record.club)
    (my_membership&.manager? && my_membership&.approved?) || user.admin?
  end

  def destroy?
    user.present? && (user == record.user || update?)
  end

  class Scope < ApplicationPolicy::Scope
    def resolve = scope.all
  end
end
```

- [ ] **Step 11: Commit**

```bash
git add db/migrate/*_create_club_memberships.rb app/models/club_membership.rb app/models/user.rb app/policies/club_membership_policy.rb test/models/club_membership_test.rb test/fixtures/club_memberships.yml db/schema.rb
git commit -m "feat: ClubMembership 모델 추가 (가입/승인/역할 관리)"
```

---

## Task 4: GameSession 모델

**Files:**
- Create: `db/migrate/TIMESTAMP_create_game_sessions.rb`
- Create: `app/models/game_session.rb`
- Create: `app/policies/game_session_policy.rb`
- Create: `test/models/game_session_test.rb`
- Create: `test/fixtures/game_sessions.yml`

- [ ] **Step 1: 마이그레이션 생성**

```bash
bin/rails g migration CreateGameSessions club_id:integer title:string venue_name:string address:string scheduled_date:date start_time:time end_time:time court_count:integer fee:integer notes:text max_participants:integer visibility:integer status:integer
```

- [ ] **Step 2: 마이그레이션 파일 편집**

```ruby
class CreateGameSessions < ActiveRecord::Migration[8.1]
  def change
    create_table :game_sessions do |t|
      t.integer :club_id,          null: false
      t.string  :title,            null: false
      t.string  :venue_name,       null: false
      t.string  :address
      t.date    :scheduled_date,   null: false
      t.time    :start_time,       null: false
      t.time    :end_time,         null: false
      t.integer :court_count,      default: 1
      t.integer :fee,              default: 0, null: false
      t.text    :notes
      t.integer :max_participants
      t.integer :visibility,       null: false, default: 0
      t.integer :status,           null: false, default: 0
      t.timestamps
    end
    add_index :game_sessions, :club_id
    add_index :game_sessions, :scheduled_date
    add_index :game_sessions, [:club_id, :scheduled_date]
    add_foreign_key :game_sessions, :clubs
  end
end
```

- [ ] **Step 3: 테스트 작성 (RED)**

`test/models/game_session_test.rb` 신규 생성:

```ruby
require "test_helper"

class GameSessionTest < ActiveSupport::TestCase
  def setup
    @club    = clubs(:approved_club)
    @session = GameSession.new(
      club:           @club,
      title:          "토요 운동",
      venue_name:     "올림픽공원 코트",
      scheduled_date: Date.today + 7,
      start_time:     "10:00",
      end_time:       "12:00"
    )
  end

  test "valid with required fields" do
    assert @session.valid?
  end

  test "invalid without title" do
    @session.title = nil
    assert_not @session.valid?
  end

  test "default visibility is public_visibility" do
    assert @session.public_visibility?
  end

  test "default status is open" do
    assert @session.open?
  end

  test "full? returns true when confirmed count meets max_participants" do
    @session.max_participants = 0
    assert @session.full?
  end

  test "full? returns false when max_participants is nil" do
    @session.max_participants = nil
    assert_not @session.full?
  end
end
```

- [ ] **Step 4: 테스트 실행 (실패 확인)**

```bash
bin/rails test test/models/game_session_test.rb
```

Expected: FAIL

- [ ] **Step 5: GameSession 모델 생성**

`app/models/game_session.rb` 신규 생성:

```ruby
class GameSession < ApplicationRecord
  belongs_to :club
  has_many :participations, dependent: :destroy

  enum :visibility, { public_visibility: 0, members_only: 1 }, default: :public_visibility
  enum :status,     { open: 0, closed: 1, cancelled: 2 }, default: :open

  validates :title, :venue_name, :scheduled_date, :start_time, :end_time, presence: true
  validates :fee,              numericality: { greater_than_or_equal_to: 0 }
  validates :court_count,      numericality: { greater_than: 0 }, allow_nil: true
  validates :max_participants,  numericality: { greater_than: 0 }, allow_nil: true

  def full?
    return false if max_participants.nil?
    confirmed_count >= max_participants
  end

  def confirmed_count
    participations.confirmed.count
  end
end
```

- [ ] **Step 6: 마이그레이션 실행**

```bash
bin/rails db:migrate
```

- [ ] **Step 7: Fixture 생성**

`test/fixtures/game_sessions.yml` 신규 생성:

```yaml
open_public_session:
  club: approved_club
  title: "토요 오픈 운동"
  venue_name: "올림픽공원 코트 A"
  address: "서울시 송파구 올림픽로 424"
  scheduled_date: "2099-12-31"
  start_time: "10:00:00"
  end_time: "12:00:00"
  court_count: 2
  fee: 5000
  max_participants: 20
  visibility: 0
  status: 0

members_only_session:
  club: approved_club
  title: "회원 전용 세션"
  venue_name: "강남 실내코트"
  scheduled_date: "2099-12-31"
  start_time: "14:00:00"
  end_time: "16:00:00"
  court_count: 1
  fee: 0
  visibility: 1
  status: 0
```

- [ ] **Step 8: 테스트 실행 (GREEN)**

```bash
bin/rails test test/models/game_session_test.rb
```

Expected: PASS

- [ ] **Step 9: GameSessionPolicy 생성**

`app/policies/game_session_policy.rb` 신규 생성:

```ruby
class GameSessionPolicy < ApplicationPolicy
  def index? = true
  def show?  = true

  def create?
    return false unless user.present?
    my_membership = user.club_memberships.find_by(club: record.club)
    (my_membership&.manager? && my_membership&.approved?) || user.admin?
  end

  def update? = create?
  def edit?   = update?
  def destroy? = user.admin?

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.nil?
        scope.where(visibility: :public_visibility).open
      elsif user.admin?
        scope.all
      else
        approved_club_ids = user.club_memberships.approved.select(:club_id)
        scope.open.where(
          "visibility = ? OR club_id IN (?)",
          GameSession.visibilities[:public_visibility],
          approved_club_ids
        )
      end
    end
  end
end
```

- [ ] **Step 10: Commit**

```bash
git add db/migrate/*_create_game_sessions.rb app/models/game_session.rb app/policies/game_session_policy.rb test/models/game_session_test.rb test/fixtures/game_sessions.yml db/schema.rb
git commit -m "feat: GameSession 모델 추가 (운동 세션 등록/관리)"
```

---

## Task 5: Participation 모델 + CreateService

**Files:**
- Create: `db/migrate/TIMESTAMP_create_participations.rb`
- Create: `app/models/participation.rb`
- Create: `app/services/participations/create_service.rb`
- Create: `app/services/participations/cancel_service.rb`
- Create: `app/policies/participation_policy.rb`
- Create: `test/models/participation_test.rb`
- Create: `test/services/participations/create_service_test.rb`
- Create: `test/fixtures/participations.yml`

- [ ] **Step 1: 마이그레이션 생성**

```bash
bin/rails g migration CreateParticipations game_session_id:integer user_id:integer guest_name:string guest_sport_level:integer guest_region:string status:integer
```

- [ ] **Step 2: 마이그레이션 파일 편집**

```ruby
class CreateParticipations < ActiveRecord::Migration[8.1]
  def change
    create_table :participations do |t|
      t.integer :game_session_id, null: false
      t.integer :user_id
      t.string  :guest_name
      t.integer :guest_sport_level, default: 0
      t.string  :guest_region
      t.integer :status,            null: false, default: 0
      t.timestamps
    end
    add_index :participations, :game_session_id
    add_index :participations, :user_id
    add_index :participations, [:game_session_id, :user_id],
              unique: true, where: "user_id IS NOT NULL",
              name: "index_participations_on_session_and_member"
    add_foreign_key :participations, :game_sessions
    add_foreign_key :participations, :users
  end
end
```

- [ ] **Step 3: Participation 모델 테스트 작성 (RED)**

`test/models/participation_test.rb` 신규 생성:

```ruby
require "test_helper"

class ParticipationTest < ActiveSupport::TestCase
  def setup
    @session = game_sessions(:open_public_session)
    @user    = users(:one)
  end

  test "valid member participation" do
    p = Participation.new(game_session: @session, user: @user)
    assert p.valid?
  end

  test "valid guest participation" do
    p = Participation.new(
      game_session:      @session,
      guest_name:        "홍길동",
      guest_sport_level: 0,
      guest_region:      "서울"
    )
    assert p.valid?
  end

  test "invalid without game_session" do
    p = Participation.new(user: @user)
    assert_not p.valid?
  end

  test "member cannot join same session twice" do
    Participation.create!(game_session: @session, user: @user, status: :confirmed)
    dup = Participation.new(game_session: @session, user: @user)
    assert_not dup.valid?
  end

  test "guest participation requires guest_name" do
    p = Participation.new(game_session: @session, guest_region: "서울")
    assert_not p.valid?
    assert_includes p.errors[:base], "회원 또는 게스트 정보가 필요합니다."
  end
end
```

- [ ] **Step 4: 테스트 실행 (실패 확인)**

```bash
bin/rails test test/models/participation_test.rb
```

Expected: FAIL

- [ ] **Step 5: Participation 모델 생성**

`app/models/participation.rb` 신규 생성:

```ruby
class Participation < ApplicationRecord
  belongs_to :game_session
  belongs_to :user, optional: true

  enum :status,            { confirmed: 0, waitlisted: 1, cancelled: 2 }, default: :confirmed
  enum :guest_sport_level, { beginner: 0, intermediate: 1, advanced: 2, pro: 3 },
       default: :beginner, prefix: :guest

  validate :member_or_guest_present
  validates :user_id, uniqueness: { scope: :game_session_id, allow_nil: true,
                                    message: "이미 신청한 세션입니다." }

  scope :active, -> { where(status: [ :confirmed, :waitlisted ]) }

  private

  def member_or_guest_present
    return if user_id.present? || guest_name.present?
    errors.add(:base, "회원 또는 게스트 정보가 필요합니다.")
  end
end
```

- [ ] **Step 6: 마이그레이션 실행**

```bash
bin/rails db:migrate
```

- [ ] **Step 7: CreateService 테스트 작성 (RED)**

```bash
mkdir -p test/services/participations
```

`test/services/participations/create_service_test.rb` 신규 생성:

```ruby
require "test_helper"

class Participations::CreateServiceTest < ActiveSupport::TestCase
  def setup
    @capped   = game_sessions(:open_public_session)   # max_participants: 20
    @uncapped = game_sessions(:members_only_session)  # max_participants: nil
    @user     = users(:one)
  end

  test "creates confirmed when under capacity" do
    result = Participations::CreateService.call(game_session: @capped, user: @user)
    assert result.success?
    assert result.participation.confirmed?
  end

  test "creates confirmed when no capacity limit" do
    result = Participations::CreateService.call(game_session: @uncapped, user: @user)
    assert result.success?
    assert result.participation.confirmed?
  end

  test "creates waitlisted when at capacity" do
    @capped.update!(max_participants: 1)
    Participation.create!(game_session: @capped, user: users(:two), status: :confirmed)
    result = Participations::CreateService.call(game_session: @capped, user: @user)
    assert result.success?
    assert result.participation.waitlisted?
  end

  test "creates confirmed guest participation" do
    result = Participations::CreateService.call(
      game_session: @capped, guest_name: "게스트",
      guest_sport_level: "beginner", guest_region: "서울"
    )
    assert result.success?
    assert result.participation.confirmed?
    assert_nil result.participation.user_id
  end

  test "fails when session is closed" do
    @capped.update!(status: :closed)
    result = Participations::CreateService.call(game_session: @capped, user: @user)
    assert_not result.success?
    assert_includes result.errors, "세션이 마감되었습니다."
  end
end
```

- [ ] **Step 8: 테스트 실행 (실패 확인)**

```bash
bin/rails test test/services/participations/create_service_test.rb
```

Expected: FAIL — "uninitialized constant Participations::CreateService"

- [ ] **Step 9: CreateService 구현**

`app/services/participations/create_service.rb` 신규 생성:

```ruby
module Participations
  class CreateService
    Result = Struct.new(:success?, :participation, :errors, keyword_init: true)

    def self.call(**args) = new(**args).call

    def initialize(game_session:, user: nil, guest_name: nil, guest_sport_level: nil, guest_region: nil)
      @game_session      = game_session
      @user              = user
      @guest_name        = guest_name
      @guest_sport_level = guest_sport_level
      @guest_region      = guest_region
    end

    def call
      return failure("세션이 마감되었습니다.") unless @game_session.open?

      status = @game_session.full? ? :waitlisted : :confirmed
      participation = @game_session.participations.build(
        user:              @user,
        guest_name:        @guest_name,
        guest_sport_level: @guest_sport_level || 0,
        guest_region:      @guest_region,
        status:            status
      )

      if participation.save
        Result.new(success?: true, participation: participation, errors: [])
      else
        Result.new(success?: false, participation: participation,
                   errors: participation.errors.full_messages)
      end
    end

    private

    def failure(message)
      Result.new(success?: false, participation: nil, errors: [message])
    end
  end
end
```

- [ ] **Step 10: CancelService 구현**

`app/services/participations/cancel_service.rb` 신규 생성:

```ruby
module Participations
  class CancelService
    Result = Struct.new(:success?, :errors, keyword_init: true)

    def self.call(participation:) = new(participation: participation).call

    def initialize(participation:)
      @participation = participation
    end

    def call
      was_confirmed = @participation.confirmed?
      @participation.cancelled!
      promote_waitlist if was_confirmed
      Result.new(success?: true, errors: [])
    end

    private

    def promote_waitlist
      next_in_line = @participation.game_session
                                   .participations
                                   .waitlisted
                                   .order(:created_at)
                                   .first
      next_in_line&.confirmed!
    end
  end
end
```

- [ ] **Step 11: 테스트 실행 (GREEN)**

```bash
bin/rails test test/services/participations/create_service_test.rb
bin/rails test test/models/participation_test.rb
```

Expected: 모두 PASS

- [ ] **Step 12: Fixture 생성**

`test/fixtures/participations.yml` 신규 생성:

```yaml
confirmed_member:
  game_session: open_public_session
  user: one
  status: 0
```

- [ ] **Step 13: ParticipationPolicy 생성**

`app/policies/participation_policy.rb` 신규 생성:

```ruby
class ParticipationPolicy < ApplicationPolicy
  def create? = true

  def destroy?
    return false if record.cancelled?
    user.present? && (user == record.user || user.admin?)
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      user&.admin? ? scope.all : scope.where(user: user)
    end
  end
end
```

- [ ] **Step 14: User 모델에 participations 관계 추가**

`app/models/user.rb` 에 추가:

```ruby
has_many :participations, dependent: :destroy
```

- [ ] **Step 15: Commit**

```bash
git add db/migrate/*_create_participations.rb app/models/participation.rb app/models/user.rb app/services/participations/ app/policies/participation_policy.rb test/models/participation_test.rb test/services/ test/fixtures/participations.yml db/schema.rb
git commit -m "feat: Participation 모델 + CreateService/CancelService (참가 신청 + 대기열)"
```

---

## Task 6: ClubsController + 뷰

**Files:**
- Create: `app/controllers/clubs_controller.rb`
- Create: `app/controllers/club_memberships_controller.rb`
- Create: `app/views/clubs/_form.html.erb`, `index.html.erb`, `show.html.erb`, `new.html.erb`, `edit.html.erb`
- Modify: `config/routes.rb`

- [ ] **Step 1: Routes 추가**

`config/routes.rb` 에서 `namespace :admin` 블록 위에 추가:

```ruby
resources :clubs do
  resources :club_memberships, only: %i[index create], shallow: false
end
resources :game_sessions, only: %i[index show new create edit update destroy] do
  resources :participations, only: %i[new create], shallow: false
end
namespace :my do
  resources :participations, only: %i[index destroy]
end
```

- [ ] **Step 2: ClubsController 생성**

`app/controllers/clubs_controller.rb` 신규 생성:

```ruby
class ClubsController < ApplicationController
  before_action :set_club,      only: %i[show edit update destroy]
  before_action :require_login, only: %i[new create edit update destroy]

  def index
    @clubs = policy_scope(Club).order(:name)
  end

  def show
    authorize @club
    @game_sessions = policy_scope(GameSession).where(club: @club).order(scheduled_date: :desc)
  end

  def new
    @club = Club.new
    authorize @club
  end

  def create
    @club = Club.new(club_params.merge(owner: Current.user, status: :pending))
    authorize @club
    if @club.save
      @club.club_memberships.create!(user: Current.user, role: :manager, status: :approved)
      redirect_to @club, notice: "동호회 개설 신청이 완료되었습니다. 관리자 승인 후 활성화됩니다."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @club
  end

  def update
    authorize @club
    if @club.update(club_params)
      redirect_to @club, notice: "동호회 정보가 수정되었습니다."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @club
    @club.destroy!
    redirect_to clubs_path, notice: "동호회가 삭제되었습니다."
  end

  private

  def set_club = @club = Club.find(params[:id])
  def club_params = params.require(:club).permit(:name, :description)
  def require_login = redirect_to(new_session_path) unless Current.user
end
```

- [ ] **Step 3: ClubMembershipsController 생성**

`app/controllers/club_memberships_controller.rb` 신규 생성:

```ruby
class ClubMembershipsController < ApplicationController
  before_action :set_club

  def index
    @membership = ClubMembership.new(club: @club)
    authorize @membership
    @pending  = @club.club_memberships.pending.includes(:user)
    @approved = @club.club_memberships.approved.includes(:user)
  end

  def create
    @membership = @club.club_memberships.build(user: Current.user)
    authorize @membership
    if @membership.save
      redirect_to @club, notice: "가입 신청이 완료되었습니다."
    else
      redirect_to @club, alert: @membership.errors.full_messages.join(", ")
    end
  end

  def update
    @membership = ClubMembership.find(params[:id])
    authorize @membership
    @membership.update!(status: params[:status])
    redirect_back_or_to club_club_memberships_path(@membership.club), notice: "가입 상태가 변경되었습니다."
  end

  def destroy
    @membership = ClubMembership.find(params[:id])
    authorize @membership
    @membership.destroy!
    redirect_back_or_to clubs_path, notice: "탈퇴 처리되었습니다."
  end

  private

  def set_club = @club = Club.find(params[:club_id])
end
```

- [ ] **Step 4: 뷰 파일 생성**

`app/views/clubs/index.html.erb`:

```erb
<div class="max-w-4xl mx-auto px-4 py-8">
  <div class="flex items-center justify-between mb-6">
    <h1 class="text-2xl font-bold">동호회 목록</h1>
    <% if Current.user %>
      <%= link_to "동호회 개설 신청", new_club_path, class: "px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700" %>
    <% end %>
  </div>
  <div class="grid gap-4">
    <% @clubs.each do |club| %>
      <div class="border rounded-lg p-4 hover:shadow-md transition-shadow">
        <%= link_to club.name, club_path(club), class: "text-lg font-semibold text-green-700 hover:underline" %>
        <p class="text-gray-600 mt-1 text-sm"><%= club.description %></p>
        <p class="text-xs text-gray-400 mt-2">회원 <%= club.club_memberships.approved.count %>명</p>
      </div>
    <% end %>
    <% if @clubs.empty? %>
      <p class="text-gray-500 text-center py-12">등록된 동호회가 없습니다.</p>
    <% end %>
  </div>
</div>
```

`app/views/clubs/show.html.erb`:

```erb
<div class="max-w-4xl mx-auto px-4 py-8">
  <h1 class="text-2xl font-bold mb-2"><%= @club.name %></h1>
  <p class="text-gray-600 mb-4"><%= @club.description %></p>
  <% if Current.user && !Current.user.club_memberships.exists?(club: @club) %>
    <%= button_to "가입 신청", club_club_memberships_path(@club), method: :post,
          class: "px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 mb-6" %>
  <% end %>
  <h2 class="text-xl font-semibold mb-4">운동 세션</h2>
  <div class="grid gap-4">
    <% @game_sessions.each do |gs| %>
      <div class="border rounded-lg p-4">
        <%= link_to gs.title, game_session_path(gs), class: "font-semibold text-green-700 hover:underline" %>
        <p class="text-sm text-gray-500"><%= gs.scheduled_date.strftime("%Y-%m-%d") %> <%= gs.start_time.strftime("%H:%M") %>~<%= gs.end_time.strftime("%H:%M") %> | <%= gs.venue_name %></p>
        <p class="text-xs text-gray-400">참가 <%= gs.confirmed_count %>명<% if gs.max_participants %> / 정원 <%= gs.max_participants %>명<% end %> | <%= gs.fee > 0 ? "#{gs.fee}원" : "무료" %></p>
      </div>
    <% end %>
  </div>
</div>
```

`app/views/clubs/_form.html.erb`:

```erb
<%= form_with model: club, class: "space-y-4" do |f| %>
  <% if club.errors.any? %>
    <div class="bg-red-50 border border-red-200 rounded p-3">
      <% club.errors.full_messages.each do |msg| %>
        <p class="text-red-600 text-sm"><%= msg %></p>
      <% end %>
    </div>
  <% end %>
  <div>
    <%= f.label :name, "동호회 이름", class: "block text-sm font-medium mb-1" %>
    <%= f.text_field :name, class: "w-full border rounded-lg px-3 py-2" %>
  </div>
  <div>
    <%= f.label :description, "소개", class: "block text-sm font-medium mb-1" %>
    <%= f.text_area :description, rows: 4, class: "w-full border rounded-lg px-3 py-2" %>
  </div>
  <%= f.submit "저장", class: "px-6 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 cursor-pointer" %>
<% end %>
```

`app/views/clubs/new.html.erb`:

```erb
<div class="max-w-lg mx-auto px-4 py-8">
  <h1 class="text-2xl font-bold mb-6">동호회 개설 신청</h1>
  <%= render "form", club: @club %>
</div>
```

`app/views/clubs/edit.html.erb`:

```erb
<div class="max-w-lg mx-auto px-4 py-8">
  <h1 class="text-2xl font-bold mb-6">동호회 정보 수정</h1>
  <%= render "form", club: @club %>
</div>
```

- [ ] **Step 5: Commit**

```bash
git add app/controllers/clubs_controller.rb app/controllers/club_memberships_controller.rb app/views/clubs/ config/routes.rb
git commit -m "feat: ClubsController + ClubMembershipsController + 뷰 추가"
```

---

## Task 7: GameSessionsController + ParticipationsController + 뷰

**Files:**
- Create: `app/controllers/game_sessions_controller.rb`
- Create: `app/controllers/participations_controller.rb`
- Create: `app/controllers/my/participations_controller.rb`
- Create: views for game_sessions, participations, my/participations

- [ ] **Step 1: GameSessionsController 생성**

`app/controllers/game_sessions_controller.rb` 신규 생성:

```ruby
class GameSessionsController < ApplicationController
  before_action :set_club,         only: %i[new create]
  before_action :set_game_session, only: %i[show edit update destroy]

  def index
    @game_sessions = policy_scope(GameSession).order(scheduled_date: :desc)
  end

  def show
    authorize @game_session
  end

  def new
    @game_session = @club.game_sessions.build
    authorize @game_session
  end

  def create
    @game_session = @club.game_sessions.build(game_session_params)
    authorize @game_session
    if @game_session.save
      redirect_to @game_session, notice: "세션이 등록되었습니다."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @game_session
  end

  def update
    authorize @game_session
    if @game_session.update(game_session_params)
      redirect_to @game_session, notice: "세션이 수정되었습니다."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @game_session
    club = @game_session.club
    @game_session.destroy!
    redirect_to club_path(club), notice: "세션이 삭제되었습니다."
  end

  private

  def set_club = @club = Club.find(params[:club_id])
  def set_game_session = @game_session = GameSession.find(params[:id])

  def game_session_params
    params.require(:game_session).permit(
      :title, :venue_name, :address, :scheduled_date,
      :start_time, :end_time, :court_count, :fee, :notes,
      :max_participants, :visibility, :status
    )
  end
end
```

- [ ] **Step 2: ParticipationsController 생성**

`app/controllers/participations_controller.rb` 신규 생성:

```ruby
class ParticipationsController < ApplicationController
  before_action :set_game_session

  def new
    if @game_session.members_only? && Current.user.nil?
      redirect_to new_session_path, alert: "로그인이 필요한 세션입니다."
      return
    end
    @participation = Participation.new
    authorize @participation
  end

  def create
    @participation = Participation.new
    authorize @participation

    result = Participations::CreateService.call(
      game_session:      @game_session,
      user:              Current.user,
      guest_name:        params.dig(:participation, :guest_name),
      guest_sport_level: params.dig(:participation, :guest_sport_level),
      guest_region:      params.dig(:participation, :guest_region)
    )

    if result.success?
      msg = result.participation.waitlisted? ? "대기열에 등록되었습니다." : "참가 신청이 완료되었습니다."
      redirect_to game_session_path(@game_session), notice: msg
    else
      flash.now[:alert] = result.errors.join(", ")
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_game_session = @game_session = GameSession.find(params[:game_session_id])
end
```

- [ ] **Step 3: My::ParticipationsController 생성**

`app/controllers/my/participations_controller.rb` 신규 생성:

```ruby
module My
  class ParticipationsController < ApplicationController
    before_action :require_login

    def index
      @participations = Current.user.participations.includes(:game_session).order(created_at: :desc)
    end

    def destroy
      @participation = Current.user.participations.find(params[:id])
      authorize @participation
      Participations::CancelService.call(participation: @participation)
      redirect_to my_participations_path, notice: "참가 신청이 취소되었습니다."
    end

    private

    def require_login = redirect_to(new_session_path) unless Current.user
  end
end
```

- [ ] **Step 4: game_sessions 뷰 생성**

`app/views/game_sessions/index.html.erb`:

```erb
<div class="max-w-4xl mx-auto px-4 py-8">
  <h1 class="text-2xl font-bold mb-6">운동 세션 목록</h1>
  <div class="grid gap-4">
    <% @game_sessions.each do |gs| %>
      <div class="border rounded-lg p-4">
        <p class="text-xs text-gray-400"><%= gs.club.name %></p>
        <%= link_to gs.title, game_session_path(gs), class: "font-semibold text-green-700 hover:underline" %>
        <p class="text-sm text-gray-500"><%= gs.scheduled_date.strftime("%Y-%m-%d") %> | <%= gs.venue_name %> | 참가 <%= gs.confirmed_count %>명<% if gs.max_participants %> / <%= gs.max_participants %>명<% end %></p>
      </div>
    <% end %>
    <% if @game_sessions.empty? %>
      <p class="text-gray-500 text-center py-12">등록된 운동 세션이 없습니다.</p>
    <% end %>
  </div>
</div>
```

`app/views/game_sessions/show.html.erb`:

```erb
<div class="max-w-2xl mx-auto px-4 py-8">
  <p class="text-sm text-gray-500 mb-1"><%= link_to @game_session.club.name, club_path(@game_session.club) %></p>
  <h1 class="text-2xl font-bold mb-4"><%= @game_session.title %></h1>
  <div class="bg-gray-50 rounded-lg p-4 mb-6 space-y-2 text-sm">
    <p><strong>날짜:</strong> <%= @game_session.scheduled_date.strftime("%Y년 %m월 %d일") %></p>
    <p><strong>시간:</strong> <%= @game_session.start_time.strftime("%H:%M") %> ~ <%= @game_session.end_time.strftime("%H:%M") %></p>
    <p><strong>장소:</strong> <%= @game_session.venue_name %><% if @game_session.address.present? %> (<%= @game_session.address %>)<% end %></p>
    <p><strong>코트:</strong> <%= @game_session.court_count %>면</p>
    <p><strong>참가비:</strong> <%= @game_session.fee > 0 ? "#{@game_session.fee}원" : "무료" %></p>
    <p><strong>정원:</strong> <%= @game_session.max_participants.present? ? "#{@game_session.max_participants}명" : "제한 없음" %></p>
    <p><strong>현재 참가:</strong> <%= @game_session.confirmed_count %>명<% if @game_session.full? %> <span class="text-red-500 font-semibold">(마감)</span><% end %></p>
    <% if @game_session.notes.present? %><p><strong>메모:</strong> <%= @game_session.notes %></p><% end %>
  </div>
  <% if @game_session.open? %>
    <%= link_to "참가 신청", new_game_session_participation_path(@game_session),
          class: "inline-block px-6 py-3 bg-green-600 text-white rounded-lg hover:bg-green-700 font-semibold" %>
  <% end %>
</div>
```

`app/views/game_sessions/_form.html.erb`:

```erb
<%= form_with model: [@club, game_session].compact, class: "space-y-4" do |f| %>
  <% if game_session.errors.any? %>
    <div class="bg-red-50 border border-red-200 rounded p-3">
      <% game_session.errors.full_messages.each do |msg| %><p class="text-red-600 text-sm"><%= msg %></p><% end %>
    </div>
  <% end %>
  <div><%= f.label :title, "세션 제목", class: "block text-sm font-medium mb-1" %><%= f.text_field :title, class: "w-full border rounded-lg px-3 py-2" %></div>
  <div><%= f.label :venue_name, "장소명", class: "block text-sm font-medium mb-1" %><%= f.text_field :venue_name, class: "w-full border rounded-lg px-3 py-2" %></div>
  <div><%= f.label :address, "주소", class: "block text-sm font-medium mb-1" %><%= f.text_field :address, class: "w-full border rounded-lg px-3 py-2" %></div>
  <div class="grid grid-cols-2 gap-4">
    <div><%= f.label :scheduled_date, "날짜", class: "block text-sm font-medium mb-1" %><%= f.date_field :scheduled_date, class: "w-full border rounded-lg px-3 py-2" %></div>
    <div><%= f.label :court_count, "코트 수", class: "block text-sm font-medium mb-1" %><%= f.number_field :court_count, min: 1, class: "w-full border rounded-lg px-3 py-2" %></div>
    <div><%= f.label :start_time, "시작 시간", class: "block text-sm font-medium mb-1" %><%= f.time_field :start_time, class: "w-full border rounded-lg px-3 py-2" %></div>
    <div><%= f.label :end_time, "종료 시간", class: "block text-sm font-medium mb-1" %><%= f.time_field :end_time, class: "w-full border rounded-lg px-3 py-2" %></div>
    <div><%= f.label :fee, "참가비 (원)", class: "block text-sm font-medium mb-1" %><%= f.number_field :fee, min: 0, class: "w-full border rounded-lg px-3 py-2" %></div>
    <div><%= f.label :max_participants, "정원 (비워두면 무제한)", class: "block text-sm font-medium mb-1" %><%= f.number_field :max_participants, min: 1, class: "w-full border rounded-lg px-3 py-2" %></div>
  </div>
  <div><%= f.label :visibility, "공개 설정", class: "block text-sm font-medium mb-1" %><%= f.select :visibility, [["공개", "public_visibility"], ["회원 전용", "members_only"]], {}, class: "w-full border rounded-lg px-3 py-2" %></div>
  <div><%= f.label :notes, "메모", class: "block text-sm font-medium mb-1" %><%= f.text_area :notes, rows: 3, class: "w-full border rounded-lg px-3 py-2" %></div>
  <%= f.submit "저장", class: "px-6 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 cursor-pointer" %>
<% end %>
```

`app/views/game_sessions/new.html.erb`:

```erb
<div class="max-w-2xl mx-auto px-4 py-8">
  <h1 class="text-2xl font-bold mb-6">운동 세션 등록</h1>
  <%= render "form", game_session: @game_session %>
</div>
```

`app/views/game_sessions/edit.html.erb`:

```erb
<div class="max-w-2xl mx-auto px-4 py-8">
  <h1 class="text-2xl font-bold mb-6">운동 세션 수정</h1>
  <%= render "form", game_session: @game_session %>
</div>
```

- [ ] **Step 5: participations/new 뷰 생성**

`app/views/participations/new.html.erb`:

```erb
<div class="max-w-lg mx-auto px-4 py-8">
  <h1 class="text-xl font-bold mb-2">참가 신청</h1>
  <p class="text-gray-600 mb-6"><%= @game_session.title %> — <%= @game_session.scheduled_date.strftime("%Y-%m-%d") %></p>
  <%= form_with url: game_session_participations_path(@game_session), method: :post, class: "space-y-4" do |f| %>
    <% if Current.user %>
      <div class="bg-blue-50 rounded-lg p-4">
        <p class="text-sm text-blue-800"><strong><%= Current.user.nickname %></strong> 으로 신청합니다.</p>
      </div>
    <% else %>
      <div class="space-y-3">
        <div><label class="block text-sm font-medium mb-1">이름 <span class="text-red-500">*</span></label><%= f.text_field :guest_name, class: "w-full border rounded-lg px-3 py-2", required: true %></div>
        <div><label class="block text-sm font-medium mb-1">운동 레벨</label><%= f.select :guest_sport_level, [["입문", "beginner"], ["중급", "intermediate"], ["고급", "advanced"], ["프로", "pro"]], {}, class: "w-full border rounded-lg px-3 py-2" %></div>
        <div><label class="block text-sm font-medium mb-1">거주지역</label><%= f.text_field :guest_region, class: "w-full border rounded-lg px-3 py-2" %></div>
      </div>
    <% end %>
    <div class="flex gap-3">
      <%= f.submit "신청하기", class: "px-6 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 cursor-pointer" %>
      <%= link_to "취소", game_session_path(@game_session), class: "px-6 py-2 border rounded-lg hover:bg-gray-50" %>
    </div>
  <% end %>
</div>
```

- [ ] **Step 6: my/participations/index 뷰 생성**

`app/views/my/participations/index.html.erb`:

```erb
<div class="max-w-3xl mx-auto px-4 py-8">
  <h1 class="text-2xl font-bold mb-6">내 신청 내역</h1>
  <% if @participations.empty? %>
    <p class="text-gray-500 text-center py-12">신청한 세션이 없습니다.</p>
  <% else %>
    <div class="space-y-3">
      <% @participations.each do |p| %>
        <div class="border rounded-lg p-4 flex items-center justify-between">
          <div>
            <%= link_to p.game_session.title, game_session_path(p.game_session), class: "font-semibold text-green-700 hover:underline" %>
            <p class="text-sm text-gray-500"><%= p.game_session.scheduled_date.strftime("%Y-%m-%d") %> | <%= p.game_session.venue_name %></p>
            <span class="text-xs px-2 py-0.5 rounded-full <%= p.confirmed? ? 'bg-green-100 text-green-700' : p.waitlisted? ? 'bg-yellow-100 text-yellow-700' : 'bg-gray-100 text-gray-500' %>">
              <%= { "confirmed" => "확정", "waitlisted" => "대기", "cancelled" => "취소" }[p.status] %>
            </span>
          </div>
          <% unless p.cancelled? %>
            <%= button_to "취소", my_participation_path(p), method: :delete,
                  class: "text-sm text-red-500 hover:underline",
                  data: { turbo_confirm: "참가를 취소하시겠습니까?" } %>
          <% end %>
        </div>
      <% end %>
    </div>
  <% end %>
</div>
```

- [ ] **Step 7: Commit**

```bash
git add app/controllers/game_sessions_controller.rb app/controllers/participations_controller.rb app/controllers/my/ app/views/game_sessions/ app/views/participations/ app/views/my/ config/routes.rb
git commit -m "feat: GameSessionsController + ParticipationsController + 뷰 추가"
```

---

## Task 8: Admin 패널 — Club 승인/정지

**Files:**
- Create: `app/controllers/admin/clubs_controller.rb`
- Create: `app/policies/admin/club_policy.rb`
- Create: `app/views/admin/clubs/index.html.erb`
- Modify: `app/views/admin/dashboards/index.html.erb`
- Modify: `config/routes.rb`

- [ ] **Step 1: Admin routes 추가**

`config/routes.rb` 의 `namespace :admin` 블록에 추가:

```ruby
namespace :admin do
  root "dashboards#index"
  resources :users, only: %i[index show update]
  resources :sessions, only: %i[index]
  resources :groups
  resources :clubs, only: %i[index show update]
end
```

- [ ] **Step 2: Admin::ClubPolicy 생성**

`app/policies/admin/club_policy.rb` 신규 생성:

```ruby
module Admin
  class ClubPolicy < ApplicationPolicy
    def index?  = user&.admin?
    def show?   = user&.admin?
    def update? = user&.admin?

    class Scope < ApplicationPolicy::Scope
      def resolve = user&.admin? ? scope.all : scope.none
    end
  end
end
```

- [ ] **Step 3: Admin::ClubsController 생성**

`app/controllers/admin/clubs_controller.rb` 신규 생성:

```ruby
module Admin
  class ClubsController < ApplicationController
    def index
      authorize [:admin, Club.new]
      @pending_clubs  = Club.pending.includes(:owner).order(:created_at)
      @approved_clubs = Club.approved.includes(:owner).order(:name)
    end

    def show
      @club = Club.find(params[:id])
      authorize [:admin, @club]
      @memberships = @club.club_memberships.includes(:user)
    end

    def update
      @club = Club.find(params[:id])
      authorize [:admin, @club]
      @club.update!(status: params[:status])
      redirect_to admin_clubs_path, notice: "동호회 상태가 변경되었습니다."
    end
  end
end
```

- [ ] **Step 4: Admin clubs/index 뷰 생성**

`app/views/admin/clubs/index.html.erb` 신규 생성:

```erb
<div class="max-w-4xl mx-auto px-4 py-8">
  <h1 class="text-2xl font-bold mb-6">동호회 관리</h1>
  <h2 class="text-lg font-semibold mb-3">승인 대기 (<%= @pending_clubs.count %>)</h2>
  <div class="space-y-2 mb-8">
    <% @pending_clubs.each do |club| %>
      <div class="border rounded-lg p-4 flex items-center justify-between bg-yellow-50">
        <div>
          <p class="font-semibold"><%= club.name %></p>
          <p class="text-sm text-gray-500">개설자: <%= club.owner.nickname %> | <%= club.created_at.strftime("%Y-%m-%d") %></p>
        </div>
        <div class="flex gap-2">
          <%= button_to "승인", admin_club_path(club), method: :patch, params: { status: "approved" }, class: "px-3 py-1 bg-green-600 text-white text-sm rounded hover:bg-green-700" %>
          <%= button_to "거절", admin_club_path(club), method: :patch, params: { status: "suspended" }, class: "px-3 py-1 bg-red-500 text-white text-sm rounded hover:bg-red-600" %>
        </div>
      </div>
    <% end %>
    <% if @pending_clubs.empty? %><p class="text-gray-400 text-sm">대기 중인 동호회가 없습니다.</p><% end %>
  </div>
  <h2 class="text-lg font-semibold mb-3">승인된 동호회 (<%= @approved_clubs.count %>)</h2>
  <div class="space-y-2">
    <% @approved_clubs.each do |club| %>
      <div class="border rounded-lg p-4 flex items-center justify-between">
        <div>
          <p class="font-semibold"><%= link_to club.name, admin_club_path(club), class: "hover:underline" %></p>
          <p class="text-sm text-gray-500">개설자: <%= club.owner.nickname %></p>
        </div>
        <%= button_to "정지", admin_club_path(club), method: :patch, params: { status: "suspended" }, class: "px-3 py-1 bg-gray-400 text-white text-sm rounded hover:bg-gray-500" %>
      </div>
    <% end %>
  </div>
</div>
```

- [ ] **Step 5: Admin 대시보드에 동호회 현황 추가**

`app/views/admin/dashboards/index.html.erb` 에서 기존 통계 카드 영역에 추가:

```erb
<div class="bg-yellow-50 border border-yellow-200 rounded-lg p-4">
  <p class="text-sm font-medium text-yellow-800">동호회 승인 대기</p>
  <p class="text-2xl font-bold text-yellow-600"><%= Club.pending.count %></p>
  <%= link_to "관리하기 →", admin_clubs_path, class: "text-sm text-yellow-700 hover:underline" %>
</div>
```

- [ ] **Step 6: Commit**

```bash
git add app/controllers/admin/clubs_controller.rb app/policies/admin/club_policy.rb app/views/admin/clubs/ app/views/admin/dashboards/index.html.erb config/routes.rb
git commit -m "feat: Admin 패널 동호회 승인/정지 기능 추가"
```

---

## Task 9: 네비게이션 메뉴 재구성

- [ ] **Step 1: 현재 네비게이션 파일 위치 확인**

```bash
find app/views/layouts -type f -name "*.erb" | sort
find app/views/shared -type f -name "*.erb" | sort
```

- [ ] **Step 2: Information / Working 메뉴 제거**

네비게이션 파일에서 아래 링크들을 제거:
- `tech_infos_path`, `posts_path`, `life_infos_path`
- `work_plans_path`, `work_journals_path`, `manpower_records_path`
- `stock_infos_path`

- [ ] **Step 3: PB 메뉴 추가**

```erb
<%= link_to "동호회", clubs_path %>
<%= link_to "운동 세션", game_sessions_path %>
<% if Current.user %>
  <%= link_to "내 신청", my_participations_path %>
<% end %>
```

- [ ] **Step 4: 전체 테스트 실행**

```bash
bin/rails test
```

Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add app/views/layouts/ app/views/shared/
git commit -m "feat: 네비게이션 재구성 — 동호회/운동세션/내신청 추가"
```

---

## 최종 검증

- [ ] 서버 구동: `bin/dev`
- [ ] `/clubs` — 동호회 목록 표시 (비로그인 가능)
- [ ] 로그인 → 동호회 개설 신청 → `/admin/clubs` 에서 승인
- [ ] 승인된 동호회 → 세션 등록 (manager 권한)
- [ ] 공개 세션 → 비로그인 게스트 참가 신청 동작
- [ ] 정원 설정 세션 → 정원 초과 시 `waitlisted` 확인
- [ ] 취소 → 대기열 첫 번째 자동 `confirmed` 승격 확인
- [ ] `/my/participations` — 내 신청 내역 표시

```bash
bin/rails test
```
