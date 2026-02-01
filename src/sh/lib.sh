#!/usr/bin/env bash
SDK_LIB_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
SDK_LIB_MODULES=$(find "$SDK_LIB_PATH" -name "*.sh")
SDK_LIB_LOADED=
export SDK_LIB_MODULES

function sdk_lib_load {
	local module_path=""
	for module in "$@"; do
		module_path=$SDK_LIB_PATH/lib-$module.sh
		# Actually, following that advice breaks the code
		# shellcheck disable=SC2076
		if ! [[ "$SDK_LIB_LOADED" =~ "[$module]" ]]; then
			if [ -e "$module_path" ]; then
				SDK_LIB_LOADED+="[$module]"
				# shellcheck source=/dev/null
				source "$module_path"
			else
				>&2 echo "${RED:-} ⚠  ERR [lib] Module '$module' not found: ${ORANGE:-}$module_path${RESET:-}"
			fi
		fi
	done
}
# EOF
