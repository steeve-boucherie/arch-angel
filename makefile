PREFIX ?= /usr/local/bin

install:
	for f in scripts/*.sh; do \
	  sudo ln -sf "$(PWD)/$$f" "$(PREFIX)/$$(basename $$f .sh)"; \
	done

uninstall:
	for f in scripts/*.sh; do \
	  sudo rm -f "$(PREFIX)/$$(basename $$f .sh)"; \
	done