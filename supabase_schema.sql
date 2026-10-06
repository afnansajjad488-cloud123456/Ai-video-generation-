-- VIP AI Video Studio - Supabase schema
-- Run this in Supabase SQL Editor if video_jobs does not already exist.

create extension if not exists pgcrypto;

create table if not exists public.video_jobs (
  id uuid primary key,
  prompt text not null,
  language text,
  duration integer,
  aspect_ratio text,
  resolution text,
  style text,
  status text not null default 'queued',
  script jsonb,
  scenes jsonb,
  final_video_url text,
  thumbnail_url text,
  subtitles_url text,
  video_url text,
  audio_base64 text,
  audio_mime_type text,
  error_message text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists video_jobs_status_idx on public.video_jobs(status);
create index if not exists video_jobs_created_at_idx on public.video_jobs(created_at desc);

create or replace function public.set_video_jobs_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists video_jobs_updated_at on public.video_jobs;
create trigger video_jobs_updated_at
before update on public.video_jobs
for each row execute function public.set_video_jobs_updated_at();

alter table public.video_jobs enable row level security;

-- Backend service-role access is expected for n8n.
-- No public insert/update/delete policy is created here.
-- If the frontend later needs direct reads, add a narrow SELECT policy only.
