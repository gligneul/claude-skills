# Code comments

The default is no comment. Add one only when it states a constraint the code cannot show, such as an invariant the caller must uphold, an ordering requirement, a unit, or a non-obvious failure mode. Write it as the constraint ("must be called before Start", "len is in bytes"), not as a description of what the code does.

Never write a comment that:

* narrates the steps the code takes ("loop over the items", "return the result", "check if nil")
* restates a name, type, or signature visible in the code
* explains the rationale, history, or justification of a change (why a value was chosen, bug links, root-cause notes). That belongs in the PR description and git history.
* labels a section ("// Helpers", "// Validation")

Doc comments on exported identifiers follow the language convention but say only what the caller needs, in one or two lines.

Before finishing a task, re-read your diff and delete every comment that fails these rules. When unsure, delete it.

# Writing style

These rules apply to chat responses, generated code, comments, and documentation:

* Do not use em dashes. Rephrase, or use commas, parentheses, or separate sentences instead.
* Do not use a colon before an explanation. Colons before a list or a quote are fine.
* Prefer subject-verb-object word order.

# Git

Do not run git commands that change git state (`git add`, `git restore`, `git stash`, `git commit`, `git checkout`, `git reset`, `git push`, and similar). Only edit files in the working tree; the user reviews the diff and stages and commits themselves. Read-only git commands (`git status`, `git diff`, `git log`, `git show`, `git blame`) are fine.

# Dune

* Create every new query and dashboard in the Platform Engineering folder (folder id `arVMayhUEyWq`, offchainlabs team) and make it private. For queries, pass `folder_id` and `is_private: true` to the MCP `createDuneQuery`. For dashboards, pass `isPrivate: true` to the MCP `createDashboard` or `--private` to `dune dashboard create`; no API places a dashboard in a folder, so tell the user to move it to Platform Engineering in the web UI and link the dashboard.
* Moving an existing query into a folder has no API (not in the CLI, the REST update endpoint, or the MCP update tool). Only the Dune web UI can do it, so get the folder right at creation time.
* The `dune` MCP writes to team queries after `/mcp dune` re-auth. If a write fails with "Your account is read-only", re-run `/mcp dune`.
* `dune query update --private` and `PATCH /api/v1/query/{id}` with `is_private` return 200 but change nothing. Set privacy through the MCP `updateDuneQuery` or `POST /api/v1/query/{id}/private`, and verify with `dune query get <id> -o json`.
