# File: Logging
# A shell logging library

if [ -z "${NOCOLOR:-}" ]; then
	CYAN="$(tput setaf 33)"
	BLUE_DK="$(tput setaf 27)"
	BLUE="$(tput setaf 33)"
	BLUE_LT="$(tput setaf 117)"
	GREEN="$(tput setaf 34)"
	YELLOW="$(tput setaf 220)"
	GRAY="$(tput setaf 153)"
	GOLD="$(tput setaf 214)"
	GOLD_DK="$(tput setaf 208)"
	PURPLE_DK="$(tput setaf 55)"
	PURPLE="$(tput setaf 92)"
	PURPLE_LT="$(tput setaf 163)"
	RED="$(tput setaf 124)"
	ORANGE="$(tput setaf 202)"
	BOLD="$(tput bold)"
	DIM="$(tput dim)"
	REVERSE="$(tput rev)"
	RESET="$(tput sgr0)"
elif tput setaf 1 &>/dev/null; then
	CYAN=""
	BLUE_DK=""
	BLUE=""
	BLUE_LT=""
	GREEN=""
	YELLOW=""
	GOLD=""
	GOLD_DK=""
	PURPLE_DK=""
	PURPLE=""
	PURPLE_LT=""
	RED=""
	ORANGE=""
	BOLD=""
	DIM=""
	REVERSE=""
	RESET=""
fi
export CYAN BLUE_DK
export BLUE
export BLUE_LT
export GREEN
export GRAY
export YELLOW
export GOLD
export GOLD_DK
export PURPLE_DK
export PURPLE
export PURPLE_LT
export RED
export ORANGE
export BOLD
export DIM
export REVERSE
export RESET

# -----------------------------------------------------------------------------
#
# LOGGING
#
# -----------------------------------------------------------------------------

# Function: action ARG…
# Logs an action
function log_action {
	echo " → $@${RESET}" >&2
}

function log_raw {
	echo "$@${RESET}" >&2
}

# Function: message ARG…
# Logs a message
function log_message {
	echo "${GRAY} … $*${RESET}" >&2
}

function log_result {
	echo "${GREEN} ✔ $*${RESET}" >&2
}

function log_tip {
	echo "${CYAN} ✱ $*${RESET}" >&2
}

function log_error {
	echo "${RED}ERR ${BOLD}$*${RESET}" >&2
}

function log_warning {
	echo "${ORANGE}WRN ${BOLD}$*${RESET}" >&2
}

function fmt_location {
	local out=""
	local name
	# Get the last index of the array
	local n=$((${#FUNCNAME[@]} - 1))
	# Iterate over the array in reverse order
	for ((i = n; i >= 1; i--)); do
		name="${FUNCNAME[i]}"
		if [ -z "$out" ]; then
			out="$name"
		else
			out="$name ← $out"
		fi
	done
	echo -n "$out"
}

# EOF
