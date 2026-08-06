---
title: "C++ STL 컨테이너 정리"
summary: "vector부터 priority_queue, map, string까지 자주 쓰는 STL 사용법과 주의사항"
status: draft
tag:
  - C++
  - STL
category: "Algorithm"
---

## 빠른 참조 요약표

| 컨테이너         | 용도                                | 핵심 메서드                                | ⚠️ 주의사항                       |
| ---------------- | ----------------------------------- | ------------------------------------------ | --------------------------------- |
| `vector`         | 동적 배열, 거의 모든 곳             | `push_back`, `[]`, `size`, `sort`          | `size()-1` 빈 벡터 시 언더플로우  |
| `queue`          | **BFS**                             | `push`, `front`, `pop`                     | `pop()`은 값 반환 안 함           |
| `stack`          | 괄호 검사, DFS 반복                 | `push`, `top`, `pop`                       | `pop()`은 값 반환 안 함           |
| `deque`          | 양쪽 삽입/삭제, 뱀 문제             | `push_front/back`, `pop_front/back`, `[]`  |                                   |
| `priority_queue` | **다익스트라**, 최대/최소 반복 추출 | `push`, `top`, `pop`                       | 기본 최대힙, 최소힙은 `greater<>` |
| `set`            | 중복 제거 + 자동 정렬               | `insert`, `erase`, `count`, `lower_bound`  |                                   |
| `multiset`       | 중복 허용 정렬                      | `insert`, `erase`, `count`, `find`         | `erase(값)` → 전부 삭제됨!        |
| `map`            | key-value 매핑                      | `[]`, `count`, `find`, `erase`             | `m[key]` 접근만으로 key 자동 생성 |
| `unordered_map`  | 빠른 카운팅/조회                    | `[]`, `count`, `find`                      | 평균 O(1), 최악 O(N)              |
| `string`         | 문자열 처리                         | `substr`, `find`, `+=`, `stoi`/`to_string` | `find` 실패 시 `string::npos`     |

## 1. vector

동적 배열. 코테에서 가장 많이 쓰는 컨테이너.

### 기본 선언 & 초기화

```cpp
vector<int> v;                    // 빈 벡터
vector<int> v(10);                // 크기 10, 모두 0
vector<int> v(10, -1);            // 크기 10, 모두 -1
vector<int> v = {1, 2, 3, 4, 5}; // 초기값 지정
vector<vector<int>> v2d(N, vector<int>(M, 0)); // N×M 2차원, 모두 0
```

### 값 재초기화 (자주 헷갈리는 부분)

```cpp
// 방법 1: assign — 크기와 값을 동시에 재설정
v.assign(10, 0);          // 크기 10, 모두 0으로 재초기화
v.assign(5, -1);          // 크기 5, 모두 -1로 재초기화

// 방법 2: fill — 기존 크기 유지, 값만 바꿈
fill(v.begin(), v.end(), 0);

// 방법 3: clear 후 resize
v.clear();                // 내용 비움 (size → 0)
v.resize(10, 0);          // 다시 크기 10, 값 0

// 방법 4: 아예 새 벡터로 교체
v = vector<int>(10, 0);

// 2차원 벡터 재초기화
v2d.assign(N, vector<int>(M, 0));
```

> **요약**: 단순히 값만 0으로 리셋하고 싶으면 `fill`, 크기까지 바꾸고 싶으면 `assign`.

### 원소 접근 & 수정

```cpp
v[0];              // 첫 번째 원소 (범위 체크 X, 빠름)
v.at(0);           // 첫 번째 원소 (범위 체크 O, 느림 → 코테에선 안 씀)
v.front();         // 첫 번째 원소
v.back();          // 마지막 원소
```

### 삽입 & 삭제

```cpp
v.push_back(10);          // 맨 뒤에 추가     O(1)
v.emplace_back(10);       // push_back과 동일, 약간 더 효율적
v.pop_back();             // 맨 뒤 제거       O(1)

// 특정 위치 삽입/삭제 (느림, O(N))
v.insert(v.begin() + 2, 99);       // index 2 위치에 99 삽입
v.erase(v.begin() + 2);            // index 2 삭제
v.erase(v.begin() + 1, v.begin() + 4); // index 1~3 구간 삭제
```

### 크기 관련

```cpp
v.size();          // 원소 개수 (반환형: size_t = unsigned)
v.empty();         // 비었는지 여부 (true/false)
v.resize(20);      // 크기를 20으로 변경 (새로 생긴 칸은 0)
v.resize(20, -1);  // 크기를 20으로, 새 칸은 -1로
v.clear();         // 모든 원소 제거 (size → 0, 메모리는 유지)
```

