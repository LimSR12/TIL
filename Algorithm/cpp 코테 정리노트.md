---
title: "C++ 코딩테스트 문법 & STL 정리노트"
summary: "코딩테스트에서 '이걸 어떻게 쓰더라?' 하고 당황하지 않기 위한 레퍼런스"
status: publish
---

> 본 문서는 Claude에 요청하여 생성한 C++ 코테 준비 정리노트 문서입니다!

## 1. 기본 입출력

### 1.1 빠른 입출력 (거의 모든 문제에서 상단에 붙이기)

```cpp
#include <bits/stdc++.h>
using namespace std;

int main() {
    ios::sync_with_stdio(false);
    cin.tie(NULL);
    // cout.tie(NULL); // 필요시
}
```

- `ios::sync_with_stdio(false)` : C의 stdio와 동기화 해제 → 입출력 속도 대폭 향상
- `cin.tie(NULL)` : cin과 cout의 묶임 해제 → flush 횟수 감소
- **주의**: 이후 `scanf/printf`와 `cin/cout`을 혼용하면 안 됨

### 1.2 정수/실수 입력

```cpp
int a, b;
cin >> a >> b;

double d;
cin >> d;

// 여러 개 한 줄에
int x, y, z;
cin >> x >> y >> z; // 공백/줄바꿈 구분 자동 처리
```

### 1.3 문자열 입력

```cpp
// 공백 없는 단어 하나
string s;
cin >> s;

// 공백 포함 한 줄 전체
string line;
getline(cin, line);

// ⚠️ cin >> 뒤에 getline 쓸 때 주의
int n;
cin >> n;
cin.ignore();           // 버퍼에 남은 '\n' 제거 (필수!)
getline(cin, line);
```

### 1.4 EOF까지 입력받기

```cpp
// 방법 1
int x;
while (cin >> x) {
    // 처리
}

// 방법 2: 문자열
string s;
while (getline(cin, s)) {
    // 처리
}
```

### 1.5 출력 포맷

```cpp
// 소수점 자릿수 고정
cout << fixed << setprecision(6) << 3.141592653 << "\n";
// 출력: 3.141593

// 줄바꿈: endl 대신 "\n" 사용 (endl은 flush 발생 → 느림)
cout << "hello" << "\n";
```

---

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

// int 오버플로우 주의
int a = 100000;
long long result = (long long)a * a; // 캐스팅 먼저!
// int끼리 곱하면 int 범위에서 오버플로우 발생 후 long long에 대입됨
```

### 2.1 형변환

```cpp
// C++ 스타일 캐스팅
int a = 7, b = 2;
double ratio = (double)a / b;        // 3.5
double ratio2 = static_cast<double>(a) / b; // 동일

// 문자 ↔ 숫자
char c = '7';
int digit = c - '0';   // 7
char back = digit + '0'; // '7'

// 문자 대소문자
char ch = 'a';
bool isUpper = (ch >= 'A' && ch <= 'Z');
char upper = ch - 32;   // 또는 toupper(ch)
char lower = ch + 32;   // 또는 tolower(ch)
```

---

## 3. string 다루기

### 3.1 기본 연산

```cpp
string s = "hello";

s.length();    // 5 (size()와 동일)
s.empty();     // false

s += " world"; // 이어붙이기 → "hello world"

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

// 찾기 패턴
if (s.find("bc") != string::npos) {
    // 찾음
}

// 삽입/삭제/교체
s.insert(2, "XY");   // "abXYcabc"
s.erase(2, 2);       // "abcabc" (위치, 길이)
s.replace(0, 3, "Z"); // "Zabc"
```

### 3.3 숫자 ↔ 문자열 변환

```cpp
// 숫자 → 문자열
int n = 42;
string s = to_string(n);    // "42"

// 문자열 → 숫자
string s2 = "123";
int num = stoi(s2);          // 123
long long big = stoll(s2);   // 123LL
double d = stod("3.14");     // 3.14
```

### 3.4 문자열 분리 (split)

```cpp
// C++에는 split이 없음 → stringstream 사용
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

