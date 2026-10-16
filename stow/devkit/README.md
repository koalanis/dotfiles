# devkit

The `~/Dev` workspace pattern, packaged so a new machine gets it in one command.

## Install

```sh
cd ~/dotfiles && ./bootstrap-dev.sh --force
```

`--force` backs up any non-symlink file it would overwrite. Other flags:
`--dev-home PATH`, `--restore` (clone everything in the manifest), `--dry-run`.

The bootstrap creates `$DEV_HOME`, stows this package, appends a `# devkit`
block to `~/.bashrc`, sets a universal `DEV_HOME` in fish, and runs `devctl doctor`.

## Layout

| path | what |
| --- | --- |
| `.local/bin/devctl` | the actual tool, bash, no deps beyond git |
| `.local/share/devctl/site/render.py` | the site renderer, python stdlib only |
| `.local/share/devctl/site/style.css` | the site stylesheet |
| `.config/dev/config` | `DEV_HOME`, default host, usernames, clone protocol |
| `.config/dev/config.local` | machine-specific overrides, not tracked |
| `.config/dev/dev.bash` | bash `dev`/`cdd` functions + completion |
| `.config/fish/functions/dev.fish` | fish `dev` |
| `.config/fish/functions/cdd.fish` | fish `cdd` |
| `.config/fish/completions/dev.fish` | fish completions |

`dev` is a shell function, not the binary: `dev` and `dev cd`, `dev clone`,
`dev new` need to change the calling shell's directory, which a subprocess
cannot do. Everything else falls through to `devctl`.

## Repo specs

One syntax for both forges. `devctl` uses `gh`/`glab` when they are installed
and authenticated, and falls back to plain `git clone` when they are not.

| spec | resolves to |
| --- | --- |
| `gh:owner/repo` | github, cloned with `gh repo clone` |
| `gl:group/sub/repo` | gitlab, cloned with `glab repo clone` |
| `owner/repo` | `DEV_DEFAULT_HOST` |
| `repo` | `DEV_GH_USER`/`DEV_GL_USER` on the default host |
| `https://…`, `git@…:…` | cloned verbatim, host detected from the url |

## Commands

```
dev                     cd $DEV_HOME
dev cd <name>           cd into a repo (fuzzy substring match)
dev clone gh:you/thing  clone and cd into it
dev new thing --gl      git init, first commit, create the gitlab remote, push
dev status              dirty / unpushed / behind, every repo, one line each
dev sync                ff-only pull every clean repo, skip the dirty ones
dev fetch               parallel fetch --all --prune
dev each git gc         run a command in every repo
dev browse thing        open the repo's web page
dev mine gitlab         list your remote repos
dev manifest --write    save every repo as a spec in ~/.config/dev/repos.txt
dev restore             clone everything in the manifest
dev meta                project metadata as json (forges + clones + nb)
dev site --serve        build the static project site and serve it
dev doctor              workspace, tools, auth
```

`dev <command> -h` prints that command's own usage, flags, and caveats;
`dev help` lists them all. For `each`, only `dev each -h` is help - anything
after the wrapped command is passed through to it.


## Project site

`dev site` builds a static page for every project you have: the index lists
them all, each project gets its own page, and a project with an `nb` notebook
gets its notes linked there.

```sh
dev site --refresh        # refetch github + gitlab, rebuild
dev site --serve          # build, then serve at http://127.0.0.1:8765
dev site --local          # workspace clones only, no network
dev site -o ~/public/dev  # build somewhere else
```

Two stages, and the seam between them is a json file:

1. `dev meta` merges three sources into one project list: your `gh repo list`
   and `glab repo list` output, the clones in `$DEV_HOME`, and the `nb`
   notebook whose name matches the project. A repo that lives only on a forge,
   or only on disk, still gets an entry. Writes `~/.cache/dev/projects.json`.
2. `render.py` turns that json into html. It never shells out to git, gh, glab
   or nb, so anything the site shows has to be in the metadata first, and
   `projects.json` ships with the output.

Forge listings are cached for `DEV_META_TTL` (6h). `--refresh` skips the cache;
a failed forge call falls back to the cached copy and warns.

### Per-project metadata

Drop a `.devctl.json` in a repo to override what the forge and git report:

```json
{
  "title": "Vitrine",
  "blurb": "tailnet museum of old static react projects",
  "tags": ["jupiter", "tailnet"],
  "status": "running",
  "links": [{ "label": "live", "url": "http://jupiter:8080" }],
  "hidden": false
}
```

`hidden: true` keeps the project out of the site.

### Notes

A project shows a notes section when an `nb` notebook has the same name as the
repo, or a name that slugifies to it (`nb notebooks add <repo>` to start one).
Each note links to the markdown file by `file://` path and shows the
`nb <notebook>:<id>` command to open it in the terminal.

### Site config

All optional, in `~/.config/dev/config`:

| var | default | what |
| --- | --- | --- |
| `DEV_SITE_OUT` | `~/.local/share/devctl/public` | output directory |
| `DEV_SITE_TITLE` | `projects` | page title |
| `DEV_SITE_SUBTITLE` | | line under the title |
| `DEV_SITE_PORT` | `8765` | `--serve` port |
| `DEV_SITE_LIB` | next to the script | renderer + stylesheet |
| `DEV_META_TTL` | `21600` | seconds before a forge listing is refetched |
| `DEV_META_LIMIT` | `200` | repos requested per forge |
| `DEV_META_README` | `800` | bytes of README kept as the excerpt |
| `DEV_META_ARCHIVED` | `0` | `1` keeps archived remote repos |
| `DEV_META_FORKS` | `0` | `1` keeps forks |

Needs `jq` and `python3`; everything else in devctl still runs without them.

## Moving to a new machine

```sh
# old machine - stow folds ~/.config/dev into the package, so this writes
# straight into the dotfiles repo. Commit it.
dev manifest --write

# new machine
git clone <dotfiles> ~/dotfiles && cd ~/dotfiles && ./bootstrap-dev.sh --force --restore
```

Repos with no `origin` remote are left out of the manifest, and `manifest`
says which ones on stderr.
