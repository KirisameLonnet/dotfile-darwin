# fnnn Configuration - FelixKratz's Custom nnn Setup
# Enhanced file manager with better colors and keymaps

# Export environment variables for fnnn
export NNN_PLUG='f:finder;o:fzopen;p:mocplay;d:diffs;t:nmount;v:imgview'
export NNN_TMPFILE="${XDG_CONFIG_HOME:-$HOME/.config}/nnn/.lastd"
export NNN_COLORS="2136"  # Custom color scheme
export NNN_FCOLORS='c1e2272e006033f7c6d6abc4'  # File type colors

# Catppuccin-inspired color scheme for fnnn
export NNN_BMS='d:~/Documents;D:~/Downloads;p:~/Pictures;v:~/Videos;m:~/Music;c:~/.config;'

# Custom keybindings following FelixKratz's workflow
export NNN_OPENER="$HOME/.config/nnn/plugins/nuke"

# Enhanced features
export NNN_FIFO='/tmp/nnn.fifo'
export NNN_USE_EDITOR=1
export NNN_CONTEXT_COLORS='1234'
export NNN_SSHFS='sshfs -o reconnect,idmap=user,compression=yes,follow_symlinks'

# Function to change directory on quit
n() {
    # Block nesting of nnn in subshells
    if [ -n $NNNLVL ] && [ "${NNNLVL:-0}" -ge 1 ]; then
        echo "nnn is already running"
        return
    fi

    # The default behaviour is to cd on quit (nnn checks if NNN_TMPFILE is set)
    # To cd on quit only on ^G, either remove the "export" as in:
    #     NNN_TMPFILE="${XDG_CONFIG_HOME:-$HOME/.config}/nnn/.lastd"
    # or, to have different tmp files for different shells, uncomment this line:
    #     NNN_TMPFILE="${XDG_CONFIG_HOME:-$HOME/.config}/nnn/.lastd$$"

    # Unmask ^Q (, ^V etc.) (if required, see `stty -a`) to Quit nnn
    # stty start undef
    # stty stop undef
    # stty lwrap undef
    # stty lnext undef

    fnnn "$@"

    if [ -f "$NNN_TMPFILE" ]; then
        . "$NNN_TMPFILE"
        rm -f "$NNN_TMPFILE" > /dev/null
    fi
}

# Set up nnn alias to use the function
alias nnn=n
alias fm=n  # File manager shortcut
