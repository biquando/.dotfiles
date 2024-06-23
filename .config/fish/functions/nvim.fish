# The purpose of this function is to change directory before executing nvim
# if there is exactly one argument, which is a directory.
function nvim
    if not status is-interactive
        command nvim $argv
        return $status
    end

    # Do nothing if there isn't exactly one argument
    if [ (count $argv) -ne 1 ]
        command nvim $argv
        return $status
    end

    # Do nothing if the argument is an option
    if [ (string shorten -m 1 -c '' -- "$argv[1]" ) = '-' ]
        command nvim $argv
        return $status
    end

    # Do nothing if not editing a directory
    if not [ -d "$argv[1]" ]
        command nvim $argv
        return $status
    end

    set -l prev_dir (pwd)
    cd "$argv[1]"
    command nvim $argv
    cd "$prev_dir"
end
