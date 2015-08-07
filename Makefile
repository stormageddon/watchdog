run:
	$(MAKE) clean
	./node_modules/grunt-cli/bin/grunt compile

clean:
	rm -rf dist
