# -----------------------------------------------------------------------------
# RULES
# -----------------------------------------------------------------------------

define js-linter
	$(call use_env)
	if [ -n "$(if $(strip $(SOURCES_JS)),JS)" ]; then
		echo "$(call fmt_action,Linting: $(SOURCES_JS))"
		$(call shell_try,$(JS_RUN) @biomejs/biome lint --config-path=$(abspath $(SDK_PATH)/etc/biome.jsonc) $1 $(SOURCES_JS),Unable to lint JavaScript sources)
	fi
	if [ -n "$(if $(strip $(SOURCES_TS)),TS)" ]; then
		echo "$(call fmt_action,Checking: $(SOURCES_TS))"
		$(call shell_try,$(JS_RUN) @biomejs/biome check --config-path=$(abspath $(SDK_PATH)/etc/biome.jsonc) $1 $(SOURCES_TS),Unable to lint TypeScript sources)
	fi
endef

define ts-linter
	if [ -n "$(wildcard tsconfig.json)" ]; then
		echo "$(call fmt_action,Type checking: $(SOURCES_TS))"
		$(call shell_try,$(JS_RUN) tsc --noEmit,Unable to lint TypeScript sources)
	fi
endef


.PHONY: js-check
js-check: $(SOURCES_TS) $(SOURCES_JS) ## Lints JavaScript and TypeScript sources
	@$(call js-linter)
	$(call ts-linter)
	$(call rule_post_cmd,$^)

js-typecheck: $(SOURCES_TS) $(SOURCES_JS) ## Lints JavaScript and TypeScript sources
	@$(call ts-linter)
	$(call rule_post_cmd,$^)

.PHONY: js-fix
js-fix: $(SOURCES_TS) $(SOURCES_JS) ## Lints JavaScript and TypeScript sources
	@$(call js-linter,--fix)
	$(call rule_post_cmd,$^)

.PHONY: js-test
js-test: $(TESTS_TS) $(TESTS_JS) ## Runs JavaScript and TypeScript tests
	@$(BUN) test $(TESTS_TS) $(TESTS_JS)
	$(call rule_post_cmd,$^)



.PHONY: js-info
js-info: ## Shows TypeScript project configuratino
	@if [ -n "$(wildcard tsconfig.json)" ]; then
		echo "$(call fmt_action,TypeScript sources: tsconfig.json)"
		$(call shell_try,$(JS_RUN) tsc --noEmit --listFiles,Unable to show TypeScript configuration)
	fi

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

# -----------------------------------------------------------------------------
# BUNDLE (Standalone production build)
# -----------------------------------------------------------------------------

# Convert JS_BUNDLE_EXTERNAL space-separated list to --external flags
JS_BUNDLE_EXTERNAL_FLAGS=$(foreach M,$(JS_BUNDLE_EXTERNAL),--external '$M')

# Extract icons from source files and fetch from Iconify API
$(JS_BUNDLE_ICONS_OUTPUT): $(JS_BUNDLE_ICONS_SOURCES)
	@$(call rule_pre_cmd)
	@mkdir -p $(dir $@)
	$(SDK_PATH)/bin/sdk-extract-icons $(JS_BUNDLE_ICONS_SOURCES) > $@

# Build the standalone bundle (depends on icons extraction)
# NOTE: We use --outdir instead of --outfile because some dependencies (like loro-crdt)
# include WASM files that get extracted as separate assets during bundling.
$(JS_BUNDLE_OUTPUT): $(JS_BUNDLE_ENTRY) $(SOURCES_TS) $(JS_BUNDLE_ICONS_OUTPUT)
	@$(call rule_pre_cmd)
	@if [ -z "$(JS_BUNDLE_ENTRY)" ]; then \
		echo "$(call fmt_error,JS_BUNDLE_ENTRY not set. Set it to your entry point.)"; \
		exit 1; \
	fi
	@mkdir -p $(dir $@)
	$(BUN) build $(JS_BUNDLE_ENTRY) \
		--bundle \
		--minify \
		--target=browser \
		--format=esm \
		$(JS_BUNDLE_EXTERNAL_FLAGS) \
		--outdir=$(dir $@) \
		--entry-naming=$(notdir $@)
	@if [ ! -f "$@" ]; then \
		echo "$(call fmt_error,Bundle output not found: $@)"; \
		exit 1; \
	fi

.PHONY: js-bundle
js-bundle: $(JS_BUNDLE_OUTPUT) ## Creates a minified standalone JS bundle
	@$(call rule_post_cmd,$(JS_BUNDLE_OUTPUT))

# Build the debug bundle (no minification, preserves symbols for debugging)
$(JS_BUNDLE_DEBUG_OUTPUT): $(JS_BUNDLE_ENTRY) $(SOURCES_TS) $(JS_BUNDLE_ICONS_OUTPUT)
	@$(call rule_pre_cmd)
	@if [ -z "$(JS_BUNDLE_ENTRY)" ]; then \
		echo "$(call fmt_error,JS_BUNDLE_ENTRY not set. Set it to your entry point.)"; \
		exit 1; \
	fi
	@mkdir -p $(dir $@)
	$(BUN) build $(JS_BUNDLE_ENTRY) \
		--bundle \
		--target=browser \
		--format=esm \
		$(JS_BUNDLE_EXTERNAL_FLAGS) \
		--outdir=$(dir $@) \
		--entry-naming=$(notdir $@)
	@if [ ! -f "$@" ]; then \
		echo "$(call fmt_error,Debug bundle output not found: $@)"; \
		exit 1; \
	fi

.PHONY: js-bundle-debug
js-bundle-debug: $(JS_BUNDLE_DEBUG_OUTPUT) ## Creates a non-minified JS bundle for debugging
	@$(call rule_post_cmd,$(JS_BUNDLE_DEBUG_OUTPUT))

# EOF
