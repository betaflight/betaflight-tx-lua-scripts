all:
	bin/build.sh

release: all
	FILE_NAME="betaflight-tx-lua-scripts_$$(git describe --abbrev=0 --tags).zip"; \
	rm -f $${FILE_NAME}; \
	zip -r $${FILE_NAME} obj/
