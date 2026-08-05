---
title: "Nginx 설정 파일 구조 알아보기"
summary: "제대로 짚고 넘어가지 않으니 너무 헷갈려서 짚고 넘어가기"
status: publish
tag: []
category: ""
---

# nginx 설정 구조

제대로 짚고 넘어가지 않으니 너무 헷갈려서 짚고 넘어가기

# /etc/nginx/ 전체 구조

```
/etc/nginx/
├── nginx.conf                  ← 메인 설정 (거의 안 건드림)
├── sites-available/            ← 사이트별 설정 파일 보관소
│   ├── default
│   └── api.limsr12.com         ← 승렬님이 만든 파일
├── sites-enabled/              ← 실제로 Nginx가 읽는 곳 (심볼릭 링크)
│   ├── default -> ../sites-available/default
│   └── api.limsr12.com -> ../sites-available/api.limsr12.com
├── conf.d/                     ← 추가 설정 파일 (*.conf 자동 로드)
├── snippets/                   ← 재사용 설정 조각
├── modules-available/          ← 모듈 보관소
├── modules-enabled/            ← 활성화된 모듈 (심볼릭 링크)
├── mime.types                  ← MIME 타입 매핑
├── fastcgi_params              ← FastCGI 파라미터
├── proxy_params                ← 프록시 파라미터
├── scgi_params                 ← SCGI 파라미터
└── uwsgi_params                ← uWSGI 파라미터
```

## 각 파일/디렉토리 역할

### `nginx.conf` -> 메인 설정 파일

nginx 최상위 설정으로, 이 파일이 나머지를 전부 include로 불러오는 구조다

```nginx
# nginx.conf 핵심 구조 (간략화)
http {
    include /etc/nginx/mime.types;
    include /etc/nginx/conf.d/*.conf;          # conf.d 안의 .conf 파일 전부 로드
    include /etc/nginx/sites-enabled/*;        # sites-enabled 안의 파일 전부 로드
}
```

또한 워커 프로세스 수, 로그 경로, gzip 압축 같은 글로벌 설정이 들어있고, 개별 사이트 설정을 여기에 직접 쓰지 않아서 보통 건드릴 일이 거의 없다고 함

### `sites-available/`, `sites-enabled/`

`sites-available/` 은 설정 파일을 보관만 하는 공간이다.
여기에 파일을 만들어도 nginx 는 읽지 않는다!

`sites-enabled/` 는 nginx가 실제로 로드하는 곳이다.
`nginx.conf` 에서 `include /etc/nginx/sites-enabled/*` 와 같이 이 디렉토리를 읽는다!

활성화/비활성화 흐름은 다음과 같다고 한다.

```nginx
# 활성화: sites-available → sites-enabled로 심볼릭 링크 생성
sudo ln -s /etc/nginx/sites-available/api.limsr12.com /etc/nginx/sites-enabled/

# 비활성화: 링크만 삭제 (원본은 보존)
sudo rm /etc/nginx/sites-enabled/api.limsr12.com

# 설정 수정은 항상 sites-available의 원본 파일에서
sudo nano /etc/nginx/sites-available/api.limsr12.com
```

> sites-available/ 에 파일을 만들고 sites-enabled/ 로 심볼릭 링크를 걸어줘서 nginx가 읽을 수 있는 것!

### `conf.d/`

`nginx.conf` 에서 `include /etc/nginx/conf.d/*.conf` 로 이 디렉토리도 읽는다!
`conf.d` 에 .conf 확장자로 파일을 넣으면 알아서 로드된다. 심볼릭 링크같은 별도 작업이 필요 없다.

> 왜 방식이 두가지인건가?

`sites-available/` + `sites-enabled/` 는 Debian/Ubuntu의 관례이고, `conf.d/` 는 RedHat/CentOS 계열과 Docker 공식 Nginx 이미지의 관례라고 한다!

| 방식                                  | 활성화/비활성화       | 주로 사용하는 환경                |
| ------------------------------------- | --------------------- | --------------------------------- |
| `sites-available/` + `sites-enabled/` | 심볼릭 링크 생성/삭제 | Ubuntu 서버 직접 설치             |
| `conf.d/`                             | 파일 추가/삭제        | Docker, CentOS, 공식 Nginx 이미지 |

그래서 클로드나 GPT가 Docker 설정을 nginx/conf.d/ 에 넣으라고 한 이유가 이거였다!
Docker 의 nginx:alpine 이미지는 sites-available/ 구조가 없고 conf.d/만 사용한다.

### `snippets/`

여러 사이트에서 공통으로 쓰는 설정 조각을 모아두는 곳이다.

예를 들어 SSL 공통 설정, 보안 헤더 같은 것들을 넣어두고 include 로 가져다 쓸 수 있다.

```nginx
# /etc/nginx/snippets/ssl-params.conf (예시)
ssl_protocols TLSv1.2 TLSv1.3;
ssl_ciphers HIGH:!aNULL:!MD5;

# 사이트 설정에서 가져다 쓰기
server {
    include snippets/ssl-params.conf;
}
```

### 나머지 기타 파일들

`mime.types`는 파일 확장자별 Content-Type 매핑이고(.html → text/html 등), `fastcgi_params`, `proxy_params`, `scgi_params`, `uwsgi_params는` 각 프록시 방식에서 공통으로 전달하는 헤더/파라미터 기본값이라고 한다.
이 파일들은 직접 수정할 일이 거의 없다!

# 그래서 정리! 언제 어디를 수정하면 되는가

| 상황                                | 수정할 곳                                            |
| ----------------------------------- | ---------------------------------------------------- |
| 새 사이트/도메인 추가 (Ubuntu 서버) | sites-available/에 파일 생성 → sites-enabled/로 링크 |
| 새 사이트/도메인 추가 (Docker)      | conf.d/에 .conf 파일 추가                            |
| 기존 사이트 설정 변경               | sites-available/의 원본 파일 수정                    |
| 사이트 일시 비활성화                | sites-enabled/의 심볼릭 링크 삭제                    |
| 워커 수, 로그 경로 등 글로벌 설정   | nginx.conf                                           |
| 여러 사이트 공통 설정               | snippets/에 작성 후 include                          |
