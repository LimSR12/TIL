# Blog Backend Spec (for TIL repo)

이 문서는 TIL 레포에서 작업할 때 블로그 백엔드 API 및 DB 스펙을 참조하기 위한 문서입니다.
블로그 레포: `LimSR12/LimSR12-log`

---

## 1. 블로그 서버 정보

- Framework: Spring Boot 3.5.x (Java 17)
- Database: Supabase PostgreSQL
- 배포 URL: `https://api.limsr12.com`
- 모든 API 응답은 `ApiResponse<T>`로 래핑됨

### ApiResponse 형식

```json
{
  "success": true,
  "code": "OK",
  "message": "성공적으로 응답되었습니다",
  "data": { ... },
  "timestamp": "2026-04-03T00:00:00Z"
}
```

---

## 2. ERD

### posts

| 컬럼         | 타입                        | 제약             | 설명                                     |
| ------------ | --------------------------- | ---------------- | ---------------------------------------- |
| id           | BIGINT (PK)                 | AUTO_INCREMENT   |                                          |
| category_id  | BIGINT (FK → categories.id) | NULLABLE         |                                          |
| title        | VARCHAR(255)                | NOT NULL         |                                          |
| slug         | VARCHAR(300)                | NOT NULL, UNIQUE | URL 경로용                               |
| content      | TEXT                        | NOT NULL         | 마크다운 본문                            |
| summary      | VARCHAR(500)                | NULLABLE         | 목록에 표시될 요약                       |
| thumbnail    | VARCHAR(500)                | NULLABLE         | 현재 미사용 (NULL)                       |
| source_path  | VARCHAR(500)                | NULLABLE, UNIQUE | TIL 파일 경로 (예: `Java/Spring/AOP.md`) |
| status       | VARCHAR(20)                 | NOT NULL         | `DRAFT`, `PUBLISHED`                     |
| published_at | TIMESTAMP                   | NULLABLE         | PUBLISHED 전환 시 자동 설정              |
| created_at   | TIMESTAMP                   | NOT NULL         |                                          |
| updated_at   | TIMESTAMP                   | NOT NULL         |                                          |
| deleted_at   | TIMESTAMP                   | NULLABLE         | Soft delete                              |

### categories

| 컬럼       | 타입         | 제약             |
| ---------- | ------------ | ---------------- |
| id         | BIGINT (PK)  | AUTO_INCREMENT   |
| name       | VARCHAR(100) | NOT NULL, UNIQUE |
| created_at | TIMESTAMP    | NOT NULL         |
| updated_at | TIMESTAMP    | NOT NULL         |

현재 등록된 카테고리: `Backend`, `DevOps`, `CS`, `Frontend`

### tags

| 컬럼       | 타입         | 제약             |
| ---------- | ------------ | ---------------- |
| id         | BIGINT (PK)  | AUTO_INCREMENT   |
| name       | VARCHAR(100) | NOT NULL, UNIQUE |
| created_at | TIMESTAMP    | NOT NULL         |
| updated_at | TIMESTAMP    | NOT NULL         |

### post_tags (다대다 조인 테이블)

| 컬럼    | 타입                   | 제약 |
| ------- | ---------------------- | ---- |
| post_id | BIGINT (FK → posts.id) |      |
| tag_id  | BIGINT (FK → tags.id)  |      |

### portfolios

| 컬럼        | 타입         | 제약                                    |
| ----------- | ------------ | --------------------------------------- |
| id          | BIGINT (PK)  | AUTO_INCREMENT                          |
| title       | VARCHAR(255) | NOT NULL                                |
| description | TEXT         | NULLABLE                                |
| thumbnail   | VARCHAR(500) | NULLABLE                                |
| github_url  | VARCHAR(500) | NULLABLE                                |
| demo_url    | VARCHAR(500) | NULLABLE                                |
| tech_stack  | TEXT         | JSON 문자열 (예: `["NestJS","Docker"]`) |
| started_at  | DATE         | NULLABLE                                |
| ended_at    | DATE         | NULLABLE                                |
| sort_order  | INT          |                                         |
| created_at  | TIMESTAMP    | NOT NULL                                |
| updated_at  | TIMESTAMP    | NOT NULL                                |
| deleted_at  | TIMESTAMP    | NULLABLE                                |

### archives

| 컬럼       | 타입         | 제약                                 |
| ---------- | ------------ | ------------------------------------ |
| id         | BIGINT (PK)  | AUTO_INCREMENT                       |
| title      | VARCHAR(255) | NOT NULL                             |
| content    | TEXT         | NULLABLE                             |
| source_url | VARCHAR(500) | NULLABLE                             |
| type       | VARCHAR(20)  | NOT NULL (`NOTE`, `LINK`, `SNIPPET`) |
| created_at | TIMESTAMP    | NOT NULL                             |
| updated_at | TIMESTAMP    | NOT NULL                             |
| deleted_at | TIMESTAMP    | NULLABLE                             |

