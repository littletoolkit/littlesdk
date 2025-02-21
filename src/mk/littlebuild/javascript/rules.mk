
# -----------------------------------------------------------------------------
# NODE (GENERIC)
# -----------------------------------------------------------------------------

$(PATH_BUILD)/install-node-%.task: ## Installs the given Node module
	@$(call rule_pre_cmd)
	if $(NPM) install  "$*"; then
		touch "$@"
	else
		echo "$(call fmt_error,Unable to install Node module: $*)"
		test -e "$@" && unlink "$@"
		exit 1
	fi

# -----------------------------------------------------------------------------
# BUN
# -----------------------------------------------------------------------------

$(PATH_BUILD)/install-bun.task: $(PATH_BUILD)/install-bun-$(BUN_VERSION).task
	@$(call rule_pre_cmd)
	touch "$@"

$(PATH_BUILD)/install-bun-%.task:
	@$(call rule_pre_cmd)
	# FIXME: This does not seem to work, I get a segfault
	curl -fsSL -o $@.zip https://github.com/oven-sh/bun/releases/$*/download/bun-linux-x64.zip
	mkdir -p "$@.files"
	unzip -j $@.zip  -d "$@.files"
	$(call sh_install_tool,$@.files/bun)


# EOF
