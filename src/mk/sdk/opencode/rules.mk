# -----------------------------------------------------------------------------
#
# OPENCODE RULES
#
# -----------------------------------------------------------------------------

# --
# Validation

OPENCODE_EXTRA:=$(filter-out $(OPENCODE_PREP_ALL),$(sort $(shell for V in .opencode/agents/* .opencode/rules/* .opencode/skills/*/*; do [ -e "$$V" ] || continue; [ -L "$$V" ] || continue; T=$$(readlink -f "$$V" 2>/dev/null || true); [[ "$$T" == "$(SDK_PATH)/etc/opencode/"* ]] && printf '%s\n' "$$V"; done)))
ifneq ($(OPENCODE_EXTRA),)
$(info [OPC] Removing extra opencode SDK files: $(RED)$(shell for V in $(OPENCODE_EXTRA); do echo "$$V ";unlink "$$V"; done)$(RESET))
OPENCODE_EXTRA:=
endif

# --
# Function: opencode_check
# Validates that OpenCode is installed and has the Lattice MCP configured.
# Returns: Exits with an error when OpenCode, the Lattice MCP, or the helper binary is unavailable
define opencode_check
	@if ! command -v opencode >/dev/null 2>&1; then
		echo "$(call fmt_error,[OPC] OpenCode CLI is not available in PATH)"
		exit 1
	fi
endef

# -----------------------------------------------------------------------------
#
# RULES
#
# -----------------------------------------------------------------------------

.PHONY: opencode-check
opencode-check: ## Validates OpenCode and Lattice MCP configuration
	@$(call rule_pre_cmd)
	$(call opencode_check)
	@$(call rule_post_cmd)

.PHONY: opencode-check
opencode-list: ## Shows open code options
	@
	echo "$(BOLD)OPENCODE_SKILL   $(GREEN)$(if $(OPENCODE_SKILLS), [$(OPENCODE_SKILLS)], $(RESET)$(RED)[none]$(RESET)) -- $(OPENCODE_SKILLS_AVAILABLE)$(RESET)"
	echo "$(BOLD)OPENCODE_RULES   $(GREEN)$(if $(OPENCODE_RULES), [$(OPENCODE_RULES)], $(RESET)$(RED)[none]$(RESET)) -- $(OPENCODE_RULES_AVAILABLE)$(RESET)"
	echo "$(BOLD)OPENCODE_AGENTS  $(GREEN)$(if $(OPENCODE_AGENTS), [$(OPENCODE_AGENTS)], $(RESET)$(RED)[none]$(RESET)) -- $(OPENCODE_AGENTS_AVAILABLE)$(RESET)"
	echo "$(BOLD)OPENCODE_EXTRA   $(GREEN)$(if $(OPENCODE_EXTRA), [$(OPENCODE_EXTRA)], $(RESET)$(RED)[none]$(RESET))$(RESET)"

$(PATH_RUN_TASK)/opencode-install.task: $(call use_cli,curl) ## Installs the OpenCode CLI when missing
	@$(call rule_pre_cmd)
	@if ! command -v opencode >/dev/null 2>&1; then
		echo "$(call fmt_action,[OPC] Installing OpenCode CLI...)"
		echo "$(call fmt_tip,[OPC] Running: curl -fsSL https://opencode.ai/install | bash)"
		curl -fsSL https://opencode.ai/install | bash
	fi
	@if command -v opencode >/dev/null 2>&1; then
		echo "$(call fmt_result,[OPC] OpenCode installed: $$(command -v opencode))"
		touch "$@"
	else
		echo "$(call fmt_error,[OPC] Failed to install OpenCode CLI)"
		exit 1
	fi
	@$(call rule_post_cmd)

$(PATH_RUN_TASK)/opencode-setup.task: $(PATH_RUN_TASK)/opencode-install.task opencode.jsonc ## Verifies the OpenCode local setup
	@$(call rule_pre_cmd)
	$(call opencode_check)
	@touch "$@"
	@$(call rule_post_cmd)

.opencode/%: $(SDK_PATH)/etc/opencode/%
	@$(call rule_pre_cmd)
	mkdir -p $(dir $@)
	ln -sfr $< $@
	$(call rule_post_cmd)

# EOF
