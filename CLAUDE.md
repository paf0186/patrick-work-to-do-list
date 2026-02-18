# Patrick's Work To-Do List

## Purpose

This repository is Patrick's personal rolling task list, managed via Claude Code and tracked with [beads](https://github.com/steveyegge/beads) (`bd`). The idea is simple: Patrick talks to Claude Code, and Claude Code manages the task list. This repo syncs across devices so the task list is always available.

## Setup

A lightweight `bd` wrapper script is bundled at `bin/bd`. It operates directly on `.beads/issues.jsonl` with no database dependencies. All `bd` commands below should be run as `./bin/bd` from the repo root. No external installation is required.

If the full `bd` binary is installed on the system (e.g., via `brew install beads`), you can use that instead for the complete feature set.

## Dictation Notice

Patrick frequently uses voice dictation to give instructions. This means input will often contain:
- Homophones and near-homophones (e.g., "right" instead of "write", "dock" instead of "doc")
- Missing or incorrect punctuation
- Run-on sentences or unusual phrasing
- Proper nouns that get mangled by speech-to-text

**Always interpret dictated input charitably.** Correct obvious dictation errors when creating tasks, commit messages, or other written artifacts. When in doubt about what was meant, ask.

## Workflow

### Adding tasks
Patrick will describe tasks conversationally. Claude Code should:
1. Interpret the request (correcting dictation errors)
2. Create a beads issue with `./bin/bd create "<title>" -t task --json`
3. Add a description if enough context was provided
4. Set priority if indicated (P0-P4, default P2)

### Checking tasks
- `./bin/bd ready --json` — show actionable tasks
- `./bin/bd list --status open --json` — show all open tasks
- `./bin/bd list --json` — show everything

### Updating tasks
- `./bin/bd update <id> --status in_progress` — mark as started
- `./bin/bd close <id> --reason "<what happened>"` — mark as done
- `./bin/bd update <id> --priority <0-4>` — change priority

### Syncing
After any changes to tasks, always commit and push:
```bash
git add -A && git commit -m "sync tasks"
git push
```

## Key Commands Reference

| Command | Purpose |
|---------|---------|
| `./bin/bd create "title" -t task` | Create a new task |
| `./bin/bd ready` | Show tasks ready to work on |
| `./bin/bd list --status open` | List all open tasks |
| `./bin/bd show <id>` | View task details |
| `./bin/bd close <id>` | Close a completed task |
