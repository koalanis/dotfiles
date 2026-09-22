function dev --description 'manage the ~/Dev workspace (wraps devctl)'
    if not set -q DEV_HOME
        set -gx DEV_HOME "$HOME/Dev"
    end

    if test (count $argv) -eq 0
        cd $DEV_HOME
        return
    end

    # -h anywhere means help: never try to cd into a usage message.
    if contains -- -h $argv; or contains -- --help $argv
        devctl $argv
        return
    end

    switch $argv[1]
        case cd
            set -l target (devctl path $argv[2..-1])
            or return 1
            cd $target
        case clone get new init
            set -l out (devctl $argv)
            or return 1
            set -l target $out[-1]
            test -d "$target"; and cd $target
        case '*'
            devctl $argv
    end
end
