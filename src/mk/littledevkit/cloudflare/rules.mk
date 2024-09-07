.PHONY: cloudflare-start-wrangler
cloudflare-start-wrangler: $(PREP_ALL) build/cloudflare-login-wrangler.task ## Starts the wrangler server
	@# SEE: https://blog.cloudflare.com/10-things-i-love-about-wrangler/
	# NOTE: There's a `dev --local` mode as well
	$(WRANGLER) dev --ip 0.0.0.0 --port $(WRANGLER_PORT)

build/cloudflare-login-wrangler.task: build/install-node-wrangler.task ## Installs and login Wrangler
	@mkdir -p "$(dir $@)"
	$(WRANGLER) login  && touch "$@"

# EOF
