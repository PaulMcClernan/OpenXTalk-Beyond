# xTalk MCP Bridge

The xTalk MCP Bridge lets Claude work on the stacks you have open in
OXT-Beyond, using your own Claude plan (Free, Pro, Max, Team or
Enterprise). You use Claude in Anthropic's own apps, the Claude desktop
app or Claude Code, and sign in there as usual. OXT-Beyond needs no API
key.

It sits beside the xTalk Assistant and changes nothing about it. The
assistant still works with an API key you paste, and you can use either
one, both, or neither.

## Why it works this way

Anthropic does not let other programs sign in to a Claude account or use
a Claude plan's sign-in on someone's behalf. So OXT-Beyond does not talk
to Claude. Claude's app talks to OXT-Beyond instead, through this MCP
server (`server.js`):

    Claude app  --stdio-->  server.js  --127.0.0.1-->  OXT-Beyond

Claude's app starts the server. The server reaches the IDE over a socket
that only this computer can reach, and it must send a key that the IDE
writes to `~/.oxt-beyond/mcp-bridge.json` while the bridge is on. That
file is readable only by you, and it is deleted when the bridge is turned
off.

## Setting it up

1. In OXT-Beyond, choose *Development > Plugins > xTalk MCP Bridge* and
   press **Turn On**.
2. In the window that follows:
   - For the **Claude desktop app**, press **Save Desktop Extension...**,
     then in Claude choose *Settings > Extensions > Advanced settings >
     Install Extension...* and choose the `.mcpb` file it saved (opening
     the file itself works only where the system knows it is Claude's).
     Claude's app runs the server with the Node.js it comes with, so you
     do not need to install anything else. Or press **Add to Claude
     Desktop**, which adds OXT-Beyond to Claude's settings file
     (`claude_desktop_config.json`, keeping a copy of it); that way needs
     Node.js. Quit Claude completely and open it again afterwards.
   - For **Claude Code**, press **Copy Claude Code Command** and paste
     the command into a terminal. This needs Node.js 16 or later.
3. Ask Claude to work on your stack. OXT-Beyond must be open with the
   bridge on.

## What Claude can do

Claude can do the same things the xTalk Assistant's tools do:

- **Read and look:** read the guide to xTalk Script, list your open
  stacks, see what you have selected, the script open in the Script
  Editor and the last error the IDE showed you, read a stack's outline
  or its cards and controls, search its scripts, look at a picture of a
  card (with each control's id written on it, if Claude asks), look up
  the Dictionary, check that code compiles, and read a script that is
  paused in the debugger. A long script is read in parts, with line
  numbers and where each handler is.
- **Build:** create, change and delete controls, cards and new stacks,
  and change one handler, or a few lines, of a script while leaving the
  rest of it as it is. Each request is checked first and is made
  completely or not at all.
- **Run and save:** run code in a sandbox or on your stack, and save a
  stack.

Claude's app asks you before it uses each tool. OXT-Beyond asks you
itself in three cases:

- before running any code, which it shows you. Code runs inside
  OXT-Beyond with everything the IDE can reach (your files, the network,
  other programs), and no check of its text can see all of what it does,
  so read it before you press **Run**;
- before saving a stack;
- before undoing something that you have changed since Claude changed it.

Anything else Claude changes or runs on a stack can be undone, either by
Claude with `undo_changes` or by you with **Undo Last Change** under
*Development > Plugins > xTalk MCP Bridge*. This works until the bridge
is turned off.

To keep the bridge off on a computer for good, set the environment
variable `OXTBEYOND_MCP_BRIDGE` to `off`.

## Tests

- `tests/lcs/mcpbridge/tools.livecodescript` tests the IDE's side.
- `tools/ci/tests/test_mcp_bridge_server.py` tests this server.
