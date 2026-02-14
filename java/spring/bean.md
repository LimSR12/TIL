# Spring Bean

## Spring Bean 이란?

Spring Bean 이란 **스프링 컨테이너(IoC Container)가 생성하고 관리하는 객체**를 말한다.

원래는 `new` 키워드로 개발자가 직접 객체를 만들고 연결해야 하지만,
스프링에서는 객체 생성/초기화/의존성 주입/소멸까지 컨테이너가 대신 관리해준다.

즉, **"내가 직접 객체를 관리" → "스프링이 객체 생명주기를 관리"** 로 바뀌는 것이 핵심이다.

## 왜 Bean 을 사용할까?

- **객체 생명주기 관리 자동화**
  - 객체 생성/초기화/소멸을 컨테이너가 관리
- **의존성 주입(DI)**
  - 클래스끼리 강하게 결합하지 않고 필요한 객체를 주입받아 사용
- **유지보수성 향상**
  - 구현체 교체, 테스트 대체(mock) 등이 쉬워짐
- **재사용성 증가**
  - 공통 객체를 컨테이너 레벨에서 재사용 가능

## Bean 등록 방법

### 1) 컴포넌트 스캔 기반 등록

`@Component` 계열 애너테이션을 붙이면 스프링이 스캔해서 Bean 으로 등록한다.

- `@Component`: 일반 컴포넌트
- `@Service`: 서비스 계층
- `@Repository`: 데이터 접근 계층
- `@Controller` / `@RestController`: 웹 계층

```java
@Service
public class UserService {

}
```

### 2) 설정 클래스에서 직접 등록

`@Configuration` + `@Bean` 으로 수동 등록할 수 있다.
외부 라이브러리 객체나 생성 로직이 복잡한 객체 등록 시 자주 사용한다.

```java
@Configuration
public class AppConfig {

    @Bean
    public ObjectMapper objectMapper() {
        return new ObjectMapper();
    }
}
```

## Bean Scope

Bean 은 생성/공유 범위를 가질 수 있다.
기본값은 `singleton` 이다.

- `singleton` (기본값)
  - 컨테이너당 1개 인스턴스 생성 후 공유
- `prototype`
  - 요청할 때마다 새 인스턴스 생성
- `request`
  - HTTP 요청마다 1개 (웹 환경)
- `session`
  - HTTP 세션마다 1개 (웹 환경)

```java
@Scope("prototype")
@Component
public class TempTask {

}
```

## Bean 생명주기

스프링 Bean 은 대략 아래 순서로 동작한다.

1. Bean 인스턴스 생성
2. 의존성 주입
3. 초기화 콜백 실행 (`@PostConstruct`, `InitializingBean`, `initMethod`)
4. 애플리케이션에서 사용
5. 컨테이너 종료 시 소멸 콜백 실행 (`@PreDestroy`, `DisposableBean`, `destroyMethod`)

## 의존성 주입 방식

스프링 Bean 은 의존성 주입을 통해 연결된다.

- 생성자 주입 (권장)
  - 필수 의존성을 명확히 표현 가능
  - 불변성 유지에 유리
- 수정자(Setter) 주입
  - 선택 의존성에 사용 가능
- 필드 주입
  - 테스트/유지보수 측면에서 비권장

```java
@Service
public class OrderService {

    private final PaymentService paymentService;

    public OrderService(PaymentService paymentService) {
        this.paymentService = paymentService;
    }
}
```

## 정리

Spring Bean 은 **스프링 컨테이너가 관리하는 객체**이고,
핵심은 **IoC(제어의 역전) + DI(의존성 주입)** 이다.

Bean 을 잘 사용하면 객체 간 결합도를 낮추고,
테스트와 유지보수가 쉬운 구조를 만들 수 있다.
