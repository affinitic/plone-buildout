CIRB buildout Plone 4

.. sectnum::

.. contents:: The tiny table of contents

Introduction
~~~~~~~~~~~~

* backup.cfg : Contient les paramètres pour la gestion des backup (pour une installation sans multistorage, il y a rien à faire, par contre lorsque vous êtes en multistorage il faut modifier la ligne 9. Il faut remplacer "zeopack -S 1" par le script de backup "packall" que vous devez modifier en fonction de vos storages)
* base.cfg : fichier définissant tous les extends, mais aussi les checkout nécessaires pour votre projet.
* hosts.cfg : liste des sites permis pour le téléchargement.
* zeo-clients.cfg : configuration des zeo clients.
* zeo-server.cfg : configuration du zeo server.
* both.cfg : dans le cas d'une installation zeocluster all in one, c'est sur ce fichier que vous devez créer votre lien symbolique depuis la racine de votre plone (commande ln -s)
* client.cfg : dans le cas d'une installation zeocluster sur plusieurs serveurs, c'est sur ce fichier que vous devez créer votre lien symbolique depuis la racine de votre plone client (commande ln -s). 
* server.cfg :dans le cas d'une installation zeocluster sur plusieurs serveurs, c'est sur ce fichier que vous devez créer votre lien symbolique depuis la racine de votre plone master (commande ln -s). 
* versions.cfg : Ce fichier contient la définition de tous les modules utilisés par Plone et Zope, ainsi que les add'on choisies par le CIRB et ceux de vos projets.

Make a new project
~~~~~~~~~~~~~~~~~~
Create a policy ::
    
    $ templer plone_cirb_policy policy.id_project

Add and release this policy.

Create a buildout ::

    $ templer plone4_cirb_buildout id_project


Puppet
~~~~~
For exemple, $env = staging, $hostname = svhwecavl073.

* First, be familiar with the doc : http://jenkins.cirb.lan/doc/

* Full the common hiera file (into puppet repo, got to hieradata/$env/plone/common.yaml::
    
    cirb:
        group:
            gid: 4xx
        user:
            name: cirb
            uid: 6xx
            home: /data/cirb
            group: cirb
        rpmversion: latest
        zeoserver:
            port: 8100
        clients:
            cirb_client1:
                port: 8080
                client: client1
        urls:
            - cirb.irisnetlab.be
            - cibg.irisnetlab.be
        env_values:
            - DEPLOY_ENV staging

* Create a yaml file (into hieradata/$env/plone/$hostname.yaml)::

    plone_project_ids:
        - cirb

* Create the node file (into manifest/nodes-$env/plone/$hostname.pp)
The node have to be named as the hostname of the server::

    node '$hostname.sta.srv.cirb.lan' {
      class {'puppet::client':
        environment => 'staging',
      }
    
      include role::plone::sites
    }

* Add facter into server
Create this file : /etc/facter/facts.d/host-info.txt 
with this info = "hostgroup=plone"::
    
    $ sudo -s
    # mkdir -p /etc/facter/facts.d
    # echo "hostgroup=plone" > /etc/facter/facts.d/host-info.txt
    # exit

Testing
~~~~~~~
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

    # -*- coding: utf-8 -*-
    from plone.app.testing import PloneWithPackageLayer
    from plone.app.testing import IntegrationTesting, FunctionalTesting
    
    import collective.product
    
    FIXTURE = PloneWithPackageLayer(
        zcml_filename="configure.zcml",
        zcml_package=collective.product,
        additional_z2_products=(),
        gs_profile_id='collective.product:default',
        name="FIXTURE")
    
    INTEGRATION = IntegrationTesting(
        bases=(FIXTURE,), name="INTEGRATION")
    
    
    FUNCTIONAL = FunctionalTesting(
        bases=(FIXTURE,), name="FUNCTIONAL")

Create tests folder, and add (for exemple) ``test_product.py`` file ::

    # -*- coding: utf-8 -*-
    import unittest2 as unittest
    
    class TestProduct(unittest.TestCase):    
        def test_product(self):
            self.assertTrue(True)

Jenkins
~~~~~~~
You need to add a ``jenkins.cfg`` for buildout like this ::

    [buildout]
    extends = 
        buildout.cfg
        https://raw.github.com/CIRB/jenkins-buildout/master/jenkins-base.cfg
    
    package-directories = ${buildout:directory}/collective/product

Finaly, you can add a jenkins job in `jenkins.cirb.lan <http://jenkins.cirb.lan>`_.



Old style 
~~~~~~~~~

Old style: create buildout
--------------------------
First, create a buildout for your project. (Adding a buildout repo into github and, ideally, a policy)

Our buildouts are supposed to be built in the following way:

* fetch ``bootstrap.py`` from ::

    http://svn.zope.org/*checkout*/zc.buildout/tags/1.4.4/bootstrap/bootstrap.py


* create and edit ``dev.cfg`` and ``project.cfg`` with at least (exemple https://github.com/CIRB/buildout-research) ::

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
      - ``instance.cfg`` provides 1 standalone Zope server/client
      - ``client.cfg`` provides two ZEO client Zope servers
      - ``server.cfg`` provides 1 ZEO server
      - ``both.cfg`` is the combination of ``client.cfg`` and ``server.cfg``

* if you need to mount databases, you should create and edit
      ``database.cfg`` and specify it in the ``extends`` section

* make ``buildout.cfg`` symbolic link ::

    ln -s dev.cfg buildout.cfg

Old style: RPM
--------------

See doc to create rpm build and spec files here : https://github.com/CIRB/Rpmizer

* rpm.cfg file looks like (replace master by the last tag of CIRB/plone-buildout) ::

    [buildout]
    extends =
        project.cfg
        https://raw.github.com/CIRB/plone-buildout/master/both.cfg?login=jenkins-cirb&token=4d0a9ab50e431868b36636193ae08c69
    
    [hosts]
    client1 = 127.0.0.1
    client2 = 127.0.0.1
    zeo = 127.0.0.1
    
    [ports]
    instance = 8080
    client1 = 8080
    client2 = 8081
    zeo = 8100
    
    [versions]
    zc.buildout = 1.4.4
