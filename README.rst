CIRB buildout Plone 4
=====================

Our buildouts are supposed to be built in the following way:

* fetch ``bootstrap.py`` from ::

    http://svn.zope.org/*checkout*/zc.buildout/tags/1.4.4/bootstrap/bootstrap.py


* create and edit ``dev.cfg`` and ``project.cfg`` with at least ::

dev.cfg::

    [buildout]                                                                  
                                                                                  
    extends =
        project.cfg
        https://raw.github.com/CIRB/plone-buildout/master/dev.cfg?login=jenkins-cirb&token=4d0a9ab50e431868b36636193ae08c69                                               

project.cfg::

    [projects]                                                                  
    zcml =                                                                      
    eggs =
    
    [versions]

* you should configure ``zcml`` and ``eggs`` values with the values appropriate for your project

* your buildout can extend four different files
      - ``instance.cfg`` provides 1 standalone Zope server and 1 Varnish server
      - ``client.cfg`` provides two ZEO client Zope servers and 1 Varnish server
      - ``server.cfg`` provides 1 ZEO server
      - ``both.cfg`` is the combination of ``client.cfg`` and ``server.cfg``

* if you need to mount databases, you should create and edit
      ``database.cfg`` and specify it in the ``extends`` section

* make ``buildout.cfg`` symbolic link ::

    ln -s dev.cfg buildout.cfg


Testing
=======
Plone egg
---------
*For this exemple, I use a fake collective.product egg.*
 
In your ``buildout.cfg`` product, add [test] section ::

    parts =
        ...
        test
        ...

    [test]
    recipe = zc.recipe.testrunner
    defaults = ['-c', '--tests-pattern', '^f?tests$']
    eggs = 
        collective.product[test]

In ``setup.py`` add extra_require section ::
 
    extras_require={'test': 
        [
          'plone.app.testing',
        ], },

The plone products must have Unittest. For this add a ``testing.py`` on root products ::

    # -*- coding: UTF-8 -*-
    from plone.app.testing import PloneWithPackageLayer
    from plone.app.testing import IntegrationTesting, FunctionalTesting
    
    import collective.products
    
    FIXTURE = PloneWithPackageLayer(
        zcml_filename="configure.zcml",
        zcml_package=collective.products,
        additional_z2_products=(),
        gs_profile_id='collective.products:default',
        name="FIXTURE")
    
    INTEGRATION = IntegrationTesting(
        bases=(FIXTURE,), name="INTEGRATION")
    
    
    FUNCTIONAL = FunctionalTesting(
        bases=(FIXTURE,), name="FUNCTIONAL")

Create tests folder, and add (for exemple) ``test_product.py`` file ::

    # -*- coding: UTF-8 -*-
    import unittest2 as unittest
    
    class TestProduct(unittest.TestCase):    
        def test_product(self):
            self.assertTrue(True)

Jenkins
-------
You need to add a ``jenkins.cfg`` for buildout like this ::

    [buildout]
    extends = 
        buildout.cfg
        https://raw.github.com/CIRB/jenkins-buildout/master/jenkins-base.cfg
    
    package-directories = ${buildout:directory}/collective/product

Finaly, you can add a jenkins job in `jenkins.cirb.lan <http://jenkins.cirb.lan>`_.

