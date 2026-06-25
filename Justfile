manifest := "plugins/skills/.claude-plugin/plugin.json"

# List recipes
default:
    @just --list

# Print the current plugin version
version:
    @jq -r .version {{ manifest }}

# Bump the plugin version (level = major | minor | patch)
bump level="patch":
    #!/usr/bin/env bash
    set -euo pipefail
    cur=$(jq -r .version {{ manifest }})
    IFS=. read -r major minor patch <<<"$cur"
    case "{{ level }}" in
      major) major=$((major + 1)); minor=0; patch=0 ;;
      minor) minor=$((minor + 1)); patch=0 ;;
      patch) patch=$((patch + 1)) ;;
      *) echo "level must be major, minor, or patch" >&2; exit 1 ;;
    esac
    new="$major.$minor.$patch"
    tmp=$(mktemp)
    jq --arg v "$new" '.version = $v' {{ manifest }} >"$tmp" && mv "$tmp" {{ manifest }}
    echo "$cur -> $new"
