function __fish_user_set_path
    switch $_UNAMESYS
        case 'Darwin'; set pathlist \
            $HOME/bin \
            $HOME/.local/bin \
            $HOME/.cargo/bin \
            $HOME/.ghcup/bin \
            /opt/homebrew/bin \
            /opt/homebrew/sbin \
            /Applications/Docker.app/Contents/Resources/bin
        case 'Linux'; set pathlist \
            $HOME/bin \
            $HOME/.local/bin \
            $HOME/.cargo/bin \
            $HOME/.ghcup/bin \
            $HOME/.cabal/bin
    end

    switch $_HOSTNAME
        case 'biquando-u'; set --prepend pathlist \
            $HOME/services/bin \
            $HOME/.nvm/versions/node/v22.17.0/bin
    end

    fish_add_path -g $pathlist
end
