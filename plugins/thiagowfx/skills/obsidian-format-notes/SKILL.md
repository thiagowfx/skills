---
name: obsidian-format-notes
description: Reformat messy notes in an Obsidian vault into clean, consistent Obsidian-flavored Markdown, for one note, a folder, or every note under the current directory. Use when the user says "format this note", "format the vault", "clean up my Obsidian notes", "tidy my notes", "obsidian format", or points at a note with loose lines, unfenced code, or no headings.
allowed-tools: Bash(rg:*), Bash(find:*), Bash(git diff:*), Bash(git status:*), Bash(ls:*), Bash(wc:*), Read, Edit, Write
---

Reformat notes into clean Obsidian-flavored Markdown. Change structure and style only. Keep all meaning.

## Scope

- Work on the current working directory. The user normally runs `cd` to the vault first. Do not hard-code any vault path.
- Input is one note, a folder, or "everything" (all `.md` files under the current directory, recursively). If the user names none, ask which.
- Skip these paths: `.obsidian/`, `.git/`, `.trash/`, other hidden folders, attachment folders, and every non-`.md` file.
- Skip `.md` files that are not plain notes: Excalidraw drawings (frontmatter with `excalidraw-plugin`), Kanban boards (`kanban-plugin`), and files with template tags such as `<% %>`.
- Edit only the files the user asked for.
- Read the project instructions (`AGENTS.md` or similar) for read-only folders. Skip them.
- For a bulk run:
  1. List the files and ask the user to confirm.
  2. Offer a dry run (a report only, no edits). The report lists, for each file, the rules that would apply.
  3. Format one file first. Show the diff. Get approval before you continue.
  4. Process the rest in batches of at most 10 files.
- If the directory is a git repo, run `git status` first. If there are uncommitted changes, ask the user to commit or stash first, so they can review and revert the formatting changes.
- If it is not a git repo, warn the user that there is no easy undo. Ask to continue.

## Obsidian syntax to preserve exactly

- Wikilinks `[[Note]]`, `[[Note|alias]]`, `[[Note#Heading]]`, and embeds `![[...]]`.
- Callouts (`> [!note]`), tags (`#tag`), block IDs (`^id`), comments (`%% ... %%`), and highlights (`==text==`).
- Dataview and other plugin code blocks (`dataview`, `tasks`, `mermaid`, and so on). Do not change their content.
- Task checkboxes `- [ ]` and `- [x]`.
- Math (`$...$`, `$$...$$`) and footnotes (`[^1]`).
- Template tags (`<% %>`, `{{...}}`).
- The `>` prefix of callouts and quotes. Format content inside them in place. Do not move it out.
- Frontmatter (YAML properties).

## Rules

Rules 7 to 13 apply to prose only. Do not apply them inside preserved syntax, fenced code, link targets, URLs, or frontmatter.

1. Preserve the frontmatter exactly (aliases, tags, and so on). Never invent frontmatter.
2. Preserve all meaning. Do not add, remove, or reorder facts.
3. Add one `#` title if the note has none. Use the file name. Put it after the frontmatter, before the first content.
4. Group content under `##` and `###` headings. Do not skip heading levels.
5. Turn orphan bold labels such as `**Identity**` into headings.
6. Turn loose lines into bullet lists where the lines are parallel items.
7. Put code, shell scripts, config, and ID patterns (for example `ABC-1234`) in fenced blocks with a language tag (`bash`, `yaml`, `json`).
8. Fix tables. Align the columns and keep the header separator.
9. Wrap bare URLs in `<...>` or in a link with text. Skip URLs that are already in a link, in code, or in frontmatter.
10. Remove runs of blank lines. Remove blank "spacer" lines made of only spaces. Use exactly one blank line between blocks. Do not change blank lines inside fenced blocks.
11. Remove stray bold markup over whole code blocks. Remove trailing whitespace, but keep two trailing spaces that make a hard line break before a following line.
12. Use sentence case for headings that you create. Do not rename existing headings, because links such as `[[Note#Heading]]` point to them. Use straight quotes. Do not use em dashes (use a comma, a colon, or parentheses).
13. Make light wording fixes only: typos, "whitelist" to "allowlist". Never rewrite the author's voice.
14. End the file with one newline.

## Safety

- Make no change that you cannot justify from the rules above.
- If the intent of a passage is unclear (for example a stray one-line fact with no context), keep it. Put it under a "Notes" section. Do not delete it.
- Never write secrets or tokens into a note. If a note already contains one, do not copy it into the report.
- In a git repo, run `git diff --stat` after each file. Outside git, run `wc -w` on each file before the edit and again after it. Compare the counts to confirm no content was lost.
- A second run on a formatted note must give no diff. Do not create a second "Notes" section. Do not re-wrap content that is already formatted.
- Do not rename or move files. Do not change link targets, including heading text that other notes can link to.
- If a file needs no change, do not rewrite it.

## Output

Report in short form:

- Files changed.
- Files skipped.
- Any passage you were unsure about.

Write the report in ASD-STE100 Simplified Technical English.
