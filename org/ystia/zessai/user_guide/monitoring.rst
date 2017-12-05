****************************
Monitoring & troubleshooting
****************************

.. contents::
	:local:
	:depth: 2
    
	
Alien
=====

Switch-over procedure
---------------------

If the Alien4Cloud host is stopped, **do NOT uninstall or kill any Cloudify Manager or Client**. 
Restart the Alien4Cloud host and wait that Alien4Cloud is reconnected to Cloudify Manager before using the alien4cloud API. 

Logs
----

Logs path depends on how you have started Alien4Cloud.

For more information about Alien4Cloud Logs, refer to `Installation and Configuration`_.

.. _`Installation and Configuration`: http://alien4cloud.github.io/#/documentation/1.1.0/admin_guide/installation_configuration.html

Backup / Restore procedure
--------------------------

For more information about Alien4Cloud Backup/Restore, refer to `Backup and restore`_ .

.. _`Backup and restore`: http://alien4cloud.github.io/#/documentation/1.1.0/admin_guide/backup_restore.html

Cloudify
========

Cloudify 3.x does not have any self-healing process available. When a service (node) crashes, there is no longer automated restart/recovery, as it was in 2.x.
In 3.x, no monitoring console is available. You can use Cloudify Manager UI to see deployment status.


Switch-over procedure
---------------------

The Cloudify Manager can be restarted. Wait a little while to let it reconnect.


Logs
----

The logs are in the folder **/var/log/cloudify/**.


Backup / Restore procedure
--------------------------


Manager
^^^^^^^

To restart Cloudify Manager, just reboot the machine and wait until the communications turn back between the Manager and Alien4Cloud.

.. warning::

 Do NOT uninstall clients when the manager is down.

.. note::

 You can continue to use your manager when you see that events are restarted in the Cloudify Manager UI (http://<ip-manager>).

Client
^^^^^^

You can stop/start your agents when you want. You just need to wait that the machine has restarted. You can also have a look in the Cloudify Manager UI or in the Alien4Cloud UI.


MapR
====

.. _MapR: http://maprdocs.mapr.com/51/index.html#AdministratorGuide/Monitoring-the-Cluster.html

For more information about monitoring the MapR cluster, refer to MapR_ .

Switch-over procedure
---------------------

When one or more MapR cluster nodes fall down, the recommended service restart order is:

1. Zookeeper instance(s)
2. CLDB instance(s)
3. Warden instance(s)

Warden should then restart all other services in the cluster.

Logs
----

The starting Hadoop (Warden, disks setup, create volume...) logs are in the folder **/opt/mapr/logs/**.

The logs of the different components are in the folder **/opt/mapr/<component-name>/<component-version>/logs**.

