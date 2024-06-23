function __fish_user_set_envars
    set -gx BETTER_EXCEPTIONS 1  # for python better exceptions
    set -gx EDITOR nvim
    set -gx RCLONE_FAST_LIST 1

    set -g PYTHONSTARTUP $HOME/.pythonrc
end