---

## 4. vector

### 4.1 선언 & 초기화

```cpp
vector<int> v;                    // 빈 벡터
vector<int> v(10);                // 크기 10, 모두 0
vector<int> v(10, -1);            // 크기 10, 모두 -1
vector<int> v = {1, 2, 3, 4, 5}; // 초기화 리스트

// 2차원 벡터
vector<vector<int>> grid(N, vector<int>(M, 0)); // N×M, 0으로 초기화

// 2차원 벡터 (인접 리스트)
vector<vector<int>> adj(N + 1); // 정점 1~N
```

### 4.2 주요 메서드

```cpp
v.push_back(10);       // 끝에 추가
v.emplace_back(10);    // push_back과 유사, 약간 더 효율적
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

### 4.3 v.size() 함정 주의

```cpp
vector<int> v; // 빈 벡터
// v.size() - 1 → 언더플로우! (size_t는 unsigned이므로 0 - 1 = 엄청 큰 수)

// 안전한 방법
for (int i = 0; i < (int)v.size() - 1; i++) { ... }
// 또는
if (!v.empty()) { ... }
```

---

## 5. pair & tuple

### 5.1 pair

```cpp
pair<int, int> p = {3, 5};    // 또는 make_pair(3, 5)
p.first;   // 3
p.second;  // 5

// 비교: first 먼저, 같으면 second 비교
pair<int, int> a = {1, 3};
pair<int, int> b = {1, 5};
// a < b → true (first 같고 second 비교)

// vector<pair> 선언
vector<pair<int, int>> vp;
vp.push_back({1, 2});
vp.emplace_back(1, 2); // 중괄호 없이도 가능
```

### 5.2 tuple (3개 이상)

```cpp
tuple<int, int, string> t = {1, 2, "abc"};
// 또는 make_tuple(1, 2, "abc")

get<0>(t); // 1
get<1>(t); // 2
get<2>(t); // "abc"

// 구조화 바인딩 (C++17)
auto [x, y, name] = t;
```

### 5.3 structured bindings (C++17)

```cpp
// pair 분해
pair<int, int> p = {3, 5};
auto [x, y] = p;

// map 순회 시 편리
map<string, int> m;
for (auto& [key, val] : m) {
    cout << key << ": " << val << "\n";
}
```

---

## 6. 정렬 (sort)

### 6.1 기본 정렬

```cpp
vector<int> v = {5, 2, 8, 1, 3};

sort(v.begin(), v.end());           // 오름차순: 1 2 3 5 8
sort(v.begin(), v.end(), greater<int>()); // 내림차순: 8 5 3 2 1

// 배열 정렬
int arr[5] = {5, 2, 8, 1, 3};
sort(arr, arr + 5);
```

### 6.2 커스텀 정렬 (비교 함수)

```cpp
// 방법 1: 별도 함수
bool cmp(const pair<int,int>& a, const pair<int,int>& b) {
    if (a.first == b.first) return a.second < b.second; // 2차 기준
    return a.first > b.first; // 1차 기준: 내림차순
}
sort(v.begin(), v.end(), cmp);

// 방법 2: 람다
sort(v.begin(), v.end(), [](const auto& a, const auto& b) {
    return a.first > b.first;
});
```

### 6.3 stable_sort

```cpp
// 같은 값의 원래 순서를 유지
stable_sort(v.begin(), v.end(), cmp);
```

---

## 7. 탐색 & 이분탐색

### 7.1 선형 탐색

```cpp
// find
auto it = find(v.begin(), v.end(), 5);
if (it != v.end()) {
    int idx = it - v.begin(); // 인덱스
}

// count
int cnt = count(v.begin(), v.end(), 5); // 5의 개수
```

### 7.2 이분탐색 (정렬된 상태에서만!)

```cpp
sort(v.begin(), v.end()); // 반드시 정렬 선행

