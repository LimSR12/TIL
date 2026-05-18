---
title: "C++ 코딩테스트 정리노트 2편"
summary: "구현 방법 레퍼런스"
status: publish
tag:
  - C++
category: "Algorithm"
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

## 13. 2차원 배열 & 방향 탐색 (BFS/DFS 필수)

### 13.1 방향 배열

```cpp
// 4방향
int dr[] = {-1, 1, 0, 0}; // 상, 하, 좌, 우
int dc[] = {0, 0, -1, 1};

// 8방향
int dr[] = {-1, -1, -1, 0, 0, 1, 1, 1};
int dc[] = {-1, 0, 1, -1, 1, -1, 0, 1};

// 범위 체크
for (int i = 0; i < 4; i++) {
    int nr = r + dr[i];
    int nc = c + dc[i];
    if (nr < 0 || nr >= N || nc < 0 || nc >= M) continue;
    if (visited[nr][nc]) continue;
    // 처리
}
```

### 13.2 BFS 템플릿

```cpp
#include <vector>
#include <queue>

int bfs(int sr, int sc) {
    queue<pair<int,int>> q;
    vector<vector<int>> dist(N, vector<int>(M, -1));

    q.push({sr, sc});
    dist[sr][sc] = 0; // 큐에 넣으면서 dist 변경!

    while (!q.empty()) {
        auto [r, c] = q.front();
        q.pop();

        for (int i = 0; i < 4; i++) {
            int nr = r + dr[i];
            int nc = c + dc[i];

            if (nr < 0 || nr >= N || nc < 0 || nc >= M) continue;
            if (dist[nr][nc] != -1) continue; // 이미 방문
            if (grid[nr][nc] == '#') continue; // 벽

            dist[nr][nc] = dist[r][c] + 1;
            q.push({nr, nc});
        }
    }
    return dist[N-1][M-1]; // 도착지 거리
}
```

### 13.3 DFS 템플릿

#### (1) 격자 DFS — 재귀형

가장 흔하게 많이 사용되는 형식이다. 2차원 맵이 주어졌을 때!

```cpp
#include

int N, M;
vector<vector> grid;
vector<vector> visited;

int dr[] = {-1, 1, 0, 0};
int dc[] = {0, 0, -1, 1};

void dfs(int r, int c) {
    visited[r][c] = true; // 진입 즉시 방문 처리

    for (int i = 0; i < 4; i++) {
        int nr = r + dr[i];
        int nc = c + dc[i];

        if (nr < 0 || nr >= N || nc < 0 || nc >= M) continue;
        if (visited[nr][nc]) continue;
        if (grid[nr][nc] == '#') continue; // 벽

        dfs(nr, nc);
    }
}

// 호출 예시: 연결 요소 개수 세기
int countComponents() {
    visited.assign(N, vector(M, false));
    int count = 0;
    for (int r = 0; r < N; r++) {
        for (int c = 0; c < M; c++) {
            if (!visited[r][c] && grid[r][c] != '#') {
                dfs(r, c);
                count++;
            }
        }
    }
    return count;
}
```

#### (2) 격자 DFS — 스택형

동일하게 2차원 맵에서 사용하는데, 재귀의 깊이가 깊어질수록 위험하다.
격자의 크기가 1000 x 1000 인 경우 최악의 경우 100만 깊이까지 재귀가 깊어질 수 있어서, 큰 격자에서는 재귀형 말고 스택형을 사용하는 것이 더 바람직한 경우도 있다.

(실제로 겪은 일...)

```cpp
#include

void dfsIterative(int sr, int sc) {
    stack<pair> st;
    st.push({sr, sc});
    visited[sr][sc] = true;

    while (!st.empty()) {
        auto [r, c] = st.top();
        st.pop();

        for (int i = 0; i < 4; i++) {
            int nr = r + dr[i];
            int nc = c + dc[i];

            if (nr < 0 || nr >= N || nc < 0 || nc >= M) continue;
            if (visited[nr][nc]) continue;
            if (grid[nr][nc] == '#') continue;

            visited[nr][nc] = true; // 스택에 넣을 때 방문 처리
            st.push({nr, nc});
        }
    }
}
```

#### (3) 그래프(인접 리스트) DFS

```cpp
vector<vector> adj; // adj[u] = u와 연결된 노드 리스트
vector visited;

void dfs(int node) {
    visited[node] = true;

    for (int next : adj[node]) {
        if (!visited[next]) {
            dfs(next);
        }
    }
}
```

