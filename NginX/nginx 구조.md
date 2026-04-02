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
