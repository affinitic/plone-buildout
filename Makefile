VIRTUALENV ?= virtualenv
BUILDOUT_DIR = plone-buildout
PYTHON = $(BUILDOUT_DIR)/bin/python
BUILDOUT = $(BUILDOUT_DIR)/bin/buildout
INSTANCE = $(BUILDOUT_DIR)/bin/instance

.PHONY: instance clean buildout

all: instance

clean:
	cp $(BUILDOUT_DIR)/Makefile.in Makefile
	rm -rf $(BUILDOUT_DIR)

buildout: $(INSTANCE)

instance: $(INSTANCE)
	$(INSTANCE) fg

$(INSTANCE): $(BUILDOUT) $(BUILDOUT_DIR)/project.cfg
	$(BUILDOUT) -Nvt 5 -c $(BUILDOUT_DIR)/dev-project.cfg


$(BUILDOUT): $(PYTHON)
	$(PYTHON) $(BUILDOUT_DIR)/bootstrap-buildout.py -c $(BUILDOUT_DIR)/base.cfg

$(PYTHON):
	$(VIRTUALENV) --no-site-packages $(BUILDOUT_DIR)

$(BUILDOUT_DIR)/project.cfg: project.cfg
	cp project.cfg $@
