# ORM 이란?

**ORM(Object Relational Mapping)** 은 객체(Object, 즉 JS 클래스)와 데이터베이스(Relational DB, 즉 테이블)를 자동으로 매핑시켜주는 기술이다!

<aside>

SQL 문을 직접 작성하지 않고 클래스와 메서드로 DB를 다루게 해주는 기술!

</aside>

### SQL로 직접 쓴다면

```sql
INSERT INTO user (username, email) VALUES ('lim', 'lim@example.com');
```

### ORM으로 쓴다면 (TypeORM)

```tsx
const user = new User();
user.username = "lim";
user.email = "lim@example.com";
await userRepository.save(user);
```

이렇게 **자바스크립트 객체를 그대로 DB row에 매핑**시켜주는 게 ORM이다

# TypeORM이란?

TypeScript 기반의 **Node.js ORM 라이브러리**

[TypeORM - Code with Confidence. Query with Power. | TypeORM](https://typeorm.io/)

## TypeORM을 쓰면 뭐가 좋은가?

| 항목                   | 설명                                                            |
| ---------------------- | --------------------------------------------------------------- |
| **객체 중심 개발**     | SQL 대신 클래스로 DB 구조를 정의 (`@Entity`, `@Column`)         |
| **DB 독립성**          | MySQL, PostgreSQL, SQLite 등 드라이버만 바꿔도 같은 코드로 작동 |
| **자동 쿼리 생성**     | `.save()`, `.find()` 같은 메서드로 SQL 없이 CRUD 가능           |
| **관계 설정**          | `@OneToMany`, `@ManyToOne` 등으로 JOIN 관계를 간단히 설정       |
| **마이그레이션 지원**  | DB 구조 변경을 코드로 관리 가능                                 |
| **Nest와 호환성 Good** | 모듈, DI(의존성 주입), 서비스 구조와 잘 맞음                    |

## TypeORM 기본 구조

| 구성요소                    | 역할                            | 예시                        |
| --------------------------- | ------------------------------- | --------------------------- |
| **Entity**                  | DB 테이블을 표현하는 클래스     | `User` 클래스               |
| **Repository**              | 엔티티를 다루는 객체, CRUD 담당 | `userRepository.save()`     |
| **DataSource / Connection** | DB 연결 설정                    | host, username, password 등 |

## NestJS에서 TypeORM 연결하기

## 설치

```tsx
npm i @nestjs/typeorm typeorm mysql2
```

## 설정 (`app.module.ts`)

```tsx
import { Module } from "@nestjs/common";
import { TypeOrmModule } from "@nestjs/typeorm";
import { User } from "./user/user.entity";

@Module({
  imports: [
    TypeOrmModule.forRoot({
      type: "mysql",
      host: "localhost",
      port: 3306,
      username: "root",
      password: "비밀번호",
      database: "bangbang",
      entities: [User], // 매핑할 엔티티 목록
      synchronize: true, // 개발 중에는 자동으로 테이블 생성
    }),
  ],
})
export class AppModule {}
```

<aside>

`synchronize: true`는 코드로 DB 테이블 구조를 자동으로 맞춰주는 기능인데,

운영 환경에서는 데이터가 날아갈 위험이 있어서 꺼두는 게 좋다!

</aside>

## 엔티티(Entity) 예시

```tsx
import { Entity, PrimaryGeneratedColumn, Column } from "typeorm";

@Entity() // user 테이블
export class User {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  username: string;

  @Column()
  email: string;
}
```

위 코드가 실제로는 다음과 같은 SQL로 변환된다!

```tsx
CREATE TABLE user (
  id INT PRIMARY KEY AUTO_INCREMENT,
  username VARCHAR(255),
  email VARCHAR(255)
);
```

## Repository 사용하기

TypeORM은 각 엔티티별로 **Repository 객체** 를 제공한다.

Repository는 테이블에 대한 CRUD 기능을 모두 가지고 있다!

```tsx
import { Injectable } from "@nestjs/common";
import { InjectRepository } from "@nestjs/typeorm";
import { Repository } from "typeorm";
import { User } from "./user.entity";

@Injectable()
export class UserService {
  constructor(
    @InjectRepository(User)
    private readonly userRepo: Repository<User>,
  ) {}

  findAll() {
    return this.userRepo.find(); // SELECT * FROM user
  }

  findOne(id: number) {
    return this.userRepo.findOneBy({ id });
  }

  create(username: string, email: string) {
    const user = this.userRepo.create({ username, email });
    return this.userRepo.save(user); // INSERT INTO user ...
  }

  delete(id: number) {
    return this.userRepo.delete(id); // DELETE FROM user WHERE id=...
  }
}
```

# 정리

| 개념              | 설명                                       |
| ----------------- | ------------------------------------------ |
| **TypeORM**       | Node.js/TS용 ORM 라이브러리                |
| **Entity**        | 테이블을 표현하는 클래스                   |
| **Repository**    | Entity CRUD를 담당하는 객체                |
| **TypeOrmModule** | Nest와 TypeORM을 연결해주는 모듈           |
| **장점**          | SQL 안 써도 됨, 유지보수 쉬움, 타입 안전성 |
