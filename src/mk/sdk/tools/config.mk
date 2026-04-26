# Parameter: USE_TOOLS
# Default tools to be installed
USE_TOOLS?=multiplex
ifneq ($(wildcard .littlesecrets),)
USE_TOOLS+=littlesecrets
endif
ifneq ($(wildcard .gitdeps .jjdeps),)
USE_TOOLS+=git-deps
PREP_ALL+=$(PATH_RUN_TASK)/git-deps-checkout.task
endif

TOOLS_WHITELIST=$(SDK_PATH)/src/mk/sdk/tools/whitelist.lst
TOOLS_SYSTEM_AVAILABLE=$(sort $(shell  grep -v '#' "$(TOOLS_WHITELIST)" | cut -d= -f1))

# Pinned revision numbers for the tools, should be updated on a regular basis.
TOOL_LITTLESECRETS_COMMIT?=a091e71def7460ffc9f3eb904870830181b73e76
TOOL_MULTIPLEX_COMMIT?=e20c6182233b37c43d1bb00791a914faed13a06c
TOOL_GITDEPS_COMMIT?=b471d6af6ec0a4da70beca05d2ab19a2e0132be1

# --
# tool_github_ref BRANCH_OR_COMMIT
# Returns the proper GitHub ref for a branch or commit
tool_github_ref=$(if $(filter @%,$1),refs/head/$(subst @,,$1),$1)

# --
# tool_github_file USER/REPO FILE BRANCH_OR_COMMIT
# Returns the proper GitHub raw file URL
tool_github_file=https://raw.githubusercontent.com/$1/$(call tool_github_ref,$3)/$2

# =============================================================================
# PACKAGE MANAGEMENT
# =============================================================================

define system_package_manager
if command -v brew >/dev/null 2>&1; then
	echo "brew";
elif command -v yum >/dev/null 2>&1 || command -v dnf >/dev/null 2>&1; then
	echo "rpm";
elif command -v apt >/dev/null 2>&1 || command -v apt-get >/dev/null 2>&1; then
	echo "deb";
else \
	echo "unknown";
fi
endef
SYSTEM_PACKAGE_MANAGER?=$(shell $(system_package_manager))
PREP_TOOLS+=$(foreach T,$(USE_TOOLS) $(if $(wildcard mise.toml),mise),$(PATH_RUN_TASK)/tool-$T.task)
PREP_ALL+=$(PREP_TOOLS)
# EOF

