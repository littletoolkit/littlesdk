# -----------------------------------------------------------------------------
# RULES
# -----------------------------------------------------------------------------

define js-linter
	$(call use_env)
	if [ -n "$(if $(strip $(SOURCES_JS)),JS)" ]; then
		echo "$(call fmt_action,Linting: $(SOURCES_JS))"
		$(call shell_try,$(JS_RUN) @biomejs/biome lint $1 $(SOURCES_JS),Unable to lint JavaScript sources)
	fi
	if [ -n "$(if $(strip $(SOURCES_TS)),TS)" ]; then
		echo "$(call fmt_action,Checking: $(SOURCES_TS))"
		$(call shell_try,$(JS_RUN) @biomejs/biome check $1 $(SOURCES_TS),Unable to lint TypeScript sources)
	fi
endef



.PHONY: js-check
js-check: $(SOURCES_TS) $(SOURCES_JS) ## Lints JavaScript and TypeScript sources
	@$(call js-linter)
	$(call rule_post_cmd,$^)

.PHONY: js-fix
js-fix: $(SOURCES_TS) $(SOURCES_JS) ## Lints JavaScript and TypeScript sources
	@$(call js-linter,--fix)
	$(call rule_post_cmd,$^)

.PHONY: js-test
js-test: $(TESTS_TS) $(TESTS_JS) ## Runs JavaScript and TypeScript tests
	@$(BUN) test $(TESTS_TS) $(TESTS_JS)
	$(call rule_post_cmd,$^)



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
