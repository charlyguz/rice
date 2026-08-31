# Alias de Arch/CachyOS — los tuyos, tal cual los tenías.
alias update="sudo pacman -Syu"
alias rmpkg="sudo pacman -Rsn"
alias cleanch="sudo pacman -Scc"
alias fixpacman="sudo rm /var/lib/pacman/db.lck"
alias cleanup='sudo pacman -Rsn $(pacman -Qtdq)'
alias rip="expac --timefmt='%Y-%m-%d %T' '%l\t%n %v' | sort | tail -200 | nl"

# La broma de CachyOS para los que vienen de Debian
alias apt="man pacman"
alias apt-get="man pacman"
