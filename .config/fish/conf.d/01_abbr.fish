if status is-interactive
    abbr -a ll ls -Alh
    abbr -a la ls -alh
    abbr -a l ls
    abbr -a sl ls
    abbr -a tree tree -C --dirsfirst
    abbr -a py "source ~/.dotfiles/venv/bin/activate.fish && ipython --TerminalInteractiveShell.editing_mode=vi --TerminalInteractiveShell.timeoutlen=0 --no-banner; deactivate"
    # abbr -a vimc "cd ~/.config/nvim && nvim ."
    abbr -a p pwd -P
    abbr -a ports "sudo lsof -i -P -n | grep LISTEN | grep ':[0-9]\+\ '"
    abbr -a t 'cut -c 1-$COLUMNS'
    abbr -a vv '. venv/bin/activate.fish'
    abbr -a vq '. ~/projects/python/quantum/venv/bin/activate.fish'

    abbr -a vimc "yazi ~/.config/nvim"
    abbr -a fishc "yazi ~/.config/fish"
    abbr -a tmuxc "yazi ~/.config/tmux"

    switch $_UNAMESYS
        case 'Darwin'
            abbr -a ip ifconfig
            abbr -a myip "ifconfig | grep 'inet[^6]'"
            abbr -a lt launchtab
            abbr -a armld "ld -lSystem -syslibroot (xcrun --sdk macosx --show-sdk-path) -e _main -arch arm64"
            abbr -a icat "kitten icat"
            abbr -a vim nvim
            abbr -a dns "sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder"
            abbr -a ssh "kitten ssh"
            abbr -a tectonic "tectonic -X"
        case 'Linux'
            abbr -a myip "ip a | grep 'inet[^6]'"
            abbr -a fdsk "sudo fdisk -l | sed -e '/Disk \/dev\/loop/,+5d'"
            abbr -a fd "fdfind"
            abbr -a sizes "find . -type f -print0 | du -h --files0-from=- | sort -h"
    end

    switch $_HOSTNAME
        case 'biquando-u'
            abbr -a vim nvim
    end
end
