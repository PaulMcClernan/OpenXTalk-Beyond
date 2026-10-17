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
forks/Clash.rsrc            ids that collide: ICON 129 and CURS 129, ICON 2842
                            (card 1's id in TestCardsBackgrounds.stack), and
                            ICON 30000, above every object id of that stack
forks/Sounds.rsrc           the sound headers beyond the standard one: snd 200
                            "Stereo 16" (extended, 16-bit stereo), 201 "Mono 8
                            Extended", 202 "IMA" (compressed, IMA 4:1 stereo),
                            203 "MACE" (compressed, MACE 3:1: logged only)
forks/Pictures.rsrc         PICT 300 "Colour" (version 2: colour shapes, an
                            8-bit PackBitsRect, a 32-bit DirectBitsRect, a
                            BitsRect and a line) and PICT 301 (version 1,
                            unnamed: an oval and a PackBitsRect), drawn as
                            the test expects pixel by pixel
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


def extended_sound(channels, bits, frames, encode=0xFF, fmt=b"\0\0\0\0",
                   compression=0, samples=b""):
    # format 2, one bufferCmd, then a 64-byte extended (0xFF) or compressed
    # (0xFE) sound header and the samples
    header_at = 2 + 2 + 2 + 8
    out = struct.pack(">HHH", 2, 0, 1)
    out += struct.pack(">HHI", 0x8051, 0, header_at)
    head = struct.pack(">IIIII", 0, channels, 0x56EE8BA3, 0, 0)
    head += bytes([encode, 0x3C]) + struct.pack(">I", frames)
    head += b"\0" * 10  # the AIFF sample rate, unused
    if encode == 0xFF:
        head += struct.pack(">IIIHHIII", 0, 0, 0, bits, 0, 0, 0, 0)
    else:
        head += struct.pack(">I", 0) + fmt + struct.pack(">IIIhHHH", 0, 0, 0,
                                                          compression, 0, 0, bits)
    assert len(head) == 64, len(head)
    return out + head + samples


def pict():
    # a version 1 PICT that draws nothing: size, frame, version, end
    return struct.pack(">Hhhhh", 10, 0, 0, 32, 32) + b"\x11\x01\xff"


def packbits_row(row):
    # literal runs only: valid PackBits, if not the smallest
    out = b""
    for i in range(0, len(row), 128):
        chunk = row[i:i + 128]
        out += bytes([len(chunk) - 1]) + chunk
    return out


def packed_rows(rows, rowbytes):
    out = b""
    for row in rows:
        packed = packbits_row(row)
        out += (struct.pack(">H", len(packed)) if rowbytes > 250 else bytes([len(packed)])) + packed
    return out


def rect(top, left, bottom, right):
    return struct.pack(">hhhh", top, left, bottom, right)


def pict_v2():
    # 64 x 48: red square, blue oval, black frame on the top row; an 8-bit
    # indexed PackBitsRect (green | yellow), a 32-bit DirectBitsRect
    # (#123456) and a 1-bit BitsRect (black top half) below; a line
    w, h = 64, 48
    ops = b""

    def op(code, data=b""):
        nonlocal ops
        ops += struct.pack(">H", code) + data
        if len(ops) % 2:
            ops += b"\0"

    op(0x0011, b"\x02\xff")
    op(0x0C00, struct.pack(">hHII", -2, 0, 0x00480000, 0x00480000) + rect(0, 0, h, w) + b"\0" * 4)
    op(0x001E)
    op(0x0001, struct.pack(">H", 10) + rect(0, 0, h, w))
    op(0x001A, struct.pack(">HHH", 0xFFFF, 0, 0))
    op(0x0031, rect(0, 0, 16, 16))
    op(0x001A, struct.pack(">HHH", 0, 0, 0xFFFF))
    op(0x0051, rect(0, 16, 16, 32))
    op(0x001A, struct.pack(">HHH", 0, 0, 0))
    op(0x0030, rect(0, 32, 16, 48))
    # 8-bit indexed, 16 x 16: index 0 green on the left, 1 yellow on the right
    pixmap = struct.pack(">H", 0x8000 | 16) + rect(0, 0, 16, 16)
    pixmap += struct.pack(">HHIIIHHHHIII", 0, 0, 0, 0x00480000, 0x00480000, 0, 8, 1, 8, 0, 0, 0)
    ctab = struct.pack(">IHH", 0, 0x8000, 1)
    ctab += struct.pack(">HHHH", 0, 0, 0xFFFF, 0) + struct.pack(">HHHH", 1, 0xFFFF, 0xFFFF, 0)
    rows = [bytes([0] * 8 + [1] * 8) for _ in range(16)]
    op(0x0098, pixmap + ctab + rect(0, 0, 16, 16) + rect(16, 0, 32, 16) + struct.pack(">H", 0)
       + packed_rows(rows, 16))
    # 32-bit, packType 4, 3 components, 16 x 16 of #123456
    pixmap = struct.pack(">IH", 0xFF, 0x8000 | 64) + rect(0, 0, 16, 16)
    pixmap += struct.pack(">HHIIIHHHHIII", 0, 4, 0, 0x00480000, 0x00480000, 16, 32, 3, 8, 0, 0, 0)
    rows = [bytes([0x12] * 16 + [0x34] * 16 + [0x56] * 16) for _ in range(16)]
    op(0x009A, pixmap + rect(0, 0, 16, 16) + rect(16, 16, 32, 32) + struct.pack(">H", 0)
       + packed_rows(rows, 64))
    # 1-bit bitmap, unpacked, 16 x 16: the top 8 rows black
    bitmap = struct.pack(">H", 2) + rect(0, 0, 16, 16)
    bits = b"\xff\xff" * 8 + b"\0\0" * 8
    op(0x0090, bitmap + rect(0, 0, 16, 16) + rect(32, 0, 48, 16) + struct.pack(">H", 0) + bits)
    op(0x0020, struct.pack(">hhhh", 40, 20, 40, 60))
    op(0x00FF)
    body = rect(0, 0, h, w) + ops
    return struct.pack(">H", (2 + len(body)) & 0xFFFF) + body


def pict_v1():
    # 32 x 32, version 1: a painted oval in the top half, a PackBitsRect
    # bitmap (black bottom-right quarter) below
    ops = b"\x11\x01"
    ops += b"\x51" + rect(0, 0, 16, 32)
    bitmap = struct.pack(">H", 2) + rect(0, 0, 16, 16)
    rows = [b"\x00\xff" if y >= 8 else b"\x00\x00" for y in range(16)]
    # rowBytes 2 is under 8: rows are stored unpacked
    ops += b"\x98" + bitmap + rect(0, 0, 16, 16) + rect(16, 16, 32, 32) + struct.pack(">H", 0) + b"".join(rows)
    ops += b"\xff"
    body = rect(0, 0, 32, 32) + ops
    return struct.pack(">H", 2 + len(body)) + body


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
    clash = resource_fork([
        ("ICON", 129, "Twin Icon", icon()),
        ("ICON", 2842, "Card Twin", icon()),
        ("ICON", 30000, "High Icon", icon()),
        ("CURS", 129, "Twin Cursor", cursor()),
    ])
    stereo16 = b"".join(struct.pack(">hh", (i * 300) % 30000, -(i * 300) % 30000)
                        for i in range(500))
    mono8 = bytes(128 + (i % 64) for i in range(800))
    # IMA 4:1: two packets per channel, each a predictor of 0 and step
    # index 0 then alternating codes
    ima_packet = b"\0\0" + bytes([0x17, 0x9F] * 16)
    ima = ima_packet * 4
    sounds = resource_fork([
        ("snd ", 200, "Stereo 16", extended_sound(2, 16, 500, samples=stereo16)),
        ("snd ", 201, "Mono 8 Extended", extended_sound(1, 8, 800, samples=mono8)),
        ("snd ", 202, "IMA", extended_sound(2, 16, 2, encode=0xFE, fmt=b"ima4",
                                           compression=-2, samples=ima)),
        ("snd ", 203, "MACE", extended_sound(1, 8, 100, encode=0xFE, fmt=b"MAC3",
                                            compression=3, samples=b"\0" * 200)),
    ])
    pictures = resource_fork([
        ("PICT", 300, "Colour", pict_v2()),
        ("PICT", 301, None, pict_v1()),
    ])
    files = {
        "Synthetic.rsrc": fork,
        "Pictures.rsrc": pictures,
        "Sounds.rsrc": sounds,
        "Clash.rsrc": clash,
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
