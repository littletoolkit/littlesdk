.PHONY: cljs-check
cljs-check: $(CLJS_BUILD_ALL) ## Compiles ClojureScript sources with Squint

ifneq ($(strip $(CLJS_BUILD_ALL)),)
$(CLJS_BUILD_ALL) &: $(CLJS_BUILD_DEPS)
	@$(call rule_pre_cmd)
	mkdir -p "$(CLJS_BUILD_PATH)"
	$(call shell_try,$(CLJS_RUN) compile --output-dir "$(CLJS_BUILD_PATH)" $(CLJS_SOURCES),Unable to compile ClojureScript sources)
	for output in $(CLJS_BUILD_ALL); do
		test -f "$$output" || { echo "$(call fmt_error,Missing ClojureScript output: $$output)"; exit 1; }
	done
	$(call rule_post_cmd,$(CLJS_BUILD_ALL))
endif
# EOF
