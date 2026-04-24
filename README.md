# MyTechInfo

개인 기술정보 관리 시스템. Ruby on Rails 8 기반의 Solid Stack 애플리케이션.

---

## Tech Stack

| 구분 | 기술 |
|------|------|
| Framework | Ruby on Rails 8.1.3 |
| Language | Ruby 3.3 |
| Database | SQLite3 |
| Background Jobs | Solid Queue |
| Caching | Solid Cache |
| WebSocket | Solid Cable |
| Frontend | Hotwire (Turbo + Stimulus), Tailwind CSS 4 |
| Asset Pipeline | Propshaft + Import Maps |
| Authentication | Rails 8 Built-in (has_secure_password) |
| Deployment | Kamal 2 + Thruster |

---

## 시스템 아키텍처

```mermaid
graph TB
    subgraph Client["클라이언트"]
        Browser["웹 브라우저"]
        TelegramApp["Telegram 앱"]
    end

    subgraph Rails["Rails 8 애플리케이션"]
        direction TB
        Router["Router\n(config/routes.rb)"]

        subgraph Controllers["Controllers"]
            AppCtrl["ApplicationController\n+ Authentication Concern"]
            TechCtrl["TechInfosController\nexport / import"]
            WorkCtrl["WorkPlansController\nhwpx 생성"]
            MemoCtrl["MemosController"]
            PostCtrl["PostsController"]
            LifeCtrl["LifeInfosController"]
            StockCtrl["StockInfosController"]
            TeleWebhook["Telegram::WebhooksController"]
            AuthCtrl["Sessions / Registrations\n/ PasswordsController"]
        end

        subgraph Services["Services"]
            ExportSvc["TechInfos::ExportService"]
            ImportSvc["TechInfos::ImportService"]
            HwpxSvc["WorkPlans::HwpxGeneratorService\n(Python subprocess)"]
            TeleClient["Telegram::Client\n(Net::HTTP)"]
            TeleProcessor["Telegram::PromptProcessor"]
        end

        subgraph Models["Models (ActiveRecord)"]
            UserM["User"]
            TechM["TechInfo"]
            CommentM["Comment"]
            ReactionM["TechInfoReaction"]
            WorkM["WorkPlan"]
            MemoM["Memo"]
            PostM["Post"]
            LifeM["LifeInfo"]
            StockM["StockInfo"]
            TelePromptM["TelegramPrompt"]
            SessionM["Session"]
        end

        subgraph Jobs["Background Jobs (Solid Queue)"]
            TeleJob["TelegramPromptJob"]
        end

        subgraph Mailers["Mailers"]
            PwMailer["PasswordsMailer"]
        end

        subgraph Views["Views (ERB + Hotwire)"]
            Turbo["Turbo Streams / Frames"]
            Stimulus["Stimulus Controllers\n(8개)"]
        end
    end

    subgraph External["외부 시스템"]
        TelegramAPI["Telegram Bot API"]
        Python["Python 3\nhwpx_fill.py"]
        SMTP["SMTP 서버\n(이메일)"]
    end

    subgraph Storage["스토리지 (SQLite)"]
        MainDB["main.sqlite3\n(애플리케이션 데이터)"]
        CacheDB["cache.sqlite3\n(Solid Cache)"]
        QueueDB["queue.sqlite3\n(Solid Queue)"]
        CableDB["cable.sqlite3\n(Solid Cable)"]
    end

    Browser --> Router
    TelegramApp -->|webhook POST| TeleWebhook
    Router --> Controllers
    AppCtrl --> Models
    Controllers --> Services
    Services --> Models
    TeleWebhook --> TeleJob
    TeleJob --> TeleProcessor
    TeleProcessor --> TeleClient
    TeleClient --> TelegramAPI
    TelegramAPI -->|메시지 전송| TelegramApp
    HwpxSvc --> Python
    Controllers --> Views
    Views --> Turbo
    Views --> Stimulus
    PwMailer --> SMTP
    Models --> MainDB
    TeleJob --> QueueDB
```

