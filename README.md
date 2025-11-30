### Setup

Vim:
- Install vim-plug: `curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim`
- Reload with: `:PlugInstall`

Tmux:
- Install TPM: `git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm`
- Reload with: `<Leader>I`

Utilities:
- fzf
- ripgrep
- fd

Python interactive venv:
```bash
python3 -m venv venv
. venv/bin/activate
pip install -r requirements.txt
```

Matplotlib kitty backend
- Clone into `~/.local/share/python`:
```bash
git clone --revision=cbe4fe2 --depth=1 https://github.com/jktr/matplotlib-backend-kitty
```
