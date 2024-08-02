.PHONY: check
check:
	expand oisd-install | awk 'length($$0) > 80 { exit(1); }'
	./oisd-install -h | expand | awk 'length($$0) > 80 { exit(1); }'
	shellcheck oisd-install

.PHONY: test
test:
	(cd test && make)
