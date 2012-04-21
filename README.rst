CIRB buildout Plone 4
=====================

Our buildouts are supposed to be built in the following way:

* fetch ``bootstrap.py`` from ::

    http://svn.zope.org/*checkout*/zc.buildout/tags/1.4.4/bootstrap/bootstrap.py


* create and edit ``dev.cfg`` and 'project.cfg'with at least ::

dev.cfg::

  1 [buildout]                                                                  
  2                                                                             
  3 extends =
  4     project.cfg
  5     https://raw.github.com/CIRB/plone-buildout/master/dev.cfg?login=jenkins-cirb&token=4d0a9ab50e431868b36636193ae08c69                                               

project.cfg::

  1 [projects]                                                                  
  2 zcml =                                                                      
  3 eggs =
  4
  5 [versions]

* you should configure ``zcml`` and ``eggs`` values with the values appropriate for your project
* your buildout can extend four different files :
      ° ``instance.cfg`` provides 1 standalone Zope server and 1 Varnish server
      ° ``client.cfg`` provides two ZEO client Zope servers and 1 Varnish server
      ° ``server.cfg`` provides 1 ZEO server
      ° ``both.cfg`` is the combination of ``client.cfg`` and ``server.cfg``
* if you need to mount databases, you should create and edit
      ``database.cfg`` and specify it in the ``extends`` section
   
    
* make ``buildout.cfg`` symbolic link ::

    ln -s dev.cfg buildout.cfg


Testing
=======
You need to add a jenkins.cfg for your buildout.
XXX



