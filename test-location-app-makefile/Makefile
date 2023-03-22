.PHONY: all
all: test-location.swift
	rm -rf -- ./test-location.app
	mkdir -p test-location.app/Contents/MacOS

	cp Info.plist test-location.app/Contents/Info.plist

	plutil -lint Info.plist

	swiftc \
		-parse-as-library \
		-sdk "$$(xcrun --show-sdk-path)" \
		-o test-location.app/Contents/MacOS/test-location \
		$^

	codesign \
		--sign - \
		--force \
		--deep \
		--entitlements entitlements.plist \
		test-location.app

	test-location.app/Contents/MacOS/test-location
