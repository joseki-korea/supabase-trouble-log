> **(폐기)** 이 레포는 폐기되었습니다. `joseki-korea/ai-trouble-log`(Orca/LLM/Agent/Supabase/Git/API 통합, 관계형 스키마, 대시보드)가 정본입니다.
> 사유: 이 레포의 단일테이블(`issues`) 구조가 ai-trouble-log의 "Supabase" 카테고리와 스코프가 겹침 — 대표 지시(2026-08-19)로 통합.
> 아래 내용은 기록 보존 목적으로 남겨둡니다.

# Supabase Trouble Log

Supabase를 운영하며 겪은 장애, 실수, 원인과 해결책을 재사용 가능한 형태로 기록하는 공개 저장소입니다.

## 데이터 구조

`public.issues` 테이블은 다음 필드를 사용합니다.

| 필드 | 형식 | 설명 |
| --- | --- | --- |
| `id` | `bigint` | 자동 증가 기본 키 |
| `date` | `date` | 이슈 발생일 |
| `title` | `text` | 짧고 검색 가능한 제목 |
| `description` | `text` | 증상과 영향 범위 |
| `root_cause` | `text` | 확인된 근본 원인 |
| `fix` | `text` | 적용하고 검증한 해결책 |
| `tags` | `text[]` | `auth`, `rls`, `migration`, `connection`, `edge-function` 등 |

## 구축

Supabase Dashboard의 SQL Editor에서 아래 파일을 순서대로 실행합니다.

1. [`supabase/migrations/202608190001_create_issues.sql`](supabase/migrations/202608190001_create_issues.sql)
2. [`supabase/seed.sql`](supabase/seed.sql)

Supabase CLI를 사용하는 경우:

```bash
supabase link --project-ref <PROJECT_REF>
supabase db push
supabase db reset  # 로컬 개발 DB에서만: seed.sql까지 다시 적용
```

## 이슈 등록

재현과 검증이 끝난 이슈만 등록합니다. 추측은 `root_cause`로 기록하지 않습니다.

```sql
insert into public.issues
  (date, title, description, root_cause, fix, tags)
values
  (current_date, '제목', '증상과 영향', '확인된 원인', '해결 및 검증 방법', array['rls']);
```

Dashboard의 Table Editor에서도 `issues` 행을 추가할 수 있습니다. 태그는 소문자 kebab-case 배열을 권장합니다.

## 조회

```sql
-- 최신 이슈
select * from public.issues order by date desc, id desc;

-- RLS 관련 이슈
select * from public.issues
where tags @> array['rls']::text[]
order by date desc, id desc;

-- 제목·증상·원인·해결책 전문 검색
select * from public.issues
where search_document @@ websearch_to_tsquery('simple', 'JWT connection');
```

REST API 조회에는 공개 URL과 publishable/anon key를 환경변수로 전달합니다. 키를 저장소에 커밋하지 마세요.

```bash
curl "$SUPABASE_URL/rest/v1/issues?select=*&order=date.desc,id.desc" \
  -H "apikey: $SUPABASE_ANON_KEY" \
  -H "Authorization: Bearer $SUPABASE_ANON_KEY"
```

현재 마이그레이션은 익명·로그인 사용자에게 읽기만 허용합니다. 쓰기는 Dashboard, SQL Editor 또는 `service_role`을 사용하는 신뢰된 서버에서 수행해야 합니다. `service_role` 키는 클라이언트에 노출하지 마세요.

## 변경 원칙

- 개인 정보, 토큰, 프로젝트 비밀번호, 실제 고객 데이터는 기록하지 않습니다.
- 해결책에는 실행 명령뿐 아니라 성공 여부를 확인한 방법도 적습니다.
- 스키마 변경은 새 timestamp 마이그레이션으로 추가합니다.

