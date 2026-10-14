# HyperCard test stacks

Input for `tests/lcs/core/interface/hypercard-import.livecodescript`, the
engine test of `import stack from file` with HyperCard stacks. Every file
here is real HyperCard data; none of it is installed with OXT-Beyond.

| Files | From | Licence |
| --- | --- | --- |
| `Test*.stack` | [HyperCardPreview](https://github.com/PierreLorenzi/HyperCardPreview)'s test stacks (`HyperCardCommon/HyperCardCommonTests/`, commit `6a84decae921`), made in HyperCard by Pierre Lorenzi | MIT, [`LICENSE.txt`](LICENSE.txt) |
| `TestFormattedContent.hqx` | `TestFormattedContent.stack` in a BinHex 4.0 file (type `STAK`, creator `WILD`, no resource fork), made for this test | MIT, as above |
| `games/Surf.stack` | `surf` from [damianuhx/hypercard-games](https://github.com/damianuhx/hypercard-games) (commit `d04170f991d1`) | Public domain, [`games/UNLICENSE.txt`](games/UNLICENSE.txt) |

Before adding a stack, check that its licence lets us redistribute it (the
stacks Apple shipped with HyperCard do not), and that it is not infected:
many stacks from the time carry a HyperCard virus in their scripts, such
as "Merryxmas" (`on openbackground --merryxmas`), which copies itself into
the Home stack and can quit the program. Most of the other stacks in
damianuhx/hypercard-games are infected with it, and are left out for that
reason. The test imports with messages locked, so no stack's own scripts
run, but a stack here can still be opened by hand.

`.gitattributes` marks `*.stack` and `*.hqx` binary: a BinHex file has
Mac line endings that must not be changed.
