.PHONY: dist-www
run-www: $(RUN_WWW_ALL) ## Runs the local web server
	@$(call rule_pre_cmd)
	if [ -d "deps/extra" ]; then
		$(if $(WWW_PATH),env -C "$(WWW_PATH)") PORT=$(PORT) PYTHONPATH=$(realpath deps/extra/src/py) python -m extra
	else
		$(if $(WWW_PATH),env -C "$(WWW_PATH)") python -m http.server $(PORT)
	fi
	$(call rule_post_cmd)


.PHONY: dist-www
dist-www: $(DIST_WWW_ALL) ## Builds web assets in $(DIST_WWW_ALL)
	@$(call rule_pre_cmd)

	$(call rule_post_cmd,$(DIST_WWW_ALL))

# =============================================================================
# RUN
# =============================================================================

run/lib/%: src/%
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
	if ! bun -e "import mod from './$<';import css from '@littlecss.js';console.log([...css(mod)].join('\n'))" > "$@"; then
		unlink "$@"
		exit 1
	fi

# EOF

# EOF
