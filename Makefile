
all:

clean:
	rm -rf src-tmp
	rm -rf src-cov

test:
	@NODE_PATH=`pwd` expresso -s tests/*

coverage:
	mkdir -p src-tmp
	rm -f src-tmp/bankersbox.js
	ln -s ../bankersbox.js src-tmp/bankersbox.js
	rm -rf src-cov
	node-jscoverage src-tmp src-cov
	NODE_PATH=`pwd`/src-cov expresso -s tests/*

.PHONY: all clean test coverage