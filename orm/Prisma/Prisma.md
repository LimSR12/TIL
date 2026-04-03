---
title: "Prisma란?"
summary: "**Prisma**는 Node.js / TypeScript 환경에서 사용하는 **차세대 ORM 라이브러리**이다."
status: publish
---
# Prisma란?

**Prisma**는 Node.js / TypeScript 환경에서 사용하는 **차세대 ORM 라이브러리**이다.

TypeORM처럼 클래스 + 데코레이터 방식이 아니라, **별도의 스키마 파일(`.prisma`)** 에 DB 구조를 정의하는 방식이 특징이다.

> SQL 문을 직접 작성하지 않고, 스키마 파일과 Prisma Client 메서드로 DB를 다루게 해주는 기술!

---

## TypeORM vs Prisma 비교

| 항목                 | TypeORM                                    | Prisma                       |
| -------------------- | ------------------------------------------ | ---------------------------- |
| **스키마 정의 방식** | 클래스 + 데코레이터 (`@Entity`, `@Column`) | `.prisma` 스키마 파일        |
| **타입 안전성**      | 보통                                       | 매우 강력 (자동 생성된 타입) |
| **쿼리 방식**        | Repository 패턴                            | Prisma Client                |
| **마이그레이션**     | synchronize 또는 migration                 | `prisma migrate` CLI         |
| **러닝 커브**        | 보통                                       | 낮음 (스키마가 직관적)       |

---

## Prisma를 쓰면 뭐가 좋은가?

| 항목                | 설명                                               |
| ------------------- | -------------------------------------------------- |
| **자동 타입 생성**  | 스키마 기반으로 TypeScript 타입이 자동 생성됨      |
| **직관적인 스키마** | `.prisma` 파일 하나에 DB 구조가 모두 담겨 있음     |
| **강력한 CLI**      | `prisma migrate`, `prisma studio` 등 도구가 풍부함 |
| **DB 독립성**       | PostgreSQL, MySQL, SQLite, MongoDB 등 지원         |
| **자동완성 지원**   | Prisma Client는 IDE 자동완성이 매우 잘 됨          |

---

## Prisma 기본 구조

| 구성요소           | 역할                                   | 예시                     |
| ------------------ | -------------------------------------- | ------------------------ |
| **Schema**         | DB 테이블 구조 정의 파일               | `prisma/schema.prisma`   |
| **Prisma Client**  | 쿼리를 실행하는 자동 생성 클라이언트   | `prisma.user.findMany()` |
| **Prisma Migrate** | 스키마 변경을 마이그레이션 파일로 관리 | `npx prisma migrate dev` |
| **Prisma Studio**  | DB를 GUI로 볼 수 있는 웹 UI            | `npx prisma studio`      |

---

## NestJS에서 Prisma 연결하기

### 설치

```bash
npm i prisma @prisma/client
npx prisma init
```

`npx prisma init` 을 실행하면 `prisma/schema.prisma` 파일과 `.env` 파일이 자동 생성된다.

---

### 스키마 정의 (`prisma/schema.prisma`)

```prisma
datasource db {
  provider = "mysql"              // 사용할 DB 종류
  url      = env("DATABASE_URL")  // .env에서 연결 정보 가져옴
}

generator client {
  provider = "prisma-client-js"   // Prisma Client 자동 생성
}

model User {
  id       Int    @id @default(autoincrement())
  username String
  email    String @unique
}
```

위 스키마가 실제로는 다음과 같은 SQL로 변환된다

```sql
CREATE TABLE User (
  id       INT PRIMARY KEY AUTO_INCREMENT,
  username VARCHAR(255),
  email    VARCHAR(255) UNIQUE
);
```

---

### `.env` 설정

```env
DATABASE_URL="mysql://root:비밀번호@localhost:3306/bangbang"
```

---

### Prisma Client 생성

스키마를 정의한 뒤, 아래 명령어로 Prisma Client를 생성해 한다.

```bash
npx prisma generate
```

> 스키마가 바뀔 때마다 다시 실행해야 타입이 최신 상태로 유지된다!

---

### PrismaService 만들기 (NestJS)

NestJS에서는 Prisma Client를 직접 서비스로 감싸서 DI(의존성 주입)에 사용한다.

```ts
// prisma/prisma.service.ts
import { Injectable, OnModuleInit } from "@nestjs/common";
import { PrismaClient } from "@prisma/client";

@Injectable()
export class PrismaService extends PrismaClient implements OnModuleInit {
  async onModuleInit() {
    await this.$connect(); // 모듈 초기화 시 DB 연결
  }
}
```

---

### PrismaModule 만들기

```ts
// prisma/prisma.module.ts
import { Module } from "@nestjs/common";
import { PrismaService } from "./prisma.service";

@Module({
  providers: [PrismaService],
  exports: [PrismaService], // 다른 모듈에서도 사용할 수 있도록 export
})
export class PrismaModule {}
```

---

### UserService에서 사용하기

```ts
import { Injectable } from "@nestjs/common";
import { PrismaService } from "../prisma/prisma.service";

@Injectable()
export class UserService {
  constructor(private readonly prisma: PrismaService) {}

  findAll() {
    return this.prisma.user.findMany(); // SELECT * FROM user
  }

  findOne(id: number) {
    return this.prisma.user.findUnique({ where: { id } });
  }

  create(username: string, email: string) {
    return this.prisma.user.create({
      data: { username, email }, // INSERT INTO user ...
    });
  }

  delete(id: number) {
    return this.prisma.user.delete({ where: { id } }); // DELETE FROM user WHERE id=...
  }
}
```

---

## 마이그레이션 관리

TypeORM의 `synchronize: true` 대신, Prisma는 **마이그레이션 파일**로 DB 변경을 관리한다.

```bash
# 개발 환경 - 마이그레이션 생성 및 적용
npx prisma migrate dev --name init

# 운영 환경 - 마이그레이션만 적용 (생성 X)
npx prisma migrate deploy
```

> 마이그레이션 파일이 자동으로 생성되고 버전 관리가 돼서, 팀 협업 시 DB 구조를 안전하게 맞출 수 있다!

---

## 정리

| 개념              | 설명                                                    |
| ----------------- | ------------------------------------------------------- |
| **Prisma**        | Node.js/TS용 차세대 ORM 라이브러리                      |
| **Schema**        | `.prisma` 파일에 모델(테이블) 구조 정의                 |
| **Prisma Client** | 스키마 기반으로 자동 생성되는 타입 안전 쿼리 클라이언트 |
| **PrismaService** | NestJS DI에서 사용하기 위해 감싼 서비스                 |
| **장점**          | 강력한 타입 추론, 직관적인 스키마, 풍부한 CLI 도구      |
