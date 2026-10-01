<div align="center">

<img src="assets/project-banner.svg" alt="Animated Commonplace — Team Project Board banner" width="900" />

# Commonplace — Team Project Board

**A collaborative planning board that makes ownership and the next action clear.**

Next.js · Supabase · dnd-kit · Tailwind CSS

![Project status](https://img.shields.io/badge/status-in%20progress-7a8b71)

</div>

## Product scope

Multi-user project board with keyboard-accessible drag-and-drop, ownership, activity, and realtime updates.

## Architecture notes

Supabase Realtime updates boards; versioned writes handle reorder conflicts; RLS scopes workspace membership; dnd-kit supports keyboard interaction.

### Data model sketch

    projects(id, workspace_id, name) · tasks(id, project_id, title, status, position, assignee_id, version) · activity_events(id, task_id, actor_id, action)

## Stack

Next.js · Supabase · dnd-kit · Tailwind CSS

## Build sequence

1. Board and task lifecycle
2. Accessible drag-and-drop ordering
3. Realtime collaboration
4. Workspace policies and history

## Current status

Public repository with an animated README. Product code is being built incrementally, one project at a time. This page records the planned product boundary and engineering milestones.

## License

MIT.
