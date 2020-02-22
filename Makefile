all:
	bin/build.sh

clean:
	rm -rf obj/*

release: clean all
	FILE_NAME="betaflight-tx-lua-scripts_$$(git describe --abbrev=0 --tags).zip"; \
	rm -f $${FILE_NAME}; \
	zip -r $${FILE_NAME} obj/
