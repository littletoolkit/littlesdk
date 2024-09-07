build/install-git-%.task:
	@echo TODO
	#@mkdir -p "$(dir $@)"
	#USERNAME=$(firstword $(subst @,$(SPACE),$*))
	#REPONAME=$(lastword $(subst @,$(SPACE),$*))
	#mkdir -p deps
	#if ! $(GIT) clone git@github.com:$$USERNAME/$$REPONAME.git deps/$$REPONAME; then
	#	exit 1
	#fi
	#if [ -e deps/$$REPONAME/bin/$$REPONAME ]; then
	#	mkdir -p run/bin
	#	ln -sfr deps/$$REPONAME/bin/$$REPONAME run/bin/$$REPONAME
	#fi
	#if [ -e deps/$$REPONAME/src/py/$$REPONAME ]; then
	#	mkdir -p run/lib/py
	#	ln -sfr deps/$$REPONAME/src/py/$$REPONAME run/lib/py/$$REPONAME
	#fi


