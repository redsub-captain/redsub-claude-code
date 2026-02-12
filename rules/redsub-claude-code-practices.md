---
description: "Claude Code best practices for development workflow"
---

# Claude Code Practices

## Read Before Edit
- 추측하지 않는다. 수정 전 반드시 Read/Grep으로 현재 상태 확인.
- 파일이 존재하는지, 내용이 어떤지 직접 확인 후 작업.

## Evidence Before Claims
- "테스트 통과" 주장 전 실제 출력을 보여준다.
- 커밋/PR 전 검증 커맨드 실행 후 결과 첨부.

## Active Tool Usage
- 후크(hooks)로 자동화할 수 있는 것은 수동으로 하지 않는다.
- 서브에이전트(Task tool)로 병렬 탐색/작업 적극 활용.
- Context7 MCP로 라이브러리 문서 조회 (추측하지 말고 조회).
- 설치된 MCP 서버의 도구를 적극 활용.

## Document Management
- CLAUDE.md는 프로젝트의 살아있는 문서. 세션마다 업데이트.
- "In progress" 섹션으로 진행 중인 작업 추적.
- 학습사항은 CLAUDE.md에 기록 → 다음 세션에 전달.

## No Guessing
- 의존성, API, 파일 경로를 추측하지 않는다.
- package.json, 실제 파일 구조를 읽고 판단.
- 불확실하면 사용자에게 질문 (AskUserQuestion).

## Parallel Work & Agent Teams
- 독립적인 작업은 **반드시 서브에이전트(Agent Teams)로 병렬 실행**. 순차 처리하지 않는다.
- 2개 이상의 독립적 탐색/수정/검증 작업 → Task tool로 병렬 디스패치.
- 파일 읽기, 검색 등 독립적 조회는 병렬 호출.
- 의존성 있는 작업만 순차 실행.
- Agent Teams 사용 판단 기준: 작업 간 공유 상태나 순차 의존이 없으면 **항상** 병렬.
