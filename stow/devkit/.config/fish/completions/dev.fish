function __dev_repos
    devctl list 2>/dev/null
end

set -l cmds cd clone get new init list status sync fetch each browse open mine manifest restore doctor meta site pages path root help

complete -c dev -f
complete -c dev -n "not __fish_seen_subcommand_from $cmds" -a cd     -d 'cd into a repo'
complete -c dev -n "not __fish_seen_subcommand_from $cmds" -a clone  -d 'clone into the workspace'
complete -c dev -n "not __fish_seen_subcommand_from $cmds" -a new    -d 'create a repo, optionally on a forge'
complete -c dev -n "not __fish_seen_subcommand_from $cmds" -a list   -d 'list repos'
complete -c dev -n "not __fish_seen_subcommand_from $cmds" -a status -d 'dirty / unpushed / behind'
complete -c dev -n "not __fish_seen_subcommand_from $cmds" -a sync   -d 'ff-only pull every clean repo'
complete -c dev -n "not __fish_seen_subcommand_from $cmds" -a fetch  -d 'fetch all repos'
complete -c dev -n "not __fish_seen_subcommand_from $cmds" -a each   -d 'run a command in every repo'
complete -c dev -n "not __fish_seen_subcommand_from $cmds" -a browse -d 'open a repo in the browser'
complete -c dev -n "not __fish_seen_subcommand_from $cmds" -a mine   -d 'list your remote repos'
complete -c dev -n "not __fish_seen_subcommand_from $cmds" -a doctor -d 'check workspace, tools, auth'
complete -c dev -n "not __fish_seen_subcommand_from $cmds" -a meta   -d 'project metadata as json'
complete -c dev -n "not __fish_seen_subcommand_from $cmds" -a site   -d 'build the static project site'

complete -c dev -n "__fish_seen_subcommand_from cd browse open path" -a '(__dev_repos)'
complete -c dev -n "__fish_seen_subcommand_from mine" -a 'github gitlab'
complete -c dev -n "__fish_seen_subcommand_from meta site pages" -l refresh -d 'refetch the forge listings'
complete -c dev -n "__fish_seen_subcommand_from meta site pages" -l local -d 'workspace clones only'
complete -c dev -n "__fish_seen_subcommand_from meta site pages" -s o -l out -d 'output path' -r
complete -c dev -n "__fish_seen_subcommand_from site pages" -l open -d 'open in the browser'
complete -c dev -n "__fish_seen_subcommand_from site pages" -l serve -d 'serve the output locally'
complete -c dev -n "__fish_seen_subcommand_from $cmds" -s h -l help -d 'help for this command'
complete -c dev -n "__fish_seen_subcommand_from clone new" -l gh -d 'use github'
complete -c dev -n "__fish_seen_subcommand_from clone new" -l gl -d 'use gitlab'
complete -c dev -n "__fish_seen_subcommand_from new" -l public -d 'create a public remote'
complete -c dev -n "__fish_seen_subcommand_from clone" -l https -d 'clone over https'
complete -c dev -n "__fish_seen_subcommand_from clone" -l ssh -d 'clone over ssh'

complete -c devctl -f -n "not __fish_seen_subcommand_from $cmds" -a "$cmds"
