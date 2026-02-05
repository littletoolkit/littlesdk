# -----------------------------------------------------------------------------
#
# GITHUB MODULE CONFIGURATION
#
# -----------------------------------------------------------------------------

# Configuration for installing dependencies from GitHub repositories.

# -----------------------------------------------------------------------------
#
# GITHUB DEPENDENCIES
#
# -----------------------------------------------------------------------------

# --
# ## Repository List

# List of GitHub repositories to install in USER/REPO[@BRANCH] format.
# Example: myuser/mylib@v1.0 owner/otherlib
USE_GITHUB?= ## GitHub repos to install as dependencies

# -----------------------------------------------------------------------------
#
# BUILD PHASES
#
# -----------------------------------------------------------------------------

# Add GitHub dependencies to prep phase
PREP_ALL+=$(foreach M,$(USE_GITHUB),build/install-github-$M.task)

# EOF
