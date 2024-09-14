.PHONY: dist-www
run-www: $(RUN_WWW_ALL) ## Runs the local web server
	@$(call rule-pre-cmd)
	if [ -d "deps/extra" ]; then
		PORT=$(PORT) PYTHONPATH=deps/extra/src/py python -m extra
	else
		python -m http.serer $(PORT)
	fi
	$(call rule-post-cmd)


.PHONY: dist-www
dist-www: $(DIST_WWW_ALL) ## Builds web assets in $(DIST_WWW_ALL)
	@$(call rule-pre-cmd)

	$(call rule-post-cmd,$(DIST_WWW_ALL))

# =============================================================================
# RUN
# =============================================================================

run/lib/%: src/%
	@$(call rule-pre-cmd)
	ln -sfr "$<" "$@"

run/%: src/html/%
	@$(call rule-pre-cmd)
	ln -sfr "$<" "$@"

run/%: src/xml/%
	@$(call rule-pre-cmd)
	ln -sfr "$<" "$@"

# =============================================================================
# DIST
# =============================================================================

dist/www/%.html: src/xml/%.xml $(SOURCES_XSLT)
	@$(call rule-pre-cmd)
	if ! $$(xsltproc "$<" > "$@.tmp"); then
		unlink "$@.tmp"
		test -e "$@" && unlink "$@"
		exit 1
	else
		mv "$@.tmp" "$@"
	fi

dist/www/lib/css/%.css: src/css/%.css
	@$(call rule-pre-cmd)
	cp -a "$<" "$@"

dist/www/lib/css/%.css: src/css/%.js
	@$(call rule-pre-cmd)
	if ! bun -e "import mod from './$<';import css from '@littlecss.js';console.log([...css(mod)].join('\n'))" > "$@"; then
		unlink "$@"
		exit 1
	fi

# EOF
