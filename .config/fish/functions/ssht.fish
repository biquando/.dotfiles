# The purpose of this function is to automatically start in tmux on a remote.
function ssht
    if not status is-interactive
        command ssht $argv
        return $status
    end

    command ssh -t $argv -- 'tmux attach || tmux new-session'
end
