## List of Github nodules to use in the form REPO/USER[@BRANCH]
USE_GITHUB?=

PREP_ALL+=$(foreach M,$(USE_GITHUB),build/install-github-$M.task)
# EOF
