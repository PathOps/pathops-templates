.PHONY: test
test:
	tests/update-preflight-gitops.sh

export-chatgpt:
	./scripts/export_repo_for_chatgpt.sh