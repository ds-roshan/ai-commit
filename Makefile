PREFIX ?= /usr/local
BINARY  = ai-commit

build:
	swift build

release:
	swift build -c release

install: release
	install -m 755 .build/release/$(BINARY) $(PREFIX)/bin/$(BINARY)

uninstall:
	rm -f $(PREFIX)/bin/$(BINARY)

test:
	swift test

.PHONY: build release install uninstall test
