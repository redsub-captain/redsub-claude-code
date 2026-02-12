# Code Quality Rules

## Security
→ `security-guidance` plugin handles detailed rules. Key reminders: no hardcoded secrets, validate user input at boundaries.

## Environment Variables
- When adding new env vars, update simultaneously:
  1. `.env` (local)
  2. Deployment config (e.g., `apphosting.yaml`, Vercel env, etc.)
  3. Related documentation

## Single Source of Truth (SSOT)
- **Every piece of data has exactly one canonical source.** All consumers read from it.
- Config values (API URLs, feature flags, limits) → one config file or env var. Never scatter across files.
- Business logic (pricing rules, validation, permissions) → one module. Other files import, never re-implement.
- Type definitions → define once, re-export. Never redeclare the same shape in multiple files.
- UI strings → i18n files only. No inline text in components.
- Constants (error codes, status enums, route paths) → one constants file per domain.
- **Review checkpoint**: When editing a value, search for duplicates (`Grep`). If found elsewhere, refactor to single source before proceeding.
- **Violation = bug**: Treating duplicated data sources as bugs, not style issues.

## Strings
- No hardcoded strings. Use i18n keys or constants.
- Includes error messages and UI text.

## Bug Propagation
- 오류/버그 발견 시 **동일/유사 패턴 전수 조사**. 한 건 수정으로 끝내지 않는다.
- Grep으로 유사 패턴 검색 → 전체 수정 → 검증.
- "하나 고치고 끝"은 버그. 전수 조사 후 리포트.

## Systematic Debugging
- **Iron Law: 근본원인 조사 없이 수정 금지.**
- 4단계:
  1. **근본원인**: 에러 메시지 꼼꼼히 읽기, 재현, `git diff`로 최근 변경 확인, 데이터 흐름 추적.
  2. **패턴분석**: 동일 코드베이스에서 작동하는 유사 사례 찾기, 차이점 비교.
  3. **가설검증**: 하나의 가설만 세우기, 최소 변경으로 테스트, 한 번에 하나의 변수만.
  4. **구현**: 실패 테스트 케이스 작성 → 단일 수정 → 검증.
- **3회 수정 실패 → STOP.** 아키텍처 문제 의심. 사용자와 논의 후 진행.
- **Red Flag**: "빨리 고치고 나중에 조사", "이것만 바꿔보자", 근본원인 파악 없이 수정 제안.

## Feature Flow Integrity
- 큰 기능을 여러 커밋에 걸쳐 개발할 때, **기능 전체 플로우를 정기적으로 점검**한다.
- 커밋 단위 리뷰만으로는 전체 아키텍처 일관성을 보장할 수 없다.
- 기능 완료 시 `git diff main...HEAD`로 **전체 변경사항** 리뷰.
- 데이터 흐름, 에러 처리, 상태 관리가 기능 전체에서 일관되는지 확인.
- 스파게티 코드 징후: 같은 로직이 여러 곳에 분산, 순환 의존, 일관성 없는 패턴 → 즉시 리팩토링.

## Project Structure
- 일관된 디렉토리 구조 유지.
- 관심사 분리: 서버/클라이언트/공유 유틸리티.
- 설정 파일은 프로젝트 루트. 디렉토리에 흩뿌리지 않는다.
- 테스트 파일은 소스 옆 또는 전용 디렉토리에.

## Styling
- 프로젝트가 선택한 CSS 방법론을 일관되게 따른다.
- 조건부 클래스 조합에는 유틸리티 함수 사용.

## Public Plugin Quality
- 보안: 사용자 자격증명, API 키가 로그/출력에 노출되지 않도록.
- 성능: 불필요한 파일 읽기/검색 최소화. 토큰 비용 인식.
- UX: 불필요한 확인 프롬프트 최소화. 자동화 가능한 것은 자동화.
