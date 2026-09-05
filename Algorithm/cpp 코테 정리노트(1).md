---
title: "C++ 코딩테스트 정리노트 1편"
summary: "코딩테스트에서 '이걸 어떻게 쓰더라?' 하고 당황하지 않기 위한 레퍼런스"
status: publish
tag:
  - C++
category: "Algorithm"
---

## 1. 기본 입출력

### 1.1 빠른 입출력

```cpp
#include <bits/stdc++.h>
using namespace std;

int main() {
    ios::sync_with_stdio(false);
    cin.tie(NULL);
    // cout.tie(NULL); // 필요시
}
```

- `ios::sync_with_stdio(false)` : C의 stdio와 동기화 해제 -> 입출력 속도 대폭 향상
- `cin.tie(NULL)` : cin과 cout의 묶임 해제 -> flush 횟수 감소

**주의**: 이후 `scanf/printf`와 `cin/cout`을 혼용하면 안 됨!

### 1.2 문자열 입력

```cpp
// 공백 없는 단어 하나
string s;
cin >> s;

// 공백 포함 한 줄 전체
string line;
getline(cin, line);

// cin 이후에 getline 쓸 때 주의 !!
int n;
cin >> n;
cin.ignore();           // 버퍼에 남은 '\n' 제거 (필수!)
getline(cin, line);
```

### 1.3 EOF까지 입력받기

```cpp
// 정수
int x;
while (cin >> x) {
    // 처리
}

// 문자열
string s;
while (getline(cin, s)) {
    // 처리
}
```

### 1.4 출력 포맷

소수점 자릿수를 고정하고 싶으면 `setprecision()`을 사용한다.

```cpp
// 소수점 자릿수 고정
cout << fixed << setprecision(6) << 3.141592653 << "\n";
// 출력: 3.141593
```

또한 출력 시 줄바꿈은 `endl` 대신 `"\n"` 사용이 더 바람직하다. `endl` 은 자동적으로 버퍼 flush 까지 수행하기 때문에 불필요하게 시간이 더 늘어난다!

```cpp
cout << "hello" << "\n";
```

## 2. 자료형 & 범위

| 타입        | 크기 | 범위        | 용도               |
| ----------- | ---- | ----------- | ------------------ |
| `int`       | 4B   | ±2.1×10⁹    | 일반 정수          |
| `long long` | 8B   | ±9.2×10¹⁸   | 큰 수 곱셈, 누적합 |
| `double`    | 8B   | 유효 15자리 | 실수 계산          |
| `char`      | 1B   | -128~127    | 문자 하나          |
| `bool`      | 1B   | 0 / 1       | 참/거짓            |

```cpp
// long long 리터럴
long long big = 1e18;       // OK (double → long long 변환)
long long big2 = 1000000007LL; // 명시적 LL 접미사
```

코테 문제를 풀다보면 정수 오버플로우에 주의해야 하는 경우가 있다.

```cpp
int a = 100000;
long long result = a * a;
```

위 코드를 보면 `result` 가 `long long` 이어도 오른쪽의 `a * a`는 `int` 로 계산되어 오버플로우가 발생한다.

```cpp
int temp = a * a;       // 여기서 이미 int 오버플로우
long long result = temp;
```

위와 같이 `long long` 에 담기 전에 이미 값이 망가져버린다.

```cpp
int a = 100000;
long long result = (long long)a * a;
```

이렇게 하면 왼쪽 피연산자 하나가 `long long`이므로 전체 곱셈이 `long long` 기준으로 계산되어 안전하다.

```cpp
long long result = 1LL * a * a;
```

찾아보니 위처럼 자주 사용한다고 한다. `1LL`은 `long long` 타입의 1로, 계산 전체가 `long long` 으로 승격되도록 할 수 있는 꿀팁이다.

### 2.1 형변환

```cpp
int a = 7, b = 2;
double ratio = (double)a / b;        // 3.5

// 문자 <-> 숫자
char c = '7';
int digit = c - '0';   // 7
char back = digit + '0'; // '7'

// 문자 대소문자
char ch = 'a';
bool isUpper = (ch >= 'A' && ch <= 'Z');
char upper = ch - 32;   // 또는 toupper(ch)
char lower = ch + 32;   // 또는 tolower(ch)
```

## 3. string 다루기

### 3.1 기본 연산

```cpp
string s = "hello";

s.size();      // 5
s.empty();     // false

s += " world"; // 이어붙이기 -> "hello world"

s[0];          // 'h' (인덱스 접근)
s.front();     // 'h'
s.back();      // 'd'

s.substr(0, 5);    // "hello" (시작위치, 길이)
s.substr(6);       // "world" (시작위치부터 끝까지)
```

### 3.2 검색 & 변환

