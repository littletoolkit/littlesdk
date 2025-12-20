# A list like VAR_NAME=secret.name of secrets to export. Will add corresponding EN
SECRETS_EXPORTS?=
SECRETS_VARNAMES=$(foreach S,$(SECRETS_EXPORTS),$(firstword $(subst :,$(SPACE),$S)))
# EOF
