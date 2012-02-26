
all: min

clean:
	rm -rf src-tmp
	rm -rf src-min-tmp
	rm -rf src-cov
	rm bankersbox.min.js

bankersbox.min.js: bankersbox.js
	@echo "Sending to Google Closure compiler..."
	@curl -vvv -d output_format=text -d output_info=compiled_code -d compilation_level=SIMPLE_OPTIMIZATIONS --data-urlencode js_code@bankersbox.js http://closure-compiler.appspot.com/compile > bankersbox.min.js 2> /dev/null
	@echo "Done."

min: bankersbox.min.js

test:
	@echo "Testing bankersbox.js:"
	@NODE_PATH=`pwd` expresso -s tests/*

testmin: min
	@mkdir -p src-min-tmp
	@rm -f src-min-tmp/bankersbox.js
	@ln -s ../bankersbox.min.js src-min-tmp/bankersbox.js
	@echo "Testing MINIFIED file:"
	@NODE_PATH=`pwd`/src-min-tmp expresso -s tests/*

testall: test testmin

coverage:
	mkdir -p src-tmp
	rm -f src-tmp/bankersbox.js
	ln -s ../bankersbox.js src-tmp/bankersbox.js
	rm -rf src-cov
	node-jscoverage src-tmp src-cov
	NODE_PATH=`pwd`/src-cov expresso -s tests/*

.PHONY: all clean min test testmin testall coverage