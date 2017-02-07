
tmp_dirs = \
	tmp/SCRIPTS/BF \
	tmp/SCRIPTS/TELEMETRY

$(tmp_dirs):
	mkdir -p $(tmp_dirs)

VERSION = `git describe --tags --long`

.PHONY: tmp_install
tmp_install: $(tmp_dirs)
	cp common/*.lua tmp/SCRIPTS/BF

.PHONY: all
all: X7 X9

.PHONY: X7
X7: tmp_install
	cp X7.lua tmp/SCRIPTS/TELEMETRY/BF.lua
	cd tmp && zip ../BFSetup-X7-$(VERSION).zip SCRIPTS/BF/* SCRIPTS/TELEMETRY/*

.PHONY: X9
X9: tmp_install
	cp X9.lua tmp/SCRIPTS/TELEMETRY/BF.lua
	cd tmp && zip ../BFSetup-X9-$(VERSION).zip SCRIPTS/BF/* SCRIPTS/TELEMETRY/*
