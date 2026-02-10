---
name: status
description: git 상태, 최근 커밋, 미완료 작업 요약.
---

# 프로젝트 현황

현재 git 상태:
```
!`git status --short`
```

최근 커밋:
```
!`git log --oneline -5`
```

현재 브랜치:
```
!`git rev-parse --abbrev-ref HEAD`
```

## 출력

위 정보를 간결하게 정리하여 보여주세요:

```
📌 브랜치: [현재 브랜치]
📝 변경: [미커밋 파일 수]개 파일
📋 최근 커밋:
  - [hash] [message]
  - ...
```

CLAUDE.md에 "진행 중" 섹션이 있으면 함께 표시합니다.
