function __fish_user_set_envars
    set -gx BETTER_EXCEPTIONS 1  # for python better exceptions
    set -gx EDITOR nvim
    set -gx RCLONE_FAST_LIST 1

    set -gx XDG_DATA_HOME "$HOME/.local/share"
    set -gx XDG_CONFIG_HOME "$HOME/.config"
    set -gx XDG_STATE_HOME "$HOME/.local/state"
    set -gx XDG_CACHE_HOME "$HOME/.cache"

    set -gx PYTHONPATH $HOME/.local/share/python

    set -gx C_INCLUDE_PATH /usr/local/include /opt/homebrew/include /opt/homebrew/opt/llvm/include $C_INCLUDE_PATH
    set -gx CPLUS_INCLUDE_PATH /usr/local/include /opt/homebrew/include /opt/homebrew/opt/llvm/include $CPLUS_INCLUDE_PATH
    set -gx LIBRARY_PATH /usr/local/lib /opt/homebrew/lib /opt/homebrew/opt/llvm/lib $LIBRARY_PATH
    set -gx PKG_CONFIG_PATH /opt/homebrew/lib/pkgconfig $PKG_CONFIG_PATH
    set -gx CMAKE_PREFIX_PATH /opt/hombrew/opt/llvm $CMAKE_PREFIX_PATH
end
