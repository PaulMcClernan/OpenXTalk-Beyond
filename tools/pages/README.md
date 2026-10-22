# The GitHub Pages site

The web IDE ([tools/web-ide](../web-ide/README.md)) and the Stack Player
([tools/web-player](../web-player/README.md)) on the repository's GitHub
Pages site, so that anyone can open them with nothing to download:

| Address | What |
| --- | --- |
| `https://<owner>.github.io/<repository>/` | the front page ([index.html](index.html)), which links to both |
| `.../ide/` | the web IDE |
| `.../player/` | the Stack Player |

The workflow [pages.yml](../../.github/workflows/pages.yml) builds nothing:
it takes the two sites as a release ships them
(`OXT-Beyond-<version>-web-ide.zip` and `OXT-Beyond-<version>-web-player.zip`),
puts them in their folders with [build_pages.py](build_pages.py) and
deploys the result. It runs when the Release workflow finishes well, and by
hand (Actions > Web pages > Run workflow, with a release's tag or none for
the newest). A release that has no web IDE zip takes the web IDE from main's
newest Web IDE run instead; the header of the workflow says how.

Both sites ask for their files with relative addresses, so they run from
a folder of the site. The web engine uses no threads, so GitHub Pages needs
no special headers, and it serves `.wasm` as `application/wasm`. Its
largest file, the engine's `.wasm` (about 23 MB), is well under GitHub
Pages' 100 MB a file, which `build_pages.py` checks.

Pages are served from `<owner>.github.io`, one address for every Pages site
of the owner, so the web IDE's saved stacks and the Stack Player's stacks
(the browser's storage) are kept per browser for that address.

## Turning it on

Once, in the repository's Settings > Pages: under "Build and deployment",
set Source to **GitHub Actions**. Then run Actions > Web pages > Run
workflow, or wait for the next release.

To try the site on your own computer:

```sh
python3 tools/pages/build_pages.py --out site \
    --ide OXT-Beyond-<version>-web-ide.zip --ide-version <version> \
    --player OXT-Beyond-<version>-web-player.zip --player-version <version>
cd site && python3 -m http.server 8000
```
