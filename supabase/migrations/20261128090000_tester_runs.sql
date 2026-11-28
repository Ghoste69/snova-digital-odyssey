create table public.tester_runs (
  id uuid primary key,
  received_at timestamptz not null default now(),
  route text not null check (route in ('infinite','story','sector','bossSurvival','lastStand','raid','survival')),
  difficulty text not null check (difficulty in ('story','relaxed','easy','normal','hard','expert','nightmare')),
  won boolean not null,
  wave integer not null check (wave between 0 and 1000000),
  stage integer not null check (stage between 0 and 100000),
  party integer not null check (party between 1 and 5),
  score bigint not null check (score between 0 and 9007199254740991),
  kills integer not null check (kills between 0 and 10000000),
  seconds integer not null check (seconds between 0 and 10000000)
);
alter table public.tester_runs enable row level security;
revoke all on public.tester_runs from anon, authenticated, public;
grant insert (id,route,difficulty,won,wave,stage,party,score,kills,seconds) on public.tester_runs to authenticated;
grant select on public.tester_runs to authenticated;
create policy tester_submit on public.tester_runs for insert to authenticated with check ((select auth.uid()) is not null);
create policy tester_owner_read on public.tester_runs for select to authenticated using (
  exists(select 1 from public.dev_lab_access where owner_id=(select auth.uid()))
);
create index tester_runs_received on public.tester_runs(received_at desc);