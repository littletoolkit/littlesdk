## Port on which the Wrangler will run
WRANGLER_PORT?=8000
## Path to where the Cloudflare Pages to be uploaded are
CLOUDFLARE_PAGES_PATH?=dist/www
CLOUDFLARE_PAGES_ALL?=$(call rwildcard,$(CLOUDFLARE_PAGES_PATH),*.*)
## Path to `wrangler`
WRANGLER?=$(NODE) node_modules/wrangler/bin/wrangler.js
# EOF
