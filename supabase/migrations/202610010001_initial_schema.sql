create extension if not exists pgcrypto;

create type public.task_status as enum ('backlog', 'in_progress', 'in_review', 'done');
create type public.task_priority as enum ('low', 'medium', 'high');

create table public.workspaces (
  id uuid primary key default gen_random_uuid(),
  name text not null check (length(trim(name)) between 1 and 100),
  created_at timestamptz not null default now()
);

create table public.workspace_members (
  workspace_id uuid not null references public.workspaces(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  role text not null default 'member' check (role in ('owner', 'admin', 'member')),
  joined_at timestamptz not null default now(),
  primary key (workspace_id, user_id)
);

create table public.tasks (
  id uuid primary key default gen_random_uuid(),
  workspace_id uuid not null references public.workspaces(id) on delete cascade,
  title text not null check (length(trim(title)) between 1 and 180),
  description text not null default '',
  status public.task_status not null default 'backlog',
  priority public.task_priority not null default 'medium',
  assignee_id uuid,
  due_at date,
  position numeric not null default 0,
  created_by uuid not null default auth.uid() references auth.users(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  foreign key (workspace_id, assignee_id) references public.workspace_members(workspace_id, user_id),
  unique (workspace_id, id)
);

create index tasks_board_order on public.tasks(workspace_id, status, position);
create index tasks_assignee on public.tasks(workspace_id, assignee_id) where assignee_id is not null;

create table public.task_comments (
  id uuid primary key default gen_random_uuid(),
  workspace_id uuid not null,
  task_id uuid not null,
  author_id uuid not null default auth.uid() references auth.users(id),
  body text not null check (length(trim(body)) between 1 and 5000),
  created_at timestamptz not null default now(),
  foreign key (workspace_id, task_id) references public.tasks(workspace_id, id) on delete cascade
);

create table public.task_activity (
  id bigint generated always as identity primary key,
  workspace_id uuid not null,
  task_id uuid not null,
  actor_id uuid default auth.uid() references auth.users(id),
  event_type text not null check (event_type in ('created', 'updated', 'moved', 'commented', 'assigned')),
  payload jsonb not null default '{}',
  created_at timestamptz not null default now(),
  foreign key (workspace_id, task_id) references public.tasks(workspace_id, id) on delete cascade
);

create or replace function public.is_workspace_member(target_workspace uuid)
returns boolean language sql stable security definer set search_path = public
as $$ select exists (select 1 from public.workspace_members m where m.workspace_id = target_workspace and m.user_id = auth.uid()) $$;

alter table public.workspaces enable row level security;
alter table public.workspace_members enable row level security;
alter table public.tasks enable row level security;
alter table public.task_comments enable row level security;
alter table public.task_activity enable row level security;

create policy workspace_member_read on public.workspaces for select using (public.is_workspace_member(id));
create policy members_read on public.workspace_members for select using (public.is_workspace_member(workspace_id));
create policy tasks_member_access on public.tasks for all using (public.is_workspace_member(workspace_id)) with check (public.is_workspace_member(workspace_id));
create policy comments_member_access on public.task_comments for all using (public.is_workspace_member(workspace_id)) with check (public.is_workspace_member(workspace_id));
create policy activity_member_read on public.task_activity for select using (public.is_workspace_member(workspace_id));
create policy activity_member_insert on public.task_activity for insert with check (public.is_workspace_member(workspace_id));

