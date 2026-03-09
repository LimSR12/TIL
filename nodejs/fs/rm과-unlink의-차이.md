# fs.rm vs fs.unlink

## fs.promises.rm(path, [options])

-> **파일 + 디렉토리 모두 삭제 가능한 고수준 API**

- 비교적 가장 최근에 도입된 통합 삭제함수
- unlink 와 rmdir 의 역할을 모두 수행
- 옵션으로 재귀 삭제도 가능 (`recursive: true`)
- 디렉토리/파일 여부 알아서 분기해서 처리해줌
- 내부적으로 unlink, rmdir, unlinkat 등의 시스템콜을 호출함

## fs.promises.unlink(path)

-> **파일 하나를 삭제하는 저수준 API** (POSIX unlink syscall)

- 파일 삭제만 가능하고, 디렉토리에 쓰면 에러(EPERM or EISDIR) 발생