```cpp
string s = "abcabc";

s.find("bc");       // 1 (처음 발견 위치)
s.find("xyz");      // string::npos (못 찾음)
s.rfind("bc");      // 4 (뒤에서부터 검색)

// 찾기 예시
if (s.find("bc") != string::npos) {
    // 찾음
}

// 삽입/삭제/교체
s.insert(2, "XY");   // "abXYcabc"
s.erase(2, 2);       // "abcabc" (위치, 길이)
s.replace(0, 3, "Z"); // "Zabc"
```

> Q. `string::npos`는 뭐죠?
> A. `string::npos`는 C++에서 문자열 검색 실패를 나타내는 특별한 값이다!

### 3.3 숫자 <-> 문자열 변환

```cpp
// 숫자 -> 문자열
int n = 42;
string s = to_string(n);    // "42"

// 문자열 -> 숫자
string s2 = "123";
int num = stoi(s2);          // 123
long long big = stoll(s2);   // 123LL
double d = stod("3.14");     // 3.14
```

### 3.4 문자열 분리 (split)

```cpp
// C++에는 split이 없음 -> stringstream 사용
#include <sstream>

string line = "apple banana cherry";
stringstream ss(line);
string word;
while (ss >> word) {
    cout << word << "\n";
}

// 특정 구분자로 분리
string csv = "a,b,c,d";
stringstream ss2(csv);
string token;
while (getline(ss2, token, ',')) {
    cout << token << "\n";
}
```

## 4. vector

### 4.1 선언 & 초기화

```cpp
vector<int> v;                    // 빈 벡터
vector<int> v(10);                // 크기 10, 모두 0
vector<int> v(10, -1);            // 크기 10, 모두 -1
vector<int> v = {1, 2, 3, 4, 5};  // 초기화 리스트

// 2차원 벡터
vector<vector<int>> grid(N, vector<int>(M, 0)); // N×M, 0으로 초기화

// 2차원 벡터 (인접 리스트)
vector<vector<int>> adj(N + 1); // 정점 1~N
```

그리고 벡터를 사용한 뒤 재 초기화해서 사용하고 싶은 경우 다음과 같은 방법들이 있다.

#### 1. clear() — 원소만 다 비우기

```cpp
vector<int> v = {1, 2, 3};
v.clear();           // v는 이제 빈 벡터, size()=0
```

#### 2. assign() — 특정 값으로 채워서 초기화

> assign(n, 초기값)

```cpp
vector<int> v(5, 1);  // {1,1,1,1,1}
v.assign(3, 0);       // {0,0,0} — 크기도 3으로, 값도 0으로 재설정
```

#### 3. = {} 또는 새 벡터 대입 — 통째로 교체

```cpp
vector<int> v = {1, 2, 3};
v = {};               // 빈 벡터로 교체
```

#### 4. resize() — 크기만 다시 지정 (기존 값 유지 여부 다름)

```cpp
vector<int> v = {1, 2, 3};
v.resize(5);          // {1,2,3,0,0} — 늘어난 자리는 기본값(0)으로 채움
v.resize(2);          // {1,2} — 줄어들면 뒤에서부터 잘림, 기존 값은 유지됨
v.resize(5, -1);      // 늘어난 자리를 -1로 채움 (두 번째 인자로 초기값 지정 가능)
```

### 4.2 주요 메서드

```cpp
v.push_back(10);       // 끝에 추가
v.pop_back();          // 마지막 원소 제거
v.size();              // 원소 개수 (반환형: size_t, unsigned)
v.empty();             // 비었는지
v.clear();             // 전체 삭제
v.front();             // 첫 원소
v.back();              // 마지막 원소

v.begin();             // 시작 이터레이터
v.end();               // 끝 다음 이터레이터

// 특정 위치 삽입/삭제
v.insert(v.begin() + 2, 99);  // 인덱스 2에 99 삽입
v.erase(v.begin() + 2);       // 인덱스 2 삭제
v.erase(v.begin(), v.begin() + 3); // 앞 3개 삭제
```

### 4.3 v.size() 주의사항

`v.size()`는 벡터의 원소 개수를 반환한다.

이때 반환 타입은 `int` 가 아닌 `size_t` 인데, 이게 `unsigned` 정수 타입이다!
따라서 빈 벡터에서 `v.size()`는 0이니까 `v.size() - 1` 을 잘못 쓰면 언더플로우가 발생할 수 있다.

```cpp
vector<int> v; // 빈 벡터

// int 로 형변환해서 사용하던가
for (int i = 0; i < (int)v.size() - 1; i++) { ... }

// 또는 empty() 메서드를 활용하던가
if (!v.empty()) { ... }
```

## 5. pair & tuple

### 5.1 pair

```cpp
pair<int, int> p = {3, 5};    // 또는 make_pair(3, 5) 라는 것도 있다
p.first;   // 3
p.second;  // 5

pair<int, int> a = {1, 3};
pair<int, int> b = {1, 5};
```

