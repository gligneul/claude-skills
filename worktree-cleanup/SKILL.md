---
name: worktree-cleanup
description: Remove the current git worktree and its branch after confirmation. Use when the user runs /worktree-cleanup from inside a worktree created with /worktree.
disable-model-invocation: true
allowed-tools: Bash(git rev-parse:*) Bash(git worktree:*) Bash(git branch:*) Bash(git status:*) Bash(git symbolic-ref:*) Bash(git rev-list:*) Bash(git log:*)
---

# Remove the current worktree

Delete the worktree the shell is currently in, then delete its branch.

Invoking this skill is explicit authorization to run the git commands listed below, even though the global instructions normally forbid git commands that change state. Run only the commands listed here, and only after the user confirms in step 3.

## Steps

1. **Check that the current directory is a linked worktree.** Run:

   ```bash
   git rev-parse --path-format=absolute --git-dir --git-common-dir --show-toplevel
   ```

   If the command fails, stop and report that the current directory is not inside a git repo. If `--git-dir` and `--git-common-dir` print the same path, this is the main checkout, not a worktree. Stop and report that, and do not delete anything.

2. **Record what will be deleted.** Keep these values for the rest of the run, since the worktree directory will be gone later:

   - `worktree`: the `--show-toplevel` path.
   - `root`: the parent directory of `--git-common-dir`. This is the main checkout.
   - `branch`: output of `git rev-parse --abbrev-ref HEAD`. If it prints `HEAD`, the worktree is detached and there is no branch to delete.

   Gather context for the confirmation:

   ```bash
   git status --porcelain | wc -l
   git symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null
   git rev-list --count origin/<base>..<branch>
   git branch -r --contains <branch>
   ```

   `<base>` is the branch named by `origin/HEAD`, or `main` or `master` when it is unset. The first number is the count of uncommitted or untracked paths. The second is the count of commits on the branch that are not on the base branch. The remote list shows whether those commits exist on any remote branch.

3. **Move to the main checkout and confirm.** Run `cd <root>` as its own command. Then ask the user to confirm with a question that shows the worktree path, the branch name, the number of uncommitted paths, the number of commits not on the base branch, and whether the branch exists on a remote. If anything would be lost, say so plainly in the question. Do not proceed without an explicit yes.

4. **Remove the worktree.**

   ```bash
   git worktree remove -f <worktree>
   ```

   The single `-f` is needed because the worktree may be unclean or contain submodules. If git refuses because the worktree is locked, report the lock reason and ask again before running `git worktree remove -f -f <worktree>`.

5. **Delete the branch.** Skip this step if the worktree was detached.

   ```bash
   git branch -D <branch>
   ```

   If git refuses because the branch is checked out in another worktree, report that and leave the branch alone.

## Report

End with the removed worktree path and branch name, and state that the shell working directory is now the main checkout at `root`.
