# -----------------------------------------------------------------------------
#
# OPENCODE CONFIGURATION
#
# -----------------------------------------------------------------------------

OPENCODE_AGENTS_AVAILABLE=$(foreach V,$(wildcard $(SDK_PATH)/etc/opencode/agents/*),$(firstword $(subst .,$(SPACE),$(notdir $(V)))))
OPENCODE_RULES_AVAILABLE=$(foreach V,$(wildcard $(SDK_PATH)/etc/opencode/rules/*),$(firstword $(subst .,$(SPACE),$(notdir $(V)))))
OPENCODE_SKILLS_AVAILABLE=$(foreach V,$(wildcard $(SDK_PATH)/etc/opencode/skills/*),$(notdir $(V)))
OPENCODE_SKILLS?=
OPENCODE_RULES?=
OPENCODE_AGENTS?=

# --
# ## Preparation Targets

OPENCODE_PREP_ALL=\
	$(foreach V,$(OPENCODE_AGENTS),.opencode/agents/$V.md) \
	$(foreach V,$(OPENCODE_RULES),.opencode/rules/$V.md) \
	$(foreach V,$(OPENCODE_SKILLS),$(subst $(SDK_PATH)/etc/opencode,.opencode,$(wildcard $(SDK_PATH)/etc/opencode/skills/$V/*))) \
	$(PATH_RUN_TASK)/opencode-setup.task ## Ensures OpenCode is installed and configured

PREP_ALL+=$(OPENCODE_PREP_ALL)
# EOF
