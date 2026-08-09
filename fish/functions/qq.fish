function qq --description 'quick question to Claude: no tools, no MCP, nothing saved'
    set -l model sonnet
    set -q QQ_MODEL; and set model $QQ_MODEL

    set -l sys 'You are a terse CLI assistant on Arch Linux with fish shell. Answer in as few lines as possible: no preamble, no pleasantries, no restating the question. For "how do I..." questions, give the exact command first in a fenced block, then at most one short line of explanation. Flag destructive commands in one line. Say plainly when you are unsure.'

    if test (count $argv) -eq 0; and isatty stdin
        echo "usage: qq <question>   |   <cmd> | qq [question]" >&2
        return 2
    end

    # claude -p takes ONE prompt argument, so join the words ourselves
    set -l q "$argv"
    test -z "$q"; and set q "Explain this concisely."

    set -l flags -p \
        --model $model \
        --safe-mode \
        --tools "" \
        --strict-mcp-config \
        --no-session-persistence \
        --system-prompt $sys

    if isatty stdin
        command claude $flags $q </dev/null
    else
        # piped input: prompt as arg, piped text flows in on stdin
        command claude $flags $q
    end
end
