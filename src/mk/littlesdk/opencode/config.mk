# -----------------------------------------------------------------------------
#
# OPENCODE CONFIGURATION
#
# -----------------------------------------------------------------------------

# --
# ## Preparation Targets

OPENCODE_LATTICE_PACKAGE?=matryoshka-rlm@0.2.8
OPENCODE_LATTICE_BINARY?=lattice-mcp

PREP_ALL+=$(PATH_RUN)/tasks/opencode-setup.task ## Ensures OpenCode is installed and configured

# EOF
