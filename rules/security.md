---
paths:
  - "**/.env*"
  - "**/secret*"
  - "src/lib/server/**"
---

# 보안 규칙

## API 키 / 시크릿
- API 키, 시크릿을 코드에 하드코딩 금지.
- `.env` 파일은 절대 git에 커밋하지 않음.
- 클라이언트 사이드 코드에 서버 시크릿 노출 금지.

## 인증 / 인가
- OAuth 토큰, 세션 토큰은 서버 사이드에서만 처리.
- JWT 검증은 서버에서만 수행. 클라이언트는 토큰 저장/전달만.
- 인가 로직은 API 엔드포인트마다 적용.

## Firebase / Supabase
- Firebase Security Rules 변경 시 영향 범위 분석.
- Supabase RLS 정책 변경 시 기존 데이터 접근 영향 확인.
- Admin SDK는 서버 환경에서만 사용.

## 입력 검증
- 사용자 입력은 서버에서 반드시 검증 (클라이언트 검증은 UX용).
- SQL injection, XSS 방어: 파라미터화 쿼리, HTML 이스케이프.
- 파일 업로드: MIME 타입 검증, 크기 제한.
