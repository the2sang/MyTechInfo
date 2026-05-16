# 피클볼 동호회 참가 사이트 설계

**날짜:** 2026-05-16  
**프로젝트:** PBPlayground → 피클볼 동호회 참가 플랫폼 리모델링

---

## 개요

기존 PBPlayground Rails 8 앱을 피클볼 동호회 운동 참가 사이트로 리모델링한다.
기존 인증(has_secure_password)은 그대로 유지하고, Information/Working 메뉴는 비활성화한다.
회원은 동호회를 만들거나 가입하고, 동호회가 등록한 운동 세션에 참가 신청할 수 있다.
로그인 없는 게스트도 공개 세션에 기본 정보만 입력하여 참가 신청할 수 있다.

---

## 데이터 모델

### 1. User (기존 확장)

기존 User 모델에 피클볼 전용 컬럼 추가:

| 컬럼 | 타입 | 설명 |
|------|------|------|
| display_name | string | 실명 |
| sport_level | integer (enum) | beginner / intermediate / advanced / pro |
| age_group | integer (enum) | 20s / 30s / 40s / 50s / 60plus |
| gender | integer (enum) | male / female / other |
| region | string | 거주지역 |

### 2. Club (동호회)

| 컬럼 | 타입 | 설명 |
|------|------|------|
| name | string | 동호회 이름 (unique) |
| description | text | 소개 |
| owner_id | references → User | 개설자 |
| status | integer (enum) | pending / approved / suspended |

- 사이트 Admin이 approved 해야 활성화됨
- 개설자는 자동으로 manager 역할 부여

### 3. ClubMembership (동호회 가입)

| 컬럼 | 타입 | 설명 |
|------|------|------|
| club_id | references → Club | |
| user_id | references → User | |
| role | integer (enum) | member / manager |
| status | integer (enum) | pending / approved |

- 가입 신청 → pending, 동호회 manager 승인 → approved
- 복합 unique index: [club_id, user_id]

### 4. GameSession (운동 세션)

| 컬럼 | 타입 | 설명 |
|------|------|------|
| club_id | references → Club | |
| title | string | 세션 제목 |
| venue_name | string | 장소명 |
| address | string | 주소 |
| scheduled_date | date | 운동 날짜 |
| start_time | time | 시작 시간 |
| end_time | time | 종료 시간 |
| court_count | integer | 코트 수 |
| fee | integer | 참가비 (원, 0이면 무료) |
| notes | text | 기타 메모 |
| max_participants | integer | 최대 인원 (null = 무제한) |
| visibility | integer (enum) | public / members_only |
| status | integer (enum) | open / closed / cancelled |

### 5. Participation (참가신청)

| 컬럼 | 타입 | 설명 |
|------|------|------|
| game_session_id | references → GameSession | |
| user_id | references → User, nullable | 회원 (게스트는 nil) |
| guest_name | string | 게스트 이름 |
| guest_sport_level | integer (enum) | 게스트 운동레벨 |
| guest_region | string | 게스트 거주지역 |
| status | integer (enum) | confirmed / waitlisted / cancelled |

- 복합 unique index: [game_session_id, user_id] (회원에 한해)

---

## 핵심 비즈니스 로직

### 동호회 생성 플로우
1. 회원이 동호회 생성 신청 → `status: pending`
2. 사이트 Admin이 승인 → `status: approved`
3. 개설자는 자동으로 ClubMembership `role: manager` 생성

### 동호회 가입 플로우
1. 회원이 가입 신청 → ClubMembership `status: pending`
2. 동호회 manager 승인 → `status: approved`

### 참가 신청 자동 처리 (Participation::CreateService)

```
정원 있는 경우 (max_participants 설정):
  confirmed_count < max_participants → status: confirmed
  confirmed_count >= max_participants → status: waitlisted

정원 없는 경우 (max_participants = nil):
  항상 status: confirmed

confirmed 취소 시:
  해당 세션의 waitlisted 중 가장 먼저 신청한 건을 confirmed으로 자동 승격
```

### 게스트 참가 신청
- 로그인 없이 접근 가능
- `visibility: public` 세션만 신청 가능
- `guest_name`, `guest_sport_level`, `guest_region` 필수 입력
- 정원 로직은 회원과 동일하게 적용

---

## 권한 설계 (Pundit)

| 역할 | 가능한 행동 |
|------|------------|
| 게스트(비로그인) | 공개 세션 목록/상세 조회, 공개 세션 참가 신청 |
| 일반 회원 | 동호회 생성/가입, 공개 세션 신청, 내 신청 내역 조회 |
| 동호회 승인 회원 | 해당 동호회의 members_only 세션 신청 (ClubMembership status: approved 필요) |
| 동호회 manager | 세션 등록/수정/취소, 클럽 가입 승인/거절 |
| 사이트 Admin | 동호회 승인/정지, 전체 회원/세션/신청 관리 |

---

## 화면 구성

### 공개 화면 (비로그인 가능)
- `/clubs` — 승인된 동호회 목록
- `/clubs/:id` — 동호회 상세 + 공개 세션 목록
- `/game_sessions/:id` — 세션 상세 + 참가 신청 폼 (회원/게스트)

### 회원 전용
- `/clubs/new` — 동호회 생성 신청
- `/game_sessions/:id/participations` — 참가 신청 내역
- `/my/participations` — 내 신청 내역

### 동호회 관리 (manager)
- `/clubs/:id/manage` — 가입 신청 승인/거절
- `/clubs/:id/game_sessions/new` — 세션 등록

### Admin
- `/admin/clubs` — 동호회 승인/정지 관리
- 기존 Admin 패널에 통합

---

## 네비게이션 변경

기존: Information, Working 메뉴 → **비활성화**

신규 메뉴:
- 동호회 (clubs)
- 운동 세션 (game_sessions)
- 내 신청 내역 (my/participations) — 로그인 시

---

## 구현 순서

| 단계 | 내용 |
|------|------|
| 1단계 | User 프로필 확장 마이그레이션 + 프로필 편집 화면 |
| 2단계 | Club + ClubMembership (CRUD + Admin 승인 + manager 가입 승인) |
| 3단계 | GameSession (세션 등록/수정/취소, 목록/상세) |
| 4단계 | Participation (회원/게스트 신청 + 대기열 자동 처리) |
| 5단계 | 네비게이션 정리 + Admin 패널 연동 |

---

## 기술 스택 유지

- Rails 8.1 + SQLite3
- Hotwire (Turbo Streams) — 참가 신청 실시간 업데이트
- Tailwind CSS 4 — 기존 스타일 유지
- Pundit — 권한 관리
- Solid Queue — 대기열 승격 이메일 알림 (선택)
