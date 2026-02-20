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
# Returns: Exits with an error when OpenCode, the Lattice MCP, or the helper binary is unavailable
define opencode_check
	@if ! command -v opencode >/dev/null 2>&1; then
		echo "$(call fmt_error,[OPC] OpenCode CLI is not available in PATH)"
		exit 1
	fi
	@if ! command -v $(OPENCODE_LATTICE_BINARY) >/dev/null 2>&1; then \
		$(MAKE) --no-print-directory opencode-repair-lattice; \
	fi
	@if ! command -v $(OPENCODE_LATTICE_BINARY) >/dev/null 2>&1; then
		echo "$(call fmt_error,[OPC] $(OPENCODE_LATTICE_BINARY) is not available in PATH)"
		exit 1
	fi
	@if ! opencode mcp list | grep -q 'lattice'; then
		echo "$(call fmt_error,[OPC] Lattice MCP is not configured for OpenCode)"
		exit 1
	fi
	@PKG_BIN="$$(readlink -f "$$(command -v $(OPENCODE_LATTICE_BINARY))")"; \
	PKG_DIR="$$(dirname "$$(dirname "$$PKG_BIN")")"; \
	MOD_DIR="$$(dirname "$$PKG_DIR")/better-sqlite3"; \
	if ! command -v lattice-pipe >/dev/null 2>&1; then \
		echo "$(call fmt_warn,[OPC] lattice-pipe is not available; attempting repair)"; \
		$(MAKE) --no-print-directory opencode-repair-lattice; \
	fi; \
	if ! command -v lattice-pipe >/dev/null 2>&1; then \
		echo "$(call fmt_error,[OPC] lattice-pipe is not available in PATH)"; \
		exit 1; \
	fi; \
	if ! lattice-pipe --help >/dev/null 2>&1; then \
		echo "$(call fmt_error,[OPC] lattice-pipe failed to start)"; \
		exit 1; \
	fi; \
	if ! node -e "require(process.argv[1])" "$$MOD_DIR" >/dev/null 2>&1; then \
		echo "$(call fmt_warn,[OPC] better-sqlite3 failed to load; attempting repair)"; \
		$(MAKE) --no-print-directory opencode-repair-lattice; \
		if ! node -e "require(process.argv[1])" "$$MOD_DIR" >/dev/null 2>&1; then \
			echo "$(call fmt_error,[OPC] better-sqlite3 is still broken after repair)"; \
			exit 1; \
		fi; \
	fi
	@echo "$(call fmt_result,[OPC] OpenCode configured)"
endef

# -----------------------------------------------------------------------------
#
# RULES
#
# -----------------------------------------------------------------------------

.PHONY: opencode-check opencode-repair-lattice
opencode-check: ## Validates OpenCode and Lattice MCP configuration
	@$(call rule_pre_cmd)
	$(call opencode_check)
	@$(call rule_post_cmd)

opencode-repair-lattice: ## Repairs the OpenCode Lattice helper install
	@$(call rule_pre_cmd)
	@echo "$(call fmt_action,[OPC] Repairing Lattice MCP helper...)"; \
	bun install -g $(OPENCODE_LATTICE_PACKAGE); \
	PKG_BIN="$$(readlink -f "$$(command -v $(OPENCODE_LATTICE_BINARY))" 2>/dev/null || true)"; \
	if [ -n "$$PKG_BIN" ] && command -v npm >/dev/null 2>&1; then \
		PKG_DIR="$$(dirname "$$(dirname "$$PKG_BIN")")"; \
		(cd "$$PKG_DIR" && npm rebuild better-sqlite3 >/dev/null 2>&1) || true; \
	fi; \
	echo "$(call fmt_result,[OPC] Lattice MCP helper repaired)"
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
	@if command -v $(OPENCODE_LATTICE_BINARY) >/dev/null 2>&1; then
		echo "$(call fmt_result,[OPC] $(OPENCODE_LATTICE_BINARY) is already available)"
	else
		$(MAKE) --no-print-directory opencode-repair-lattice
	fi
	@touch "$@"
	@$(call rule_post_cmd)

$(PATH_RUN)/tasks/opencode-setup.task: $(PATH_RUN)/tasks/opencode-install.task $(PATH_RUN)/tasks/opencode-matryoshka.task opencode.jsonc ## Verifies the OpenCode local setup
	@$(call rule_pre_cmd)
	$(call opencode_check)
	@touch "$@"
	@$(call rule_post_cmd)

# EOF