// 존재 여부
bool found = binary_search(v.begin(), v.end(), 5);

// lower_bound: target 이상인 첫 위치
auto lb = lower_bound(v.begin(), v.end(), 5);

// upper_bound: target 초과인 첫 위치
auto ub = upper_bound(v.begin(), v.end(), 5);

// target의 개수 = upper_bound - lower_bound
int cnt = ub - lb;

// 인덱스로 변환
int idx = lower_bound(v.begin(), v.end(), 5) - v.begin();
```

### 7.3 직접 이분탐색 구현 (파라메트릭 서치)

```cpp
long long lo = 0, hi = 1e18;
while (lo < hi) {
    long long mid = (lo + hi) / 2;   // lo + (hi - lo) / 2 도 가능
    if (check(mid)) {
        hi = mid;       // 조건 만족 → 범위 줄이기
    } else {
        lo = mid + 1;   // 조건 불만족 → 범위 올리기
    }
}
// lo == hi 가 답
```

---

## 8. 주요 STL 컨테이너

### 8.1 stack

```cpp
stack<int> st;
st.push(10);
st.top();      // 10 (제거 안 함)
st.pop();      // 제거 (반환값 없음!)
st.empty();
st.size();
```

### 8.2 queue

```cpp
queue<int> q;
q.push(10);
q.front();     // 맨 앞
q.back();      // 맨 뒤
q.pop();       // front 제거
q.empty();
q.size();
```

### 8.3 deque (양방향 큐)

```cpp
deque<int> dq;
dq.push_front(1);
dq.push_back(2);
dq.pop_front();
dq.pop_back();
dq.front();
dq.back();
dq[i]; // 인덱스 접근 가능 (vector처럼)
```

### 8.4 priority_queue (힙)

```cpp
// 기본: 최대 힙 (큰 값이 top)
priority_queue<int> maxpq;
maxpq.push(3);
maxpq.push(1);
maxpq.push(5);
maxpq.top();   // 5

// 최소 힙 (작은 값이 top)
priority_queue<int, vector<int>, greater<int>> minpq;
minpq.push(3);
minpq.push(1);
minpq.top();   // 1

// pair: first 기준 → second 기준 순으로 비교
priority_queue<pair<int,int>> pq; // {큰 first, 큰 second}가 top

// 커스텀 비교 (다익스트라 등)
// 최소 힙으로 {거리, 노드} 쓰려면:
priority_queue<pair<int,int>, vector<pair<int,int>>, greater<pair<int,int>>> pq;
```

### 8.5 set / multiset

```cpp
set<int> s;
s.insert(3);
s.insert(1);
s.insert(3);   // 무시됨 (중복 불가)
s.erase(3);    // 삭제
s.count(3);    // 0 또는 1
s.find(3);     // 이터레이터 (없으면 s.end())
s.size();

// 자동 정렬됨 (오름차순)
for (int x : s) cout << x << " "; // 1 3 (정렬 상태)

// 최솟값/최댓값
*s.begin();    // 최솟값
*s.rbegin();   // 최댓값

// lower_bound / upper_bound도 사용 가능
auto it = s.lower_bound(5);

// multiset: 중복 허용
multiset<int> ms;
ms.insert(3);
ms.insert(3); // OK
ms.erase(ms.find(3)); // 하나만 삭제
ms.erase(3);           // 3 전부 삭제 주의!
```

### 8.6 map / unordered_map

```cpp
map<string, int> m;
m["apple"] = 3;
m["banana"] = 5;
m["apple"]++;           // 4

m.count("apple");       // 1 (있으면) or 0
m.erase("apple");

// 순회 (key 기준 오름차순 정렬)
for (auto& [key, val] : m) {
    cout << key << ": " << val << "\n";
}

// [] 연산자 주의: 없는 키에 접근하면 기본값(0)으로 자동 삽입됨
cout << m["cherry"]; // 0 출력 + "cherry" 키가 생성됨

