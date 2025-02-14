build/install-python-%.task: ## Installs the given Python module for the given version
	@$(call rule_pre_cmd)
	MODULE="$(firstword $(subst @,$(SPACE),$*))"
	VERSION="$(lastword $(subst @,$(SPACE),$*))"
	if [ -n "$$VERSION" ]; then
		MODULE+="--$$VERSION"
	fi
	if $(PYTHON) -m pip install --user -U "$$MODULE"; then
		touch "$@"
	else
		echo "$(call fmt_error,Unable to install Python module: $$MODULE)"
		test -e "$@" && unlink "$@"
		exit 1
	fi

# EOF
