# Project Configuration

## Tech Stack

- **Ruby** 3.3, **Rails** 8.1, **SQLite3**
- **Frontend:** Hotwire (Turbo + Stimulus), Tailwind CSS 4, ViewComponent, fontawesome icon
- **Testing:** RSpec, FactoryBot, Shoulda Matchers, Capybara
- **Auth:** `has_secure_password` (Rails 8 built-in), Pundit (authorization)
- **Background Jobs:** Solid Queue (database-backed, no Redis)
- **Caching:** Solid Cache | **WebSockets:** Solid Cable
- **Assets:** Propshaft + Import Maps (no Node.js)
- **Deployment:** Kamal 2 + Thruster

## Architecture

```
app/
  controllers/     # Thin. Delegates to services. Renders responses.
  models/          # Persistence: validations, associations, scopes, simple predicates.
  views/           # ERB markup only. No logic.
  services/        # Business logic. Orchestrates models, APIs, side effects.
  queries/         # Complex database queries. Returns relations or hashes.
  forms/           # Multi-model form objects.
  policies/        # Pundit authorization. Default deny.
  presenters/      # View formatting (SimpleDelegator).
  components/      # ViewComponents (reusable UI with tests).
  jobs/            # Background jobs (Solid Queue). Must be idempotent.
  mailers/         # Email delivery. Always HTML + text templates.
```

## Key Commands

```bash
# Server (ruby 3.3 required)
/opt/homebrew/Cellar/ruby@3.3/3.3.11/bin/ruby bin/rails runner "puts 'ok'"

# Tests
bundle exec rspec                              # Full suite
bundle exec rspec spec/path/to_spec.rb         # Specific file
bundle exec rspec spec/path/to_spec.rb:25      # Specific line

# Linting
bundle exec rubocop -a                         # Auto-fix Ruby

# Security
bin/brakeman --no-pager                        # Static analysis

# Database
bin/rails db:migrate                           # Run migrations
bin/rails db:migrate:status                    # Check status
bin/rails console                              # Interactive console
```

## Development Workflow

Follow **TDD: Red -> Green -> Refactor**:
1. **RED:** Write a failing test describing desired behavior
2. **GREEN:** Write minimal code to pass the test
3. **REFACTOR:** Improve code structure while keeping tests green

## Core Conventions

- **Skinny Everything:** Controllers orchestrate. Models persist. Services contain business logic. Views display.
- **Callbacks:** Only for data normalization (`before_validation`, `before_save`). Side effects (emails, jobs, APIs) belong in services.
- **Services:** `.call` class method, return Result objects, namespace by domain (`Entities::CreateService`).
- **No premature abstraction:** Don't extract until complexity demands it. Three similar lines > wrong abstraction.
- **Explicit > implicit:** Clear service calls over hidden callbacks. Named methods over metaprogramming.

See @docs/rails-development-principles.md for the complete development principles guide.

## Naming Conventions

| Layer | Pattern | Example |
|-------|---------|---------|
| Model | Singular PascalCase | `Entity`, `OrderItem` |
| Controller | Plural PascalCase | `EntitiesController` |
| Service | Namespaced + `Service` | `Entities::CreateService` |
| Query | Namespaced + `Query` | `Entities::SearchQuery` |
| Policy | Singular + `Policy` | `EntityPolicy` |
| Job | Descriptive + `Job` | `ProcessPaymentJob` |
| Presenter | Singular + `Presenter` | `EntityPresenter` |
| Form | Descriptive + `Form` | `EntityRegistrationForm` |

---

## Skill & Command Reference

### gstack Skills (`~/.claude/skills/gstack/`)

> 설치 완료. `/skill-name` 형태로 호출.

| 슬래시 커맨드 | 역할 | 언제 사용 |
|---|---|---|
| `/office-hours` | CEO/어드바이저 | 기능 구현 전 — 무엇을 만들지 재정의 |
| `/plan-ceo-review` | 제품 전략가 | 코딩 전 범위 검토 |
| `/plan-eng-review` | 스태프 엔지니어 | 아키텍처 확정 |
| `/plan-design-review` | 디자인 리드 | 빌드 전 디자인 검토 |
| `/review` | 시니어 엔지니어 | 브랜치 변경사항 코드 리뷰 |
| `/ship` | 릴리즈 엔지니어 | 테스트→리뷰→푸시→PR 원커맨드 |
| `/qa` | QA 리드 | 실제 브라우저로 기능 검증 + 버그 수정 |
| `/qa-only` | QA 리드 | 브라우저 테스트만 (코드 변경 없음) |
| `/investigate` | 디버거 | 복잡한 버그 근본 원인 분석 |
| `/autoplan` | 플래너 | 구현 계획 자동 생성 |
| `/retro` | 팀 리드 | 기능 완료 후 회고 |
| `/careful` | 안전 담당 | 위험 커맨드 실행 전 경고 |
| `/freeze` | 가드 | 디버깅 중 특정 디렉토리 잠금 |
| `/cso` | 보안 담당 | OWASP Top 10 + STRIDE 위협 모델 |
| `/design-html` | 디자이너 | HTML/CSS 디자인 생성 |
| `/design-consultation` | 디자인 시스템 | 디자인 시스템 구축 |
| `/browse` | 브라우저 | 헤드리스 Chromium (~100ms/command) |

### Superpowers Skills (플러그인, 자동 적용)

> `superpowers@claude-plugins-official` v5.0.7 설치됨. 상황에 맞게 자동 트리거.

| 스킬 | 트리거 시점 |
|---|---|
| `rails-architecture` | Rails 코드 구조 결정 시 |
| `code-review` | 구현 완료 후 품질 검토 |
| `security-audit` | 보안 민감 코드 커밋 전 |
| `performance-optimization` | 성능 이슈 발생 시 |
| `feature-tdd-implementation` | 새 기능 구현 코드 작성 전 |
| `extraction-timing` | 추상화/추출 시점 판단 |
| `caching-strategies` | Rails 캐싱 구현 시 |
| `authentication-flow` | 인증 흐름 구현 시 |
| `i18n-patterns` | 다국어 처리 시 |

### 내장 스킬 (Claude Code)

| 슬래시 커맨드 | 역할 |
|---|---|
| `/review` | PR 코드 리뷰 |
| `/security-review` | 보안 리뷰 |
| `/init` | 새 CLAUDE.md 초기화 |
| `/commit-commands:commit` | git commit |
| `/commit-commands:commit-push-pr` | commit → push → PR |
| `/hookify` | 반복 실수 방지 훅 생성 |
| `/feature-dev:feature-dev` | 가이드 피처 개발 |

### 워크플로우 권장 순서

```
새 기능:    /office-hours → /plan-eng-review → /feature-tdd-implementation → /review → /ship
버그 수정:  /investigate → fix → /review → /commit-commands:commit
UI 작업:    /plan-design-review → 구현 → /qa → /ship
보안 검토:  /cso → /security-audit → fix
```