// 안전하게 확인
if (m.count("cherry")) { ... }
// 또는
auto it = m.find("cherry");
if (it != m.end()) { ... }

// unordered_map: 해시 기반, O(1) 평균 접근 (정렬 안 됨)
unordered_map<string, int> um;
// 사용법은 map과 동일
```

### 8.7 unordered_set

```cpp
unordered_set<int> us;
us.insert(5);
us.count(5);    // O(1) 평균
// 정렬 불필요하고 존재 여부만 확인할 때 set보다 빠름
```

---

## 9. 유용한 알고리즘 함수 (`<algorithm>`)

### 9.1 최대/최소

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

### 9.2 swap & reverse

```cpp
int a = 1, b = 2;
swap(a, b);     // a=2, b=1

reverse(v.begin(), v.end());           // 벡터 뒤집기
reverse(s.begin(), s.end());           // 문자열 뒤집기
reverse(v.begin(), v.begin() + 3);     // 앞 3개만 뒤집기
```

### 9.3 next_permutation (순열)

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

### 9.4 unique (중복 제거)

```cpp
sort(v.begin(), v.end());  // 정렬 필수!
v.erase(unique(v.begin(), v.end()), v.end());
// unique는 연속 중복만 제거하고 끝 이터레이터 반환
// erase로 뒤쪽 쓰레기값 제거
```

### 9.5 accumulate (합계)

```cpp
#include <numeric>
int sum = accumulate(v.begin(), v.end(), 0);         // 초기값 0
long long sum2 = accumulate(v.begin(), v.end(), 0LL); // long long 합
```

### 9.6 fill & iota

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

---

## 10. 수학 관련

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

### 10.2 GCD / LCM

```cpp
// C++17
__gcd(12, 8);     // 4 (GCC 확장, 대부분 사용 가능)
// 또는
#include <numeric>
gcd(12, 8);       // 4 (C++17 표준)
lcm(12, 8);       // 24

// 직접 구현 (유클리드 호제법)
int gcd(int a, int b) {
    while (b) {
        a %= b;
        swap(a, b);
    }
    return a;
}
```

### 10.3 MOD 연산

```cpp
const int MOD = 1e9 + 7;

// 덧셈
(a + b) % MOD;

// 곱셈 (오버플로우 주의!)
(1LL * a * b) % MOD;  // long long 캐스팅

// 뺄셈 (음수 방지)
((a - b) % MOD + MOD) % MOD;
```

---

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

// __builtin 함수 (GCC)
__builtin_popcount(x);    // 1인 비트 개수
__builtin_clz(x);         // 앞쪽 0의 개수 (count leading zeros)
```

---

## 12. 반복문 & 범위 기반 for

```cpp
// 기본 for
for (int i = 0; i < n; i++) { ... }

// 역순
for (int i = n - 1; i >= 0; i--) { ... }

// 범위 기반 for (읽기 전용)
for (int x : v) { cout << x; }

// 범위 기반 for (수정 가능 - 참조)
for (int& x : v) { x *= 2; }

// auto 활용
for (auto& x : v) { ... }
for (auto& [key, val] : m) { ... }
```

---

## 13. 함수형 도구 / 람다

```cpp
// 람다 기본
auto add = [](int a, int b) -> int { return a + b; };
cout << add(3, 5); // 8

// 외부 변수 캡처
int threshold = 10;
auto isAbove = [threshold](int x) { return x > threshold; };
// [&] → 모든 외부 변수 참조 캡처
// [=] → 모든 외부 변수 값 캡처
// [&threshold] → threshold만 참조 캡처

// count_if, any_of, all_of
int cnt = count_if(v.begin(), v.end(), [](int x) { return x > 5; });
bool anyPositive = any_of(v.begin(), v.end(), [](int x) { return x > 0; });
bool allPositive = all_of(v.begin(), v.end(), [](int x) { return x > 0; });
```

---

## 14. 2차원 배열 & 방향 탐색 (BFS/DFS 필수)

