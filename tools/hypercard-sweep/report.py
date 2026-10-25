#!/usr/bin/env python3
"""Sum up a sweep's logs, or compare two sweeps handler by handler.

    python3 report.py runs/fix-main
    python3 report.py runs/fix-main --compare runs/fix-branch

One run: how many stacks imported, ran clean, timed out; the handlers
left out, grouped by the parse error (with the HyperTalk line of a few);
the lines left out of handlers that were kept (rule T39), grouped the
same way; and for a "run" sweep the errors while running, and the
handlers no object had. Error numbers are named from
engine/src/parseerrors.h and executionerrors.h of this checkout.

--compare: the handlers each stack left out in the first run and in the
second, by name (a doMenu handler is one handler, whether the import
kept its name or, outside HyperCard's message order, named it
hcDoMenu). A handler no longer left out either compiles whole or was
kept with lines left out of it (T39), counted apart. "Newly left out"
must be zero for a change to rules that only add forms; every one is
listed by stack and handler. For two "run" sweeps it also compares the
errors while running: their number, the stacks with none, and the kinds
of error that came more or less often.
"""

import argparse
import base64
import collections
import os
import re

HERE = os.path.dirname(os.path.abspath(__file__))
ENGINE = os.path.normpath(os.path.join(HERE, "..", "..", "engine", "src"))


def error_names(header, prefix):
    names = {}
    try:
        with open(os.path.join(ENGINE, header), encoding="utf-8", errors="replace") as handle:
            for line in handle:
                match = re.search(r"\{%s-(\d+)\}\s*(.*)" % prefix, line)
                if match:
                    names[int(match.group(1))] = match.group(2).strip()
    except OSError:
        pass
    return names


PARSE = error_names("parseerrors.h", "PE")
EXECUTION = error_names("executionerrors.h", "EE")


def decode(text):
    try:
        return base64.b64decode(text).decode("utf-8", "replace")
    except (ValueError, TypeError):
        return ""


def read_run(folder):
    """{stack: {...}} from the logs of one run."""
    stacks = {}
    index = {}
    for name in sorted(os.listdir(folder)):
        if not re.match(r"\d+\.txt$", name):
            continue
        stack = {"imported": False, "opened": False, "done": False, "exit": None, "left": [], "lines": [],
                 "errors": [], "mace": (0, 0)}
        with open(os.path.join(folder, name), encoding="utf-8", errors="replace") as handle:
            for line in handle:
                fields = line.rstrip("\n").split("\t")
                kind = fields[0]
                if kind == "IMPORTED":
                    stack["imported"] = True
                    stack["name"] = fields[1] if len(fields) > 1 else ""
                elif kind == "LEFT" and len(fields) >= 4:
                    stack["left"].append((fields[1], fields[2], decode(fields[3])))
                elif kind == "LINE" and len(fields) >= 6:
                    # a line rule T39 left out of a handler it kept: the
                    # handler, the line's number in it, skipped or stops,
                    # the compile error, the line's HyperTalk
                    stack["lines"].append((fields[1], fields[2], fields[3], fields[4], decode(fields[5])))
                elif kind in ("ERR", "THROW") and len(fields) >= 3:
                    stack["errors"].append((decode(fields[2]), decode(fields[3]) if len(fields) > 3 else ""))
                elif kind == "MACE" and len(fields) >= 3:
                    # the MACE sounds the import log names, and how many
                    # the IDE's decoder added as audio clips
                    try:
                        stack["mace"] = (int(fields[1]), int(fields[2]))
                    except ValueError:
                        stack["mace"] = (int(fields[1]) if fields[1].isdigit() else 0, 0)
                elif kind == "OPENED":
                    stack["opened"] = True
                elif kind == "DONE":
                    stack["done"] = True
                elif kind == "EXIT":
                    stack["exit"] = fields[1] if len(fields) > 1 else ""
        stacks[name[:-4]] = stack
    return stacks


