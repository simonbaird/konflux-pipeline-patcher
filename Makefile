
test:
	@bash shellspec

SHELLSPEC_INSTALLER=https://github.com/shellspec/shellspec/raw/master/install.sh
install-shellspec:
	curl -sL $(SHELLSPEC_INSTALLER) | bash -s -- -y
