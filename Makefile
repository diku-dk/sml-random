
.PHONY: all
all:
	$(MAKE) -C lib/github.com/diku-dk/sml-random all

.PHONY: test
test:
	$(MAKE) -C lib/github.com/diku-dk/sml-random test

.PHONY: clean
clean:
	$(MAKE) -C lib/github.com/diku-dk/sml-random clean
	rm -rf MLB *~ .*~
