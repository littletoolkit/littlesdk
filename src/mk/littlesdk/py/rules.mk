# -----------------------------------------------------------------------------
# RULES
# -----------------------------------------------------------------------------

define py-linter
	$(call use_env)
	if [ -n "$(if $(strip $(SOURCES_PY)),PY)" ]; then
		echo "$(call fmt_action,Linting: $(SOURCES_PY))"
		$(call shell_try,$(UV) run ruff check $(SOURCES_PY) $1,Unable to lint Python sources)
	fi
endef

define py-typechecker
	$(call use_env)
	if [ -n "$(if $(strip $(SOURCES_PY)),PY)" ]; then
		echo "$(call fmt_action,Linting: $(SOURCES_PY))"
		$(call shell_try,$(UV) run ty check $(SOURCES_PY) $1,Unable to typecheck Python sources)
	fi
endef

define py-fixer
	$(call use_env)
	if [ -n "$(if $(strip $(SOURCES_PY)),PY)" ]; then
		echo "$(call fmt_action,Fixing: $(SOURCES_PY))"
		$(call shell_try,$(UV) fmt $(SOURCES_PY),Unable to fix Python sources)
	fi
endef

.PHONY: py-check
py-check: $(SOURCES_PY)  ## Lints Python sources
	@$(call py-linter)
	$(call rule_post_cmd,$^)

.PHONY: py-typecheck
py-typecheck: $(SOURCES_PY) ## Typechecks Python sources
	@$(call py-typechecker)
	$(call rule_post_cmd,$^)

.PHONY: py-fix
py-fix: $(SOURCES_PY) ## Fixes/formats Python source
	@$(call py-linter,--fix)
	$(call rule_post_cmd,$^)

.PHONY: py-test
py-test: $(TESTS_PY)  ## Runs Python tests
	@$(BUN) test $(TESTS_PY)
	$(call rule_post_cmd,$^)

.PHONY: py-info
py-info: ## Shows Python project configuratino
	@
	# TODO

$(PATH_BUILD)/install-python-%.task: ## Installs the given Python module for the given version
	@$(call rule_pre_cmd)
	MODULE="$(firstword $(subst @,$(SPACE),$*))"
	VERSION="$(lastword $(subst @,$(SPACE),$*))"
	if [ -n "$$VERSION" ]; then
		MODULE+="--$$VERSION"
	fi
	# TODO: We should modularize that and support other installers
	if $(PYTHON) -m pip install --user -U "$$MODULE"; then
		touch "$@"
	else
		echo "$(call fmt_error,Unable to install Python module: $$MODULE)"
		test -e "$@" && unlink "$@"
		exit 1
	fi

# EOF