> **주의**: `v.size()`는 unsigned이므로 `v.size() - 1` 이 벡터가 비어있을 때 **언더플로우** 발생.
> 안전하게 쓰려면 `(int)v.size() - 1` 로 캐스팅.

### 정렬 & 탐색

```cpp
sort(v.begin(), v.end());                  // 오름차순
sort(v.begin(), v.end(), greater<int>());   // 내림차순
reverse(v.begin(), v.end());               // 뒤집기

// 중복 제거 (정렬 후 사용)
sort(v.begin(), v.end());
v.erase(unique(v.begin(), v.end()), v.end());

// 이분 탐색 (정렬된 상태에서)
binary_search(v.begin(), v.end(), x);       // x 존재 여부 (bool)
lower_bound(v.begin(), v.end(), x);         // x 이상인 첫 iterator
upper_bound(v.begin(), v.end(), x);         // x 초과인 첫 iterator

// lower_bound로 인덱스 구하기
int idx = lower_bound(v.begin(), v.end(), x) - v.begin();
```

### 기타 유용한 연산

```cpp
// 최대/최소
*max_element(v.begin(), v.end());
*min_element(v.begin(), v.end());

// 합계
accumulate(v.begin(), v.end(), 0);     // 초기값 0에서 전체 합
accumulate(v.begin(), v.end(), 0LL);   // long long 합계

// 벡터 복사
vector<int> copied = v;                // 깊은 복사
vector<int> copied(v.begin(), v.begin() + 5); // 앞 5개만 복사
```

---

## 2. pair & tuple

### pair

```cpp
pair<int, int> p = {3, 5};     // 선언
p.first;                       // 3
p.second;                      // 5
make_pair(3, 5);               // 생성 (C++11 이전 스타일)

// pair의 비교: first 먼저, 같으면 second 비교 (자동)
// → 정렬 시 first 기준 오름차순, 동률이면 second 기준 오름차순
vector<pair<int,int>> vp = {{3,1}, {1,5}, {3,0}};
sort(vp.begin(), vp.end());
// 결과: {1,5}, {3,0}, {3,1}

// 구조적 바인딩 (C++17) — 가독성 좋음
auto [x, y] = p;              // x=3, y=5
for (auto& [a, b] : vp) {
    cout << a << " " << b << '\n';
}
```

### tuple (3개 이상 묶을 때)

```cpp
tuple<int, int, int> t = {1, 2, 3};
auto [a, b, c] = t;           // C++17 구조적 바인딩
get<0>(t);                    // 1 (C++17 이전 방식)

// BFS에서 좌표+거리 묶기
queue<tuple<int,int,int>> q;
q.push({x, y, dist});
auto [cx, cy, cd] = q.front(); q.pop();
```

> **팁**: pair로 부족할 때 tuple 대신 `struct`를 쓰면 가독성이 훨씬 좋음.

---

## 3. queue

FIFO(선입선출). **BFS의 핵심 자료구조**.

```cpp
queue<int> q;

q.push(10);       // 뒤에 삽입
q.front();        // 맨 앞 원소 확인 (제거 X)
q.back();         // 맨 뒤 원소 확인
q.pop();          // 맨 앞 원소 제거 (반환 X!)
q.size();         // 크기
q.empty();        // 비었는지
```

> **주의**: `q.pop()`은 값을 반환하지 않음. 반드시 `q.front()`로 먼저 값을 꺼낸 뒤 `q.pop()`.

```cpp
// BFS 전형적인 패턴
queue<pair<int,int>> q;
q.push({sr, sc});

while (!q.empty()) {
    auto [r, c] = q.front();  // 값 확인
    q.pop();                   // 제거
    // ... 처리
}
```

### 큐 초기화 (재사용 시)

```cpp
// 방법 1: 빈 큐로 교체
q = queue<int>();

// 방법 2: 하나씩 pop (비효율)
while (!q.empty()) q.pop();
```

---

## 4. deque (덱)

양쪽 끝에서 삽입/삭제 가능. 뱀 문제, 슬라이딩 윈도우 등에 사용.

```cpp
deque<int> dq;

dq.push_front(1);    // 앞에 삽입
dq.push_back(2);     // 뒤에 삽입
dq.pop_front();      // 앞에서 제거
dq.pop_back();       // 뒤에서 제거
dq.front();          // 앞 원소
dq.back();           // 뒤 원소
dq[i];               // 인덱스 접근 가능 (queue는 불가)
```

