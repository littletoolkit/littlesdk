# -----------------------------------------------------------------------------
#
# MISE MODULE RULES
#
# -----------------------------------------------------------------------------

# Rules for installing and managing mise tool versions.

# -----------------------------------------------------------------------------
#
# PREPARATION
#
# -----------------------------------------------------------------------------

.PHONY: prep-mise
prep-mise: $(PATH_BUILD)/prep-mise-$(MISE_VERSION).task ## Installs mise version manager
	@$(call rule_pre_cmd)
	$(call rule_post_cmd)

# -----------------------------------------------------------------------------
#
# MISE INSTALLATION
#
# -----------------------------------------------------------------------------

$(PATH_RUN)/bin/mise-$(MISE_VERSION): $(call use_cli,curl) ## Downloads and installs mise
	@$(call rule_pre_cmd)
	# Mise is a static binary, no config file required
	curl https://mise.run | MISE_VERSION="$*" MISE_INSTALL_PATH="$(abspath $@)" sh
	$(call rule_post_cmd)

# EOF
