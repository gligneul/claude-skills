#!/usr/bin/env bash
# Symlinks every skill directory in this repo (a directory containing SKILL.md)
# into Claude's skills directory so Claude Code can discover them.

set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
skills_dir="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"

mkdir -p "$skills_dir"

found=0
for skill_file in "$repo_dir"/*/SKILL.md; do
    [ -e "$skill_file" ] || continue
    found=1

    src="$(dirname "$skill_file")"
    name="$(basename "$src")"
    dst="$skills_dir/$name"

    if [ -L "$dst" ]; then
        if [ "$(readlink "$dst")" = "$src" ]; then
            echo "ok       $name (already linked)"
        else
            echo "skip     $name (symlink points elsewhere: $(readlink "$dst"))" >&2
        fi
    elif [ -e "$dst" ]; then
        echo "skip     $name (already exists and is not a symlink)" >&2
    else
        ln -s "$src" "$dst"
        echo "linked   $name -> $src"
    fi
done

if [ "$found" -eq 0 ]; then
    echo "no skills found in $repo_dir (expected <skill-name>/SKILL.md)" >&2
    exit 1
fi