For example, the yarn logs are in the folder **/opt/mapr/hadoop/hadoop-2.7.0/logs/**.

Configuration files
-------------------

.. _MapR configuration files documentation : http://maprdocs.mapr.com/51/index.html#ReferenceGuide/ConfigurationFiles.html

For more information about MapR configuration files, refer to `MapR configuration files documentation`_.


Backup / Restore procedure
--------------------------

.. _MapR data management documentation : http://maprdocs.mapr.com/51/index.html#AdministratorGuide/Data-Protection-YoucanuseMapRtoprote-d3e64.html

For more information about MapR backup/restore, refer to `MapR data management documentation`_.

Known issues
============

Deploy/Undeploy Stuck up
------------------------

When deploying a complex application, it may happen that application state remains blocked 'In progress', whereas deployment succeeded.
In this situation, if user restarts Alien4Cloud GUI, the application state becomes 'Started' after Alien4Cloud restart.

Same work-around can be used when application undeployment seems to be blocked whith state 'In progress', whereas undeployment succeeded.

Elasticsearch: Limit of total fields in index may be exceeded
-------------------------------------------------------------

Using the TwitterConnector on Logstash and storing those events in Elasticsearch may cause the exceeding of the limit of total fields in index.
In this case, this log appears in elasticsearch Logstash output logs:

"[WARN ][logstash.outputs.elasticsearch] Failed action. {:status=>400, :action=>["index", ...], :response=>{"index"=>{"_index"=>"logstash-2017.01.26", ...,"reason"=>"Limit of total fields [1000] in index [logstash-2017.01.26] has been exceeded"}}}}

**Workaround**

See Elasticsearch documentation for details:

  - https://www.elastic.co/guide/en/elasticsearch/reference/5.1/mapping.html#mapping-limit-settings
  - https://www.elastic.co/guide/en/elasticsearch/reference/5.1/indices-templates.html

You can update this limit after the index has been created as for example:

.. code-block:: none

  PUT my_index/_setting
  {
      "index.mapping.total_fields.limit": 2000
  }

or using index templates before the index creation as for example:

.. code-block:: none

  PUT _template/my_template
  {
      "template" : "logstash-*",
      "order" : my_order,
      "settings" : {"index.mapping.total_fields.limit": 2000 }
  }

MapR deployment application gets stuck after MapRWarden is starting on all nodes
--------------------------------------------------------------------------------

When deploying a MapR topology, it can appear that application deployment gets stuck after starting MapRWarden on all nodes.
Connecting to the node where CLDB is embedded, it can be observed this message in /opt/mapr/logs/mfs.log-3 :

"Replication cldbha.cc:997 Got error Read-only file system (30) while trying to register with CLDB..."

**Workaround**

Connected to the node where CLDB is hosted (ensure that volume attached to the node doesn't contain any backup datas, which will be removed with next steps), run these commands :

.. code-block:: bash

  systemctl stop mapr-warden
  cd /opt/mapr/conf
  mv disktab disktab.old
  /opt/mapr/server/disksetup -F /opt/mapr/bdcf/storage/device
  systemctl start mapr-warden

Sqoop2 User Interface is not accessible from MCS
------------------------------------------------

When trying to access to the Sqoop2 web user interface through MCS navigation tab, you would get the error :

"Service: sqoop2 does not have reachable URL"

**Workaround**

You can directly access to this user interface from your browser:   http://<ip_address>:11000

Cloudera Manager failing to install Oozie SharedLib on service Oozie
--------------------------------------------------------------------

We may have this following error when we are trying to install Oozie service using Cloudera Manager:

.. code-block:: none

  Upload Oozie ShareLib
    Command aborted because of exception: Command timed-out after 270 seconds

**Workaround**

Via the Cloudera Manager Admin Console, select the Oozie service, go to its configuration,
search for *oozie_upload_sharelib_cmd_timeout* parameter and change it to something bigger than 270.

LinuxFileSystem and XFS limitation
----------------------------------

Dynamic scaling and existing volume ids
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

LinuxFileSystem and XFS (eXtendedFileSystem) components do not work in scenario with reuse existing volume ids and scale dynamically.

This problem may appears with this following scenario:

#. Deploy an application with non deletable volume
#. Undeploy --> volume id is pulled up from Provider and filled into *volume_id* property of the Volume node
#. Deploy application --> volume is reused
#. Scale application --> newly created machines fail to mount volume.

In this case, we got this following error :

.. code-block:: none

  error output mount: special device /dev/vdb1 does not exist

**Workaround**

Do not reuse existing volume by unsetting the *volume_id* property of the Volume node before deploy again an application if you want to be able to scale dynamically the application.

Block storage device property issue on Openstack
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Alien4Cloud block storage implementation on Openstack Cloud won't always respect the 'device' property of this component. A bug in certain versions of the virtualization API KVM doesn't
allow to customise this property. Devices will be always accessible as /dev/vdX on the virtual machine, where X will be assigned in alphabetical order.

Nevertheless, if the property named 'device' of block storage component doesn't correspond to the one KVM will define, the LinuxFileSystem and XFS components
won't be able to format this block storage and the BDCF application will fail to deploy.

**Workaround**

The 'device' property of block storage component must always be checked, almost when more than one block storage is attached to a compute in Alien4Cloud and one of filesystem
components is also used in the topology. This one of the first attached block storage must be /dev/vda, the second /dev/vdb, the third /dev/vdc, etc...

Cloudify troubles
-----------------

Using Cloudify, you might encounter these types of errors for which there is no bypass and block or failed your A4C's deployment application.

1. **Timeout reaching in starting Celery worker on deployed compute nodes.**

   Typical error into cloudify's logs :

"Task failed 'cloudify_agent.operations.install_plugins' -> Worker celery@Client_95845 appears to be dead"

2. **Diamond is used by Cloudify to monitor deployed clusters. Configuration of this tool require it to be restarted during deployment.**

   Typical error into cloudify's logs :

"Workflow failed    'a4c_install' workflow execution failed: RuntimeError: Workflow failed: Task failed 'diamond_agent.tasks.add_collectors' -> NonRecoverableError("Diamond couldn't be killed",)"

3. **On very slow platform, workflow deployment failed to start Riemann task.**

   Typical error into cloudify's logs :

"create_deployment_environment' workflow execution failed: RuntimeError: Workflow failed: Task failed 'riemann_controller.tasks.create' -> Riemann core has not started in 30 seconds.
tail -n 100 /tmp/riemann.log:
Failed extracting log: Command 'tail -n 100 /tmp/riemann.log' returned non-zero exit status 1"
