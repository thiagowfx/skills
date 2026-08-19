claude_manifest := "plugins/thiagowfx/.claude-plugin/plugin.json"
pi_manifest := "package.json"
skills_dir := "plugins/thiagowfx/skills"

# List recipes
default:
    @just --list

# Print the current plugin version
version:
    @jq -r .version {{ claude_manifest }}

# List skill names
list-skills:
    @for skill in "{{ skills_dir }}"/*/SKILL.md; do \
      awk '/^name:/{print $2; exit}' "$skill"; \
    done | sort

# Update the installed thiagowfx plugin to the latest published version (restart required to apply)
update:
    claude plugin marketplace update thiagowfx
    claude plugin update thiagowfx@thiagowfx
    pi update git:github.com/thiagowfx/skills

# Check skills with drskill
doctor:
    #!/usr/bin/env bash
    set -euo pipefail
    tmp=$(mktemp -d)
    trap 'trash "$tmp"' EXIT
    mkdir -p "$tmp/project/.claude/skills" "$tmp/home"
    for skill in "$PWD"/{{ skills_dir }}/*; do
      ln -s "$skill" "$tmp/project/.claude/skills/$(basename "$skill")"
    done
    uv_cache=$(uv cache dir)
    cd "$tmp/project"
    HOME="$tmp/home" UV_CACHE_DIR="$uv_cache" uvx drskill scan --ci --harness claude-code

# Bump the plugin version (level = major | minor | patch)
bump level="patch":
    #!/usr/bin/env bash
    set -euo pipefail
    cur=$(jq -r .version {{ claude_manifest }})
    IFS=. read -r major minor patch <<<"$cur"
    case "{{ level }}" in
      major) major=$((major + 1)); minor=0; patch=0 ;;
      minor) minor=$((minor + 1)); patch=0 ;;
      patch) patch=$((patch + 1)) ;;
      *) echo "level must be major, minor, or patch" >&2; exit 1 ;;
    esac
    new="$major.$minor.$patch"
    tmp=$(mktemp)
    jq --arg v "$new" '.version = $v' {{ claude_manifest }} >"$tmp" && mv "$tmp" {{ claude_manifest }}
    tmp=$(mktemp)
    jq --arg v "$new" '.version = $v' {{ pi_manifest }} >"$tmp" && mv "$tmp" {{ pi_manifest }}
    echo "$cur -> $new"

alias release := bump

# Scaffold a third-party skill from upstream (e.g. `just vendor-skill mattpocock/skills handoff`)
vendor-skill pkg skill:
    #!/usr/bin/env bash
    set -euo pipefail
    dir="{{ skills_dir }}/{{ skill }}"
    if [[ -e "$dir" ]]; then echo "$dir already exists" >&2; exit 1; fi
    # Fetch into a tempfile and validate before creating the skill dir, so a failed or
    # redesigned upstream fetch never leaves a partial dir behind.
    # `skills use` prints a prompt preamble + the SKILL.md fenced block; extract the block.
    tmp=$(mktemp)
    npx -y skills@latest use "{{ pkg }}@{{ skill }}" \
      | sed -n '/^<SKILL.md>$/,/^<\/SKILL.md>$/p' \
      | sed '1d;$d' \
      > "$tmp"
    if [[ ! -s "$tmp" ]]; then echo "fetch produced empty SKILL.md" >&2; exit 1; fi
    mkdir -p "$dir"
    mv "$tmp" "$dir/SKILL.md"
    echo "Scaffolded $dir/SKILL.md from {{ pkg }}@{{ skill }}"
    echo
    echo "Manual steps remaining:"
    echo "  1. Add 'source:' to frontmatter: source: https://github.com/{{ pkg }} (<path>, <LICENSE> © <Author>)"
    echo "  2. Make body self-contained — drop refs to helper files / sibling skills not in this repo"
    echo "  3. README.md: add skills-table row + provenance paragraph mention"
    echo "  4. THIRD_PARTY.md: add bullet under the upstream's heading (+ license notice if new owner)"
    echo "  5. just bump"