---

## 3. TIL Sync API

TIL 레포에서 main에 push하면 GitHub Actions가 이 엔드포인트를 호출한다.

### `POST /api/v1/til/sync`

#### Headers

| 이름          | 필수 | 설명                               |
| ------------- | ---- | ---------------------------------- |
| X-Sync-Secret | O    | 서버에 등록된 시크릿과 일치해야 함 |

#### Request Body

```json
{
  "files": [
    {
      "path": "Java/Spring/AOP.md",
      "content": "---\ntitle: 제목\nsummary: 소제목\nstatus: PUBLISHED\n---\n# AOP 개념 정리\n\n본문...",
      "createdAt": "2026-03-15T10:30:00",
      "updatedAt": "2026-04-01T14:20:00"
    }
  ]
}
```

- `path`: TIL 레포 루트 기준 상대 경로
- `content`: frontmatter를 포함한 마크다운 원문
- `createdAt`: 파일의 최초 git 커밋 시각 (ISO 8601, UTC)
- `updatedAt`: 파일의 마지막 git 커밋 시각 (ISO 8601, UTC)

#### Response

```json
{
  "success": true,
  "code": "OK",
  "data": {
    "synced": 2,
    "skipped": 1,
    "failed": 0
  }
}
```

### 서버 처리 로직

1. **루트 파일 필터링**: `/`가 없거나 `.md`가 아닌 파일은 skip (예: `README.md` → skip)
2. **title**: 요청 JSON의 `title` 필드 사용. `null`이면 파일명에서 `.md` 제거하여 fallback (예: `AOP.md` → `AOP`)
3. **slug**: 경로 전체를 `-`로 연결, 소문자 (예: `Java/Spring/AOP.md` → `java-spring-aop`)
4. **tags**: 디렉토리 세그먼트를 태그 이름으로 사용 (예: `Java/Spring/AOP.md` → `Java`, `Spring`). `images`, `assets` 디렉토리는 제외. 없는 태그는 자동 생성
5. **이미지 URL 변환**: 마크다운 내 상대 경로 이미지를 `https://raw.githubusercontent.com/LimSR12/TIL/main/` 기준 절대 URL로 변환. `http://`, `https://`로 시작하는 절대 URL은 그대로 유지
6. **upsert**: `source_path` 기준으로 기존 글이 있으면 update, 없으면 insert
7. **slug 충돌 방지**: insert 시 slug가 이미 존재하면 뒤에 타임스탬프 추가
8. **status**: TIL sync로 생성된 글은 `PUBLISHED` 상태, `category`는 `null`
9. **summary**: 요청 JSON의 `summary` 필드를 `posts.summary`에 저장. `null`이면 `null` 유지
10. **타임스탬프**: `createdAt`은 `posts.created_at`과 `published_at`에 저장, `updatedAt`은 `posts.updated_at`에 저장. 기존 글 update 시에는 `updatedAt`만 갱신

### GitHub Actions Secrets (TIL 레포에 등록)

| Secret 이름       | 설명                                 |
| ----------------- | ------------------------------------ |
| `BLOG_API_URL`    | 블로그 API 서버 주소 (뒤에 `/` 없이) |
| `TIL_SYNC_SECRET` | `X-Sync-Secret` 헤더에 보낼 값       |

---

## 4. TIL 디렉토리 구조 → 블로그 매핑 규칙

```
TIL/
├── README.md                    → skip (루트 파일)
├── Java/
│   └── Spring/
│       └── AOP.md               → post: title=frontmatter title (fallback: "AOP"),
│                                   slug="java-spring-aop", tags=["Java","Spring"],
│                                   source_path="Java/Spring/AOP.md"
├── DevOps/
│   └── Docker기초.md            → post: title=frontmatter title (fallback: "Docker기초"),
│                                   slug="devops-docker기초", tags=["DevOps"],
│                                   source_path="DevOps/Docker기초.md"
└── images/                      → 태그에서 제외되는 디렉토리
```

### 주의사항

- 글 제목은 frontmatter `title`을 우선 사용하며, 없으면 파일명을 fallback으로 사용
- 디렉토리명이 곧 태그이므로 일관된 네이밍 유지 (예: `Java` vs `java` 혼용 시 별도 태그 생성됨)
- 같은 `source_path`로 재push하면 기존 글이 업데이트됨 (파일 이동 시 새 글로 생성됨)
- summary는 frontmatter에서 전달. category는 TIL sync에서 설정하지 않음 (null). 필요하면 블로그 관리 API로 별도 수정
