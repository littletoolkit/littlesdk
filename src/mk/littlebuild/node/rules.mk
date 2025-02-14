
build/install-node-%.task: ## Installs the given Node module
	@$(call rule_pre_cmd)
	if $(NPM) install  "$*"; then
		touch "$@"
	else
		echo "$(call fmt_error,Unable to install Node module: $*)"
		test -e "$@" && unlink "$@"
		exit 1
	fi

# EOF