---

## 도메인 구조

```mermaid
graph LR
    subgraph Domains["6개 도메인"]
        D1["기술정보 관리\nTechInfo"]
        D2["작업계획\nWorkPlan"]
        D3["메모\nMemo"]
        D4["포스트\nPost"]
        D5["생활정보\nLifeInfo"]
        D6["주식정보\nStockInfo"]
    end

    subgraph Features["주요 기능"]
        F1["마크다운 / HTML 에디터\n(lexxy)"]
        F2["댓글 + 반응 (Good/Bad)"]
        F3["JSON Import / Export"]
        F4["HWPX 문서 생성"]
        F5["Telegram Bot 연동"]
        F6["비밀번호 리셋 이메일"]
    end

    D1 --> F1
    D1 --> F2
    D1 --> F3
    D2 --> F4
    D6 --> F5
    Auth["인증\nAuthentication"] --> F6
```

---

## 데이터베이스 ERD

```mermaid
erDiagram
    users {
        integer id PK
        string email_address
        string nickname
        string password_digest
        datetime created_at
        datetime updated_at
    }

    sessions {
        integer id PK
        integer user_id FK
        string ip_address
        string user_agent
        datetime created_at
        datetime updated_at
    }

    tech_infos {
        integer id PK
        integer user_id FK
        string title
        text content
        string content_format
        integer usefulness
        boolean is_public
        string reference_url
        string related_tech
        text extra_info
        datetime created_at
        datetime updated_at
    }

    comments {
        integer id PK
        integer tech_info_id FK
        integer user_id FK
        text body
        datetime created_at
        datetime updated_at
    }

    tech_info_reactions {
        integer id PK
        integer user_id FK
        integer tech_info_id FK
        integer kind
        datetime created_at
        datetime updated_at
    }

    work_plans {
        integer id PK
        integer user_id FK
        string department_name
        string work_name
        date work_at
        date work_end_at
        date doc_date
        text work_content
        text extra_info
        datetime created_at
        datetime updated_at
    }

    memos {
        integer id PK
        integer user_id FK
        string title
        text content
        datetime created_at
        datetime updated_at
    }

    posts {
        integer id PK
        integer user_id FK
        string title
        datetime created_at
        datetime updated_at
    }

    life_infos {
        integer id PK
        integer user_id FK
        string title
        text content
        string category
        string reference_url
        datetime created_at
        datetime updated_at
    }

    stock_infos {
        integer id PK
        integer user_id FK
        string query
        datetime queried_at
        text content
        datetime created_at
        datetime updated_at
    }

    telegram_prompts {
        integer id PK
        string chat_id
        integer telegram_message_id
        string message_text
        string command
        string status
        text result
        datetime created_at
        datetime updated_at
    }

    users ||--o{ sessions : "has many"
    users ||--o{ tech_infos : "has many"
    users ||--o{ comments : "has many"
    users ||--o{ tech_info_reactions : "has many"
    users ||--o{ work_plans : "has many"
    users ||--o{ memos : "has many"
    users ||--o{ posts : "has many"
    users ||--o{ life_infos : "has many"
    users ||--o{ stock_infos : "has many"
    tech_infos ||--o{ comments : "has many"
    tech_infos ||--o{ tech_info_reactions : "has many"
```

---

## 요청 흐름

