# -----------------------------------------------------------------------------
#
# OPENCODE RULES
#
# -----------------------------------------------------------------------------

# --
# ## Validation

# --
# Function: opencode_check
# Validates that OpenCode is installed and has the Lattice MCP configured.
# Returns: Exits with an error when OpenCode or the Lattice MCP is unavailable
define opencode_check
	@if ! command -v opencode >/dev/null 2>&1; then
		echo "$(call fmt_error,[OPC] OpenCode CLI is not available in PATH)"
		exit 1
	elif ! opencode mcp list | grep -q 'lattice'; then
		echo "$(call fmt_error,[OPC] Lattice MCP is not configured for OpenCode)"
		exit 1
	else
		echo "$(call fmt_result,[OPC] OpenCode configured)"
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

$(PATH_RUN)/tasks/opencode-install.task: $(call use_cli,curl) ## Installs the OpenCode CLI when missing
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

$(PATH_RUN)/tasks/opencode-matryoshka.task: $(call use_cli,bun) ## Installs the Lattice MCP helper when missing
	@$(call rule_pre_cmd)
	@if command -v lattice-mcp >/dev/null 2>&1; then
		echo "$(call fmt_result,[OPC] lattice-mcp is already available)"
	else
		echo "$(call fmt_action,[OPC] Installing matryoshka-rlm globally...)"
		bun install -g matryoshka-rlm
		echo "$(call fmt_result,[OPC] matryoshka-rlm installed globally)"
	fi
	@touch "$@"
	@$(call rule_post_cmd)

$(PATH_RUN)/tasks/opencode-setup.task: $(PATH_RUN)/tasks/opencode-install.task $(PATH_RUN)/tasks/opencode-matryoshka.task opencode.jsonc ## Verifies the OpenCode local setup
	@$(call rule_pre_cmd)
	$(call opencode_check)
	@touch "$@"
	@$(call rule_post_cmd)

# EOF
