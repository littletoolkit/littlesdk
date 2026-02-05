# -----------------------------------------------------------------------------
# RULES
# -----------------------------------------------------------------------------

# --
# Exports secrets defined in SECRETS_EXPORTS
# This rule ensures that all secrets defined in SECRETS_EXPORTS are exported
# to the environment variables.
ifneq ($(SECRETS_EXPORTS),)
	# We define each variable
	$(foreach S,$(SECRETS_EXPORTS),$(eval $(firstword $(subst :,$(SPACE),$S))?=$$(shell littlesecrets get $(lastword $(subst :,$(SPACE),$S)))))
	$(foreach V,$(SECRETS_VARNAMES),$(eval SHELL_$V=$$($V)))
	# And add them to the export
	SHELL_EXPORTS+=$(foreach S,$(SECRETS_EXPORTS),export $(firstword $(subst :,$(SPACE),$S)))
	$(info --- [SEC] Exported secrets: $(foreach S,$(SECRETS_EXPORTS),$(firstword $(subst :,$(SPACE),$S))))
endif

# EOF