def handler_key(name):
    """A handler's name for comparing two runs: outside HyperCard's message
    order the import names an "on doMenu" handler hcDoMenu"""
    name = name.lower()
    return "domenu" if name == "hcdomenu" else name


def error_key(error):
    """An error while running, by its first line: the error's name and
    the token it names"""
    first = error.split("\n")[0].split(",")
    try:
        number = int(first[0])
    except ValueError:
        return None
    return EXECUTION.get(number, "error %d" % number), ",".join(first[3:]).lower()[:30]


def parse_key(error):
    parts = error.split(",")
    try:
        number = int(parts[0])
    except ValueError:
        return error, ""
    return PARSE.get(number, "parse error %d" % number), ",".join(parts[3:]).lower()[:30]


def source_line(error, text):
    parts = error.split(",")
    try:
        line = int(parts[1])
    except (ValueError, IndexError):
        return ""
    lines = text.split("\n")
    return lines[line - 1].strip() if 0 < line <= len(lines) else ""


def summary(folder, limit):
    stacks = read_run(folder)
    imported = [s for s in stacks.values() if s["imported"]]
    print("stacks", len(stacks), "imported", len(imported),
          "finished", sum(s["done"] for s in stacks.values()),
          "timed out", sum(s["exit"] == "timeout" for s in stacks.values()))
    print("handlers left out", sum(len(s["left"]) for s in imported),
          "in", sum(1 for s in imported if s["left"]), "stacks")
    if any(s["lines"] for s in imported):
        lines = [line for s in imported for line in s["lines"]]
        print("lines left out of handlers kept (T39)", len(lines), "in",
              sum(1 for s in imported if s["lines"]), "stacks;",
              sum(1 for line in lines if line[2] == "skipped"), "skipped,",
              sum(1 for line in lines if line[2] == "stops"), "stop their handler")
    if any(s["mace"] != (0, 0) for s in imported):
        print("MACE sounds", sum(s["mace"][0] for s in imported), "logged,",
              sum(s["mace"][1] for s in imported), "decoded into audio clips, in",
              sum(1 for s in imported if s["mace"][0]), "stacks")
    if any(s["opened"] for s in imported):
        print("errors while running", sum(len(s["errors"]) for s in imported),
              "in", sum(1 for s in imported if s["errors"]), "stacks;",
              "no error at all", sum(1 for s in imported if not s["errors"] and not s["left"]))

    groups = collections.defaultdict(lambda: {"stacks": set(), "count": 0, "examples": []})
    for name, stack in stacks.items():
        for handler, error, text in stack["left"]:
            group = groups[parse_key(error)]
            group["stacks"].add(name)
            group["count"] += 1
            if len(group["examples"]) < 3:
                group["examples"].append(source_line(error, text)[:110])
    print("\n== handlers left out: stacks, handlers, parse error")
    for key, group in sorted(groups.items(), key=lambda item: -len(item[1]["stacks"]))[:limit]:
        print(len(group["stacks"]), group["count"], key)
        for example in group["examples"]:
            print("      ", example)

    groups = collections.defaultdict(lambda: {"stacks": set(), "count": 0, "examples": []})
    for name, stack in stacks.items():
        for handler, line, how, error, text in stack["lines"]:
            group = groups[parse_key(error)]
            group["stacks"].add(name)
            group["count"] += 1
            if len(group["examples"]) < 3:
                group["examples"].append(("[stops] " if how == "stops" else "") + text[:110])
    if groups:
        print("\n== lines left out of handlers kept (T39): stacks, lines, parse error")
        for key, group in sorted(groups.items(), key=lambda item: -len(item[1]["stacks"]))[:limit]:
            print(len(group["stacks"]), group["count"], key)
            for example in group["examples"]:
                print("      ", example)

    errors = collections.defaultdict(set)
    missing = collections.defaultdict(set)
    for name, stack in stacks.items():
        for error, source in stack["errors"]:
            key = error_key(error)
            if key is None:
                continue
            errors[key].add(name)
            for line in error.split("\n"):
                parts = line.split(",")
                if parts[0] == "573" and len(parts) > 3:
                    missing[parts[3].lower()].add(name)
                    break
    if errors:
        print("\n== errors while running: stacks, error")
        for key, names in sorted(errors.items(), key=lambda item: -len(item[1]))[:limit]:
            print(len(names), key)
        print("\n== handlers no object had: stacks, name")
        for key, names in sorted(missing.items(), key=lambda item: -len(item[1]))[:limit]:
            print(len(names), key)


