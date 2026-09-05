---
title: "C++ 코딩테스트 정리노트 2편"
summary: "구현 방법 레퍼런스"
status: publish
tag:
  - C++
category: "Algorithm"
---

## 13. 2차원 배열 & 방향 탐색

### 13.1 방향 배열

```cpp
// 4방향
int dr[] = {-1, 1, 0, 0}; // 상, 하, 좌, 우
int dc[] = {0, 0, -1, 1};

// 8방향
int dr[] = {-1, -1, -1, 0, 0, 1, 1, 1};
int dc[] = {-1, 0, 1, -1, 1, -1, 0, 1};
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

    visited[r][c] = false;
    // [선택] 기록한 상태 되돌리기
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
   - `일반 DFS`: 함수 진입 직후 `visited[r][c] = true`
   - `백트래킹`: 진입 시 `true`로 바꾸고 **종료 직전 `false`로 복구**
2. **종료 조건**: 재귀의 base case를 함수 맨 위에 명시
3. **매개변수 vs 전역변수**
   - 누적값(sum, depth, path)은 **매개변수**로 전달 → 함수 리턴하면서 자동 복구
   - 정답 카운트는 **전역변수** 또는 참조 전달
4. **재귀 깊이**: N×M이 250,000 이상이면 스택 오버플로우 위험! (스택형 또는 BFS로 전환 고려하기)

## 14. 기타 알아두면 좋은 것들

### 14.1 INF 값 설정

```cpp
const int INF = 0x3f3f3f3f;           // 약 10⁹, 더해도 오버플로우 안 남
const long long LINF = 0x3f3f3f3f3f3f3f3fLL;

// memset으로 배열 전체를 INF로 초기화 가능
int dist[1001];
memset(dist, 0x3f, sizeof(dist)); // 모든 원소가 0x3f3f3f3f가 됨
```

### 14.2 전역 변수 vs 지역 변수

```cpp
// 전역: 자동으로 0 초기화 (큰 배열에 유용)
int arr[1000001];

// 지역: 초기화 안 됨 → 쓰레기값 주의!
int main() {
    int local_arr[100];
    memset(local_arr, 0, sizeof(local_arr)); // 직접 해야 함
}
```

### 14.5 자주 하는 실수 체크리스트

- [ ] `int` 오버플로우 → `long long` 필요한지 확인
- [ ] 배열/벡터 인덱스 0-based vs 1-based 혼동
- [ ] `v.size() - 1` unsigned 언더플로우
- [ ] `priority_queue` 기본이 최대 힙
- [ ] `map[]` 접근 시 키 자동 생성
- [ ] BFS에서 큐에 넣을 때 방문 표시 (꺼낼 때 하면 중복 삽입)
- [ ] 재귀 DFS 깊이 제한 (스택 오버플로우) → 반복문 DFS 고려
