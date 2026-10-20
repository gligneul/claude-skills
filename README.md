# claude-skills

Personal skills for Claude Code.

Each skill lives in its own top-level directory containing a `SKILL.md`:

```
claude-skills/
  my-skill/
    SKILL.md
```

## Install

```sh
./install.sh
```

This symlinks every skill directory into `~/.claude/skills/` so Claude Code
can discover them. Re-run it after adding a new skill. It never overwrites an
existing entry; set `CLAUDE_SKILLS_DIR` to install somewhere else.
