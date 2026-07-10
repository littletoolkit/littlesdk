# -----------------------------------------------------------------------------
#
# OPENCODE CONFIGURATION
#
# -----------------------------------------------------------------------------

OPENCODE_AGENTS_AVAILABLE=$(foreach V,$(wildcard $(SDK_PATH)/etc/opencode/agents/*),$(firstword $(subst .,$(SPACE),$(notdir $(V)))))
OPENCODE_RULES_AVAILABLE=$(foreach V,$(wildcard $(SDK_PATH)/etc/opencode/rules/*),$(firstword $(subst .,$(SPACE),$(notdir $(V)))))
OPENCODE_SKILLS_DEPS=$(filter-out %.md, $(foreach V,$(wildcard deps/*),$(wildcard $V/docs/skills/*)))
OPENCODE_SKILLS_AVAILABLE=$(foreach V,$(wildcard $(SDK_PATH)/etc/opencode/skills/*) $(OPENCODE_SKILLS_DEPS),$(notdir $(V)))
OPENCODE_SKILLS?=$(foreach V,$(OPENCODE_SKILLS_DEPS),$(notdir $(V)))
OPENCODE_RULES?=
OPENCODE_AGENTS?=

OPENCODE_SKILLS_SDK_FILES=$(foreach V,$(OPENCODE_SKILLS),$(wildcard $(SDK_PATH)/etc/opencode/skills/$V/*))
OPENCODE_SKILLS_DEPS_PREP=$(foreach V,$(OPENCODE_SKILLS_DEPS),$(if $(filter $(notdir $V),$(OPENCODE_SKILLS)),$(addprefix .opencode/skills/$(notdir $V)/,$(notdir $(wildcard $V/*)))))

# --
# ## Preparation Targets

OPENCODE_PREP_ALL=\
	$(foreach V,$(OPENCODE_AGENTS),.opencode/agents/$V.md) \
	$(foreach V,$(OPENCODE_RULES),.opencode/rules/$V.md) \
	$(subst $(SDK_PATH)/etc/opencode,.opencode,$(OPENCODE_SKILLS_SDK_FILES)) \
	$(subst $(SDK_PATH)/etc/opencode,.agents,$(OPENCODE_SKILLS_SDK_FILES)) \
	$(OPENCODE_SKILLS_DEPS_PREP) \
	$(subst .opencode/,.agents/,$(OPENCODE_SKILLS_DEPS_PREP)) \
	$(PATH_RUN_TASK)/opencode-setup.task ## Ensures OpenCode is installed and configured

PREP_ALL+=$(OPENCODE_PREP_ALL)
# EOF
