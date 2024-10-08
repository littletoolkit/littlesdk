# Shell prompt
BOLD=$(tput bold)
RESET=$(tput sgr0)
RED=$(tput setaf 196)
BLUE=$(tput setaf 33)
UNDERLINE=$(tput smul)
REV=$(tput rev)
DIM=$(tput dim)
function okthanksbye {
  echo "←―――   👋 Thanks for using ${BOLD}LittleDevShell${RESET}, come back with ${BOLD}make shell${RESET}"
}

function prompt {
  status_color=$(if [[ $? == 0 ]]; then echo -n "${BLUE}"; else echo -n "${RED}"; fi)
  prompt_path="$(basename "$(dirname "$PWD")")/$BOLD$(basename "$PWD")"
  PS1="┄―――→  🐚 \[${BOLD}\]LittleDevShell\[${RESET}\]\n\[${BOLD}\][kit]\[${RESET}\]  ⏣  \[$status_color\]${prompt_path}\[$RESET\] ▷  "
}
echo "${BOLD}[kit]${RESET}  →  Provisioning sandboxed shell: ${BOLD}PATH,PYTHONPATH,LDLIBRARYPATH${RESET}"
export PROMPT_COMMAND=prompt
trap okthanksbye EXIT
# EOF
