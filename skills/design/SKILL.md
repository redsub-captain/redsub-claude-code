---
name: design
description: Stitch MCP로 UI/UX 화면을 설계하고 프로토타이핑.
context: fork
agent: designer
argument-hint: "[screen-description]"
---

# UI/UX 화면 설계

## 입력

`$ARGUMENTS`로 화면 설명을 받습니다.

## 절차

### 1. 프로젝트 확인

Stitch 프로젝트가 있는지 확인합니다. 없으면 새로 생성합니다.

### 2. 화면 설계

`$ARGUMENTS` 기반으로 Stitch MCP를 사용하여 화면을 생성합니다:
- 디바이스 타입: 모바일(`MOBILE`) 또는 데스크톱(`DESKTOP`)
- 사용자가 지정하지 않으면 `DESKTOP` 기본값

### 3. SvelteKit 연계 가이드

생성된 화면을 SvelteKit 컴포넌트로 구현하기 위한 가이드를 제공합니다:
- 필요한 SvelteKit 라우트 구조
- 컴포넌트 분리 방안
- Tailwind CSS 4 스타일링 가이드
- $state, $derived 등 runes 활용 방안

### 4. 출력

```markdown
## 디자인: [화면 설명]

### Stitch 결과
- 프로젝트: [이름]
- 화면: [URL/ID]

### SvelteKit 구현 가이드
- 라우트: `src/routes/[path]/+page.svelte`
- 컴포넌트: [분리 방안]
- 스타일: [Tailwind 클래스]
```

## 주의사항

- 이 스킬은 **디자인만** 합니다. 코드 작성은 하지 않습니다.
- `STITCH_API_KEY` 환경변수가 필요합니다.
