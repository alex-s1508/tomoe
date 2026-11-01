#!/usr/bin/env python3
"""Replace the source property in Fastfetch's top-level logo object."""

import json
import sys
from pathlib import Path


def skip_trivia(text: str, pos: int) -> int:
    size = len(text)
    while pos < size:
        if text[pos].isspace():
            pos += 1
        elif text.startswith("//", pos):
            end = text.find("\n", pos + 2)
            pos = size if end < 0 else end + 1
        elif text.startswith("/*", pos):
            end = text.find("*/", pos + 2)
            if end < 0:
                raise ValueError("comentário /* sem fechamento")
            pos = end + 2
        else:
            break
    return pos


def read_string(text: str, pos: int) -> tuple[str, int]:
    end = pos + 1
    escaped = False
    while end < len(text):
        char = text[end]
        if escaped:
            escaped = False
        elif char == "\\":
            escaped = True
        elif char == '"':
            token = text[pos : end + 1]
            return json.loads(token), end + 1
        end += 1
    raise ValueError("string JSON sem fechamento")


def find_logo_object(text: str) -> int:
    pos = 0
    while pos < len(text):
        pos = skip_trivia(text, pos)
        if pos >= len(text):
            break
        if text[pos] == '"':
            value, end = read_string(text, pos)
            if value == "logo":
                colon = skip_trivia(text, end)
                if colon < len(text) and text[colon] == ":":
                    opening = skip_trivia(text, colon + 1)
                    if opening < len(text) and text[opening] == "{":
                        return opening
            pos = end
        elif text.startswith(("//", "/*"), pos):
            pos = skip_trivia(text, pos)
        else:
            pos += 1
    raise ValueError('objeto "logo" não encontrado')


def inject(text: str, source: str) -> str:
    opening = find_logo_object(text)
    pos = opening + 1
    brace_depth = 1
    bracket_depth = 0
    value_spans: list[tuple[int, int]] = []

    while pos < len(text) and brace_depth:
        pos = skip_trivia(text, pos)
        if pos >= len(text):
            break
        char = text[pos]
        if char == '"':
            key, end = read_string(text, pos)
            if brace_depth == 1 and bracket_depth == 0 and key == "source":
                colon = skip_trivia(text, end)
                if colon < len(text) and text[colon] == ":":
                    value_pos = skip_trivia(text, colon + 1)
                    if value_pos < len(text) and text[value_pos] == '"':
                        _, value_end = read_string(text, value_pos)
                        value_spans.append((value_pos, value_end))
                        pos = value_end
                        continue
            pos = end
        elif text.startswith(("//", "/*"), pos):
            pos = skip_trivia(text, pos)
        elif char == "{":
            brace_depth += 1
            pos += 1
        elif char == "}":
            brace_depth -= 1
            pos += 1
        elif char == "[":
            bracket_depth += 1
            pos += 1
        elif char == "]":
            bracket_depth = max(0, bracket_depth - 1)
            pos += 1
        else:
            pos += 1

    if brace_depth:
        raise ValueError('objeto "logo" sem fechamento')
    if not value_spans:
        raise ValueError('propriedade "source" não encontrada dentro de "logo"')

    encoded_source = json.dumps(source, ensure_ascii=False)
    for start, end in reversed(value_spans):
        text = text[:start] + encoded_source + text[end:]
    return text


def main() -> int:
    if len(sys.argv) != 3:
        print(f"uso: {Path(sys.argv[0]).name} CONFIG SOURCE", file=sys.stderr)
        return 2
    try:
        config = Path(sys.argv[1]).read_text(encoding="utf-8")
        sys.stdout.write(inject(config, sys.argv[2]))
    except (OSError, ValueError, json.JSONDecodeError) as error:
        print(f"Fastfetch: {error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
