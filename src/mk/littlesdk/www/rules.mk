.PHONY: www-run
www-run: $(WWW_RUN_ALL) ## Runs the local web server
	@$(call rule_pre_cmd)
	if [ -d "deps/extra" ]; then
		$(if $(WWW_PATH),env -C "$(WWW_PATH)") PORT=$(PORT) PYTHONPATH=$(realpath deps/extra/src/py) $(PYTHON) -m extra
	else
		$(if $(WWW_PATH),env -C "$(WWW_PATH)") $(PYTHON) -m http.server $(PORT)
	fi
	$(call rule_post_cmd)


.PHONY: www-dist
www-dist: $(WWW_DIST_ALL) ## Builds web assets in $(WWW_DIST_ALL)
	@$(call rule_pre_cmd)

	$(call rule_post_cmd,$(WWW_DIST_ALL))

# =============================================================================
# RUN
# =============================================================================

run/lib/%: src/%
	@$(call rule_pre_cmd)
	ln -sfr "$<" "$@"

run/lib/%: build/lib/%
	@$(call rule_pre_cmd)
	ln -sfr "$<" "$@"

run/%: src/html/%
	@$(call rule_pre_cmd)
	ln -sfr "$<" "$@"

run/%: src/xml/%
	@$(call rule_pre_cmd)
	ln -sfr "$<" "$@"

# =============================================================================
# DIST
# =============================================================================

dist/www/%.html: src/xml/%.xml $(SOURCES_XSLT)
	@$(call rule_pre_cmd)
	if ! $$(xsltproc "$<" > "$@.tmp"); then
		unlink "$@.tmp"
		test -e "$@" && unlink "$@"
		exit 1
	else
		mv "$@.tmp" "$@"
	fi

dist/www/lib/js/%.js: src/js/%.js
	@$(call rule_pre_cmd)
	$(call use_cmd,esbuild) --minify --outfile="$@" "$<"

dist/www/lib/css/%.css: src/css/%.css
	@$(call rule_pre_cmd)
	cp -Lp "$<" "$@"

dist/www/lib/css/%.css: src/css/%.js
	@$(call rule_pre_cmd)
	if ! $(BUN) -e "import mod from './$<';import css from '@littlecss.js';console.log([...css(mod)].join('\n'))" > "$@"; then
		unlink "$@"
		exit 1
	fi

# EOF
