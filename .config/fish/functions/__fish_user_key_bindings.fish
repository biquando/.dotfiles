function __fish_user_key_bindings

    #### Set vi mode #################################################
    fish_vi_key_bindings
    fish_vi_cursor
    set -g fish_cursor_default block
    set -g fish_cursor_insert line
    set -g fish_cursor_replace_one underscore
    set -g fish_cursor_visual block

    switch $_UNAMESYS
        case 'Darwin'
            function fish_mode_prompt
            end
    end

    bind -M insert \cf forward-char
    bind -M insert \cb backward-char
    bind -M insert \cp up-or-search
    bind -M insert \cn down-or-search
    bind -M insert -k nul forward-char  # ctrl+space

    ### Set fzf key bindings #########################################
    switch $_UNAMESYS
        case 'Darwin'
            set -f fzfpath "/opt/homebrew/opt/fzf/shell/key-bindings.fish"
        case 'Linux'
            set -f fzfpath "/usr/share/doc/fzf/examples/key-bindings.fish"
    end

    if set -q fzfpath
    and test -f $fzfpath
    and test -r $fzfpath
        source $fzfpath
        fzf_key_bindings
    end

end
