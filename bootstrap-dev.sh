#!/usr/bin/env bash
# Bootstrap the ~/Dev workspace pattern on a machine:
#   - creates $DEV_HOME
#   - installs the devkit stow package (devctl, dev.bash, fish functions, completions)
#   - wires the bash side into ~/.bashrc
#   - optionally restores every repo from ~/.config/dev/repos.txt
#
# usage: ./bootstrap-dev.sh [--dev-home PATH] [--restore] [--dry-run] [--force]

set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STOW_DIR="$DOTFILES/stow"
PACKAGE=devkit
DEV_HOME="${DEV_HOME:-$HOME/Dev}"
DRY=0
FORCE=0
RESTORE=0

while [ $# -gt 0 ]; do
    case "$1" in
        --dev-home) DEV_HOME="$2"; shift 2 ;;
        --restore)  RESTORE=1; shift ;;
        --dry-run)  DRY=1; shift ;;
        --force)    FORCE=1; shift ;;
        -h|--help)  sed -n '2,9p' "${BASH_SOURCE[0]}" | sed 's/^# \?//'; exit 0 ;;
        *) echo "unknown flag: $1" >&2; exit 1 ;;
    esac
done

step() { printf '\033[1m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[33m !\033[0m %s\n' "$*" >&2; }
run()  { if [ "$DRY" = 1 ]; then printf '   dry-run: %s\n' "$*"; else "$@"; fi; }

# --- dependencies ----------------------------------------------------------
step "checking dependencies"
missing=()
for t in git stow; do command -v "$t" >/dev/null 2>&1 || missing+=("$t"); done
[ ${#missing[@]} -eq 0 ] || { echo "install first: ${missing[*]}" >&2; exit 1; }
for t in gh glab fish jq; do
    command -v "$t" >/dev/null 2>&1 || warn "$t not installed (devkit degrades gracefully, but install it)"
done

# --- workspace -------------------------------------------------------------
step "workspace $DEV_HOME"
[ -d "$DEV_HOME" ] || run mkdir -p "$DEV_HOME"

# --- move conflicting files out of the way ---------------------------------
step "checking for files stow would conflict with"
stamp="$(date +%Y%m%d%H%M%S)"
for rel in .local/bin/devctl \
           .config/dev/config .config/dev/dev.bash \
           .config/fish/functions/dev.fish .config/fish/functions/cdd.fish \
           .config/fish/completions/dev.fish; do
    tgt="$HOME/$rel"
    [ -e "$tgt" ] || continue
    # stow folds whole directories into a single symlink, so a path under $HOME can
    # already resolve into the package itself. Never touch those - moving one would
    # rename the source file inside the dotfiles repo.
    real="$(readlink -f "$tgt")"
    case "$real" in "$(readlink -f "$STOW_DIR")"/*) continue ;; esac
    if [ ! -L "$tgt" ]; then
        if [ "$FORCE" = 1 ]; then
            run mv "$tgt" "$tgt.bak.$stamp"
            warn "backed up $rel -> $rel.bak.$stamp"
        else
            warn "$rel exists and is not a symlink; re-run with --force to back it up"
            exit 1
        fi
    fi
done

# --- stow ------------------------------------------------------------------
step "stowing $PACKAGE"
run stow --dir "$STOW_DIR" --target "$HOME" --restow "$PACKAGE"

# --- bash wiring -----------------------------------------------------------
step "wiring bash"
BASHRC="$HOME/.bashrc"
MARK="# devkit"
if grep -qF "$MARK" "$BASHRC" 2>/dev/null; then
    echo "   ~/.bashrc already sources devkit"
else
    if [ "$DRY" = 1 ]; then
        printf '   dry-run: append devkit block to %s\n' "$BASHRC"
    else
        cp "$BASHRC" "$BASHRC.bak.$stamp" 2>/dev/null || true
        cat >> "$BASHRC" <<EOF

$MARK
export DEV_HOME="$DEV_HOME"
[ -r "\$HOME/.config/dev/dev.bash" ] && . "\$HOME/.config/dev/dev.bash"
EOF
        echo "   appended to ~/.bashrc (backup: .bashrc.bak.$stamp)"
    fi
fi
# The old standalone dev() is defined earlier in .bashrc, so the sourced one wins,
# but leaving it around is confusing.
if grep -qE '^\s*dev\(\)\s*\{' "$BASHRC" 2>/dev/null; then
    warn "~/.bashrc still has an old dev() definition; delete it (the devkit one now overrides it)"
fi

# --- fish wiring -----------------------------------------------------------
step "wiring fish"
if command -v fish >/dev/null 2>&1; then
    if [ "$DRY" = 1 ]; then
        echo "   dry-run: set DEV_HOME universally"
    else
        fish -c "set -Ux DEV_HOME '$DEV_HOME'"
        echo "   set universal DEV_HOME=$DEV_HOME"
    fi
else
    warn "fish not installed; skipping"
fi

# --- restore ---------------------------------------------------------------
if [ "$RESTORE" = 1 ]; then
    step "restoring repos from manifest"
    run "$HOME/.local/bin/devctl" restore
fi

# --- report ----------------------------------------------------------------
step "doctor"
if [ "$DRY" = 1 ]; then
    echo "   dry-run: devctl doctor"
else
    DEV_HOME="$DEV_HOME" "$HOME/.local/bin/devctl" doctor || true
fi

cat <<EOF

done. open a new shell, then:
  dev                 cd into $DEV_HOME
  dev clone gh:owner/repo
  dev status
  dev manifest --write   save this machine's repo list for the next one
EOF
