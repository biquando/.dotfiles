if status is-interactive
    abbr -a ll ls -Alh
    abbr -a la ls -alh
    abbr -a l ls
    abbr -a sl ls
    abbr -a tree tree -C --dirsfirst
    abbr -a py "PYTHONSTARTUP=\$PYTHONSTARTUP ipython --TerminalInteractiveShell.editing_mode=vi --TerminalInteractiveShell.timeoutlen=0 --no-banner"
    abbr -a vim nvim
    abbr -a vimc "nvim -c 'cd ~/.config/nvim' ~/.config/nvim"
    # abbr -a vimc "cd ~/.config/nvim && nvim ."
    abbr -a p pwd -P
    abbr -a ports "sudo lsof -i -P -n | grep LISTEN | grep ':[0-9]\+\ '"
    abbr -a t 'cut -c 1-$COLUMNS'
    abbr -a vv '. venv/bin/activate.fish'
    abbr -a fishc "nvim -c 'cd ~/.config/fish' ~/.config/fish"

    switch $_UNAMESYS
        case 'Darwin'
            abbr -a ip ifconfig
            abbr -a myip "ifconfig | grep 'inet[^6]'"
            abbr -a lt launchtab
            abbr -a armld "ld -lSystem -syslibroot (xcrun --sdk macosx --show-sdk-path) -e _main -arch arm64"
        case 'Linux'
            abbr -a myip "ip a | grep 'inet[^6]'"
            abbr -a fdsk "sudo fdisk -l | sed -e '/Disk \/dev\/loop/,+5d'"
            abbr -a fd "fdfind"
            abbr -a sizes "find . -type f -print0 | du -h --files0-from=- | sort -h"
    end
end
