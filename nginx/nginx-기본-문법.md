# Nginx 문법

Nginx 설정파일은 Directive 와 Context 로 구성된 블록 기반 문법을 사용한다고 한다.

> “무엇을 설정할지(Directive)”와 “어디에 적용할지(Context)”를 중괄호 `{}`로 구분하는 구조
> 

## 기본 문법 구조

```nix
directive_name  value;  # 세미콜론 필수
```

- **directive_name** : 설정 항목 이름 (ex. `listen`, `server_name`, `root`)
- **value** : 설정 값

## 주요 문법 규칙 정리

- **세미콜론 필수**
    
    ```
    listen 80;
    ```
    
- **중괄호 `{}` 로 블록 열고 닫기**
    
    ```
    http {
        server {
            ...
        }
    }
    ```
    
- **주석은 `#` 으로 시작**
    
    ```
    # 이것은 주석입니다.
    ```
    
- **중첩 가능**
    - `http` 안에 `server`
    - `server` 안에 `location`
    - 이런 식으로 **계층적으로 중첩 가능**
- **변수 사용 가능 (`$변수명`)**
    
    ```
    location /user/ {
        rewrite ^/user/(.*)$ /profile/$1 break;
    }
    ```
    
- **와일드카드 및 정규식 사용 가능**
    - `location /images/` → 단순 경로 매칭
    - `location ~ \.php$` → 정규식 매칭

## 블록 구조 예시

```
http {
    server {
        listen 80;
        server_name example.com;

        location / {
            root /var/www/html;
            index index.html;
        }

        location /api/ {
            proxy_pass http://127.0.0.1:3000/;
        }
    }
}
```

여기서 `server {}` 가 하나의 **컨텍스트**, `location / {}` 가 하나의 **컨텍스트**, … 이고

각각의 **컨텍스트** 는 위와 같이 계층 구조로 구성된다!

| 컨텍스트 | 설명 |
| --- | --- |
| **http** | HTTP 서버 전체에 적용되는 설정 |
| **server** | 특정 도메인/가상호스트 단위 설정 |
| **location** | URL 경로별 세부 설정 |
| **main** | 전역 설정 (`user`, `worker_processes` 등) |
| **events** | 커넥션/요청 처리 관련 설정 (worker connection 등) |

# 기본적인 HTTP 서버 구조 뜯어보기

```nix
http {                 # HTTP 컨텍스트
    server {           # 서버 컨텍스트
        listen 80;                     # 수신할 포트
        server_name example.com;       # 도메인 이름

        location / {                   # 루트 경로 (정적 파일 처리)
            root /var/www/html;
            index index.html;
        }

        location /api/ {               # /api/ 경로 (프록시 처리)
            proxy_pass http://127.0.0.1:3000/;
        }
    }
}
```

## http 컨텍스트 (`http { ... }`)

**역할**

- **HTTP 프로토콜 전체에 적용되는 전역 설정 범위**
- Nginx가 웹 서버로 동작할 때, 여기에 포함된 **모든 `server` 블록**이 HTTP 요청을 처리하게 됨

**포함 가능한 주요 directive**

| directive | 설명 |
| --- | --- |
| `include` | 다른 설정 파일 불러오기 (`include /etc/nginx/conf.d/*.conf;`) |
| `server` | 하나의 가상 호스트(도메인/포트) 정의 블록 |
| `log_format` | 로그 형식 정의 |
| `sendfile`, `keepalive_timeout` 등 | HTTP 전송 관련 설정 |

즉, `http`는 **“모든 웹 서버 설정의 상위 컨텍스트”** 다!

## server 컨텍스트 (`server { ... }`)

**역할**

- 하나의 **가상 호스트(Virtual Host)**를 정의함.
- 즉, 특정 **도메인/포트 조합**으로 접근한 요청을 처리할 블록.

**구성 요소**

- **`listen 80;`**
    - 서버가 **수신할 포트 번호**를 지정.
    - `80`은 HTTP 기본 포트 (HTTPS는 `443`).
    - 예시
        - `listen 80;` → 모든 IP의 80포트 요청 수신
        - `listen 127.0.0.1:8080;` → 로컬호스트 8080포트만 수신
        - `listen [::]:80;` → IPv6용 설정
- **`server_name example.com;`**
    - 어떤 **도메인 이름**으로 접근했을 때 이 서버 블록이 반응할지 지정.
    - 예시:
        - `server_name example.com www.example.com;`
        - `server_name _;` → 기본 서버 (catch-all)

요청이 들어오면 Nginx는 요청의 `Host` 헤더를 보고, `server_name`과 일치하는 `server` 블록을 선택함 !

## location 컨텍스트 (`location { ... }`)

**역할**

- `server` 블록 안에서 **특정 URL 경로별 동작을 정의**함.
- 즉, 요청된 **URI 패턴에 따라 서로 다른 처리를 하도록 구분**함.

**1. `location / { ... }`**  → 기본 루트 경로

```
location / {
    root /var/www/html;
    index index.html;
}
```

**역할**

- `/`로 시작하는 모든 요청 (즉, `/api/` 등 특정 하위 경로 제외 나머지)에 적용됨
- **정적 파일 제공용 블록**

**주요 directive**

| directive | 설명 |
| --- | --- |
| `root /var/www/html;` | 요청된 파일을 찾을 **기본 디렉토리 경로** 지정. → 예: `/about.html` 요청 → 실제 `/var/www/html/about.html` |
| `index index.html;` | 디렉토리 요청 시 기본 파일로 `index.html` 제공. → `/` 요청 → `/var/www/html/index.html` 반환 |

**정리하면 `location / { … }` 컨텍스트는 정적 파일이 있는 폴더 경로를 지정**하고, index.html를 자동으로 열어주는 역할을 함.

**2. `location /api/ { ... }`** → API 프록시 경로

```
location /api/ {
    proxy_pass http://127.0.0.1:3000/;
}
```

**역할**

- `/api/`로 시작하는 요청은 로컬의 백엔드 서버로 **프록시** 시킴
- **Nginx는 프론트엔드와 백엔드 사이의 게이트웨이 역할**을 하게 된다!

**주요 directive**

| directive | 설명 |
| --- | --- |
| `proxy_pass http://127.0.0.1:3000/;` | 요청을 내부 서버(보통 Node.js, NestJS, Spring 등)로 전달. 요청 헤더, 본문 등을 그대로 넘겨줌. |
| `proxy_set_header Host $host;` | 원래의 Host 헤더를 전달하도록 설정 |
| `proxy_set_header X-Real-IP $remote_addr;` | 클라이언트의 실제 IP 전달 |

따라서 사용자가 브라우저에서 **`http://example.com/api/users`** 를 요청하면

→ Nginx가 이 요청을 **`http://127.0.0.1:3000/api/users`** 로 전달함.