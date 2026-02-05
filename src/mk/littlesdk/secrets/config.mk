# -----------------------------------------------------------------------------
#
# SECRETS MODULE CONFIGURATION
#
# -----------------------------------------------------------------------------

# Configuration for managing secrets via littlesecrets integration.
# Secrets are exported as environment variables during build/runtime.

# -----------------------------------------------------------------------------
#
# SECRETS CONFIGURATION
#
# -----------------------------------------------------------------------------

# --
# ## Secret Exports

# List of secrets to export as VAR_NAME=secret.name pairs.
# Example: DATABASE_URL=database.prod.uri API_KEY=api.key
SECRETS_EXPORTS?= ## Secrets to export (format: VAR_NAME=secret.path)

# Extract variable names from SECRETS_EXPORTS
SECRETS_VARNAMES=$(foreach S,$(SECRETS_EXPORTS),$(firstword $(subst :,$(SPACE),$S))) ## Derived variable names

# EOF
