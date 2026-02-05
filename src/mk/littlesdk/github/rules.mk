# -----------------------------------------------------------------------------
#
# GITHUB MODULE RULES
#
# -----------------------------------------------------------------------------

# Rules for cloning and installing GitHub repository dependencies.

# -----------------------------------------------------------------------------
#
# REPOSITORY INSTALLATION
#
# -----------------------------------------------------------------------------

$(PATH_RUN)/install-github-%.task: ## Installs GitHub repo (format: USER/REPO@VERSION)
	@$(call rule_pre_cmd)
	USERNAME="$(firstword $(subst /,$(SPACE),$*))"
	REPONAME="$(firstword $(subst @,$(SPACE),$(lastword $(subst /,$(SPACE),$*))))"
	REVISION="$(lastword $(subst @,$(SPACE),$(lastword $(subst /,$(SPACE),$*))))"
	mkdir -p "$(PATH_DEPS)"
	if [ ! -e "$(PATH_DEPS)/$$REPONAME" ]; then
		if ! $(GIT) clone "git@github.com:$$USERNAME/$$REPONAME.git" "$(PATH_DEPS)/$$REPONAME"; then
			echo "$(call fmt_error,Unable to install Github repository: $*)"
			test -e "$@" && unlink "$@"
			exit 1
		fi
	fi
	if [ ! -e "$@" ]; then touch "$@"; fi
	if [ -e "$(PATH_DEPS)/$$REPONAME/bin/$$REPONAME" ]; then
		mkdir -p run/bin
		ln -sfr "$(PATH_DEPS)/$$REPONAME/bin/$$REPONAME" "run/bin/$$REPONAME"
	fi
	if [ -e "$(PATH_DEPS)/$$REPONAME/src/py/$$REPONAME" ]; then
		mkdir -p $(PATH_RUN)/lib/py
		ln -sfr "$(PATH_DEPS)/$$REPONAME/src/py/$$REPONAME" "$(PATH_RUN)/lib/py/$$REPONAME"
	fi

# EOF