```mermaid
sequenceDiagram
    actor User as 사용자
    participant Browser as 브라우저
    participant AC as ApplicationController
    participant Auth as Authentication Concern
    participant Ctrl as Feature Controller
    participant Svc as Service
    participant Model as Model (ActiveRecord)
    participant DB as SQLite

    User->>Browser: 페이지 요청
    Browser->>AC: HTTP Request
    AC->>Auth: require_authentication
    Auth->>DB: Session 조회 (signed cookie)
    DB-->>Auth: Session + User
    Auth-->>AC: Current.user 설정
    AC->>Ctrl: 라우팅
    Ctrl->>Svc: 비즈니스 로직 위임
    Svc->>Model: 데이터 조작
    Model->>DB: SQL 쿼리
    DB-->>Model: 결과
    Model-->>Svc: 반환
    Svc-->>Ctrl: Result
    Ctrl-->>Browser: HTML (Turbo Frame/Stream)
    Browser-->>User: 화면 렌더링
```

---

## Telegram Bot 흐름

```mermaid
sequenceDiagram
    actor TUser as Telegram 사용자
    participant TAPI as Telegram Bot API
    participant Webhook as Telegram::WebhooksController
    participant TP as TelegramPrompt (Model)
    participant Queue as Solid Queue
    participant Job as TelegramPromptJob
    participant Proc as Telegram::PromptProcessor
    participant Client as Telegram::Client

    TUser->>TAPI: 메시지 전송
    TAPI->>Webhook: POST /telegram/webhook\n(Secret-Token 검증)
    Webhook->>TP: find_or_create_by\n(chat_id + message_id)
    Webhook->>Queue: TelegramPromptJob.perform_later
    Queue->>Job: 비동기 실행
    Job->>TP: mark_processing!
    Job->>Proc: 명령 파싱 및 처리\n(/help /status /review /ship)
    Proc->>Client: Telegram API 호출
    Client->>TAPI: sendMessage
    TAPI->>TUser: 응답 메시지
    Job->>TP: mark_completed!
```

---

## 인증 흐름

```mermaid
flowchart TD
    A[HTTP 요청] --> B{signed cookie\n있음?}
    B -->|Yes| C[Session 조회]
    C --> D{Session\n유효?}
    D -->|Yes| E[Current.user 설정]
    D -->|No| F[쿠키 삭제]
    F --> G[로그인 페이지 리다이렉트]
    B -->|No| G
    E --> H[컨트롤러 액션 실행]

    subgraph 비밀번호 리셋
        I[리셋 요청] --> J[토큰 생성]
        J --> K[PasswordsMailer\n이메일 발송]
        K --> L[이메일 링크 클릭]
        L --> M[토큰 검증]
        M --> N[새 비밀번호 저장]
    end
```

---

## 디렉토리 구조

```
app/
├── controllers/
│   ├── concerns/authentication.rb   # 세션 기반 인증
│   ├── telegram/webhooks_controller.rb
│   └── ...
├── models/
│   ├── current.rb                   # CurrentAttributes
│   ├── telegram_prompt.rb           # 상태 머신 (pending→processing→completed/failed)
│   └── ...
├── services/
│   ├── tech_infos/
│   │   ├── export_service.rb        # JSON export
│   │   └── import_service.rb        # JSON import
│   ├── telegram/
│   │   ├── client.rb                # Telegram Bot API
│   │   └── prompt_processor.rb      # 명령 처리
│   └── work_plans/
│       └── hwpx_generator_service.rb  # Python subprocess → HWPX
├── jobs/
│   └── telegram_prompt_job.rb       # Solid Queue
├── javascript/controllers/          # Stimulus (8개)
│   ├── content_editor_controller.js # lexxy 에디터
│   ├── nav_search_controller.js     # Cmd+K 검색
│   └── ...
└── views/                           # ERB + Turbo
```

---

## 개발 명령어

```bash
# 서버 실행
bin/dev

# 테스트
bundle exec rspec

# 린트
bundle exec rubocop -a

# 마이그레이션
bin/rails db:migrate

# 보안 검사
bin/brakeman --no-pager

# 콘솔
bin/rails console
```

---

## 배포

[Kamal 2](https://kamal-deploy.org/) + [Thruster](https://github.com/basecamp/thruster) 사용.

```bash
kamal deploy
```
