#!/usr/bin/env python3
"""Block banned words before they reach Lucas or a file.

Two hook events, one script:
  Stop        -> scans the last assistant message in the transcript
  PreToolUse  -> scans Write/Edit content before it is written

Exit 2 blocks and sends stderr back to Claude, which then has to rewrite.

The list lives in the voice skill at skills/voice/references/banned-words.md and is
read on every run, so adding a word there needs no code change. Same file the voice
skill reads when ghost-writing. Everything is in the dotfiles repo, so every machine
gets it (~/.claude/bin and ~/.claude/skills are dir symlinks into the repo).
"""

import json
import os
import re
import sys

# Canonical list, shared with the voice skill. ~/.claude/skills is a dir symlink into
# the dotfiles repo, so every machine reads the same file.
LIST_FILE = os.path.expanduser("~/.claude/skills/voice/references/banned-words.md")

FENCED = re.compile(r"```.*?```|~~~.*?~~~", re.S)
INLINE = re.compile(r"`[^`\n]*`")
URL = re.compile(r"https?://\S+")
# Note titles and file names are data, not prose: "[[AI Writing Tells — Research Base]]".
LINK = re.compile(r"\[\[[^\]]*\]\]")


def load_list():
    """Parse banned-words.md into (word_regex, [(regex, label)], exempt_paths)."""
    words, phrases, patterns, exempt = [], [], [], []
    section = None
    try:
        with open(LIST_FILE, encoding="utf-8") as handle:
            lines = handle.readlines()
    except OSError:
        return None, [], []

    for raw in lines:
        line = raw.strip()
        if line.startswith("##"):
            section = line.lstrip("#").strip().lower()
            continue
        if not line or line.startswith(("#", ">")):
            continue  # blank, comment, or blockquote prose
        if section == "words":
            words.append(line)
        elif section == "phrases":
            phrases.append(line)
        elif section == "regex" and "|" in line:
            pattern, _, label = line.rpartition("|")
            patterns.append((pattern.strip(), label.strip()))
        elif section == "exempt-paths":
            exempt.append(line)

    # Phrases match literally, single words match every inflection.
    terms = sorted(phrases, key=len, reverse=True)
    parts = [re.escape(p) for p in terms] + [inflections(w) for w in sorted(set(words))]
    word_re = re.compile(r"\b(" + "|".join(parts) + r")\b", re.I) if parts else None
    return word_re, patterns, exempt


def inflections(word):
    """One entry in the list covers its variations: gate, gates, gated, gating, gatingly."""
    if " " in word or "-" in word:
        return re.escape(word)
    stem = re.escape(word)
    suffix = "(?:s|es|ed|d|ing|ings|ly|ingly|er|ers|est)?"
    if word.endswith("e"):
        # gate -> gating, gated: the final e drops before a vowel suffix
        return f"(?:{stem}{suffix}|{re.escape(word[:-1])}(?:ing|ed|es|ingly))"
    if word.endswith("y") and len(word) > 2 and word[-2] not in "aeiou":
        # tidy -> tidies, tidied
        return f"(?:{stem}{suffix}|{re.escape(word[:-1])}(?:ies|ied|ily))"
    if len(word) >= 3 and word[-1] not in "aeiousxyz" and word[-2] in "aeiou" and word[-3] not in "aeiou":
        # ban -> banning, banned: short vowel doubles the final consonant
        return f"(?:{stem}{word[-1]}?{suffix})"
    return f"{stem}{suffix}"


def summarise():
    """Raw list text for the up-front reminder, so there is still one source of truth."""
    words, phrases, labels = [], [], []
    section = None
    try:
        lines = open(LIST_FILE, encoding="utf-8").readlines()
    except OSError:
        return "", "", ""
    for raw in lines:
        line = raw.strip()
        if line.startswith("##"):
            section = line.lstrip("#").strip().lower()
            continue
        if not line or line.startswith(("#", ">")):
            continue
        if section == "words":
            words.append(line)
        elif section == "phrases":
            phrases.append(line)
        elif section == "regex" and "|" in line:
            labels.append(line.rpartition("|")[2].strip())
    return ", ".join(words), "; ".join(phrases), "; ".join(labels)


def strip_code(text):
    """Technical usage inside code is fine, only prose is checked."""
    for pattern in (FENCED, INLINE, URL, LINK):
        text = pattern.sub(" ", text)
    return text


def find_hits(text, word_re, patterns):
    prose = strip_code(text)
    hits = []
    if word_re:
        for match in word_re.finditer(prose):
            hits.append(match.group(0).lower())
    for pattern, label in patterns:
        try:
            if re.search(pattern, prose, re.I):
                hits.append(label)
        except re.error:
            continue  # a bad line in the list file must not break the hook
    seen = []
    for hit in hits:
        if hit not in seen:
            seen.append(hit)
    return seen


def last_assistant_text(transcript_path):
    if not transcript_path or not os.path.exists(transcript_path):
        return ""
    with open(transcript_path, encoding="utf-8", errors="replace") as handle:
        lines = handle.readlines()
    for line in reversed(lines):
        try:
            entry = json.loads(line)
        except ValueError:
            continue
        if entry.get("type") != "assistant":
            continue
        content = entry.get("message", {}).get("content", [])
        if isinstance(content, str):
            return content
        parts = [b.get("text", "") for b in content if isinstance(b, dict) and b.get("type") == "text"]
        text = "\n".join(p for p in parts if p).strip()
        if text:
            return text
    return ""


def block(hits, where):
    print(
        f"BANNED WORDS in {where}: {', '.join(hits)}\n"
        f"Lucas hard-banned these (full list: {LIST_FILE}).\n"
        "Resend the SAME message with those words replaced. This hook is invisible to him: "
        "do not acknowledge it, do not say 'understood' or 'you are right', do not describe "
        "the rewrite, do not apologise. A reply that only acknowledges this is the failure mode.",
        file=sys.stderr,
    )
    sys.exit(2)


def main():
    try:
        payload = json.load(sys.stdin)
    except ValueError:
        sys.exit(0)

    word_re, patterns, exempt = load_list()
    if not word_re and not patterns:
        sys.exit(0)  # no list, nothing to enforce

    event = payload.get("hook_event_name")

    if event == "UserPromptSubmit":
        # A Stop hook cannot help with chat text: the reply is already on screen by then,
        # and blocking only produces a second message. So the list is injected up front
        # instead, before anything is written.
        words, phrases, labels = summarise()
        print(json.dumps({"hookSpecificOutput": {
            "hookEventName": "UserPromptSubmit",
            "additionalContext": (
                "Before sending this reply, scan it for banned words. Never use: "
                f"{words}. Never use these phrases: {phrases}. Never use these shapes: {labels}. "
                "No em-dash. Inflections count (gated, gating, landing). "
                f"Canonical list: {LIST_FILE}"
            ),
        }}))
        sys.exit(0)

    if event == "PreToolUse":
        tool_input = payload.get("tool_input", {})
        path = str(tool_input.get("file_path", ""))
        if any(token in path for token in exempt):
            sys.exit(0)
        text = " ".join(str(tool_input.get(key, "")) for key in ("content", "new_string"))
        hits = find_hits(text, word_re, patterns)
        if hits:
            block(hits, os.path.basename(path) or "this edit")

    sys.exit(0)


if __name__ == "__main__":
    main()
