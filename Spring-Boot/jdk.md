---
title: "Java 버전 변천사 및 Spring Boot 버전 선택 가이드"
summary: ""
status: publish
tag: []
category: ""
---

# Java 버전 변천사 및 Spring Boot 버전 선택 가이드

## Java 버전 개요

Java는 1995년 출시 이후 꾸준히 발전해왔다. 2017년 Java 9부터 **6개월 주기 릴리즈** 정책으로 전환되었으며, 그 중 일부 버전이 **LTS(Long-Term Support)** 로 지정되어 장기 지원을 받는다.

> LTS 버전은 최소 8년 이상 보안 패치와 버그 수정을 제공받기 때문에, 프로덕션 환경에서는 LTS 버전을 선택하는 것이 원칙이라고 한다.

---

## 주요 버전 변천사

### Java 8 (2014) — 현대 Java의 시작

그 이전까지는 함수를 전달하려면 **익명 클래스**를 사용해야 했다. 코드가 장황하고 가독성이 낮다는 문제가 있었다.

```java
// Java 8 이전 — 익명 클래스
list.sort(new Comparator<String>() {
    @Override
    public int compare(String a, String b) {
        return a.compareTo(b);
    }
});

// Java 8 — 람다 표현식
list.sort((a, b) -> a.compareTo(b));
```

또한 `null` 처리를 매번 `if (x != null)`으로 해야 해서 NPE(NullPointerException)가 빈번했다. `Optional`이 도입되어 null 가능성을 타입으로 표현할 수 있게 되었다.

```java
// 이전 — null 체크를 명시하지 않으면 NPE 발생 가능
String name = user.getName();
System.out.println(name.toUpperCase()); // NPE 위험

// Java 8 — Optional로 null 가능성을 명시
Optional<String> name = Optional.ofNullable(user.getName());
name.ifPresent(n -> System.out.println(n.toUpperCase()));
```

`Stream API`도 이때 도입되어 컬렉션을 함수형 스타일로 처리할 수 있게 되었다.

```java
List<String> result = users.stream()
    .filter(u -> u.getAge() >= 20)
    .map(User::getName)
    .collect(Collectors.toList());
```

**핵심 추가 기능**

- 람다(Lambda) 표현식
- Stream API
- Optional
- 인터페이스 default/static 메서드
- Date/Time API (`java.time` 패키지)

---

### Java 11 (2018) — 첫 번째 주요 LTS

Java 9, 10에서 모듈 시스템 등이 도입되었지만 현장 체감은 적었고, **11이 8 이후 첫 LTS**로 자리잡았다.

지역 변수 타입 추론 `var`가 정식 도입되어 반복적인 타입 선언을 줄일 수 있게 되었다.

```java
// 이전
Map<String, List<Integer>> map = new HashMap<String, List<Integer>>();

// Java 11
var map = new HashMap<String, List<Integer>>();
```

문자열 처리 편의 메서드도 추가되었다.

```java
"  hello  ".strip();         // trim()의 개선판 (유니코드 공백까지 처리)
"  ".isBlank();              // true
"a\nb\nc".lines().toList();  // ["a", "b", "c"]
```

또한 이 시점에 **Oracle JDK가 유료화**되면서 OpenJDK 기반의 무료 배포판인 **Eclipse Temurin(Adoptium)**, **Amazon Corretto** 등이 주류로 자리잡았다.

**핵심 추가 기능**

- `var` 키워드 (지역 변수 타입 추론)
- 문자열 API 개선 (`strip`, `isBlank`, `lines`)
- `HttpClient` 표준 도입
- Oracle JDK 유료화 → OpenJDK 배포판 주류화

---

### Java 17 (2021) — Spring Boot 3.x의 기준 LTS

현재 가장 널리 쓰이는 LTS 버전이다. **Spring Boot 3.x의 최소 요구 버전**이기도 하다.

**Record** 가 정식 도입되었다. 불변 데이터 클래스를 한 줄로 선언할 수 있어 DTO 작성이 간결해졌다.

```java
// 이전 — Lombok 없이 DTO 작성
public class UserDto {
    private final String name;
    private final int age;

    public UserDto(String name, int age) {
        this.name = name;
        this.age = age;
    }

    public String getName() { return name; }
    public int getAge() { return age; }
    // equals, hashCode, toString 구현 필요...
}

// Java 17 — record
record UserDto(String name, int age) {}
// constructor, getter, equals, hashCode, toString 자동 생성
```

**Sealed Class**가 도입되어 상속 가능한 클래스를 명시적으로 제한할 수 있게 되었다.

```java
sealed interface Shape permits Circle, Rectangle {}

record Circle(double radius) implements Shape {}
record Rectangle(int width, int height) implements Shape {}

// Shape의 구현체는 Circle, Rectangle만 가능하다
```

**Switch 표현식**도 개선되어 fall-through 버그를 방지하고 값을 직접 반환할 수 있게 되었다.

