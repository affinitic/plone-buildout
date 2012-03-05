CIRB buildout Plone 4
=====================

Our buildouts are supposed to be built in the following way:

* fetch ``bootstrap.py`` from ::

    http://svn.zope.org/*checkout*/zc.buildout/tags/1.4.4/bootstrap/bootstrap.py

* create and edit ``.httpauth`` with a single line ::
    
    trac,http://trac.xnet.irisnet.be,buildout,Bu!ld0ut

* create and edit ``dev.cfg`` with at least ::

  1 [buildout]                                                                  
  2                                                                             
  3 extends = http://buildout:Bu!ld0ut@trac.xnet.irisnet.be/svn/Plone_ASP/buildo    uts/plone4/trunk/instance.cfg                                               
  4                                                                             
  5 [projects]                                                                  
  6 zcml =                                                                      
  7 eggs =

    - you should configure ``zcml`` and ``eggs`` values with the values appropriate for your project
    - your buildout can extend four different files :
      ° ``instance.cfg`` provides 1 standalone Zope server and 1 Varnish server
      ° ``client.cfg`` provides two ZEO client Zope servers and 1 Varnish server
      ° ``server.cfg`` provides 1 ZEO server
      ° ``both.cfg`` is the combination of ``client.cfg`` and ``server.cfg``
    - if you need to mount databases, you should create and edit
      ``database.cfg`` and specify it in the ``extends`` section
   
    
* make ``buildout.cfg`` symbolic link ::

    ln -s dev.cfg buildout.cfg



