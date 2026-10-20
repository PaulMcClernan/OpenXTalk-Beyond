# Changelog fragments

A pull request puts its lines for [CHANGELOG.md](../CHANGELOG.md) here,
in a file of its own, instead of adding them to CHANGELOG.md. Each pull
request then changes a file no other one touches, so a merge to main
leaves the other open pull requests without a conflict, and without the
merge of main and the full builds that settling one used to cost.

Name the file after the pull request's branch, or its number once it has
one (`changelog/168.md`), and write CHANGELOG.md's own lines, one per
change, each ending with the pull request's number:

```
- Tools palette: long names shrink or wrap instead of being cut off (#168)
```

The pull request that sets a release's version folds every fragment into
the "Unreleased" section of CHANGELOG.md, in the order they were merged,
and deletes them (`python3 tools/ci/changelog.py fold`; see "Making a
release" in [BUILDING.md](../BUILDING.md)). CI checks that every fragment
is made of such lines (`python3 tools/ci/changelog.py check`). A change to
this folder alone starts no build.
