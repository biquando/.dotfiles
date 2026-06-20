function __fish_user_login
    __fish_user_set_path
    __fish_user_set_envars
end

function __fish_user_interactive
    __fish_user_key_bindings
    # fish_config theme choose tokyonight_night
    # fish_config theme choose "Snow Day"
    # fish_config theme choose "Catppuccin Macchiato"
    fish_config theme choose "coolbeans"

    ### Variables ####################################################
    set -gx A "$HOME/Sync/Documents/Housing/03 midvale towers"
    set -gx D "$HOME/Downloads"
    set -gx N "$HOME/Obsidian"
    set -gx O "$HOME/Sync/Research/quantum/07_symbolic_execution"
    set -gx Q "$HOME/Sync/Documents/UCLA/25-26/Spring"
    set -gx R "$HOME/Sync/Research/quantum"
    set -gx S "$HOME/Sync"
    set -gx T "$HOME/Sync/Documents/UCLA/TA"

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

# direnv hook
which direnv 1>/dev/null 2>&1 && direnv hook fish | source
