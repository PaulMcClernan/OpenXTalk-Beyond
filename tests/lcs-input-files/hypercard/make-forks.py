#!/usr/bin/env python3
"""Write the synthetic resource forks in forks/.

The HyperCard import test (tests/lcs/core/interface/hypercard-import.
livecodescript) needs stacks that carry a resource fork, and no stack whose
fork we may redistribute has one, so the forks are made here from nothing:
every byte below is written by this script. Run it from anywhere after
changing it, and commit what it writes:

    python3 tests/lcs-input-files/hypercard/make-forks.py

forks/Synthetic.rsrc        a raw resource fork (Inside Macintosh: More
                            Macintosh Toolbox, 1-121): ICON 128, CURS 129,
                            snd 130, PICT 131, XCMD 132, XFCN 133
forks/Synthetic.appledouble the same fork in an AppleDouble file (RFC 1740),
                            as macOS writes "._Name"
forks/Empty.appledouble     an AppleDouble file whose fork holds nothing, as
                            macOS writes for a file with Finder info only
forks/TestCardsBackgrounds.applesingle
                            ../TestCardsBackgrounds.stack and the fork in one
                            AppleSingle file, named "Synthetic Stack"
"""

import os
import struct

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(HERE, "forks")


def icon():
    # 32x32, 1 bit: a frame with a diagonal, so that a wrong row stride or
    # bit order shows
    rows = []
    for y in range(32):
        row = 0
        for x in range(32):
            if x in (0, 31) or y in (0, 31) or x == y:
                row |= 1 << (31 - x)
        rows.append(struct.pack(">I", row))
    return b"".join(rows)


def cursor():
    # 16x16 image, 16x16 mask, hot spot (v, h) = (8, 4)
    image = b"".join(struct.pack(">H", 0x8000 >> (y % 16)) for y in range(16))
    mask = b"\xff\xff" * 16
    return image + mask + struct.pack(">hh", 8, 4)


def sound(samples):
    # format 2 'snd ': one bufferCmd (0x8051, the data offset flag set)
    # pointing at a standard sound header, 8-bit unsigned, 22254 Hz
    header_at = 2 + 2 + 2 + 8
    out = struct.pack(">HHH", 2, 0, 1)
    out += struct.pack(">HHI", 0x8051, 0, header_at)
    out += struct.pack(">IIIII", 0, len(samples), 0x56EE8BA3, 0, 0)
    out += bytes([0, 0x3C])
    return out + samples


def pict():
    # a version 1 PICT that draws nothing: size, frame, version, end
    return struct.pack(">Hhhhh", 10, 0, 0, 32, 32) + b"\x11\x01\xff"


def resource_fork(resources):
    """resources: [(type, id, name or None, data)], grouped by type in order"""
    data = b""
    offsets = []
    for _type, _id, _name, body in resources:
        offsets.append(len(data))
        data += struct.pack(">I", len(body)) + body
    types = []
    for rtype, _id, _name, _body in resources:
        if rtype not in types:
            types.append(rtype)
    names = b""
    name_offsets = []
    for _type, _id, name, _body in resources:
        if name is None:
            name_offsets.append(0xFFFF)
        else:
            raw = name.encode("mac_roman")
            name_offsets.append(len(names))
            names += bytes([len(raw)]) + raw
    type_list = struct.pack(">H", len(types) - 1)
    ref_lists = b""
    ref_base = 2 + 8 * len(types)
    for rtype in types:
        members = [i for i, r in enumerate(resources) if r[0] == rtype]
        type_list += rtype.encode("ascii") + struct.pack(
            ">HH", len(members) - 1, ref_base + len(ref_lists))
        for i in members:
            ref_lists += struct.pack(">hHI", resources[i][1], name_offsets[i],
                                     offsets[i] & 0xFFFFFF) + b"\0\0\0\0"
    data_offset = 256
    map_offset = data_offset + len(data)
    types_offset = 28
    names_offset = types_offset + len(type_list) + len(ref_lists)
    map_size = names_offset + len(names)
    header = struct.pack(">IIII", data_offset, map_offset, len(data), map_size)
    # the map: a copy of the header, a handle and a file reference (both
    # zero on disk), attributes, then the offsets of the type and name lists
    rmap = header + struct.pack(">IHHHH", 0, 0, 0, types_offset, names_offset)
    assert len(rmap) == types_offset
    rmap += type_list + ref_lists + names
    return header + b"\0" * (data_offset - 16) + data + rmap


def applefile(magic, entries):
    """entries: [(id, bytes)]"""
    out = struct.pack(">II", magic, 0x00020000) + b"\0" * 16
    out += struct.pack(">H", len(entries))
    offset = len(out) + 12 * len(entries)
    table = b""
    body = b""
    for entry_id, data in entries:
        table += struct.pack(">III", entry_id, offset + len(body), len(data))
        body += data
    return out + table + body


FINDER_INFO = b"STAKWILD" + b"\0" * 24
APPLESINGLE = 0x00051600
APPLEDOUBLE = 0x00051607


def main():
    os.makedirs(OUT, exist_ok=True)
    samples = bytes(128 + (40 if (i // 25) % 2 else -40) for i in range(2000))
    fork = resource_fork([
        ("ICON", 128, "Synth Icon", icon()),
        ("CURS", 129, "Synth Cursor", cursor()),
        ("snd ", 130, "Synth Beep", sound(samples)),
        ("PICT", 131, "Synth Picture", pict()),
        ("XCMD", 132, "PopUpMenu", b"\x4e\x75"),
        ("XFCN", 133, "FileName", b"\x4e\x75"),
    ])
    # macOS's empty fork: a map with no types (the type count field is -1)
    data_offset = 256
    header = struct.pack(">IIII", data_offset, data_offset, 0, 30)
    empty = header + b"\0" * (data_offset - 16) + header + \
        struct.pack(">IHHHHH", 0, 0, 0, 28, 30, 0xFFFF)
    with open(os.path.join(HERE, "TestCardsBackgrounds.stack"), "rb") as f:
        stack = f.read()
    files = {
        "Synthetic.rsrc": fork,
        "Synthetic.appledouble": applefile(APPLEDOUBLE, [(9, FINDER_INFO), (2, fork)]),
        "Empty.appledouble": applefile(APPLEDOUBLE, [(9, FINDER_INFO), (2, empty)]),
        "TestCardsBackgrounds.applesingle": applefile(APPLESINGLE, [
            (3, b"Synthetic Stack"), (9, FINDER_INFO), (1, stack), (2, fork)]),
    }
    for name, data in files.items():
        with open(os.path.join(OUT, name), "wb") as f:
            f.write(data)
        print("%-36s %6d bytes" % (name, len(data)))


if __name__ == "__main__":
    main()
