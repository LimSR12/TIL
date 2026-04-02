# nginx/nginx.conf 에서 SSL 보안 설정

## 0️⃣ nginx/nginx.conf

```nix
  server {
    listen 443 ssl http2;
    server_name boostus.site www.boostus.site;

    # SSL 인증서 설정
    ssl_certificate /etc/letsencrypt/live/boostus.site/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/boostus.site/privkey.pem;

    # SSL 보안 설정
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;
```

## 1️⃣ SSL 인증서 설정

```nix
ssl_certificate /etc/letsencrypt/live/boostus.site/fullchain.pem;
ssl_certificate_key /etc/letsencrypt/live/boostus.site/privkey.pem;
```

### 역할

- **HTTPS 통신을 위해 서버가 사용하는 공개키 인증서와 개인키를 지정**합니다.
- 브라우저가 `https://boostus.site`에 접속하면:
  1. Nginx가 이 인증서를 브라우저에 전달
  2. 브라우저는 인증서가 **신뢰된 CA(여기서는 Let's Encrypt)** 에 의해 발급되었는지 검증
  3. 검증이 성공하면 TLS 핸드셰이크 진행 → 암호화 통신 시작

### 각 파일의 의미

- `fullchain.pem`
  - **서버 인증서 + 중간 인증서 체인**
  - 브라우저가 “이 서버 인증서가 신뢰 가능한 루트 CA까지 이어지는지” 검증하는 데 필요하다고 합니다
- `privkey.pem`
  - **서버의 개인키**
  - TLS 핸드셰이크 중 세션 키 교환 및 서버 신원 증명에 사용된다고 합니다
  - ⚠️ 외부 유출 시 심각한 보안 사고로 이어짐 → 컨테이너/서버 내부 접근 제한 필수 ⚠️

## 2️⃣ SSL / TLS 프로토콜 제한

```nix
ssl_protocols TLSv1.2 TLSv1.3;
```

### 역할

- **허용할 TLS 버전만 명시적으로 제한**합니다.

### 왜 필요한가?

- TLS 1.0 / 1.1
  - 이미 **취약점이 다수 발견되어 deprecated** 된 상태
  - 최신 브라우저도 기본적으로 거부
- TLS 1.2 / 1.3
  - 현재 실서비스에서 **표준적으로 사용되는 안전한 버전이라고 합니다!**

## 3️⃣ 암호 스위트(Cipher Suite) 설정

```nix
ssl_ciphers HIGH:!aNULL:!MD5;
```

### 역할

- **TLS 통신에 사용할 암호화 알고리즘 조합을 제한**합니다. (라고 하는데 이해는 잘 안되네요 ㅎㅎ;;)

> 이 TLS 연결에서는
>
> 🔑 키 교환은 어떻게 하고
>
> 🔐 암호화는 무엇으로 하고
>
> 🧾 무결성 검증은 어떤 방식으로 할지

### 구성 해석

- `HIGH`
  - 강력한 암호화 수준의 cipher만 허용
- `!aNULL`
  - 인증 없는 cipher 제거
- `!MD5`
  - MD5 해시 기반 cipher 제거 (이미 충돌 공격 가능)

### 왜 중요한가?

- TLS는 “암호화 방식 + 키 교환 + 해시”의 조합으로 동작
- 약한 cipher가 하나라도 허용되면
  → **중간자 공격, 복호화 위험** 발생 가능

## 4️⃣ 서버 우선 암호 선택

```nix
ssl_prefer_server_ciphers on;
```

### 역할

- 클라이언트(브라우저)와 서버가 공통으로 지원하는 cipher가 여러 개일 때 **서버가 정의한 우선순위를 따르도록 강제**

### 왜 켜야 하나?

- 일부 오래된 브라우저는 보안이 약한 cipher를 우선 제안함
- 이 옵션을 켜면:
  - 서버가 **가장 안전한 cipher를 선택**
  - 보안 정책을 서버가 통제 가능
