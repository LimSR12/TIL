---
title: "DDD 알아보기"
summary: "도메인 주도 설계라는 개념이 어려워서 학습해본 내용 정리"
status: DRAFT
tag: [Design Pattern, DDD]
category: Study
---

# 1️⃣ Domain 이란?

사전적 의미는 `영역`, `집합`
소프트웨어에서 의미는 `사용자가 사용하는 것`, `소프트웨어로 해결하고자 하는 문제 영역`, `비즈니스 영역`

가령 쇼핑몰 서비스에서는 주문, 결제, 배송 도메인이 있을 수 있고, 커뮤니티 서비스라면 게시글, 댓글, 신고 도메인이 있을 수 있겠다.

# 2️⃣ DDD란?

> Domain-Driven Design
>
> 2003년 `Domain-Driven Design` - Eric Evans

DDD는 소프트웨어 설계에서 도메인 지식을 중심에 두고 설계하는 방법론이다.

각각의 기능적인 문제의 영역들을 정의하는 도메인과 그 도메인을 사용하는 비즈니스 로직을 중심으로 설계하는 방식!

## 특징

1. 데이터가 아닌 도메인 모델과 로직에 집중한다.
2. Ubiquitous Language, 보편적 언어를 사용한다. (개발단 뿐만아니라 기획, 개발, 사업까지 업무용어 통일)
3. Software Entity 와 Domain 간 개념이 일치한다.

# 3️⃣ DDD의 등장 맥락

초기의 소프트웨어 설계는 대부분 데이터 중심 설계였다.

`DB 테이블 -> 서비스 -> 기능`과 같은 흐름으로 시스템이 만들어졌다.

이러한 방식은 단순한 시스템에서는 문제 없이 동작하지만, 비즈니스 규칙이 복잡해질수록 다음과 같은 문제가 발생했다고 한다.

- 비즈니스 로직이 Service, Util 등에 흩어진다
- Entity는 단순 데이터 덩어리가 된다
- 코드가 아닌 문서에만 비즈니스 규칙이 존재한다
- 개발자와 도메인 전문가 간의 의사소통이 불편하다
- 기능 추가 시 영향 범위를 예측하기 어렵다

즉, 소프트웨어 구조가 실제 비즈니스 구조를 반영하지 못하는 문제가 발생했다.
따라서 이를 해결하기 위해 도메인 자체를 중심으로 설계하자는 접근인 DDD 가 등장하게 되었다.

# 4️⃣ DDD는 언제 사용하는거지?

DDD는 모든 프로젝트에 적용하는 만능 해법은 아니다.

테스트 중심의 TDD, 행위 중심의 BDD와 같은 다양한 디자인 방식이 있다.

### 🔹 사용하기 좋은 경우

- 비즈니스 로직이 복잡한 경우
- 행위가 중요한 경우
- 여러 조직/팀이 협업하는 대규모 서비스
- 장기적으로 유지보수해야 하는 서비스
- 문제 영역 자체가 중요한 경우

다음과 같은 시스템에 대해서는 DDD를 사용하기 좋다고 한다!

- 금융 시스템
- 물류 / 주문 / 결제 시스템
- SaaS 플랫폼
- 커뮤니티 / 권한 / 정책 시스템

### 🔹 굳이 필요하지 않는 경우

- 로직이 복잡하지 않은 단순 CRUD
- 관리자용 내부 툴
- 검증 PoC / MVP 단계

# 5️⃣ DDD의 핵심 요소

## 🔹 Bounded Context

같은 개념이라도 문맥에 따라 그 의미가 달라질 수 있다.
예를 들어

- Project 도메인
- Auth 도메인
- Notification 도메인

각각에서 User 의 의미는 다를 수 있다.

| Context      | User 의미          |
| ------------ | ------------------ |
| Auth         | 인증 주체          |
| Project      | 프로젝트 소속 멤버 |
| Notification | 알림 수신자        |

따라서 이를 명확히 분리하는 경계가 Bounded Context 라고 한다

> 하나의 도메인 모델이 유효한 의미를 가지는 범위

## 🔹 Context Map

Bounded Context는 독립적이지만 서로 협력해야 한다.

예를 들어

- Project → Notification 발생
- Auth → Project 참여 권한 제공

이러한 관계를 정의하는 것이 Context Map 이다!

> 도메인 간 관계와 상호작용을 정의한 지도

## 🔹 Aggregate

도메인 객체는 개별적으로 존재하지 않고, 하나의 일관성을 유지해야 하는 단위로 묶인다.

> 함께 생성되고, 함께 변경되며,
> 비즈니스 규칙을 함께 지켜야 하는 객체들의 묶음

### 예시

#### BoostUs의 Project 도메인에서의 Aggregate

Project 도메인에는 다음과 같은 구성 요소가 존재한다.

- Project
- ProjectParticipant
- ProjectTechStack

이때 이 세 객체는 단순히 연관 관계에 있는 것이 아니라 하나의 비즈니스 의미를 가지는 단위다.

> 하나의 프로젝트는
> 반드시 참여자 목록을 가지며,
> 기술스택 정보를 포함하고,
> 이 정보들은 프로젝트의 생성/수정과 함께 일관되게 관리되어야 한다.

따라서 이들은 독립적으로 변경될 수 있는 대상이 아니라 프로젝트라는 하나의 개념 아래 함께 변경되어야 하는 요소들이다.

#### Project Aggregate

Boostus 에서는 이를 다음과 같이 하나의 Aggregate 로 정의할 수 있겠다.

> Project Aggregate = Project(루트) + ProjectParticipant(참여자) + ProjectTechStack(기술스택)

#### 왜 Aggregate로 묶을 수 있는가?

프로젝트와 참여자, 기술 스택은 다음과 같은 규칙을 공유한다.

- 프로젝트 생성 시 참여자와 기술스택이 함께 정의되어야 한다.
- 프로젝트 수정 시 참여자와 기술스택 정보도 함께 변경되어야 한다.
- 참여자 또는 기술스택은 프로젝트 없이 존재할 수 없다.
- 기술 스택은 사전에 정의된 값만 사용할 수 있다.
- 참여자 목록에는 등록자가 반드시 포함된다.

즉, 이 객체들은 개별적으로 변경되면 비즈니스 규칙이 깨질 수 있기에 하나의 트랜잭션 단위로 묶어 항상 일관성을 유지하도록 관리된다!

#### 접근 방식

ProjectParticipant를 단독으로 수정하거나
ProjectTechStack을 별도로 추가/삭제하지 않는다.

> ProjectRepository를 통해
> Project Aggregate 단위로 생성/조회/수정한다!

# 6️⃣ DDD의 목적

# 7️⃣ 참고 자료

- [[Backend] ㄷㄷㄷ: Domain Driven Design과 적용 사례공유 / if(kakao)dev2022](https://www.youtube.com/watch?v=s0twDQ6lIGU)

<img width="60%" alt="Image" src="https://github.com/user-attachments/assets/f3019dae-49f5-4ccd-b6da-62eadd398eda" />
<img width="60%" alt="Image" src="https://github.com/user-attachments/assets/bc09068f-b2bc-401b-9164-e608808ac699" />
<img width="60%" alt="Image" src="https://github.com/user-attachments/assets/a857ba3b-6159-46a6-a18e-7299c9d1cc09" />
<img width="60%" alt="Image" src="https://github.com/user-attachments/assets/33062e27-4b9b-4258-b330-e6dcba148d51" />
