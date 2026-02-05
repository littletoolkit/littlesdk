
.PHONY: prep-mise
prep-mise: $(PATH_BUILD)/prep-mise-$(MISE_VERSION).task
	@$(call rule_pre_cmd)
	$(call rule_post_cmd)

$(PATH_RUN)/bin/mise-$(MISE_VERSION): $(call use_cli,curl) ## Sets up mise
	@$(call rule_pre_cmd)
	# Mise is a static binary, no config file required
	curl https://mise.run | MISE_VERSION="$*" MISE_INSTALL_PATH="$(abspath $@)" sh
	$(call rule_post_cmd)

# EOF
