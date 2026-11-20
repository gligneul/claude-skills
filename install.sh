#!/usr/bin/env bash
# Symlinks CLAUDE.md into Claude's config directory and every skill directory
# in this repo (a directory containing SKILL.md) into Claude's skills directory
# so Claude Code can discover them.

set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
claude_dir="${CLAUDE_DIR:-$HOME/.claude}"
skills_dir="${CLAUDE_SKILLS_DIR:-$claude_dir/skills}"

link() {
    local src="$1" dst="$2" name="$3"

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
}

mkdir -p "$claude_dir" "$skills_dir"

link "$repo_dir/CLAUDE.md" "$claude_dir/CLAUDE.md" CLAUDE.md

found=0
for skill_file in "$repo_dir"/*/SKILL.md; do
    [ -e "$skill_file" ] || continue
    found=1

    src="$(dirname "$skill_file")"
    name="$(basename "$src")"
    link "$src" "$skills_dir/$name" "$name"
done

if [ "$found" -eq 0 ]; then
    echo "no skills found in $repo_dir (expected <skill-name>/SKILL.md)" >&2
    exit 1
fi
