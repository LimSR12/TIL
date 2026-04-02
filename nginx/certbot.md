# certbot 이 하는 일

```bash
sudo certbot --nginx -d api.limsr12.com
```

위와 같이 certbot 을 실행하면 두가지 일을 한다.

## 1. 인증서 발급 (Let's Encrypt와 통신)

```
Certbot → Let's Encrypt 서버: "api.limsr12.com 인증서 주세요"
Let's Encrypt → Certbot: "이 도메인이 정말 당신 것인지 증명하세요"
Certbot → Nginx의 80포트를 이용해 검증 파일 배치
Let's Encrypt → http://api.limsr12.com/.well-known/acme-challenge/xxxx 로 접속해서 검증
Let's Encrypt → Certbot: "확인됨, 인증서 발급합니다"
```

발급된 인증서는 호스트의 `/etc/letsencrypt/` 에 저장된다.

```
/etc/letsencrypt/
├── live/
│   └── api.limsr12.com/
│       ├── fullchain.pem    ← 인증서 (Nginx의 ssl_certificate)
│       ├── privkey.pem      ← 개인키 (Nginx의 ssl_certificate_key)
│       ├── cert.pem         ← 서버 인증서만
│       └── chain.pem        ← 중간 인증서만
├── renewal/
│   └── api.limsr12.com.conf ← 갱신 설정 (어떤 도메인, 어떤 방식으로 발급했는지)
└── archive/
    └── api.limsr12.com/     ← 인증서 이력 (live/는 여기로의 심볼릭 링크)
```

## 2. nginx 설정 자동 수정 (--nginx 플러그인)

Certbot은 인증서 발급이 완료되면 직접 `/etc/nginx/sites-available/api.limsr12.com` 파일을 열어서 SSL 관련 설정을 자동으로 추가한다.

```
# 이 줄들은 전부 Certbot이 자동 추가한 것
listen 443 ssl;                                                    # managed by Certbot
ssl_certificate /etc/letsencrypt/live/api.limsr12.com/fullchain.pem; # managed by Certbot
ssl_certificate_key /etc/letsencrypt/live/api.limsr12.com/privkey.pem; # managed by Certbot
include /etc/letsencrypt/options-ssl-nginx.conf;                   # managed by Certbot
ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;                     # managed by Certbot
```

# 컨테이너 환경에서는 다르다!

## Certbot 이 Nginx 설정을 수정하지 않는다

컨테이너 환경에서는 `--nginx` 플러그인 대신 `--webroot` 방식을 사용한다.

Certbot 컨테이너 안에는 Nginx가 없기 때문에 설정 파일을 수정할 수가 없다.
그래서 **Nginx 설정은 직접 미리 작성**해두고, Certbot은 **인증서 발급/갱신만** 담당한다!

> docker-compose.yml 이 정의하는 볼륨 공유 방식

```
[프로젝트 디렉토리]
./certbot/conf/    ←──── 볼륨 ────→  Certbot 컨테이너: /etc/letsencrypt
      │                                    (여기에 인증서를 발급/저장)
      │
      └──────────── 볼륨 ────→  Nginx 컨테이너: /etc/letsencrypt (읽기전용)
                                       (여기서 인증서를 읽어서 사용)

./certbot/www/     ←──── 볼륨 ────→  Certbot 컨테이너: /var/www/certbot
      │                                    (검증 파일을 여기에 생성)
      │
      └──────────── 볼륨 ────→  Nginx 컨테이너: /var/www/certbot (읽기전용)
                                       (검증 요청을 이 경로에서 응답)
```

실제 docker-compose.yml 을 보면 이런 식이다.

```yml
nginx:
  volumes:
    - ./certbot/conf:/etc/letsencrypt:ro # 인증서 읽기 (읽기전용)
    - ./certbot/www:/var/www/certbot:ro # 검증 파일 읽기 (읽기전용)

certbot:
  volumes:
    - ./certbot/conf:/etc/letsencrypt # 인증서 저장 (읽기+쓰기)
    - ./certbot/www:/var/www/certbot # 검증 파일 생성 (읽기+쓰기)
```

**같은 호스트 디렉토리를 두 컨테이너가 공유**하기 때문에, Certbot이 인증서를 저장하면 Nginx가 바로 볼 수 있다!

### 인증서 발급 시나리오 (시간순)

```
[Step 1] Nginx 컨테이너가 HTTP(80)로 먼저 기동
         (아직 인증서 없으므로 HTTPS 서버 블록 없는 임시 설정)

[Step 2] Certbot 컨테이너 실행
         certbot certonly --webroot --webroot-path /var/www/certbot -d api.limsr12.com

[Step 3] Let's Encrypt가 검증 요청
         → http://api.limsr12.com/.well-known/acme-challenge/xxxx
         → Nginx 컨테이너가 요청 수신
         → /var/www/certbot/.well-known/acme-challenge/xxxx 파일 응답
           (이 파일은 Certbot이 공유 볼륨에 생성해둔 것)

[Step 4] 검증 성공 → Certbot이 인증서를 /etc/letsencrypt/live/에 저장
         → 실제로는 호스트의 ./certbot/conf/live/에 저장됨
         → Nginx 컨테이너도 같은 볼륨을 마운트하고 있으므로 접근 가능

[Step 5] Nginx 설정을 HTTPS 포함 버전으로 교체 → Nginx 재시작
```

### 인증서 갱신 시나리오

```
[12시간마다] Certbot 컨테이너가 certbot renew 실행
             → 만료 30일 전이면 자동 갱신
             → 새 인증서가 같은 볼륨 경로에 덮어써짐

[갱신 후]    Nginx가 새 인증서를 반영하려면 reload 필요
             → crontab이나 스크립트로 자동화:
             docker compose exec nginx nginx -s reload

# 로컬과 컨테이너 환경 비교

| 단계                | 로컬(certbot --nginx)      | 컨테이너(certbot --webroot)   |
| ------------------- | -------------------------- | ----------------------------- |
| 인증서 발급         | Certbot 이 직접 수행       | Certbot 컨테이너가 수행       |
| 검증 방식           | Nginx 플러그인이 자동 처리 | 공유 볼륨의 파일로 검증       |
| 인증서 저장         | /etc/letsencrypt/ (호스트) | ./certbot/conf/ (프로젝트 내) |
| Nginx 설정 수정     | Certbot 이 자동으로 해줌   | 직접 미리 작성해야 함         |
| Nginx가 인증서 접근 | 같은 호스트 파일 시스템    | 볼륨 마운트로 접근            |
| 갱신 후 반영        | Certbot 이 자동 reload     | 별도로 nginx -s reload 필요   |
```
