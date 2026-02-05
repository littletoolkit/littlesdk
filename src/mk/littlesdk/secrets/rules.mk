# -----------------------------------------------------------------------------
#
# SECRETS MODULE RULES
#
# -----------------------------------------------------------------------------

# Rules for exporting secrets to environment variables using littlesecrets.

# -----------------------------------------------------------------------------
#
# SECRET EXPORT
#
# -----------------------------------------------------------------------------

# --
# ## Export Secrets

# Exports secrets defined in SECRETS_EXPORTS to environment variables
ifneq ($(SECRETS_EXPORTS),)
# Define each secret variable
$(foreach S,$(SECRETS_EXPORTS),$(eval $(firstword $(subst :,$(SPACE),$S)))?=$$(shell littlesecrets get $(lastword $(subst :,$(SPACE),$S))))

# Create shell versions of variables
$(foreach V,$(SECRETS_VARNAMES),$(eval SHELL_$V=$$($V)))

# Add to shell exports
SHELL_EXPORTS+=$(foreach S,$(SECRETS_EXPORTS),export $(firstword $(subst :,$(SPACE),$S)))

# Log exported secrets
$(info --- [SEC] Exported secrets: $(foreach S,$(SECRETS_EXPORTS),$(firstword $(subst :,$(SPACE),$S))))
endif

# EOF