### 14.1 방향 배열

```cpp
// 상하좌우 (4방향)
int dx[] = {-1, 1, 0, 0};
int dy[] = {0, 0, -1, 1};

// 8방향
int dx[] = {-1, -1, -1, 0, 0, 1, 1, 1};
int dy[] = {-1, 0, 1, -1, 1, -1, 0, 1};

// 범위 체크
for (int d = 0; d < 4; d++) {
    int nx = x + dx[d];
    int ny = y + dy[d];
    if (nx < 0 || nx >= N || ny < 0 || ny >= M) continue;
    if (visited[nx][ny]) continue;
    // 처리
}
```

### 14.2 BFS 템플릿

```cpp
#include <queue>

int bfs(int sx, int sy) {
    queue<pair<int,int>> q;
    vector<vector<int>> dist(N, vector<int>(M, -1));

    q.push({sx, sy});
    dist[sx][sy] = 0;

    while (!q.empty()) {
        auto [x, y] = q.front();
        q.pop();

        for (int d = 0; d < 4; d++) {
            int nx = x + dx[d];
            int ny = y + dy[d];
            if (nx < 0 || nx >= N || ny < 0 || ny >= M) continue;
            if (dist[nx][ny] != -1) continue; // 이미 방문
            if (grid[nx][ny] == '#') continue; // 벽

            dist[nx][ny] = dist[x][y] + 1;
            q.push({nx, ny});
        }
    }
    return dist[N-1][M-1]; // 도착지 거리
}
```

---

## 15. 그래프 기본 세팅

### 15.1 인접 리스트

```cpp
int N, M; // 정점 수, 간선 수
vector<vector<int>> adj(N + 1);       // 비가중 그래프
vector<vector<pair<int,int>>> adj(N + 1); // 가중 그래프 {다음정점, 가중치}

// 입력
for (int i = 0; i < M; i++) {
    int u, v, w;
    cin >> u >> v >> w;
    adj[u].push_back({v, w});
    adj[v].push_back({u, w}); // 양방향이면
}
```

### 15.2 DFS 템플릿

```cpp
vector<bool> visited(N + 1, false);

void dfs(int cur) {
    visited[cur] = true;
    for (int next : adj[cur]) {
        if (!visited[next]) {
            dfs(next);
        }
    }
}
```

### 15.3 Union-Find (서로소 집합)

```cpp
int parent[100001];

int find(int x) {
    if (parent[x] != x) parent[x] = find(parent[x]); // 경로 압축
    return parent[x];
}

void unite(int a, int b) {
    a = find(a);
    b = find(b);
    if (a != b) parent[a] = b;
}

// 초기화
for (int i = 1; i <= N; i++) parent[i] = i;
```

---

## 16. 자주 쓰는 테크닉 모음

### 16.1 좌표 압축

```cpp
vector<int> v = {100, 3, 50, 3, 200};
vector<int> sorted_v = v;
sort(sorted_v.begin(), sorted_v.end());
sorted_v.erase(unique(sorted_v.begin(), sorted_v.end()), sorted_v.end());

for (int& x : v) {
    x = lower_bound(sorted_v.begin(), sorted_v.end(), x) - sorted_v.begin();
}
// v: {2, 0, 1, 0, 3}
```

### 16.2 누적합 (Prefix Sum)

```cpp
// 1차원
vector<int> prefix(n + 1, 0);
for (int i = 0; i < n; i++) {
    prefix[i + 1] = prefix[i] + arr[i];
}
// 구간 [l, r] 합 = prefix[r+1] - prefix[l]

// 2차원
vector<vector<int>> psum(N+1, vector<int>(M+1, 0));
for (int i = 1; i <= N; i++)
    for (int j = 1; j <= M; j++)
        psum[i][j] = grid[i][j] + psum[i-1][j] + psum[i][j-1] - psum[i-1][j-1];

// (r1,c1) ~ (r2,c2) 합
int sum = psum[r2][c2] - psum[r1-1][c2] - psum[r2][c1-1] + psum[r1-1][c1-1];
```

