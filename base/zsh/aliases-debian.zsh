# Los mismos alias, pero hablando apt.
#
# OJO: aquí NO se alias-ea 'apt' ni 'apt-get'. En CachyOS la gracia era
# mandarte al manual de pacman; en Debian son los comandos de verdad y
# romperlos sería un disparo en el pie.

alias update="sudo apt update && sudo apt upgrade"
alias rmpkg="sudo apt remove --purge"
alias cleanch="sudo apt clean && sudo apt autoclean"
alias fixapt="sudo rm -f /var/lib/apt/lists/lock /var/cache/apt/archives/lock /var/lib/dpkg/lock*"
alias cleanup="sudo apt autoremove --purge"
alias rip="grep ' install ' /var/log/dpkg.log | tail -200 | nl"
alias buscar="apt search"
alias info="apt show"

# El chiste al revés, por si lo extrañas
alias pacman="man apt"
