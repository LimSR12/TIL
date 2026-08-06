# Frontmatter 수동 확인 체크리스트

아래 파일들은 title, summary, tag, category 를 직접 작성해야 합니다.

---

## 1. frontmatter 신규 추가 (title=파일명, summary 비어있음)

- [ ] `prettier/설정-방법.md`
- [ ] `nodejs/path/path-모듈-메서드.md`
- [ ] `nodejs/fs/rm과-unlink의-차이.md`
- [ ] `log/nest-로그.md`
- [ ] `typescript/interface-사용.md`
- [ ] `typescript/해체할당-및-객체매핑.md`
- [ ] `swagger/nestjs-swagger.md`
- [ ] `swagger/swagger.md`
- [ ] `Claude/지침 문서.md`
- [ ] `docker/dockerfile/dockerfile이란.md`
- [ ] `docker/container/docker container란.md`
- [ ] `java/0.java-intro.md`
- [ ] `java/1.java-get-started.md`
- [ ] `java/2.java-syntax.md`

## 2. title 누락 (빈 문자열로 추가됨)

- [ ] `architecture/Clean Architecture/CleanArchitecture.md`
- [ ] `architecture/TDD/TDD.md`
- [ ] `architecture/TDD, BDD, DDD.md`

## 3. title/summary 자동생성 의심 (파일명=title 또는 summary가 placeholder)

- [ ] `Spring-Boot/Spring-study/개요.md` — title: "개요", summary: "개요 관련 학습 메모"
- [ ] `Spring-Boot/빌더패턴.md` — title: "빌더패턴", summary: "빌더패턴 관련 학습 메모"
- [ ] `orm/Hibernate/Hibernate.md` — title: "Hibernate", summary: "Hibernate 관련 학습 메모"
- [ ] `orm/Hibernate/JPA.md` — title: "JPA", summary: "JPA 관련 학습 메모"
- [ ] `was/java/개요.md` — title: "", summary: "" (둘 다 비어있음)

## 4. summary에 마크다운 원문이 그대로 들어간 경우

- [ ] `orm/Prisma/Prisma.md` — summary: "**Prisma**는 Node.js / TypeScript 환경에서 사용하는 **차세대 ORM 라이브러리**이다."
- [ ] `Algorithm/BufferedReader 와 StringTokenizer.md` — summary: "Java 코딩테스트에서는 입력을 거의 항상 **BufferedReader**로 받는다."

## 5. summary 비어있음

- [ ] `Algorithm/Do it 알고리즘 코딩테스트 C++/꿀팁.md`
- [ ] `Algorithm/STL containers.md`
- [ ] `Algorithm/삼성 코테 대비.md`
- [ ] `Spring-Boot/jdk.md`

## 6. YAML 문법 오류 (닫는 따옴표 누락)

- [ ] `Algorithm/Do it 알고리즘 코딩테스트 C++/4장.md` — title 닫는 따옴표 누락
- [ ] `Spring-Boot/IoC.md` — summary 닫는 따옴표 누락
