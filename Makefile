.PHONY: publish publish-local stage clean patch release

# Strip non-package files (.git/, README, Makefile, .gitignore) before publish —
# opkg 0.11.1 has no .opkgignore, would otherwise slurp everything.
stage:
	rm -rf .stage
	mkdir .stage
	cp -r openpackage.yml skills .stage/

publish: stage
	cd .stage && opkg publish
	rm -rf .stage

publish-local: stage
	cd .stage && opkg publish --local
	rm -rf .stage

# Bump the patch component of `version:` in openpackage.yml (0.4.2 → 0.4.3).
patch:
	@cur=$$(awk '/^version:/{gsub(/"/,"",$$2);print $$2}' openpackage.yml); \
	new=$$(echo "$$cur" | awk -F. -v OFS=. '{$$NF+=1; print}'); \
	echo "patch: $$cur → $$new"; \
	opkg set --ver "$$new" >/dev/null

# Full release: bump patch → publish to remote registry → commit + push.
# Publish runs before commit so a registry failure leaves git clean for retry.
release: patch publish
	@new=$$(awk '/^version:/{gsub(/"/,"",$$2);print $$2}' openpackage.yml); \
	committer "chore: release $$new" openpackage.yml; \
	git push

clean:
	rm -rf .stage
