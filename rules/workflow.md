---
---

# 워크플로우 규칙

## 브랜치
- main/master 브랜치에 직접 커밋 금지.
- 작업 브랜치: `feature/`, `fix/`, `chore/` 접두사 사용.
- `/start-work`로 브랜치를 생성하고 작업 시작.

## 커밋
- Conventional Commits 형식: `feat:`, `fix:`, `chore:`, `docs:`, `test:`, `refactor:`.
- WIP 커밋은 `/save`로. 최종 커밋은 의미 있는 메시지로.

## 머지 / 푸시 / 배포
- 사용자 지시 없이 push, merge, deploy 실행 금지.
- merge 전 반드시 `/validate` 통과 필수.
- `/ship`으로 Save → Validate → Merge 순서 강제.

## 토큰 최적화
- 파일 탐색은 Glob/Grep 우선. 대량 cat/read 지양.
- 응답은 간결하게. 불필요한 코드 블록 반복 지양.
- MCP보다 CLI 대안이 있으면 CLI 사용 (컨텍스트 절약).

## 계획 우선
- 새 기능, 큰 변경은 `/plan`으로 계획 수립 후 진행.
- 계획 없이 대규모 수정 시작 금지.
