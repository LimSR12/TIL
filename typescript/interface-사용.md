## 입력 제네릭 주입

```ts
// 1) 스토어에서 사용할 타입 정의
interface StoreState {
  count: number;
  increase: () => void;
}

// 2) 제네릭을 "함수에 주입"하는 예시
function createStore<T>(initializer: () => T): T {
  return initializer(); // 핵심 로직
}

// 3) createStore<T>에 타입을 넣어서 스토어 생성
const store = createStore<StoreState>(() => ({
  count: 0,
  increase() {
    console.log("increase!");
  },
}));

// 사용
store.increase();
```

- createStore<StoreState>는 제네릭 타입을 함수에 주입
- 함수 내부에서 initializer()가 반환하는 객체가 StoreState 타입을 만족해야 함
- 즉, 입력 타입을 제한하는 역할

## 출력 타입 선언

```ts
// 1) API 응답 타입 정의
interface ApiResponse<T> {
  data: T;
  status: number;
}

// 2) 반환 타입을 지정하는 함수
interface User {
  id: number;
  name: string;
}

function fetchUser(): ApiResponse<User> {
  return {
    data: { id: 1, name: "승렬" },
    status: 200, // 핵심 로직
  };
}

// 사용
const result = fetchUser();
console.log(result.data.name);
```

- 함수 선언에서 반환 타입을 명시
- 반환하는 객체가 ApiResponse<User> 타입 구조를 따라야 함
- 즉, 출력 타입을 설명하는 역할
