build/cloudflare-login-wrangler.task: build/install-node-wrangler.task
	@mkdir -p "$(dir $@)"
	$(WRANGLER) login  && touch "$@"

