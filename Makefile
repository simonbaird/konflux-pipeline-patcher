
# Provide a dummy git config for the test suite
GIT_CONF=$(shell pwd)/spec/data/gitconfig

_default: test

SHELLSPEC_INSTALLER=https://github.com/shellspec/shellspec/raw/master/install.sh
install-shellspec:
	@curl -sL $(SHELLSPEC_INSTALLER) | GIT_CONFIG_GLOBAL="$(GIT_CONF)" bash -s -- -y

test:
	@GIT_CONFIG_GLOBAL="$(GIT_CONF)" bash shellspec

# For faster hacking, run just the spec files with changes since the last commit
quick-test:
	@for spec in $$(git diff --name-only HEAD^ -- spec/*_spec.sh); do \
	  GIT_CONFIG_GLOBAL="$(GIT_CONF)" bash shellspec "$$spec"; \
	done
