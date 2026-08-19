insert into public.issues
  (date, title, description, root_cause, fix, tags)
values
  (
    '2026-07-29',
    'Publishable key embedded directly in a static page',
    'A static client contained a project URL and publishable key as hard-coded values, making environment separation and key rotation error-prone.',
    'The browser client was coupled directly to one Supabase project instead of receiving configuration through a controlled deployment boundary.',
    'Moved data access behind an API proxy, removed project-specific values from the page, and verified the built artifact contained no Supabase key.',
    array['auth', 'connection']
  ),
  (
    '2026-07-27',
    'Service validation used a different environment from the resident process',
    'A manually stripped environment reported an authentication failure even though the resident process used a valid authenticated environment.',
    'The validation command did not reproduce the launch service environment, so its result was not representative.',
    'Validate through the actual resident service path, inspect its exit status and logs, then run one end-to-end workload.',
    array['auth', 'connection']
  ),
  (
    '2026-08-19',
    'Schema changes need a reproducible migration',
    'Dashboard-only SQL makes it difficult to review, reproduce, or recover a project schema.',
    'Schema state existed outside version control.',
    'Store ordered SQL migrations and seed data in Git, review them, and apply them with Supabase CLI or the SQL Editor.',
    array['migration']
  )
on conflict do nothing;

