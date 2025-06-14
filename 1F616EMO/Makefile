env_setup.lua: header.lua src/*.lua
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