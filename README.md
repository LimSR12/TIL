# TIL

Today I Learned

> 오늘 배운 건 오늘 기록하자!

---

## Documentation Rules

### frontmatter 명시

모든 문서는 최상단에 다음과 같은 형태로 frontmatter를 기입한다.

```yml
---
title: 문서 제목
summary: 문서 요약(소제목)
status: DRAFT/PUBLISHED
tag: [Java, Spring Boot]
category: [Backend, Study]
---
```

| 필드       | 필수 | 형식                  | 설명                                                           |
| ---------- | ---- | --------------------- | -------------------------------------------------------------- |
| `title`    | O    | 문자열                | 문서 제목. 블로그 포스트 목록에 표시                           |
| `summary`  | O    | 문자열                | 문서 요약(소제목). title 하위에 표시                           |
| `status`   | X    | `DRAFT` / `PUBLISHED` | `DRAFT`이면 블로그에 노출되지 않음. 미지정 시 `PUBLISHED` 취급 |
| `category` | X    | `[값1, 값2]`          | 게시글 분류. title 앞에 표시되며 category 별 조회 가능         |
| `tag`      | X    | `[값1, 값2]`          | 게시글 태그. 목록 하위에 작게 표시                             |
| `date`     | X    | `YYYY-MM-DD`          | 작성일. 미지정 시 git 최초 커밋 일자 사용                      |

- `category`와 `tag`는 대괄호(`[]`) 안에 쉼표로 구분하여 작성한다.
- `status`가 없거나 `PUBLISHED`이면 블로그에 노출된다. 데이터베이스에는 status와 관계없이 저장된다.
