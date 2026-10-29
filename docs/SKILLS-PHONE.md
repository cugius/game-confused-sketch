# Confused By Me Canon: use from a phone

## ChatGPT

The personal **Confused By Me Canon** skill has been installed. Open the sidebar → Plugins → Skills and find the skill; refresh/reopen that page if necessary. Mention it from the skill selector, or ask “Applica Confused By Me Canon a Sketch”. Repository-based Codex tasks also find the copy under `.agents/skills/`.

## Claude

1. Download `skills/confused-by-me-canon-claude.zip` to the iPhone Files app and keep it compressed.
2. Open claude.ai in Safari using the intended account. Enable Code execution and file creation in Settings → Capabilities if available/required for the account.
3. Open Customize → Skills → + → Create skill → Upload a skill and choose the downloaded ZIP. Enable the skill. If the phone layout does not show the controls, request the desktop website in Safari.
4. In a conversation say “Applica la skill confused-by-me-canon a questo repository”. Connect/open the intended repository when code access is needed; installing the skill does not grant access by itself.

A skill activated in one product is not automatically installed in the other. In Claude Code the repository copy is under `.claude/skills/`. Both copies follow the same pinned canon in `docs/CANON.md`; the included reference is the portable fallback for a new project.

Sources checked 29 October 2026:
- https://learn.chatgpt.com/docs/build-skills
- https://support.claude.com/en/articles/12512180-use-skills-in-claude

## Updating

Change the authoritative canon deliberately, then regenerate the skill references/packages and update the pinned version for each game. Do not maintain independently rewritten GPT/Claude rules. Automatic checks belong in CI; a skill cannot certify tests that its environment cannot run.
