function git-strip-llm-msg --description 'Strip LLM attribution lines from a commit message file, in place'
    if test (count $argv) -ne 1
        echo "Usage: git-strip-llm-msg <commit-msg-file>" >&2
        return 1
    end

    set -l file $argv[1]
    if not test -f $file
        echo "git-strip-llm-msg: no such file: $file" >&2
        return 1
    end

    set -l pattern (__git_strip_llm_pattern)

    if not grep -qiE $pattern $file
        return 0
    end

    set -l cleaned (grep -ivE $pattern <$file | git stripspace)

    # Never hand git an empty message; that aborts the commit.
    if test -z (string join '' $cleaned | string trim)
        echo "git-strip-llm-msg: stripping would empty the message; leaving it alone" >&2
        return 0
    end

    printf '%s\n' $cleaned >$file
end
