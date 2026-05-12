---
title: "AOP (Aspect-Oriented Programming, 관점 지향 프로그래밍)"
summary: "여러 곳에 반복되는 공통 관심사를 한 곳에 모아서 관리하는 프로그래밍 기법"
status: publish
category: "Backend"
---

# AOP (Aspect-Oriented Programming, 관점 지향 프로그래밍)

## 1. AOP란?

**"여러 곳에 반복되는 공통 관심사를 한 곳에 모아서 관리하는 프로그래밍 기법"**

---

## 2. 왜 필요한가? - 문제 상황부터 이해하기

### 시나리오: 모든 API 실행 시간을 측정하고 싶다

```java
@Service
public class OrderService {
    public void createOrder() {
        long start = System.currentTimeMillis();  // 시작 시간 측정

        // 실제 비즈니스 로직
        System.out.println("주문 생성");

        long end = System.currentTimeMillis();    // 종료 시간 측정
        System.out.println("실행 시간: " + (end - start) + "ms");
    }
}

@Service
public class UserService {
    public void createUser() {
        long start = System.currentTimeMillis();  // 똑같은 코드 반복 😫

        // 실제 비즈니스 로직
        System.out.println("회원 가입");

        long end = System.currentTimeMillis();    // 똑같은 코드 반복 😫
        System.out.println("실행 시간: " + (end - start) + "ms");
    }
}

@Service
public class PaymentService {
    public void processPayment() {
        long start = System.currentTimeMillis();  // 또 반복 😫

        // 실제 비즈니스 로직
        System.out.println("결제 처리");

        long end = System.currentTimeMillis();    // 또 반복 😫
        System.out.println("실행 시간: " + (end - start) + "ms");
    }
}
```

서비스가 100개면 이 코드를 100번 반복해야 한다.
측정 방식이 바뀌면 100군데를 다 수정해야 한다.

이처럼 **핵심 비즈니스 로직과 관계없지만 여러 곳에 반복되는 코드**를
**횡단 관심사(Cross-cutting Concern)** 라고 부른다.

### 횡단 관심사의 대표적인 예

- 실행 시간 측정 (성능 모니터링)
- 로깅
- 트랜잭션 처리
- 보안/인증 체크
- 예외 처리

---

## 3. AOP로 해결하기

AOP를 사용하면 횡단 관심사를 **한 곳에 모아서** 관리할 수 있다.

```java
// 핵심 비즈니스 로직만 남음 ✅
@Service
public class OrderService {
    public void createOrder() {
        System.out.println("주문 생성");
    }
}

@Service
public class UserService {
    public void createUser() {
        System.out.println("회원 가입");
    }
}

// 실행 시간 측정은 여기 한 곳에서만 관리 ✅
@Aspect
@Component
public class TimeTrackingAspect {
    // "모든 서비스의 모든 메서드 실행 전후로 시간을 측정해줘"
    @Around("execution(* com.example.service.*.*(..))")
    public Object measureTime(ProceedingJoinPoint joinPoint) throws Throwable {
        long start = System.currentTimeMillis();

        Object result = joinPoint.proceed(); // 실제 메서드 실행

        long end = System.currentTimeMillis();
        System.out.println(joinPoint.getSignature() + " 실행 시간: " + (end - start) + "ms");

        return result;
    }
}
```

---

## 4. AOP 핵심 용어

### Aspect (애스펙트)

횡단 관심사를 모아놓은 클래스. `@Aspect` 어노테이션으로 선언한다.

```java
@Aspect
@Component
public class LoggingAspect { ... }  // 이 클래스 전체가 하나의 Aspect
```

### Advice (어드바이스)

**"언제, 무엇을 할지"** 정의한 실제 실행 코드.

| 종류           | 어노테이션        | 실행 시점                                  |
| -------------- | ----------------- | ------------------------------------------ |
| Before         | `@Before`         | 메서드 실행 **전**                         |
| After          | `@After`          | 메서드 실행 **후** (성공/실패 무관)        |
| AfterReturning | `@AfterReturning` | 메서드 **정상 반환 후**                    |
| AfterThrowing  | `@AfterThrowing`  | 메서드에서 **예외 발생 후**                |
| Around         | `@Around`         | 메서드 실행 **전후 전부** (가장 많이 사용) |

### Pointcut (포인트컷)

**"어디에 적용할지"** 정의한 표현식.

```java
// 표현식 문법: execution(반환타입 패키지.클래스.메서드(파라미터))

"execution(* com.example.service.*.*(..))"
//           ↑        ↑          ↑  ↑  ↑
//         반환타입   패키지     클래스 메서드 파라미터
//         (전부)              (전부) (전부) (전부)
```

