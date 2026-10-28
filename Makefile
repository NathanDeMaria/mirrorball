# Render a library and an app from the template and run their checks and tests
test:
	scripts/test-template.sh


# Open a `copier update` PR in every repo in repos.txt, to the newest tag or
# to REF: `make propagate REF=v1.1.0`. `make propagate DRY_RUN=1` shows the
# diffs without pushing.
propagate:
	DRY_RUN=$(DRY_RUN) scripts/propagate.sh $(REF)


.PHONY: test propagate
