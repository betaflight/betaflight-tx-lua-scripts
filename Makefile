DIR := ${CURDIR}

all:	files

files:
	@bin/build.sh

clean:
	@rm -rf obj/*

release: clean files
	@RELEASE_DIR=release; \
	FILE_NAME="betaflight-tx-lua-scripts_$$(git describe --abbrev=0 --tags).zip"; \
	mkdir -p $${RELEASE_DIR}; \
	rm -f $${RELEASE_DIR}/$${FILE_NAME}; \
	zip -q -r $${RELEASE_DIR}/$${FILE_NAME} obj/
