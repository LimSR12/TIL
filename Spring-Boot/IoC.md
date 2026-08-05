---
title: "IoC / DI 개념 정리"
summary: "간단한 예시로 학습해보는 IoC 와 DI
status: publish
tag:
category: "Backend"
---

# IoC / DI 개념 정리

## 1. IoC (Inversion of Control, 제어의 역전)

### 개념

일반적으로 객체는 자신이 사용할 의존 객체를 **직접 생성**한다.
IoC는 이 **제어권을 개발자가 아닌 외부(스프링 컨테이너)에게 넘기는** 것을 의미한다.

> "내가 필요한 객체를 내가 만들지 않고, 누군가가 만들어서 줄 때까지 기다린다."

---

## 2. 강한 결합 vs 느슨한 결합

### 기존 방식 (강한 결합)

```java
class OrderService {
    private KakaoPaymentService paymentService = new KakaoPaymentService();
}
```

- `OrderService`가 `KakaoPaymentService`를 **직접 생성**
- 결제 수단이 바뀌면 `OrderService` 코드를 **직접 수정**해야 함
- Mock 주입이 불가능해서 **테스트도 어려움**
- 유연성 ↓, 결합도 ↑

### 변경이 필요한 상황 예시

처음엔 카카오페이로 결제하다가 토스 결제를 추가해야 한다면?

```java
class OrderService {
    // ❌ 코드를 직접 열어서 수정해야 함
    // private KakaoPaymentService paymentService = new KakaoPaymentService();
    private TossPaymentService paymentService = new TossPaymentService();
}
```

결제 수단이 바뀔 때마다 `OrderService`를 수정해야 하고,
`OrderService`가 100곳에서 쓰인다면 100군데를 다 고쳐야 한다.

---

## 3. IoC 적용 (느슨한 결합)

### 인터페이스로 추상화

```java
interface PaymentService {
    void pay(int amount);
}

class KakaoPaymentService implements PaymentService {
    public void pay(int amount) {
        System.out.println("카카오페이로 " + amount + "원 결제");
    }
}

class TossPaymentService implements PaymentService {
    public void pay(int amount) {
        System.out.println("토스로 " + amount + "원 결제");
    }
}
```

### 생성자 주입 (DI 적용)

```java
class OrderService {
    private PaymentService paymentService;

    // 어떤 구현체가 들어올지 OrderService는 몰라도 됨
    public OrderService(PaymentService paymentService) {
        this.paymentService = paymentService;
    }
}
```

- 객체 생성은 **스프링 컨테이너**가 담당
- `OrderService`는 `PaymentService` 인터페이스만 알면 됨
- 결제 수단이 바뀌어도 `OrderService` 코드는 **수정 불필요**

```java
// 카카오페이 → 토스로 변경할 때, OrderService 코드 수정 없음
new OrderService(new KakaoPaymentService()); // 카카오페이
new OrderService(new TossPaymentService());  // 토스
```

---

## 4. DI (Dependency Injection, 의존성 주입)

IoC를 구현하는 구체적인 방법이 DI다.
즉, **필요한 객체(의존성)를 외부에서 주입받는 것**을 말한다.

### 주입 방식 3가지

#### 1) 생성자 주입 (권장 ✅)

```java
@Service
public class OrderService {
    private final PaymentService paymentService;

    public OrderService(PaymentService paymentService) {
        this.paymentService = paymentService;
    }
}
```

#### 2) 필드 주입

```java
@Service
public class OrderService {
    @Autowired
    private PaymentService paymentService;
}
```

#### 3) Setter 주입

```java
@Service
public class OrderService {
    private PaymentService paymentService;

    @Autowired
    public void setPaymentService(PaymentService paymentService) {
        this.paymentService = paymentService;
    }
}
```

> 생성자 주입이 권장되는 이유: `final` 선언으로 불변성 보장, 테스트 시 Mock 주입 용이

---

## 5. @PostConstruct

`jakarta.annotation` 패키지에 속한 어노테이션.
스프링이 Bean을 생성하고 **의존성 주입(DI)을 완료한 직후**, 딱 한 번 실행할 초기화 메서드를 지정할 때 사용한다.

```java
@Component
public class MyService {

    @Autowired
    private MyRepository myRepository;

    @PostConstruct
    public void init() {
        // 의존성 주입 완료 후 자동 실행
        myRepository.findAll();
    }
}
```

### 생성자 대신 @PostConstruct를 쓰는 이유

```java
public MyService() {
    // ❌ 이 시점엔 myRepository가 아직 null
    //    의존성 주입 전이기 때문
}

@PostConstruct
public void init() {
    // ✅ 이 시점엔 myRepository가 정상 주입된 상태
}
```

---

## 6. 비교 요약

| 구분             | 강한 결합                | IoC / DI             |
| ---------------- | ------------------------ | -------------------- |
| 객체 생성 주체   | 개발자 (직접 `new`)      | 스프링 컨테이너      |
| 결제수단 변경 시 | `OrderService` 수정 필요 | 컨테이너 설정만 변경 |
| 테스트           | 실제 구현체 사용         | Mock 주입 가능       |
| 결합도           | 높음                     | 낮음                 |
| 유연성           | 낮음                     | 높음                 |

---

## 7. 관련 원칙

- **OCP (개방-폐쇄 원칙)**: 변경에는 닫혀있고, 확장에는 열려있어야 한다.
  - IoC/DI를 적용하면 `OrderService`를 수정하지 않고도 결제 수단을 확장할 수 있다.
- **DIP (의존 역전 원칙)**: 구체 클래스가 아닌 인터페이스(추상화)에 의존해야 한다.
  - `KakaoPaymentService`가 아닌 `PaymentService` 인터페이스에 의존하는 것이 이에 해당한다.
