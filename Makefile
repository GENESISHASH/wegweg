export NODE_ENV = test
export TAKY_DEV = 1

main:
	if [ -d build ] ; \
	then \
			rm -rf build/ ; \
	fi;
	mkdir build
	iced -c --runtime inline --output build src

r:
	$(MAKE)
	node build/module.js

test:
	$(MAKE)
	iced src/module.iced

