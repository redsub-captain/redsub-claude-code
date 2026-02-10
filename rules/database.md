---
paths:
  - "src/**/*store*"
  - "src/**/*db*"
  - "src/**/*firebase*"
  - "src/**/*supabase*"
  - "supabase/**"
  - "firestore*"
---

# 데이터베이스 규칙

## Supabase
- RLS(Row Level Security) 필수. RLS 없는 테이블 생성 금지.
- 스키마 변경은 마이그레이션 파일로만 (`supabase migration new`).
- N+1 쿼리 방지: 관련 데이터는 join 또는 select에서 함께 조회.
- 인덱스: WHERE 절에 자주 사용되는 컬럼에 인덱스 추가.

## Firestore
- Security Rules 변경 시 영향 범위 분석 필수.
- 복합 인덱스가 필요한 쿼리는 `firestore.indexes.json`에 명시.
- 문서 크기 1MB 제한 주의. 대량 데이터는 서브컬렉션 사용.
- 트랜잭션 사용 시 재시도 로직 포함.

## 공통
- 마이그레이션에는 반드시 롤백 계획 포함.
- 프로덕션 DB 직접 수정 금지. 반드시 마이그레이션 경유.
- 민감 데이터 (PII) 는 암호화 저장.
- 쿼리 성능: 풀스캔 방지, 필요한 필드만 select.