(참고) pair끼리 비교할때는 first 먼저 비교하고, 같으면 second 비교하는 식이다.
그래서 위 a, b라는 두 pair를 비교할 때 `a < b` 는 `true`를 반환한다.

```cpp
// vector<pair> 선언
vector<pair<int, int>> vp;
vp.push_back({1, 2});
vp.emplace_back(1, 2);
```

벡터 이야기이긴 한데, `push_back()`은 객체를 만들어서 넘겨줘야 하지만 `emplace_back()`은 값만 넘겨줘도 내부적으로 객체 하나 만들어서 삽입하는 방식이라 위와 같이 사용 가능하다.

### 5.2 tuple (3개 이상일 때)

```cpp
tuple<int, int, string> t = {1, 2, "abc"};
// 또는 make_tuple(1, 2, "abc")

get<0>(t); // 1
get<1>(t); // 2
get<2>(t); // "abc"

// 구조화 바인딩 (C++17)
auto [x, y, name] = t;
```

### 5.3 구조화 바인딩

> 구조화 바인딩이란?
>
> 배열, 튜플(tuple), 구조체(struct)와 같이 여러 값을 묶어서 가진 객체를 분해하여, 내부의 개별 요소들을 각각의 독립적인 변수에 한 번에 할당하는 C++17의 핵심 기능!

```cpp
// 기존 방식
pair<int, int> p = {3, 5};
int x = p.first;
int y = p.second;

// 구조화 바인딩
pair<int, int> p = {3, 5};
auto [x, y] = p;

```

```cpp
// map 순회 시 편리
map<string, int> m;
for (auto& [key, val] : m) {
    cout << key << ": " << val << "\n";
}
```

## 6. 정렬 (sort)

### 6.1 기본 정렬

```cpp
vector<int> v = {5, 2, 8, 1, 3};

sort(v.begin(), v.end());                  // 오름차순: 1 2 3 5 8
sort(v.begin(), v.end(), greater<int>());  // 내림차순: 8 5 3 2 1

// 일반 배열 정렬도 가능하다
int arr[5] = {5, 2, 8, 1, 3};
sort(arr, arr + 5);
```

### 6.2 커스텀 정렬 (비교 함수)

#### 방법 1: cmp 함수

> `cmp(a, b)`는 **"a가 b보다 앞에 와야 하면 true"**를 반환하는 함수다.

예를 들어 오름차순 정렬해야 한다면, 작은게 큰 것보다 앞에 와야 하니까 `return a < b;` !

```cpp
bool cmp(const pair<int,int>& a, const pair<int,int>& b) {
    if (a.first == b.first) return a.second < b.second; // 2차 기준
    return a.first < b.first; // 1차 기준: 오름차순
}

sort(v.begin(), v.end(), cmp);

```

#### 방법 2: 람다

```cpp
sort(v.begin(), v.end(), [](const auto& a, const auto& b) {
    return a.first > b.first;
});
```

### 6.3 stable_sort()

sort()와 동일하게 C++에서 제공하는 정렬 함수인데, 정렬 기준이 같은 원소에 대해서는 기존의 순서를 유지한다는 특징이 있다.

```cpp
// 같은 값의 원래 순서를 유지
stable_sort(v.begin(), v.end(), cmp);
```

## 7. 선형 탐색 & 이분탐색

### 7.1 선형 탐색

데이터를 선형 탐색할때는 단순 반복문으로 탐색할 수 있고, `<algorithm>` 의 `find()` 메서드를 활용할 수도 있다.
이때 메서드가 반환하는 것은 iterator!

> -> `it - v.begin()` 으로 인덱스를 구하거나
> -> `*it` 으로 바로 출력하거나

```cpp
// find
auto it = find(v.begin(), v.end(), 5); // it 에 저장되는 건 iterator!!
if (it != v.end()) {
    int idx = it - v.begin();
}

// count
int cnt = count(v.begin(), v.end(), 5); // 5의 개수
```

### 7.2 이분탐색

이분 탐색은 `<algorithm>`의 `binary_search()`라는 함수를 사용하면 된다.
이때 반드시 배열이나 벡터가 정렬된 상태여야 한다.

#### 내장 함수 사용

```cpp
sort(v.begin(), v.end()); // 반드시 정렬 선행

// 존재 여부
bool found = binary_search(v.begin(), v.end(), 5);
```

그런데 `binary_search()` 는 존재 여부만 `true`/`false` 로 반환하고, 정확한 인덱스를 찾아주지는 않는다!

```cpp
// lower_bound: target 이상인 첫 위치
auto lb = lower_bound(v.begin(), v.end(), 5);

// upper_bound: target 초과인 첫 위치
auto ub = upper_bound(v.begin(), v.end(), 5);

// target의 개수 = upper_bound - lower_bound
int cnt = ub - lb;

// 인덱스로 변환
int idx = lower_bound(v.begin(), v.end(), 5) - v.begin();
```

