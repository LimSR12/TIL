# DI (Dependency Injection, 의존성 주입)

## 1. DI란?

IoC를 구현하는 구체적인 방법이다.
**"필요한 객체(의존성)를 내가 직접 만들지 않고, 외부에서 주입받는 것"**

```
IoC = 개념 (제어권을 외부에 넘긴다)
DI  = 구현 방법 (외부에서 의존성을 주입한다)
```

---

## 2. 의존성(Dependency)이란?

A 클래스가 B 클래스를 사용할 때, "A는 B에 의존한다"고 표현한다.

```java
class OrderService {
    private PaymentService paymentService; // OrderService는 PaymentService에 의존
}
```

---

## 3. 주입 방식 3가지

### 1) 생성자 주입 (Constructor Injection) ✅ 권장

```java
@Service
public class OrderService {
    private final PaymentService paymentService;

    // 스프링이 PaymentService 빈을 생성해서 여기로 넣어줌
    public OrderService(PaymentService paymentService) {
        this.paymentService = paymentService;
    }
}
```

**권장되는 이유:**

- `final` 선언 가능 → 주입 후 변경 불가, **불변성 보장**
- 객체 생성 시점에 의존성이 확정되므로 **NPE 방지**
- 생성자 파라미터만 보면 의존성을 한눈에 파악 가능
- **테스트 시 Mock 주입이 가장 쉬움**

```java
// 테스트 코드에서 Mock 주입 예시
OrderService orderService = new OrderService(new MockPaymentService());
```

> 참고: 스프링 4.3 이후부터는 생성자가 하나면 `@Autowired` 생략 가능

---

### 2) 필드 주입 (Field Injection) ⚠️ 비권장

```java
@Service
public class OrderService {
    @Autowired
    private PaymentService paymentService;
}
```

**단점:**

- `final` 선언 불가 → 불변성 보장 안 됨
- 스프링 컨테이너 없이는 주입 방법이 없어서 **순수 Java 테스트 불가**
- 의존성이 많아져도 코드가 길어지지 않아서 **의존성 과다를 인지하기 어려움**

---

### 3) Setter 주입 (Setter Injection) ⚠️ 제한적 사용

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

**단점:**

- 주입 전에 메서드를 호출하면 NPE 발생 가능
- 의존성이 선택적(Optional)일 때만 제한적으로 사용

---

## 4. 스프링에서 DI가 동작하는 흐름

```
1. 스프링 컨테이너 시작
        ↓
2. @Component, @Service, @Repository 등이 붙은 클래스를 스캔
        ↓
3. 스프링이 각 클래스의 인스턴스(Bean)를 생성
        ↓
4. 생성자 파라미터 타입을 보고 알맞은 Bean을 찾아서 주입
        ↓
5. 완성된 Bean을 컨테이너가 관리
```

```java
@Service  // 스프링아, 이 클래스를 Bean으로 등록해줘
public class KakaoPaymentService implements PaymentService {
    public void pay(int amount) {
        System.out.println("카카오페이로 " + amount + "원 결제");
    }
}

@Service
public class OrderService {
    private final PaymentService paymentService;

    // 스프링이 KakaoPaymentService Bean을 찾아서 자동으로 넣어줌
    public OrderService(PaymentService paymentService) {
        this.paymentService = paymentService;
    }
}
```

---

## 5. 구현체가 여러 개일 때 - @Qualifier

`PaymentService` 구현체가 카카오페이, 토스 둘 다 있으면 스프링이 어떤 걸 주입해야 할지 몰라서 에러가 발생한다.

```java
@Service
@Qualifier("kakao")
public class KakaoPaymentService implements PaymentService { ... }

@Service
@Qualifier("toss")
public class TossPaymentService implements PaymentService { ... }

@Service
public class OrderService {
    private final PaymentService paymentService;

    public OrderService(@Qualifier("toss") PaymentService paymentService) {
        this.paymentService = paymentService; // TossPaymentService가 주입됨
    }
}
```

---

## 6. 주입 방식 비교 요약

| 구분           | 생성자 주입 | 필드 주입   | Setter 주입    |
| -------------- | ----------- | ----------- | -------------- |
| 권장 여부      | ✅ 권장     | ⚠️ 비권장   | ⚠️ 제한적 사용 |
| `final` 사용   | 가능        | 불가        | 불가           |
| 불변성         | 보장        | 미보장      | 미보장         |
| 테스트 용이성  | 높음        | 낮음        | 보통           |
| 순환 참조 감지 | 컴파일 시점 | 런타임 시점 | 런타임 시점    |
| 코드 가독성    | 높음        | 높음        | 보통           |

---

## 7. 순환 참조 문제

A가 B를 주입받고, B가 A를 주입받으면 어떻게 될까?

```java
@Service
public class AService {
    public AService(BService bService) { ... } // A → B 의존
}

@Service
public class BService {
    public BService(AService aService) { ... } // B → A 의존
}
```

```
생성자 주입: 애플리케이션 시작 시점에 즉시 에러 발생 ✅ (빠르게 감지)
필드 주입:  실제로 호출되는 순간에 에러 발생 ❌ (늦게 감지)
```

생성자 주입을 쓰면 순환 참조를 **컴파일/시작 시점에 빠르게 발견**할 수 있어서 더 안전하다.

---

## 8. 핵심 요약

- DI는 IoC를 구현하는 방법이다
- **생성자 주입**을 기본으로 사용한다
- 스프링 컨테이너가 Bean을 생성하고 의존성을 주입해준다
- 인터페이스에 의존하면 구현체가 바뀌어도 주입받는 쪽 코드는 수정이 필요 없다
