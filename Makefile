.PHONY: publish publish-local stage clean

# Strip non-package files (.git/, README.md, .gitignore, Makefile) before
# publish — opkg 0.11.1 has no .opkgignore, would otherwise slurp them all.
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

clean:
	rm -rf .stage