### 16.3 투 포인터

```cpp
int left = 0, right = 0;
int sum = 0;

while (right < n) {
    sum += arr[right];
    while (sum > target) {
        sum -= arr[left];
        left++;
    }
    if (sum == target) {
        // 조건 충족
    }
    right++;
}
```

### 16.4 슬라이딩 윈도우

```cpp
// 고정 크기 K의 윈도우
int windowSum = 0;
for (int i = 0; i < K; i++) windowSum += arr[i]; // 초기 윈도우

int maxSum = windowSum;
for (int i = K; i < n; i++) {
    windowSum += arr[i] - arr[i - K]; // 하나 추가, 하나 제거
    maxSum = max(maxSum, windowSum);
}
```

---

## 17. 기타 알아두면 좋은 것들

### 17.1 INF 값 설정

```cpp
const int INF = 0x3f3f3f3f;           // 약 10⁹, 더해도 오버플로우 안 남
const long long LINF = 0x3f3f3f3f3f3f3f3fLL;

// memset으로 배열 전체를 INF로 초기화 가능
int dist[1001];
memset(dist, 0x3f, sizeof(dist)); // 모든 원소가 0x3f3f3f3f가 됨
```

### 17.2 전역 변수 vs 지역 변수

```cpp
// 전역: 자동으로 0 초기화 (큰 배열에 유용)
int arr[1000001]; // 전역이면 0으로 초기화됨

// 지역: 초기화 안 됨 → 쓰레기값 주의!
int main() {
    int local_arr[100]; // 초기화 안 됨!
    memset(local_arr, 0, sizeof(local_arr)); // 직접 해야 함
}
```

### 17.3 `#define` 매크로 (취향/대회용)

```cpp
#define ll long long
#define pii pair<int,int>
#define pb push_back
#define all(v) v.begin(), v.end()
#define rep(i, n) for(int i = 0; i < n; i++)

// 사용
sort(all(v));
rep(i, n) cin >> arr[i];
```

### 17.4 디버깅 팁

```cpp
// 조건부 디버깅 출력 (제출 시 주석 처리)
#ifdef DEBUG
#define debug(x) cerr << #x << " = " << x << "\n"
#else
#define debug(x)
#endif

// 컴파일: g++ -DDEBUG solution.cpp
// 제출 시엔 -DDEBUG 빼면 debug() 출력 자동 무시
```

### 17.5 자주 하는 실수 체크리스트

- [ ] `int` 오버플로우 → `long long` 필요한지 확인
- [ ] 배열/벡터 인덱스 0-based vs 1-based 혼동
- [ ] `v.size() - 1` unsigned 언더플로우
- [ ] `cin >>` 후 `getline()` 시 `cin.ignore()` 누락
- [ ] `sort` 안 하고 `lower_bound` / `binary_search` 사용
- [ ] `priority_queue` 기본이 최대 힙인 것 잊기
- [ ] `map[]` 접근 시 키 자동 생성
- [ ] `multiset.erase(값)` → 해당 값 전부 삭제됨
- [ ] BFS에서 큐에 넣을 때 방문 표시 (꺼낼 때 하면 중복 삽입)
- [ ] 재귀 DFS 깊이 제한 (스택 오버플로우) → 반복문 DFS 고려

---

## 부록: 컴파일 & 실행 (Windows 기준)

```bash
# MinGW g++ 사용 시
g++ -std=c++17 -O2 -o solution solution.cpp
./solution < input.txt

# 매크로 포함 디버그 빌드
g++ -std=c++17 -O2 -DDEBUG -o solution solution.cpp
```

> **Tip**: 대부분의 온라인 저지(백준, 프로그래머스)는 C++17을 지원합니다.
> `bits/stdc++.h`는 GCC 전용이지만 대회/코딩테스트에서는 사실상 표준처럼 사용됩니다.
