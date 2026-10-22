---
name: worktree
description: Create a git worktree and branch for a Linear issue. Use when the user runs /worktree with a Linear issue id (e.g. NIT-1234) and optionally a base branch.
argument-hint: <linear-issue> [base-branch]
disable-model-invocation: true
allowed-tools: Bash(git fetch:*) Bash(git worktree:*) Bash(git reset:*) Bash(git rev-parse:*) Bash(git symbolic-ref:*) Bash(git show-ref:*) Bash(git branch:*) Bash(git status:*) Bash(make init-submodules) mcp__claude_ai_Linear__get_issue
---

# New worktree for a Linear issue

Create a worktree and branch for `$0`, based on `$1` when given.

Invoking this skill is explicit authorization to run the git commands listed below, even though the global instructions normally forbid git commands that change state. Run only the commands listed here. Do not commit, push, or touch any other branch.

## Inputs

- `$0` (required): the Linear issue. Accept `NIT-1234`, `nit-1234`, or a Linear issue URL. If it is missing or does not look like `<team>-<number>`, stop and ask the user for it. Do not guess.
- `$1` (optional): the base branch. When omitted, detect the primary branch of the repo (see step 3).

## Steps

1. **Normalize the ticket.** Lowercase the team key and number, e.g. `NIT-1234` becomes `nit-1234`. This is `<ticket>`.

2. **Pick the tag.** Fetch the issue with the Linear `get_issue` tool using the uppercase id (`NIT-1234`) and read its title. Derive `<tag>` from the title: one to three lowercase ASCII words, separated by `-`, that describe the work (e.g. `fix-batch-poster`, `stylus-cache`). Drop articles, ticket ids, and punctuation. If Linear is unavailable, ask the user for the tag instead of inventing one.

3. **Find the repo and base branch.** Run from the current directory:

   ```bash
   root="$(dirname "$(git rev-parse --path-format=absolute --git-common-dir)")"
   repo="$(basename "$root")"
   git symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null
   git show-ref --verify --quiet refs/heads/main && echo main
   git show-ref --verify --quiet refs/heads/master && echo master
   ```

   `root` is the main checkout even when run from inside another worktree. `<repo-name>` is `repo`.

   Base branch: `$1` if given. Otherwise use the branch named by `origin/HEAD` (strip the `origin/` prefix). If that is unset, use `main` if it exists, else `master`. If neither exists, ask the user.

4. **Create the worktree.** Run from `root`:

   ```bash
   cd "$root" && git worktree add ../<repo-name>-<tag> -b gligneul/<ticket>-<tag>
   ```

   If the target directory or branch already exists, stop and report it. Do not delete or overwrite anything.

5. **Move into the worktree.** Run `cd <root-parent>/<repo-name>-<tag>` as its own command so later commands run there.

6. **Reset to the base branch.** The new branch starts at the current HEAD, which may be unrelated to `<base>`, so move it instead of rebasing:

   ```bash
   git fetch origin <base> && git reset --hard origin/<base>
   ```

   If `origin` has no such branch, reset to the local `<base>` instead. The worktree is brand new, so the reset cannot discard any work.

7. **Nitro only.** If `<repo-name>` is `nitro`, run `make init-submodules` in the worktree.

## Report

End with the worktree path, the branch name, and the base branch it was reset to. Mention that the shell working directory is now the worktree.
