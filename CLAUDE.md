# Patrick's Work To-Do List

## Purpose

This repository is Patrick's personal rolling task list, managed via Claude Code and tracked with [beads](https://github.com/steveyegge/beads) (`bd`). The idea is simple: Patrick talks to Claude Code, and Claude Code manages the task list. This repo syncs across devices so the task list is always available.

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
2. Create a beads issue with `bd create "<title>" -t task --json`
3. Add a description if enough context was provided
4. Set priority if indicated (P0-P4, default P2)

### Checking tasks
- `bd ready --json` — show actionable tasks
- `bd list --status open --json` — show all open tasks
- `bd list --json` — show everything

### Updating tasks
- `bd update <id> --status in_progress` — mark as started
- `bd close <id> --reason "<what happened>"` — mark as done
- `bd update <id> --priority <0-4>` — change priority

### Syncing
After any changes to tasks, always sync and push:
```bash
bd sync
git add -A && git commit -m "sync tasks"
git push
```

## Key Commands Reference

| Command | Purpose |
|---------|---------|
| `bd create "title" -t task` | Create a new task |
| `bd ready` | Show tasks ready to work on |
| `bd list --status open` | List all open tasks |
| `bd show <id>` | View task details |
| `bd close <id>` | Close a completed task |
| `bd sync` | Sync beads state with git |