#### (4) 그래프(인접 행렬) DFS

```cpp
vector<vector> graph; // graph[i][j] == 1 이면 i-j 연결
vector visited;
int N;

void dfs(int node) {
    visited[node] = true;

    for (int next = 0; next < N; next++) {
        if (graph[node][next] == 1 && !visited[next]) {
            dfs(next);
        }
    }
}
```

#### (5) 백트래킹 DFS — 경로 복구 필요 시

```cpp
// 모든 경우 탐색 후 원상복구 (순열, 조합, 미로 경로 탐색 등)
void backtrack(int r, int c) {
    visited[r][c] = true;
    // [선택] 현재 상태 기록

    for (int i = 0; i < 4; i++) {
        int nr = r + dr[i];
        int nc = c + dc[i];

        if (nr < 0 || nr >= N || nc < 0 || nc >= M) continue;
        if (visited[nr][nc]) continue;

        backtrack(nr, nc);
    }

    visited[r][c] = false; // 핵심: 빠져나올 때 방문 해제
    // [선택] 기록한 상태 되돌리기
}
```

#### (6) 상태 기반 DFS — 누적값 추적

````cpp
// 타겟 넘버 류: idx와 누적합을 매개변수로 전달
int answer = 0;

void dfs(vector& nums, int target, int idx, int sum) {
    if (idx == (int)nums.size()) {
        if (sum == target) answer++;
        return;
    }

    dfs(nums, target, idx + 1, sum + nums[idx]);
    dfs(nums, target, idx + 1, sum - nums[idx]);
}
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
````

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

### 13.4 BFS vs DFS 선택 기준

| 상황                         | 추천                                       |
| ---------------------------- | ------------------------------------------ |
| 최단 거리 / 최소 횟수        | **BFS** (가중치 없는 그래프)               |
| 모든 경로 탐색 / 경우의 수   | **DFS**                                    |
| 연결 요소 개수 / 영역 채우기 | **둘 다 가능** (구현 편한 쪽)              |
| 백트래킹 (조합/순열)         | **DFS**                                    |
| 격자 깊이 ≤ N×M ≤ 10,000     | **재귀 DFS 안전**                          |
| 격자 깊이 > 100,000          | **스택 DFS** 또는 BFS (스택 오버플로 위험) |
| 사이클 검출 / 위상 정렬      | **DFS**                                    |

### 13.5 DFS 사용 시 주의사항

1. **방문 처리 시점**
   - 일반 DFS: 함수 진입 직후 `visited[r][c] = true`
   - 백트래킹: 진입 시 `true`, **종료 직전 `false`로 복구**
2. **종료 조건**: 재귀의 base case를 함수 맨 위에 명시
3. **매개변수 vs 전역변수**
   - 누적값(sum, depth, path)은 **매개변수**로 전달 → 자동 복구
   - 정답 카운트는 **전역변수** 또는 참조 전달
4. **재귀 깊이**: N×M이 250,000 이상이면 스택 오버플로 고려 (스택형 또는 BFS로 전환)
5. **방향 벡터**: BFS와 동일하게 `dr[]`, `dc[]` 사용. 4방향/8방향 명확히 구분

## 14. 자주 쓰는 테크닉 모음

### 14.1 좌표 압축

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

### 14.2 누적합 (Prefix Sum)

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

### 14.3 투 포인터

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

### 14.4 슬라이딩 윈도우

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

## 15. 기타 알아두면 좋은 것들

### 15.1 INF 값 설정

```cpp
const int INF = 0x3f3f3f3f;           // 약 10⁹, 더해도 오버플로우 안 남
const long long LINF = 0x3f3f3f3f3f3f3f3fLL;

// memset으로 배열 전체를 INF로 초기화 가능
int dist[1001];
memset(dist, 0x3f, sizeof(dist)); // 모든 원소가 0x3f3f3f3f가 됨
```

### 15.2 전역 변수 vs 지역 변수

```cpp
// 전역: 자동으로 0 초기화 (큰 배열에 유용)
int arr[1000001]; // 전역이면 0으로 초기화됨

// 지역: 초기화 안 됨 → 쓰레기값 주의!
int main() {
    int local_arr[100]; // 초기화 안 됨!
    memset(local_arr, 0, sizeof(local_arr)); // 직접 해야 함
}
```

### 15.5 자주 하는 실수 체크리스트

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
