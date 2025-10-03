
# -----------------------------------------------------------------------------
# NODE (GENERIC)
# -----------------------------------------------------------------------------

$(PATH_BUILD)/install-node-module-%.task: ## Installs the given Node module
	@$(call rule_pre_cmd)
	$(call shell_create_if,$(NPM) install  "$*",Unable to install Node module: $*)

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

$(PATH_BUILD)/install-bun-module-%.task: ## Installs the given Node module
	@$(call rule_pre_cmd)
	$(call shell_create_if,$(BUN) install  "$*",Unable to install Bun module: $*)

$(JS_BUILD_PATH)/%.js: src/ts/%.ts
	@$(call rule_pre_cmd)
	$(call shell_create_if,$(BUN) build  --external '*' "$<" > "$@",Unable to compile TypeScript module: $*)

$(JS_DIST_PATH)/%.js: src/ts/%.ts
	@$(call rule_pre_cmd)
	$(call shell_create_if,$(BUN) build  --minify --external '*' "$<" > "$@",Unable to compile TypeScript module: $*)

$(JS_BUILD_PATH)/%.js: src/js/%.js
	@$(call rule_pre_cmd)
	cp -a "$<" "$@"

$(JS_DIST_PATH)/%.js: src/js/%.js
	@$(call rule_pre_cmd)
	$(call shell_create_if,$(BUN) build --minify "$<" > "$@",Unable to compile JavaScript module: $*)
# EOF
