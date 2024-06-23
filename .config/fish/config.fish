function __fish_user_login
    __fish_user_set_path
    __fish_user_set_envars
end

function __fish_user_interactive
    __fish_user_key_bindings
    fish_config theme choose tokyonight_night
    # fish_config theme choose "Snow Day"

    ### Variables ####################################################
    set -g Q "$HOME/Cloud/Documents/UCLA/23-24/Spring"
    set -g L "$HOME/Cloud/Documents/logs"
    set -g N "$HOME/Cloud/Documents/notes"
    set -g O "$HOME/Obsidian"

    source ~/.iterm2_shell_integration.fish

    ### Host-dependent ###############################################
    switch $_HOSTNAME
        case 'biquando-u'
            set -l ARCHIVE_BASE "$HOME/Archive"
            set -g ARCHIVE (date "+$ARCHIVE_BASE"'/%y/%m')
            test -d "$ARCHIVE"; or mkdir -p $ARCHIVE
            if ! test -d "$ARCHIVE"
                mkdir -p $ARCHIVE
            end
            rm -f "$ARCHIVE_BASE/current"
            ln -s (date "+%y/%m") "$ARCHIVE_BASE/current"
    end
end

status is-login; and __fish_user_login
status is-interactive; and __fish_user_interactive

direnv hook fish | source