#### 직접 구현

```cpp
long long lo = 0, hi = 1e18;
while (lo < hi) {
    long long mid = (lo + hi) / 2;   // lo + (hi - lo) / 2 도 가능
    if (check(mid)) {
        hi = mid;       // 조건 만족하면 범위 줄이기
    } else {
        lo = mid + 1;   // 조건 불만족하면 범위 올리기
    }
}
```

## 8. `<algorithm>`의 다양한 함수들

### 8.1 최대/최소

```cpp
int a = 3, b = 7;
max(a, b);         // 7
min(a, b);         // 3
max({1, 2, 3, 4}); // 4 (여러 개 비교 - 초기화 리스트)

// 벡터에서 최대/최소
*max_element(v.begin(), v.end());
*min_element(v.begin(), v.end());

// 인덱스
int maxIdx = max_element(v.begin(), v.end()) - v.begin();
```

### 8.2 swap & reverse

```cpp
int a = 1, b = 2;
swap(a, b);     // a=2, b=1

reverse(v.begin(), v.end());           // 벡터 뒤집기
reverse(s.begin(), s.end());           // 문자열 뒤집기
reverse(v.begin(), v.begin() + 3);     // 앞 3개만 뒤집기
```

### 8.3 next_permutation (순열)

```cpp
vector<int> v = {1, 2, 3};
sort(v.begin(), v.end()); // 반드시 오름차순 정렬 선행!

do {
    for (int x : v) cout << x << " ";
    cout << "\n";
} while (next_permutation(v.begin(), v.end()));
// 1 2 3 → 1 3 2 → 2 1 3 → ... → 3 2 1

// prev_permutation: 이전 순열
```

### 8.4 unique (중복 제거)

```cpp
sort(v.begin(), v.end());  // 정렬 필수!
v.erase(unique(v.begin(), v.end()), v.end());
// unique는 연속 중복만 제거하고 끝 이터레이터 반환
// erase로 뒤쪽 쓰레기값 제거
```

### 8.5 accumulate (합계)

```cpp
#include <numeric>
int sum = accumulate(v.begin(), v.end(), 0);         // 초기값 0
long long sum2 = accumulate(v.begin(), v.end(), 0LL); // long long 합
```

### 8.6 fill & iota

```cpp
// fill: 특정 값으로 채우기
fill(v.begin(), v.end(), -1);

// 배열도 가능
int arr[100];
fill(arr, arr + 100, 0);

// memset: 0 또는 -1로 초기화할 때만 안전
memset(arr, 0, sizeof(arr));
memset(arr, -1, sizeof(arr)); // 모든 바이트를 0xFF → int는 -1이 됨

// iota: 순차적으로 채우기
vector<int> idx(10);
iota(idx.begin(), idx.end(), 0); // {0, 1, 2, ..., 9}
```

## 10. `<cmath>`

### 10.1 기본 수학 함수

```cpp
#include <cmath>

abs(-5);           // 5 (정수)
fabs(-5.3);        // 5.3 (실수)
abs(-5LL);         // long long도 가능 (C++11~)

ceil(2.3);         // 3 (올림)
floor(2.7);        // 2 (내림)
round(2.5);        // 3 (반올림)

pow(2, 10);        // 1024.0 (double 반환 → 정수 비교 시 주의)
sqrt(16);          // 4.0
log2(8);           // 3.0

// 정수 올림 나눗셈 (자주 쓰임!)
int a = 7, b = 3;
int ceil_div = (a + b - 1) / b; // 3
```

### 10.2 MOD 연산

```cpp
const int MOD = 1e9 + 7;

// 덧셈
(a + b) % MOD;

// 곱셈 (오버플로우 주의!)
(1LL * a * b) % MOD;  // long long 캐스팅

// 뺄셈 (음수 방지)
((a - b) % MOD + MOD) % MOD;
```

## 11. 비트 연산

```cpp
// 기본 연산자
a & b    // AND
a | b    // OR
a ^ b    // XOR
~a       // NOT
a << n   // 왼쪽 시프트 (×2ⁿ)
a >> n   // 오른쪽 시프트 (÷2ⁿ)

// 자주 쓰는 테크닉
(1 << n)            // 2ⁿ
(x >> i) & 1        // x의 i번째 비트 확인
x | (1 << i)        // i번째 비트 켜기
x & ~(1 << i)       // i번째 비트 끄기
x ^ (1 << i)        // i번째 비트 토글

// 비트마스킹 (부분집합 열거)
for (int mask = 0; mask < (1 << n); mask++) {
    for (int i = 0; i < n; i++) {
        if (mask & (1 << i)) {
            // i번째 원소 선택됨
        }
    }
}
```
