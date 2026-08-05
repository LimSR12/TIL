---
title: "nestjs-swagger"
summary: ""
status: DRAFT
tag: []
category: ""
---

# NestJS Swagger 데코레이터(커스텀 applyDecorators) 작성 가이드

> 목적: 컨트롤러에서 Swagger 데코레이터를 반복 작성하지 않고, 엔드포인트별 문서 규칙을 **재사용 가능한 함수(Decorator Factory)**로 표준화한다.

---

## 1) 기본 개념

### applyDecorators의 역할

- 여러 Swagger 데코레이터를 하나로 묶어 **하나의 데코레이터 함수로 반환**한다.
- 컨트롤러 메서드에서 `@GetProjectSwagger()`처럼 호출해 적용한다.

예시:

`export function GetProjectSwagger() { return applyDecorators(...); }`

---

## 2) Swagger 데코레이터별 역할과 사용 시점

### 2.1 ApiOperation

- **summary**: 엔드포인트 목록에서 보이는 한 줄 설명
- **description**: 상세 설명(필터/제약/교체 규칙 등 비즈니스 룰 포함)

사용 시점: **모든 엔드포인트**

권장 패턴:

- summary: 짧게 “동사 + 대상” (예: `프로젝트 목록 조회`)
- description: “무엇을/어떻게/제약”을 문장으로 (예: 페이징/필터/전체 교체 규칙)

---

### 2.2 ApiParam

- `/:id` 같은 **Path Parameter** 문서화

사용 시점: `GET /:id`, `PUT /:id`, `DELETE /:id` 등 **path param이 있을 때**

권장 패턴:

- `name`은 라우트 파라미터와 동일하게
- `description`에 의미를 명확히
- `example` 또는 `schema`로 예시/타입 명확히

---

### 2.3 ApiQuery

- `?page=1&size=10` 같은 **Query Parameter** 문서화

사용 시점: **쿼리 파라미터가 있는 엔드포인트** (목록 조회/검색/필터 등)

권장 패턴:

- 실제로 받는 query를 모두 `ApiQuery`로 선언
- description에만 “쿼리로 받는다”를 적지 말고, swagger에 파라미터를 표기

---

### 2.4 ApiBody

- POST/PUT/PATCH의 **Request Body** 문서화

사용 시점: `POST`, `PUT`, `PATCH` 등 **body가 있는 요청**

권장 패턴:

- `type: CreateDto`처럼 DTO 기반으로 문서화하여 스키마를 일관되게 유지

---

### 2.5 ApiConsumes (파일 업로드)

- multipart/form-data 같은 **Content-Type** 명시

사용 시점: **파일 업로드 엔드포인트**

권장 패턴:

- `ApiConsumes('multipart/form-data')`
- `ApiBody({ schema: { ... } })`로 `file` 필드를 `format: 'binary'`로 명시

---

### 2.6 ApiResponse / ApiOkResponse / ApiCreatedResponse 등

- **응답 문서화의 핵심**
- 통일성 확보를 위해 **status를 항상 명시**하는 것이 좋다고 함

사용 시점: **모든 엔드포인트**

- 성공 응답(200/201/204 등)
- 실패 응답(400/401/403/404/413 등 필요한 것)

권장 패턴:

- 성공 응답 1개 + 실패 응답(상황에 따라 여러 개)
- "우리 API가 공통 래핑 포맷"이라면 Swagger도 wrapper 스키마를 반영해야 실제 응답과 어긋나지 않음

---

## 3) 엔드포인트 유형별 “정석 템플릿”

> 아래 템플릿은 "무조건 필요한 구성요소" 기준입니다.  
> (인증/권한이 있으면 401/403 추가, 중복이면 409 추가 등)

---

### 3.1 목록 조회 (GET /resources)

필수:

- ApiOperation
- 200 성공 응답

선택(있으면 꼭):

- ApiQuery (page/size/filter 등)
- pagination meta가 있다면 schema/DTO로 문서화

구성 예시:

- summary: `리소스 목록 조회`
- description: `페이지네이션 및 필터링 조건으로 목록을 조회합니다.`
- response: `status 200`, `type: [ListItemDto]`

---

### 3.2 상세 조회 (GET /resources/:id)

필수:

- ApiOperation
- ApiParam(id)
- 200 성공 응답(type=DetailDto)
- 404 실패 응답

선택:

- 400 (파라미터 타입 오류 등을 400으로 내리는 정책이면)

구성 예시:

- response: `status 200`, `type: DetailDto`
- error: `status 404`

---

### 3.3 생성 (POST /resources)

필수:

- ApiOperation
- ApiBody(CreateDto)
- 201 성공 응답(type=DetailDto)
- 400 실패 응답

선택:

- 401/403 (인증/권한이 있다면)
- 409 (중복 생성이 있다면)

구성 예시:

- response: `status 201`, `type: DetailDto`
- error: `status 400`

---

### 3.4 수정 (PUT/PATCH /resources/:id)

필수:

- ApiOperation
- ApiParam(id)
- ApiBody(UpdateDto)
- 200 성공 응답(또는 204)
- 400, 404 실패 응답

중요:

- “전체 교체” 같은 핵심 비즈니스 룰은 **description에 반드시 명시**

구성 예시:

- response: `status 200`, `type: DetailDto`
- error: `status 400`, `status 404`

---

### 3.5 삭제 (DELETE /resources/:id)

필수:

- ApiOperation
- ApiParam(id)
- 200 성공 응답(또는 204)
- 404 실패 응답

구성 예시:

- response: `status 200` 또는 `status 204`
- error: `status 404`

---

### 3.6 파일 업로드 (POST /resources/:id/upload)

필수:

- ApiOperation
- ApiConsumes('multipart/form-data')
- ApiBody(schema 또는 DTO)
- 200/201 성공 응답
- 400 실패 응답

선택:

- 413 (용량 초과)
- 415 (미지원 미디어 타입)

권장 요청 스키마 예시(개념):

- body.schema.type: object
- properties.file: { type: string, format: binary }
- required: [file]

---

## 4) 통일성 체크리스트

- [ ] 모든 엔드포인트에 `ApiOperation`이 있는가?
- [ ] path param이 있으면 `ApiParam`을 선언했는가?
- [ ] query param이 있으면 `ApiQuery`를 선언했는가?
- [ ] body가 있으면 `ApiBody`를 선언했는가?
- [ ] 파일 업로드면 `ApiConsumes('multipart/form-data')` + body schema를 선언했는가?
- [ ] `ApiResponse`에 **status를 항상 명시**했는가?
- [ ] 에러 응답(400/404 등)을 엔드포인트 특성에 맞게 포함했는가?
- [ ] 문서 내용이 실제 동작과 1:1로 정확히 매칭되는가?
- [ ] 응답이 공통 래핑 포맷이라면 Swagger도 wrapper를 반영했는가?

---