```java
// 이전 — break 빠뜨리면 fall-through 버그 발생
String result;
switch (day) {
    case MON: result = "월요일"; break;
    case TUE: result = "화요일"; break;
    default: result = "기타";
}

// Java 17 — switch 표현식
String result = switch (day) {
    case MON -> "월요일";
    case TUE -> "화요일";
    default  -> "기타";
};
```

**핵심 추가 기능**

- Record (정식)
- Sealed Class (정식)
- Switch 표현식 (정식)
- 텍스트 블록 `"""..."""` (정식)
- 패턴 매칭 `instanceof` (정식)

---

### Java 21 (2023) — 현재 최신 LTS

**Virtual Thread(가상 스레드)** 가 가장 큰 변화다. 기존 Java 스레드는 OS 스레드와 1:1로 매핑되어 수천 개 이상 생성 시 메모리와 컨텍스트 스위칭 비용이 컸다. 가상 스레드는 JVM이 직접 스케줄링하여 수십만 개도 가볍게 처리할 수 있다.

```java
// 기존 — OS 스레드 1:1 매핑, 수천 개가 한계
ExecutorService executor = Executors.newFixedThreadPool(200);

// Java 21 — 가상 스레드, 수십만 개 가능
ExecutorService executor = Executors.newVirtualThreadPerTaskExecutor();
```

Spring Boot 3.2부터 설정 한 줄로 가상 스레드를 활성화할 수 있다.

```yaml
# application.yml
spring:
  threads:
    virtual:
      enabled: true
```

**패턴 매칭 switch**도 강력해졌다.

```java
// 이전 — instanceof 체크 후 캐스팅을 별도로 해야 했다
if (shape instanceof Circle) {
    Circle c = (Circle) shape;
    return Math.PI * c.radius() * c.radius();
}

// Java 21 — switch 패턴 매칭
double area = switch (shape) {
    case Circle c    -> Math.PI * c.radius() * c.radius();
    case Rectangle r -> (double) r.width() * r.height();
};
```

**핵심 추가 기능**

- Virtual Thread (정식)
- 패턴 매칭 switch (정식)
- Sequenced Collections (`getFirst()`, `getLast()` 등)
- Record 패턴 (정식)

---

## LTS 버전 한눈에 비교

| 버전    | 출시 | LTS 지원 종료 | 핵심 변화                   |
| ------- | ---- | ------------- | --------------------------- |
| Java 8  | 2014 | 2030          | 람다, Stream, Optional      |
| Java 11 | 2018 | 2032          | var, HttpClient, 문자열 API |
| Java 17 | 2021 | 2029          | Record, Sealed, Switch 개선 |
| Java 21 | 2023 | 2031          | Virtual Thread, 패턴 매칭   |

---

## Spring Boot 버전과 JDK 선택

### Spring Boot와 Java 버전 호환표

| Spring Boot | 최소 Java | 권장 Java      | 비고            |
| ----------- | --------- | -------------- | --------------- |
| 2.x         | 8         | 11 또는 17     | 2025년 11월 EOL |
| 3.x         | **17**    | **17 또는 21** | 현재 메인스트림 |

> Spring Boot 2.x는 2025년 11월에 공식 지원이 종료된다. 신규 프로젝트는 반드시 3.x로 시작해야 한다.

---

### 신규 프로젝트 버전 선택 기준

**Spring Boot 3.x + Java 17 조합** 을 기본으로 선택한다.

- 가장 많은 레퍼런스와 커뮤니티 지원
- 대부분의 라이브러리가 안정적으로 지원
- Spring Security 6, Jakarta EE 10 기반

**Spring Boot 3.2+ + Java 21 조합** 은 아래 상황에서 선택한다.

- 높은 동시성이 필요한 API 서버 (Virtual Thread 활용)
- 새로운 문법을 적극적으로 사용하고 싶을 때
- 팀 전체가 Java 21 환경을 갖출 수 있을 때

---

### IntelliJ 프로젝트 설정 시 주의사항

SDK 버전과 언어 수준(Language Level)은 반드시 일치시켜야 한다. 불일치 시 컴파일 오류 또는 런타임 오류가 발생할 수 있다.

```
SDK: Java 17  →  언어 수준: 17 - Sealed classes...  ✅
SDK: Java 17  →  언어 수준: 24 - 스트림 수집기      ❌
```

`build.gradle`에도 동일하게 명시한다.

```groovy
java {
    sourceCompatibility = JavaVersion.VERSION_17
    targetCompatibility = JavaVersion.VERSION_17
}
```

또는 `build.gradle.kts` (Kotlin DSL):

```kotlin
java {
    sourceCompatibility = JavaVersion.VERSION_17
    targetCompatibility = JavaVersion.VERSION_17
}
```

---

## 결론

- 신규 프로젝트는 **Spring Boot 3.x + Java 17** 을 기본으로 선택한다.
- 높은 동시성이 필요하거나 최신 기능을 활용하려면 **Java 21** 을 선택한다.
- IntelliJ에서 SDK와 언어 수준은 항상 동일하게 맞춘다.
