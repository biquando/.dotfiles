function ranger
    if not status is-interactive
        command ranger $argv
        return $status
    end

    eval command ranger --choosedir="$HOME/.rangerdir" $argv; and cd (cat "$HOME/.rangerdir")
end
