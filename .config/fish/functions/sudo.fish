function sudo
    if not status is-interactive
        command sudo $argv
        return $status
    end

    if test "$argv" = '!!'
        eval command sudo $history[1]
    else
        command sudo $argv
    end
end
