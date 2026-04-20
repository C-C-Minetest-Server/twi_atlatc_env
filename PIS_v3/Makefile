.PHONY: all
all: env_setup.lua env_setup_tracy.lua

env_setup.lua: header.lua src/*.lua
	mv -f env_setup.lua ~env_setup.lua &>/dev/null || true
	printf "" > env_setup.lua
	printf -- "-- Running on " >> env_setup.lua
	git rev-parse --verify HEAD | tr -d '\n' >> env_setup.lua
	git update-index --refresh || exit 0
	if ! git diff-index --quiet HEAD --; then \
		printf -- "-dirty" >> env_setup.lua; \
	fi
	echo >> env_setup.lua
	cat header.lua >> env_setup.lua
	echo >> env_setup.lua
	for f in src/*.lua; do \
		echo "-- $$f"; \
		cat $$f; \
		echo; \
	done >> env_setup.lua
env_setup_tracy.lua: env_setup.lua
	sed -E 's/^([[:space:]]*)--[[:space:]]*tracy:[[:space:]]*([^[:space:]]+)([[:space:]]*(.*))?/\1tracy.\2("\4")/' env_setup.lua > env_setup_tracy.lua
	sed -i '1a -- This env_setup.lua is compiled with tracy enabled. DO NOT USE IN PROD!' env_setup_tracy.lua
	sed -i 's/local is_loading = true/assert(tracy)\nlocal is_loading = true/' env_setup_tracy.lua