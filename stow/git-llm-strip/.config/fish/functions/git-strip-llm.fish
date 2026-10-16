function git-strip-llm --description 'Remove LLM/AI attribution lines from commit messages (rewrites history)'
    argparse n/dry-run y/yes h/help -- $argv
    or return 1

    if set -q _flag_help
        echo "Usage: git-strip-llm [-n|--dry-run] [-y|--yes] [rev-range]"
        echo
        echo "Scans commit messages for LLM attribution lines (Claude, Copilot,"
        echo "ChatGPT, aider, etc.) and rewrites history to remove them."
        echo
        echo "Examples of lines that get stripped:"
        echo "  Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>"
        echo "  🤖 Generated with [Claude Code](https://claude.com/claude-code)"
        echo
        echo "Options:"
        echo "  -n, --dry-run   only show matching commits, change nothing"
        echo "  -y, --yes       skip the confirmation prompt"
        echo
        echo "rev-range defaults to HEAD (entire current branch)."
        echo "Use e.g. 'main..HEAD' to only rewrite unpushed commits."
        return 0
    end

    if not git rev-parse --is-inside-work-tree >/dev/null 2>&1
        echo "git-strip-llm: not inside a git repository" >&2
        return 1
    end

    set -l range HEAD
    if test (count $argv) -gt 0
        set range $argv[1]
    end

    set -l pattern (__git_strip_llm_pattern)

    set -l hashes (git log --extended-regexp --regexp-ignore-case --grep=$pattern --format=%H $range)
    if test (count $hashes) -eq 0
        echo "No LLM attribution found in $range"
        return 0
    end

    echo "Found "(count $hashes)" commit(s) with LLM attribution in $range:"
    echo
    for h in $hashes
        echo "  "(git show -s --format='%h %s' $h)
        git show -s --format=%B $h | grep -iE $pattern | sed 's/^/      /'
    end
    echo

    if set -q _flag_dry_run
        echo "Dry run - no changes made."
        return 0
    end

    if not git diff --quiet; or not git diff --cached --quiet
        echo "git-strip-llm: working tree has uncommitted changes; commit or stash them first" >&2
        return 1
    end

    if not set -q _flag_yes
        read -l -P "Rewrite these commits? History changes; already-pushed branches will need a force-push. [y/N] " reply
        if not string match -qi 'y*' -- $reply
            echo "Aborted."
            return 1
        end
    end

    FILTER_BRANCH_SQUELCH_WARNING=1 git filter-branch -f \
        --msg-filter "grep -ivE '$pattern' | git stripspace; true" \
        -- $range
    or return 1

    set -l branch (git branch --show-current)
    echo
    echo "Done. A backup of the old history is kept under refs/original/."
    echo "To undo:   git reset --hard refs/original/refs/heads/$branch"
    echo "To forget the backup once happy:   git update-ref -d refs/original/refs/heads/$branch"
end
