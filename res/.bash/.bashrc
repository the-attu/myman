export PATH=$PATH:$HOME/../usr/local/bin

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

eval "$(starship init bash)"

eval "$(zoxide init bash)"