### JoinPoint (조인포인트)

Advice가 적용될 수 있는 지점. 스프링 AOP에서는 **메서드 실행 시점**을 의미한다.

```java
public Object around(ProceedingJoinPoint joinPoint) throws Throwable {
    joinPoint.getSignature().getName(); // 실행 중인 메서드 이름
    joinPoint.getArgs();               // 메서드 파라미터
    joinPoint.proceed();               // 실제 메서드 실행
}
```

---

## 5. 실제 예시 코드

### 예시 1: 로깅

```java
@Aspect
@Component
@Slf4j
public class LoggingAspect {

    // com.example.controller 패키지의 모든 메서드에 적용
    @Before("execution(* com.example.controller.*.*(..))")
    public void logBefore(JoinPoint joinPoint) {
        log.info("메서드 호출: {}", joinPoint.getSignature().getName());
    }

    @AfterReturning(pointcut = "execution(* com.example.controller.*.*(..))", returning = "result")
    public void logAfter(JoinPoint joinPoint, Object result) {
        log.info("메서드 완료: {}, 반환값: {}", joinPoint.getSignature().getName(), result);
    }
}
```

### 예시 2: 실행 시간 측정

```java
@Aspect
@Component
@Slf4j
public class TimeTrackingAspect {

    @Around("execution(* com.example.service.*.*(..))")
    public Object measureTime(ProceedingJoinPoint joinPoint) throws Throwable {
        long start = System.currentTimeMillis();

        Object result = joinPoint.proceed(); // 실제 메서드 실행

        long end = System.currentTimeMillis();
        log.info("{} 실행 시간: {}ms", joinPoint.getSignature().getName(), (end - start));

        return result;
    }
}
```

### 예시 3: @Transactional (스프링이 제공하는 AOP)

사실 우리가 자주 쓰는 `@Transactional`도 AOP로 구현되어 있다.

```java
@Service
public class OrderService {

    @Transactional  // 내부적으로 AOP가 트랜잭션 시작/커밋/롤백을 자동으로 처리해줌
    public void createOrder() {
        // 비즈니스 로직만 작성하면 됨
        orderRepository.save(order);
        paymentRepository.save(payment);
        // 예외 발생 시 자동 롤백
    }
}
```

`@Transactional` 없이 직접 구현하면 이렇게 된다:

```java
public void createOrder() {
    TransactionStatus status = transactionManager.getTransaction(...);
    try {
        orderRepository.save(order);
        paymentRepository.save(payment);
        transactionManager.commit(status);  // 직접 커밋
    } catch (Exception e) {
        transactionManager.rollback(status); // 직접 롤백
        throw e;
    }
}
```

AOP 덕분에 이 반복 코드를 어노테이션 하나로 처리할 수 있는 것이다.

---

## 6. AOP 동작 원리 - 프록시 패턴

스프링 AOP는 내부적으로 **프록시(Proxy) 패턴**으로 동작한다.

```
클라이언트가 OrderService 호출
        ↓
실제로는 스프링이 만든 프록시 객체가 대신 받음
        ↓
프록시: Before Advice 실행 (로깅, 시간 측정 시작 등)
        ↓
프록시: 실제 OrderService 메서드 호출
        ↓
프록시: After Advice 실행 (시간 측정 종료, 트랜잭션 커밋 등)
        ↓
클라이언트에게 결과 반환
```

개발자는 `OrderService`만 작성하고, 스프링이 **자동으로 프록시 객체를 생성**해서 앞뒤로 Advice를 끼워 넣어주는 것이다.

---

## 7. 핵심 요약

| 용어      | 한 줄 설명                               |
| --------- | ---------------------------------------- |
| AOP       | 횡단 관심사를 한 곳에 모아 관리하는 기법 |
| Aspect    | 횡단 관심사를 담은 클래스                |
| Advice    | 언제, 무엇을 실행할지 정의한 코드        |
| Pointcut  | 어디에 적용할지 정의한 표현식            |
| JoinPoint | Advice가 실행되는 시점 (메서드 실행)     |
| 프록시    | AOP를 구현하는 내부 동작 방식            |

- AOP를 쓰면 **비즈니스 로직에서 공통 관심사를 분리**할 수 있다
- `@Transactional`, `@Cacheable` 등 스프링의 주요 기능들이 AOP로 구현되어 있다
- 직접 Aspect를 만들 일은 많지 않지만, **동작 원리를 알아야 트러블슈팅이 가능**하다
