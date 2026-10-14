# Plugin packages for other xTalks

The xTalk Assistant and the xTalk MCP Bridge ship built into OXT-Beyond
(`ide/Extensions/org.openxtalk.plugin.xtalkassistant` and
`ide/Extensions/org.openxtalk.plugin.mcpbridge`). This folder makes them
into extension packages (`.lce`) that the Extension Manager of any IDE
built on LiveCode Community 9 can install: LiveCode Community 9.x,
OpenXTalk, HyperXTalk, and OXT-Beyond itself.

```sh
python3 tools/plugins/build-plugin-packages.py            # into _build/plugins
python3 tools/plugins/build-plugin-packages.py --out DIR --version 0.2.7
python3 tools/plugins/build-plugin-packages.py --check DIR/*.lce
```

The packages are built from the plugins' own folders, so there is one copy
of their code. A package adds:

- `<main>-compat.livecodescript`, made from
  [plugin-compat.livecodescript.in](plugin-compat.livecodescript.in). On an
  IDE whose menu bar does not list the plugin (every IDE but OXT-Beyond), it
  writes a small launcher stack named after the menu item into the user's
  Plugins folder, so the plugin appears in Development > Plugins, and takes
  it out again when the extension is uninstalled. It also answers
  `revSEInsertText` and `revSEGetLastSelectedLine` for a Script Editor that
  has neither (LiveCode Community 9.6's), through the editor's own field
  handlers. It gives the IDE's name where the plugins name it (OXT-Beyond
  on OXT-Beyond; HyperXTalk, OpenXTalk or LiveCode elsewhere), and keeps
  the copy of the bridge's MCP server that Claude runs in `~/.oxt-beyond`,
  so that Claude's settings still point at a file after the package is
  upgraded (its install folder is named with its version). OXT-Beyond's
  own copy of the plugins has no such file, and the
  main stacks load it only when it is there, so nothing changes in
  OXT-Beyond's built-in plugins.
- For the bridge, `xtalkassistant/` with the assistant's core, build
  library and guide, which the bridge uses. In OXT-Beyond they are in the
  assistant's folder beside the bridge's; an installed package lives in a
  folder of its own, named with its version.
- The version: the package manifest says OXT-Beyond's version
  (`ide/.version`), so each release's packages install over the last's.

Each package is checked as the Extension Manager checks it before
installing (`extensionValidateLCEPackage` and
`extensionFetchSourceFromFolder` in
`extensions/script-libraries/extension-utils`, the same in LiveCode
Community 9.6.3). `tools/ci/tests/test_plugin_packages.py` tests the
builder and the packages; `tests/lcs/plugins` tests the compatibility stack
on the engine. `.github/workflows/plugin-packages.yml` builds the packages
for every change to the plugins and uploads them as the run's artifact; it
also compiles every stack in them on LiveCode Community 9.6.3's own engine
when the repository variable `LCC_SERVER_URL` names a zip of its server
build (`tools/plugins/stock-compile-check.lc`). LiveCode Ltd no longer
serves the Community builds, so the variable has to name a copy of one.

Each GitHub release carries both packages, built by the release
workflow's publish job with the release's version
(`build-plugin-packages.py --release`):
`OXT-Beyond-<version>-xtalk-assistant-plugin.lce` and
`OXT-Beyond-<version>-mcp-bridge-plugin.lce`, checked with the release's
other files against its `SHA256SUMS`.

## Installing

In the IDE: Tools > Extension Manager, then its install button (it asks
for a `.lce` file), and choose the package. The plugin is then in
Development > Plugins. To remove it, uninstall it in the Extension Manager.

## What still needs a pass on a real IDE

Verified statically; needs a pass on LiveCode Community 9.6 and on
HyperXTalk:

1. The Extension Manager installs both packages, and they load at the next
   start.
2. "xTalk Assistant" and "xTalk MCP Bridge" are in Development > Plugins,
   and choosing one opens it without leaving an empty window (the
   launcher hides itself in `preOpenStack` and closes in `openStack`).
3. Insert puts the answer's code at the caret in the Script Editor, as one
   undoable step.
4. The bridge starts and Claude reaches it; `ide_context` gives the line
   the caret is on. Its dialogs and what Claude is told name the IDE
   (LiveCode or HyperXTalk), not OXT-Beyond.
5. Uninstalling takes the launcher out of the Plugins folder.
