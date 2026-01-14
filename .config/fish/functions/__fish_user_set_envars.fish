function __fish_user_set_envars
    set -gx BETTER_EXCEPTIONS 1  # for python better exceptions
    set -gx EDITOR nvim
    set -gx RCLONE_FAST_LIST 1

    set -gx PYTHONPATH $HOME/.local/share/python

    set -gx C_INCLUDE_PATH /usr/local/include /opt/homebrew/include $C_INCLUDE_PATH
    set -gx CPLUS_INCLUDE_PATH /usr/local/include /opt/homebrew/include $CPLUS_INCLUDE_PATH
    set -gx LIBRARY_PATH /usr/local/lib /opt/homebrew/lib $LIBRARY_PATH
    set -gx PKG_CONFIG_PATH /opt/homebrew/lib/pkgconfig $PKG_CONFIG_PATH
end