---

## 5. stack

LIFO(후입선출). 괄호 검사, DFS 반복문 구현 등.

```cpp
stack<int> st;

st.push(10);       // 맨 위에 삽입
st.top();          // 맨 위 원소 확인 (제거 X)
st.pop();          // 맨 위 원소 제거 (반환 X!)
st.size();
st.empty();
```

---

## 6. priority_queue (우선순위 큐 / 힙)

### 최대힙 (기본)

```cpp
priority_queue<int> pq;
pq.push(3); pq.push(1); pq.push(5);
pq.top();    // 5 (가장 큰 값)
pq.pop();    // 5 제거
```

### 최소힙 (다익스트라 등에 사용)

```cpp
priority_queue<int, vector<int>, greater<int>> pq;
pq.push(3); pq.push(1); pq.push(5);
pq.top();    // 1 (가장 작은 값)
```

### pair와 함께 (다익스트라 패턴)

```cpp
// pair의 first 기준으로 정렬됨
// 최소힙: 비용이 작은 것부터
priority_queue<pair<int,int>, vector<pair<int,int>>, greater<pair<int,int>>> pq;
pq.push({cost, node});

auto [c, n] = pq.top(); pq.pop();
```

### 커스텀 비교 (구조체)

```cpp
struct Data {
    int cost, x, y;
};

// 비교 함수 객체
struct Compare {
    bool operator()(const Data& a, const Data& b) {
        return a.cost > b.cost; // cost 작은 게 top (최소힙)
    }
};

priority_queue<Data, vector<Data>, Compare> pq;
```

### 우선순위 큐 초기화

```cpp
pq = priority_queue<int>();  // 빈 큐로 교체
// while (!pq.empty()) pq.pop(); 도 가능하지만 느림
```

---

## 7. set & multiset

자동 정렬 + 중복 제거(set) 또는 중복 허용(multiset). 내부적으로 레드-블랙 트리.

```cpp
set<int> s;

s.insert(3);          // 삽입 O(log N)
s.insert(1);
s.insert(3);          // 중복이므로 무시됨
// s = {1, 3}

s.erase(3);           // 값으로 삭제
s.erase(s.begin());   // iterator로 삭제

s.count(3);           // 존재하면 1, 없으면 0
s.find(3);            // iterator 반환, 없으면 s.end()

// 순회 (자동 오름차순)
for (int x : s) cout << x << ' ';

// 최솟값, 최댓값
*s.begin();           // 최솟값
*s.rbegin();          // 최댓값 (또는 *prev(s.end()))

// lower_bound, upper_bound 사용 가능
auto it = s.lower_bound(5);  // 5 이상인 첫 원소
```

### multiset (중복 허용)

```cpp
multiset<int> ms;
ms.insert(3); ms.insert(3); ms.insert(1);
// ms = {1, 3, 3}

ms.count(3);          // 2
ms.erase(3);          // 값이 3인 원소 "전부" 삭제!
ms.erase(ms.find(3)); // 값이 3인 원소 "하나만" 삭제
```

> **multiset 주의**: `erase(값)`은 해당 값 전부 삭제, `erase(iterator)`는 하나만 삭제.

---

## 8. map & unordered_map

key-value 쌍 저장.

### map (자동 정렬, O(log N))

```cpp
map<string, int> m;

m["apple"] = 3;            // 삽입 또는 수정
m["banana"] = 5;
m["apple"] = 10;           // 수정

m.count("apple");          // 존재하면 1, 없으면 0
m.find("apple");           // iterator 반환
m.erase("apple");          // 삭제

// 순회 (key 기준 오름차순)
for (auto& [key, val] : m) {
    cout << key << ": " << val << '\n';
}

// 없는 key에 [] 접근하면 자동으로 0(int) 또는 ""(string)이 생김!
cout << m["cherry"];       // 0 출력 + "cherry" 키가 자동 삽입됨
// → 존재 여부 확인은 반드시 count() 또는 find() 사용
```

> **주의**: `m[key]`로 접근만 해도 해당 키가 없으면 **자동 생성**됨.
> 존재 확인 시 반드시 `m.count(key)` 또는 `m.find(key) != m.end()` 사용.

### unordered_map (해시, 평균 O(1))

```cpp
unordered_map<int, int> um;

// 사용법은 map과 동일
um[1] = 100;
um.count(1);
um.erase(1);

// 정렬이 필요 없고 빠른 조회가 필요할 때 사용
// 카운팅에 자주 활용
for (int x : arr) um[x]++;  // 각 값의 등장 횟수
```

