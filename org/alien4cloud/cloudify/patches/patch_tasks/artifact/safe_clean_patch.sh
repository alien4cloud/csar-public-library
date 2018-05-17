#!/bin/bash -e

# Prerequistes
if [ `whoami` != "root" ] ; then
  echo "should run with: sudo $0 $*"
  exit 1
fi

if [ ! $(which patch 2> /dev/null) ] ; then 
  echo "Installing patch command"
  yum -y install patch
fi

# Create the patch
cat << EOF > ~/tasks.py.patch
@@ -67,6 +67,10 @@
 DEFAULT_TASK_LOG_DIR = os.path.join(tempfile.gettempdir(), 'cloudify')


+def safe_remove_script(script_path):
+    if os.path.exists(script_path):
+        os.remove(script_path)
+
 @operation
 def run(script_path, process=None, ssl_cert_content=None, **kwargs):
     ctx = operation_ctx._get_current_object()
@@ -78,7 +82,8 @@
     os.chmod(script_path, 0755)
     script_func = get_run_script_func(script_path, process)
     script_result = process_execution(script_func, script_path, ctx, process)
-    os.remove(script_path)
+    #os.remove(script_path)
+    safe_remove_script(script_path)
     return script_result


@@ -89,7 +94,8 @@
         ctx.internal.handler.download_deployment_resource, script_path,
         ssl_cert_content)
     script_result = process_execution(eval_script, script_path, ctx)
-    os.remove(script_path)
+    #os.remove(script_path)
+    safe_remove_script(script_path)
     return script_result
EOF


# Patch the file
if [ ! -f '/opt/mgmtworker/env/lib/python2.7/site-packages/script_runner/tasks.py.default' ] ; then
  cp /opt/mgmtworker/env/lib/python2.7/site-packages/script_runner/tasks.py /opt/mgmtworker/env/lib/python2.7/site-packages/script_runner/tasks.py.default
fi
patch /opt/mgmtworker/env/lib/python2.7/site-packages/script_runner/tasks.py ~/tasks.py.patch --verbose
rm -f /opt/mgmtworker/env/lib/python2.7/site-packages/script_runner/tasks.pyc

# Clean
rm -f ~/tasks.py.patch