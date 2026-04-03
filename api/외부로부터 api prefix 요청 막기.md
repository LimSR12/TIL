---
summary: 외부로부터 /api/ prefix 요청 막는 방법 - 클로드에게 물어보기
status: publish
---

# 질문

Next 에서 사용자가 브라우저 주소창에 /api/ 로 접속을 시도하면 막는 방법이 있겠으나, 이렇게 하면 postman 이나 curl 등을 통해 직접 http 요청을 날릴 경우를 막을 수 없을거야.

그런데 지금 프로젝트 구조를 보면, 사용자가 브라우저에 요청을 보내면 Nginx 가 Next 서버로 프록시하고, Next 서버는 http://backend:3000 혹은 http://127.0.0.1:3000 으로 요청을 보내고 있잖아. 여기서 두 방식이 어떤 차이가 있는지 궁금해.
그리고 Next 에서 클라이언트 컴포넌트와 서버컴포넌트에서 API 호출 방식이 달라야만 하는지, 통일해버리면 안되는지 궁금해.
통일 가능하다면 외부에서 들어오는 요청과 동일하게 nginx 를 거쳐서 프록시되는게 아니라 내부 통신하도록 하면, 외부로부터 들어오는 /api/ 요청을 전부 deny all 해버리더라도 내부에서의 /api/ 는 여전히 정상 동작 가능하지 않을까 싶어서 말이야

# 클로드 답변

### `http://backend:3000` vs `http://127.0.0.1:3000`

두 개는 완전히 달라요.

`http://backend:3000`은 Docker 내부 DNS를 통해 `boostus_backend` 컨테이너로 직접 통신해요. nginx를 전혀 거치지 않아요.

`http://127.0.0.1:3000`은 루프백 주소라서 **자기 자신(Next 컨테이너)의 3000포트**를 가리켜요. Next가 3000번에서 안 뜨고 있으면 연결 실패하고, 설령 포트가 맞더라도 backend가 아니라 자기 자신에게 요청하는 거라 잘못된 설정이에요.

---

## 클라이언트/서버 컴포넌트 API 호출을 통일할 수 있냐

기술적으로는 **서버 컴포넌트 기준으로 통일 가능**해요.

현재 상황이 이렇게 섞여 있는 이유는 클라이언트 컴포넌트는 브라우저에서 실행되니까 `http://backend:3000` 같은 내부 주소를 쓸 수 없기 때문이에요. 브라우저 입장에서 `backend`라는 호스트명은 존재하지 않아요.

```
클라이언트 컴포넌트 (브라우저에서 실행)
→ fetch('/api/xxx')                      ✅ 브라우저가 boostus.site/api/xxx 호출
→ fetch('http://backend:3000/api/xxx')   ❌ 브라우저는 backend 호스트 모름

서버 컴포넌트 (Next 서버에서 실행)
→ fetch('http://backend:3000/api/xxx')   ✅ Docker 내부 통신
→ fetch('/api/xxx')                      ❌ 상대경로는 서버에선 base URL 필요
```

그래서 완전 통일은 안 되고, **실행 환경에 따라 분기**가 필요해요.

---

## 원하는 구조로 만들 수 있냐

가능해요. 클라이언트 컴포넌트의 API 호출을 **Next API Route를 통해 중계**하면 외부에서 `/api/`를 완전히 차단해도 돼요.

```
[현재]
브라우저 → https://boostus.site/api/xxx → nginx → backend   (외부 노출)

[변경 후]
브라우저 → https://boostus.site/next-api/xxx → nginx → Next 서버
                                                          ↓ 내부
                                               http://backend:3000/api/xxx
```

Next에 API Route(`/next-api/`)를 두고, 클라이언트 컴포넌트는 전부 거기로 요청하고, Next API Route가 내부에서 backend로 중계하는 구조예요. 그러면 nginx에서 `/api/`를 `deny all` 해도 서비스가 정상 동작해요.

다만 이 구조는 **모든 API 요청이 Next 서버를 한 번 더 거치는 오버헤드**가 생기고, Next API Route를 새로 만들어야 해서 리팩토링 범위가 꽤 커요.

---

## 현실적인 판단

보안 목적이 Swagger 노출 차단이라면, **Swagger 경로만 `deny all`** 하는 게 비용 대비 효과가 훨씬 커요. API 스펙 노출이 문제지 `/api/` 자체가 외부에 열려 있는 건 일반적인 구조거든요. REST API 서버는 원래 외부에서 호출 가능한 게 정상이고, 인증/인가로 보호하는 게 맞는 방향이에요.

Next API Route 중계 구조는 **BFF(Backend For Frontend) 패턴**이라고 부르는데, 보안보다는 API 조합이나 토큰 은닉 목적으로 쓰는 경우가 많아요. 지금 당장 도입하기보다는 나중에 구조 개선할 때 고려해보는 게 좋을 것 같아요.
