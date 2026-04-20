# MyTechInfo Project
# Claude Code Project Guide: Rails 8 (Solid Stack)

## Project Context
This is a modern Ruby on Rails 8 application. It follows the "One Person Framework" philosophy, prioritizing simplicity, minimal infrastructure, and server-side rendering.

## Core Tech Stack
- **Framework:** Ruby on Rails 8.0+
- **Database:** SQLite (Development/Production) with **Solid Stack**
- **Background Jobs:** Solid Queue
- **Caching:** Solid Cache
- **Pub/Sub:** Solid Cable
- **Frontend:** Hotwire (Turbo & Stimulus), Tailwind CSS
- **Asset Pipeline:** Propshaft
- **Authentication:** Rails 8 Built-in Authentication (System-generated)
- **Deployment:** Kamal 2

## Development Commands
- **Test:** `bin/rails test` (Minitest preferred)
- **System Test:** `bin/rails test:system`
- **Lint:** `bundle exec rubocop -A`
- **Database Migrate:** `bin/rails db:migrate`
- **Server:** `bin/dev` (Runs Rails, Tailwind, and Solid Queue)
- **Console:** `bin/rails console`

## Critical Rules & Patterns

### 1. Rails 8 "Solid" First
- **No Redis:** Never suggest Redis for caching or queuing. Use `Solid Cache`, `Solid Queue`, and `Solid Cable`.
- **Infrastructure:** Assume a single-node SQLite deployment unless specified otherwise.

### 2. Coding Standards
- **Convention over Configuration:** Always use standard Rails folder structures.
- **Concise Controllers:** Keep controllers "skinny" using `CurrentAttributes` and `Concerns`.
- **Fat Models:** Business logic stays in models or dedicated `Services` if it spans multiple models.
- **Naming:** Follow Ruby snake_case for methods/variables and PascalCase for classes.

### 3. Frontend (Hotwire)
- **No Heavy JS Frameworks:** Do not introduce React/Vue. Use **Turbo Streams** for real-time updates.
- **Stimulus:** Keep Stimulus controllers small and reusable. Use data-attributes for state.
- **Tailwind:** Use utility classes directly in views. Avoid custom CSS files unless necessary.

### 4. AI Interaction Guidelines
- **Generate, Don't Just Write:** Use `bin/rails generate` commands to create scaffolds, migrations, and controllers to ensure Rails conventions are met.
- **Migration Safety:** When modifying schema, always create a new migration. Never edit old migrations.
- **Minimal Gems:** Suggest adding new gems only if a standard Rails feature or a highly trusted gem (e.g., `image_processing`, `kaminari`) cannot solve the problem.

### 5. Authentication
- Use the built-in Rails 8 authentication generator logic.
- Reference `app/models/session.rb` and `app/models/user.rb` for auth-related logic.

## gstack (recommended)

This project uses [gstack](https://github.com/garrytan/gstack) for AI-assisted workflows.
Install it for the best experience:

```bash
git clone --depth 1 https://github.com/garrytan/gstack.git ~/.claude/skills/gstack
cd ~/.claude/skills/gstack && ./setup --team
```

Skills like /qa, /ship, /review, /investigate, and /browse become available after install.
Use /browse for all web browsing. Use ~/.claude/skills/gstack/... for gstack file paths.

### gstack Commands

| Command | Role | When to Use |
|---------|------|-------------|
| `/office-hours` | CEO/Advisor | Start here — clarify what you're building |
| `/plan-ceo-review` | Product Strategist | Challenge scope before coding |
| `/plan-eng-review` | Staff Engineer | Lock architecture before coding |
| `/plan-design-review` | Design Lead | Review design before building |
| `/review` | Senior Engineer | Review any branch with changes |
| `/ship` | Release Eng | Verifiable, test-first feature delivery |
| `/qa` | QA Lead | Browser-based testing on staging URL |
| `/cso` | Security Officer | OWASP Top 10 + STRIDE threat model |
| `/investigate` | Detective | Debug complex issues |
| `/autoplan` | Planner | Auto-generate implementation plan |
| `/retro` | Team Lead | Post-feature retrospective |
| `/careful` | Safety Officer | Warn before destructive commands |
| `/freeze` | Guard | Lock a directory during debugging |

## Superpowers (using-superpowers)

This project uses the [superpowers skill system](https://github.com/superpowers-ai/claude-superpowers).
Always invoke relevant skills **before** any response or action.

### Key Workflow Skills

| Skill | When to Use |
|-------|-------------|
| `brainstorming` | Before any new feature or creative work |
| `test-driven-development` | Before writing any implementation code |
| `systematic-debugging` | When encountering bugs or failures |
| `verification-before-completion` | Before claiming work is done |
| `rails-architecture` | When deciding code organization |
| `security-audit` | Before committing security-sensitive code |
| `code-review` | After implementation for quality check |
