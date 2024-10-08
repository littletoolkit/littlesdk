# Shell prompt
BOLD=$(tput bold)
RESET=$(tput sgr0)
RED=$(tput setaf 196)
BLUE=$(tput setaf 33)
UNDERLINE=$(tput smul)
REV=$(tput rev)
DIM=$(tput dim)
function prompt {
  status_color=$(if [[ $? == 0 ]]; then echo -n "${BLUE}"; else echo -n "${RED}"; fi)
  prompt_path="$(basename "$(dirname "$PWD")")/$BOLD$(basename "$PWD")"
  PS1="―――→  🐚 ${BOLD}LittleDevShell${RESET}\n${BOLD}[kit]${RESET} 🛠️\[$status_color\]❲${prompt_path}❳\[$RESET\] ▷  "
}
export PROMPT_COMMAND=prompt
# EOF