def compare(first_folder, second_folder):
    first = read_run(first_folder)
    second = read_run(second_folder)
    both = [name for name in first if name in second and first[name]["imported"] and second[name]["imported"]]
    newly_left = []
    newly_saved = 0
    newly_kept = 0
    for name in both:
        before = collections.Counter(handler_key(handler) for handler, _, _ in first[name]["left"])
        after = collections.Counter(handler_key(handler) for handler, _, _ in second[name]["left"])
        for handler, count in (after - before).items():
            newly_left.append((name, handler, count))
        # a handler no longer left out compiles whole, or was kept with
        # lines left out of it (T39)
        with_lines = {handler_key(line[0]) for line in second[name]["lines"]}
        for handler, count in (before - after).items():
            if handler in with_lines:
                newly_kept += count
            else:
                newly_saved += count
    count_first = sum(len(first[name]["left"]) for name in both)
    count_second = sum(len(second[name]["left"]) for name in both)
    print("stacks in both", len(both))
    print("handlers left out:", count_first, "then", count_second)
    print("stacks with a handler left out:", sum(1 for name in both if first[name]["left"]),
          "then", sum(1 for name in both if second[name]["left"]))
    lines_first = sum(len(first[name]["lines"]) for name in both)
    lines_second = sum(len(second[name]["lines"]) for name in both)
    if lines_first or lines_second:
        print("lines left out of handlers kept (T39):", lines_first, "then", lines_second)
        print("stacks with a handler or a line left out:", sum(1 for name in both if first[name]["left"] or first[name]["lines"]),
              "then", sum(1 for name in both if second[name]["left"] or second[name]["lines"]))
    print("newly compiling", newly_saved, "newly kept with lines left out", newly_kept,
          "newly left out", sum(count for _, _, count in newly_left))
    for name, handler, count in newly_left:
        print("   newly left out:", name, handler, "x%d" % count if count > 1 else "")

    # two "run" sweeps: the errors while running
    if not any(first[name]["opened"] and second[name]["opened"] for name in both):
        return
    print("errors while running:", sum(len(first[name]["errors"]) for name in both),
          "in", sum(1 for name in both if first[name]["errors"]), "stacks, then",
          sum(len(second[name]["errors"]) for name in both),
          "in", sum(1 for name in both if second[name]["errors"]), "stacks")
    print("no error at all (none while running, no handler left out):",
          sum(1 for name in both if not first[name]["errors"] and not first[name]["left"]), "then",
          sum(1 for name in both if not second[name]["errors"] and not second[name]["left"]))
    print("stacks with errors while running in the second run only:",
          sum(1 for name in both if second[name]["errors"] and not first[name]["errors"]),
          "in the first only:", sum(1 for name in both if first[name]["errors"] and not second[name]["errors"]))
    more = collections.Counter()
    fewer = collections.Counter()
    for name in both:
        before = collections.Counter(error_key(error) for error, _ in first[name]["errors"])
        after = collections.Counter(error_key(error) for error, _ in second[name]["errors"])
        more.update(after - before)
        fewer.update(before - after)
    for title, counts, sign in (("more often", more, "+"), ("less often", fewer, "-")):
        if counts:
            print("errors while running %s in the second run (count, error):" % title)
            for key, count in counts.most_common(15):
                print("   %s%d" % (sign, count), key)


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("run")
    parser.add_argument("--compare", metavar="RUN")
    parser.add_argument("--limit", type=int, default=40)
    args = parser.parse_args()
    if args.compare:
        compare(args.run, args.compare)
    else:
        summary(args.run, args.limit)


if __name__ == "__main__":
    main()
