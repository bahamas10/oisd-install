.PHONY: check
check:
	awk 'length($$0) > 80 { exit(1); }' oisd-install
	./oisd-install -h | awk 'length($$0) > 80 { exit(1); }'
	shellcheck oisd-install

.PHONY: test
test:
	(cd test && make)
