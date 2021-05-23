# exa
alias ls='exa -lFag --git --header'

# ccze
function tailc () {
    tail $@ | ccze -A
}

export -f tailc
