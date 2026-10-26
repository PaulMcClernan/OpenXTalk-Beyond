# stack-scripts

Every object script of every binary IDE stack in `ide/` and `ide-support/`
(`*.livecode`, `*.rev`, `*.oxtstack`), as a text file of its own, so that
Git can show what a change to a stack did and an editor can search them:

    stack-scripts/<stack file>.bst/scripts/<name>.livecodescript

The layout and names are those of Brian Milby's
[BST](https://github.com/Milby-Computer/hxt-bst): `stack_<stack>` is a
stack's own script and `stack_<stack>_<type>_id_<id>` an object's, with the
innermost stack for an object in a substack. A header in each file names
its stack file and object.

**These files are made from the stacks; do not edit them.** The stack holds
the script that runs. Change a stack as
[CONTRIBUTING.md](../CONTRIBUTING.md#binary-stacks) says, then bring this
folder up to date and commit it with the stack:

    tools/oxt/stack-scripts.sh <development engine>

(`tools/oxt/ide-stack-patch.sh` does it for you after applying patches.)
The Linux build runs it with `--check` and fails if a file is missing, out
of date or left over. See
[tools/oxt/README.md](../tools/oxt/README.md#the-stacks-scripts-as-text-stack-scripts).
