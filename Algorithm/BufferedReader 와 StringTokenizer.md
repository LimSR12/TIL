---
title: "Java 입력 정리 (BufferedReader vs StringTokenizer)"
summary: "Java 코딩테스트에서는 입력을 거의 항상 **BufferedReader**로 받는다."
status: publish
---

# Java 입력 정리 (BufferedReader vs StringTokenizer)

## 1️⃣ BufferedReader는 항상 기본 베이스

Java 코딩테스트에서는 입력을 거의 항상 **BufferedReader**로 받는다.

### 이유

- `Scanner` → 속도가 느림 (시간초과 원인이 될 수 있다!)
- `BufferedReader` → 문자열 단위로 빠르게 입력 가능

👉 **입력을 읽는 도구 = BufferedReader**

## 2️⃣ StringTokenizer는 "한 줄에 여러 값이 있을 때만"

공백 기준으로 값을 나눠야 할 때 사용한다.

👉 **문자열을 쪼개는 도구 = StringTokenizer**

---

### ✅ Case 1: 입력이 줄 단위 (값 1개씩)

#### 입력

    9
    3

#### 사용

```java
int x = Integer.parseInt(br.readLine());
int y = Integer.parseInt(br.readLine());
```

✔️ StringTokenizer 필요 없음

---

### ✅ Case 2: 한 줄에 여러 값

#### 입력

    9 3

#### 사용

```java
StringTokenizer st = new StringTokenizer(br.readLine());
int x = Integer.parseInt(st.nextToken());
int y = Integer.parseInt(st.nextToken());
```

---

### ✅ Case 3: N개 숫자가 한 줄에 있음

#### 입력

    5
    1 2 3 4 5

#### 사용

```java
int n = Integer.parseInt(br.readLine());
StringTokenizer st = new StringTokenizer(br.readLine());

for (int i = 0; i < n; i++) {
    int num = Integer.parseInt(st.nextToken());
}
```

---

### ✅ Case 4: N줄에 걸쳐 있음

#### 입력

    5
    1
    2
    3
    4
    5

#### 사용

```java
int n = Integer.parseInt(br.readLine());

for (int i = 0; i < n; i++) {
    int num = Integer.parseInt(br.readLine());
}
```

✔️ StringTokenizer 필요 없음

---

### ✅ Case 5: 2차원 배열 입력

#### 입력

    3 3
    1 2 3
    4 5 6
    7 8 9

#### 사용

```java
StringTokenizer st = new StringTokenizer(br.readLine());
int n = Integer.parseInt(st.nextToken());
int m = Integer.parseInt(st.nextToken());

int[][] arr = new int[n][m];

for (int i = 0; i < n; i++) {
    st = new StringTokenizer(br.readLine());
    for (int j = 0; j < m; j++) {
        arr[i][j] = Integer.parseInt(st.nextToken());
    }
}
```

---

# 정리

| 상황            | BufferedReader | StringTokenizer |
| --------------- | -------------- | --------------- |
| 입력 1개        | O              | X               |
| 줄마다 값 1개   | O              | X               |
| 한 줄에 여러 값 | O              | O               |
| 배열 입력       | O              | O               |
| 행렬 입력       | O              | O               |

> 입력은 `BufferedReader`  
> 한 줄에 여러 값이 들어있고, 그걸 공백 기준으로 나눠야 할 때만 `StringTokenizer` 사용
