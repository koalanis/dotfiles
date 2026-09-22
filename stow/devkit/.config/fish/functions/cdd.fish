function cdd --wraps='dev cd' --description 'cd into ~/Dev or one of its repos'
    if test (count $argv) -eq 0
        cd (devctl root)
    else
        dev cd $argv
    end
end