**map vs unordered_map:**

|           | map                | unordered_map        |
| --------- | ------------------ | -------------------- |
| 내부 구조 | 레드-블랙 트리     | 해시 테이블          |
| 삽입/조회 | O(log N)           | 평균 O(1), 최악 O(N) |
| key 정렬  | 자동 정렬됨        | 정렬 안 됨           |
| 용도      | key 순서 필요할 때 | 빠른 조회/카운팅     |

---

## 9. string (문자열)

### 기본 조작

```cpp
string s = "hello";

s.length();           // 5 (size()와 동일)
s.empty();            // false
s[0];                 // 'h'
s.back();             // 'o'

s += " world";        // 이어붙이기: "hello world"
s.append("!!!");      // 이어붙이기: "hello world!!!"

s.substr(0, 5);       // "hello" (시작위치, 길이)
s.substr(6);          // "world!!!" (시작위치부터 끝까지)
```

### 검색 & 치환

```cpp
s.find("world");      // 6 (시작 인덱스 반환)
s.find("xyz");        // string::npos (못 찾음)

// 찾았는지 확인
if (s.find("world") != string::npos) {
    // 찾음
}

// 치환 (find + replace 조합)
size_t pos = s.find("world");
if (pos != string::npos) {
    s.replace(pos, 5, "earth"); // pos부터 5글자를 "earth"로
}
```

### 문자열 ↔ 숫자 변환

```cpp
// 문자열 → 숫자
int n = stoi("123");           // string to int
long long ll = stoll("99999999999");
double d = stod("3.14");

// 숫자 → 문자열
string s = to_string(123);    // "123"
string s = to_string(3.14);   // "3.140000"
```

### 문자 단위 조작

```cpp
// 문자 판별
isdigit(c);    // 숫자인가
isalpha(c);    // 알파벳인가
isupper(c);    // 대문자인가
islower(c);    // 소문자인가

// 문자 변환
toupper(c);    // 대문자로
tolower(c);    // 소문자로

// 문자 → 숫자
int digit = c - '0';      // '3' → 3
int alpha = c - 'a';      // 'c' → 2 (0-indexed)

// 숫자 → 문자
char ch = digit + '0';    // 3 → '3'
char ch = alpha + 'a';    // 2 → 'c'
```

### 문자열 정렬 & 비교

```cpp
// 사전순 비교 (==, <, > 모두 사용 가능)
if (s1 < s2) { /* s1이 사전순으로 앞 */ }

// 문자열 정렬
sort(s.begin(), s.end());          // 문자 단위 정렬
reverse(s.begin(), s.end());       // 뒤집기

// 문자열 벡터 정렬 (사전순)
vector<string> vs = {"banana", "apple", "cherry"};
sort(vs.begin(), vs.end());
```

### 문자열 파싱 (공백/구분자 기준)

```cpp
// 공백 기준 파싱: stringstream
string line = "hello world 123";
stringstream ss(line);
string word;
while (ss >> word) {
    cout << word << '\n';  // hello, world, 123 각각 출력
}

// 특정 구분자 기준: getline
string csv = "a,b,c,d";
stringstream ss2(csv);
string token;
while (getline(ss2, token, ',')) {
    cout << token << '\n'; // a, b, c, d
}

// 한 줄 전체 입력 (공백 포함)
getline(cin, s);  // 주의: cin >> 뒤에 쓰면 개행 남아있으므로
                  // cin.ignore(); 먼저 호출 필요
```

---

## 10. 자주 쓰는 STL 알고리즘 함수

```cpp
#include <algorithm>  // bits/stdc++.h에 포함됨

// 정렬
sort(v.begin(), v.end());
stable_sort(v.begin(), v.end()); // 동일 값 순서 유지

// 뒤집기
reverse(v.begin(), v.end());

// 최대/최소
*max_element(v.begin(), v.end());
*min_element(v.begin(), v.end());
max({a, b, c});     // 3개 이상 비교
min({a, b, c});

// 순열
next_permutation(v.begin(), v.end());  // 다음 순열, 마지막이면 false
prev_permutation(v.begin(), v.end());

// 개수 세기
count(v.begin(), v.end(), target);

// 채우기
fill(v.begin(), v.end(), 0);
fill(arr, arr + n, -1);     // C 배열에도 사용 가능

// swap
swap(a, b);                  // 두 변수 교환
swap(v[i], v[j]);            // 벡터 원소 교환

// abs (절댓값)
abs(-5);       // 5 (int)
abs(-3.14);    // 3.14 (double)
```

---
