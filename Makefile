APP_NAME := MenuIP
BUNDLE := build/$(APP_NAME).app
EXEC := $(BUNDLE)/Contents/MacOS/$(APP_NAME)

.PHONY: all build run clean

all: build

build:
	@mkdir -p $(BUNDLE)/Contents/MacOS
	@mkdir -p $(BUNDLE)/Contents/Resources
	@cp Info.plist $(BUNDLE)/Contents/Info.plist
	@xcrun swiftc -O \
		-framework Cocoa \
		-o $(EXEC) \
		Sources/AppMain.swift \
		Sources/AppDelegate.swift
	@echo "Built $(BUNDLE)"

run: build
	@open $(BUNDLE)

clean:
	@rm -rf build
	@echo "Cleaned build artifacts."
