# Nginx

## Nginx 란?

Nginx란 **트래픽이 많은 웹사이트의 서버(WAS)를 도와주는 비동기 이벤트 기반구조의 경량화 웹 서버** 이다.

클라이언트로부터 요청을 받았을 때 요청에 맞는 정적 파일을 응답해주는 **HTTP Web Server**로 활용되기도 하고 

**Reverse Proxy Server**로 활용하여 WAS의 부하를 줄일 수 있는 로드밸런서 역할을 하기도 한다.

[nginx](https://nginx.org/)

## Nginx 의 장점

- **고성능**
    - 비동기 이벤트 기반 구조를 사용하여 매우 빠르고 효율적인 웹 서버 기능을 제공한다.
    - 프로세스간의 블로킹을 최소화하고 많은 요청을 동시에 처리할 수 있어서 큰 트래픽 처리에 탁월하다고 한다.
- **리버스 프록시**
    - 클라이언트로부터 들어오는 요청을 대신 받아서 내부 서버로 전달해주는 것!
    - **클라이언트 → Nginx → 웹서버** 로 구성해서 사용자의 요청을 Nginx 가 웹 서버로 대신 전달해주기 때문에, **서버의 직접적인 주소를 숨기고 프록시 서버의 주소만을 노출**하여 중요한 정보가 담긴 **DB 서버, 캐시 서버** 등의 해킹을 방지할 수도 있다고 한다.
    <img width="850" height="392" alt="Image" src="https://github.com/user-attachments/assets/7e9acf08-5fc0-4616-ba4a-bc57d1f3ad3d" />
        
- **로드 밸런싱**
    - 프록시 서버는 트래픽 분산 기능을 제공할 수 있다
    - **한 서버에 트래픽이 과도하게 몰릴 경우 해당 서버가 버티지 못하는 경우**가 생길 수 있어서, Nginx 는 로드 밸런싱을 통해 **다수의 서버에 트래픽을 분산시켜 트래픽 과부하를 방지**할 수 있다.
    <img width="721" height="475" alt="Image" src="https://github.com/user-attachments/assets/b45e5a7e-8236-4a70-8210-0e67bf60be73" />
    

# 설치

아래 링크에 들어가면 각 OS별로 설치하는 방법이 상세하게 나와있다.

[nginx: Linux packages](https://nginx.org/en/linux_packages.html)

# Nginx 설정파일의 위치와 구조

Nginx의 설정은 기본적으로 **`/etc/nginx/`** 안에 모여있다!

그리고 대부분의 Linux 배포판에서 기본 구조는 아래와 같다고 한다,

```
/etc/nginx/
├── nginx.conf                 ← 메인 설정 파일 (전역 설정)
├── conf.d/                    ← 추가 설정 파일 모음 (서브 설정)
│   ├── default.conf           ← 기본 서버 설정 (여기에 server 블록 종종 있음)
├── sites-available/           ← 서버(가상호스트) 설정 템플릿 모음
│   └── example.com.conf
├── sites-enabled/             ← 실제 사용 중인 설정의 심볼릭 링크
│   └── example.com.conf -> ../sites-available/example.com.conf
├── snippets/                  ← 자주 쓰는 설정 조각 (include용)
└── mime.types                 ← 파일 확장자별 MIME 타입 정의
```

<aside>

실제로 지금 할당받아서 사용중인 EC2 환경에서는 어떻게 구성되어있는지 출력해보니 다음과 같았고, 구조가 조금은 다른 것 같기도 해서 관련해서는 추가적으로 학습해보면 좋을 것 같다.

</aside>

<img width="1102" height="402" alt="Image" src="https://github.com/user-attachments/assets/dc974072-9ee2-4ec6-8e3f-1c695d6d5484" />

## 각 파일/디렉토리의 역할 정리

| 경로 | 설명 |
| --- | --- |
| **`/etc/nginx/nginx.conf`** | 메인 설정 파일. 모든 설정의 진입점. 보통 `include /etc/nginx/conf.d/*.conf;` 라고 되어 있어서 하위 설정들을 불러옴. |
| **`/etc/nginx/conf.d/`** | 추가 설정을 넣는 기본 디렉토리. 여기 `.conf` 파일을 넣으면 자동으로 로드됨 (Ubuntu 20.04 기준). |
| **`/etc/nginx/sites-available/`** | 여러 도메인(가상 호스트)을 관리할 때 사용하는 “설정 저장소”. 여기에 설정 파일을 만들어두고, 실제 사용할 때는 아래의 `sites-enabled`로 링크를 걸어줌. |
| **`/etc/nginx/sites-enabled/`** | 현재 활성화된 사이트 설정만 들어가는 디렉토리. `ln -s /etc/nginx/sites-available/example.com.conf /etc/nginx/sites-enabled/` 형식으로 연결. |
| **`/etc/nginx/snippets/`** | 공통 설정 조각(예: SSL 설정, 보안 헤더 등)을 따로 분리해두는 곳. `include snippets/ssl.conf;` 이런 식으로 가져다 씀. |
| **`/etc/nginx/mime.types`** | 파일 확장자와 MIME 타입의 매핑 정의 파일. 예: `.html text/html`, `.css text/css` 등. |

## 설정 파일의 로드 흐름

Nginx는 실행될 때 다음 순서로 설정을 읽는다

1. `/etc/nginx/nginx.conf` ← **가장 먼저 읽힘 (Main config)**
2. `nginx.conf` 안에서 `include` 지시어로 하위 설정을 불러옴
    
    예시:
    
    ```
    include /etc/nginx/conf.d/*.conf;
    include /etc/nginx/sites-enabled/*;
    ```
    
3. 결과적으로 `conf.d` 또는 `sites-enabled` 안의 `.conf` 파일들이 합쳐져 전체 설정이 됨.

<aside>

실제로 EC2 환경에서 해당 파일을 열어보니 `include /etc/nginx/conf.d/*.conf;`  ****설정이 존재함을 확인해볼 수 있었다!

</aside>

<img width="914" height="1035" alt="Image" src="https://github.com/user-attachments/assets/29a33ed8-cce0-4398-b883-453b9d13b952" />

## 자주 쓰는 명령어

| 명령어 | 설명 |
| --- | --- |
| `sudo nginx -t` | 설정 문법 검사 (에러 있으면 출력해줌) |
| `sudo systemctl restart nginx` | 설정 변경 후 Nginx 재시작 |
| `sudo systemctl reload nginx` | **무중단으로 설정만 다시 로드** |
| `sudo nginx -s reload` | 위와 동일, 프로세스 재시작 없이 설정만 반영 |
| `sudo nginx -v` | Nginx 버전 확인 |
| `sudo tail -f /var/log/nginx/error.log` | 에러 로그 실시간 확인 |

## 배포 환경별 기본 경로 차이

| OS / 배포판 | 주요 설정 파일 경로 |
| --- | --- |
| **Ubuntu / Debian** | `/etc/nginx/nginx.conf` / `sites-available` / `sites-enabled` |
| **Amazon Linux / CentOS / RHEL** | `/etc/nginx/nginx.conf` / `conf.d/` (보통 `default.conf`로 바로 구성) |
| **Mac (Homebrew 설치 시)** | `/usr/local/etc/nginx/nginx.conf` |
| **Docker 컨테이너** | `/etc/nginx/nginx.conf` (이미지마다 다를 수 있음) |

