VIRTUALENV ?= virtualenv
BUILDOUT_DIR = plone-buildout
RPMIZER = rpmizer
PYTHON = $(BUILDOUT_DIR)/bin/python
BUILDOUT = $(BUILDOUT_DIR)/bin/buildout
INSTANCE = $(BUILDOUT_DIR)/bin/instance
RPMIZER_VERSION = multiple_versions

.PHONY: instance clean buildout rpm cleanrpmizer

all: instance

clean:
	cp $(BUILDOUT_DIR)/Makefile.in Makefile
	rm -rf $(BUILDOUT_DIR)

cleanrpmizer:
	rm -rf $(RPMIZER)

buildout: $(INSTANCE)

instance: $(INSTANCE)
	$(INSTANCE) fg

$(RPMIZER)/build.sh: cleanrpmizer
	git clone --depth=1 --branch=$(RPMIZER_VERSION) git@github.com:CIRB/Rpmizer.git $(RPMIZER)

rpm: $(BUILDOUT_DIR)/project.cfg $(RPMIZER)/build.sh
	$(RPMIZER)/build.sh $(PROJECT_ID)

$(INSTANCE): $(BUILDOUT) $(BUILDOUT_DIR)/project.cfg
	$(BUILDOUT) -Nvt 5 -c $(BUILDOUT_DIR)/dev-project.cfg


$(BUILDOUT): $(PYTHON)
	$(PYTHON) $(BUILDOUT_DIR)/bootstrap-buildout.py -c $(BUILDOUT_DIR)/base.cfg

$(PYTHON):
	$(VIRTUALENV) --no-site-packages $(BUILDOUT_DIR)

$(BUILDOUT_DIR)/project.cfg: project.cfg
	cp project.cfg $@
