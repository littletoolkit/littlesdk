build/install-github-%.task: ## Installs the given Github repo in the form USER/REPO@VERSION
	@$(call rule_pre_cmd)
	USERNAME="$(firstword $(subst /,$(SPACE),$*))"
	REPONAME="$(firstword $(subst @,$(SPACE),$(lastword $(subst /,$(SPACE),$*))))"
	REVISION="$(lastword  $(subst @,$(SPACE),$(lastword $(subst /,$(SPACE),$*))))"
	mkdir -p deps
	if [ ! -e "deps/$$REPONAME" ]; then
		if ! $(GIT) clone "git@github.com:$$USERNAME/$$REPONAME.git" "deps/$$REPONAME"; then
			echo "$(call fmt_error,Unable to install Github repository: $*)"
			test -e "$@" && unlink "$@"
			exit 1
		fi
	fi
	if [ ! -e "$@" ]; then touch "$@"; fi
	if [ -e "deps/$$REPONAME/bin/$$REPONAME" ]; then
		mkdir -p run/bin
		ln -sfr "deps/$$REPONAME/bin/$$REPONAME" "run/bin/$$REPONAME"
	fi
	if [ -e "deps/$$REPONAME/src/py/$$REPONAME" ]; then
		mkdir -p run/lib/py
		ln -sfr "deps/$$REPONAME/src/py/$$REPONAME" "run/lib/py/$$REPONAME"
	fi

# EOF
