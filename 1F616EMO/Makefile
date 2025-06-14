env_setup.lua: header.lua src/*.lua
	printf "" > env_setup.lua
	cat header.lua >> env_setup.lua
	echo >> env_setup.lua
	for f in src/*.lua; do \
		echo "-- $$f"; \
		cat $$f; \
		echo; \
	done >> env_setup.lua