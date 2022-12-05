# OCI Service Mesh

## Create OCI Service Mesh for VueJS SPA, NodeJS microservices and Autonomous Database using OCI Cloud Shell

Have Oracle Oracle Kubernetes Engine (OKE) cluster up and running with <code>kubectl</code> access from OCI Cloud shell

<p>
Install Oracle Services Operator for Kubernetes (OSOK), see <a href="https://github.com/oracle/oci-service-operator/blob/main/docs/installation.md#install-operator-sdk">
https://github.com/oracle/oci-service-operator/blob/main/docs/installation.md#install-operator-sdk</a>

<p>
Open Cloud shell from OCI Console
    
<p>
Run
<pre>
git clone https://github.com/mikarinneoracle/oci-service-mesh.git
cd oci-service-mesh
</pre>

## Setup environment

Run
<pre>
export mesh_name=pricing
export mesh_compartment=ocid1.compartment.oc1..
export ca_ocid=ocid1.certificateauthority.oc1.eu-amsterdam-1.amaaaa...
export ocir=ams.ocir.io/&lt;YOUR TENANCY NAME HERE&gt;
export dns_domain=&lt;YOUR MESH DNS DOMAIN HERE&gt; e.g. mymesh.mysite.com
</pre>

<p>
To use <i>private</i> repos for OCIR images run
<pre>
export docker_username='&lt;YOUR TENANCY NAME HERE&gt;/oracleidentitycloudservice/&lt;YOUR USER NAME HERE&gt;'
export docker_password='&lt;YOUR ACCESS TOKEN HERE&gt;'
</pre>
<p>
This will create <code>ocirsecret</code> for OKE to access private OCIR repos. Alternatively can use <i>public</i> repos for images.
    
## Create Autonomous Database using kubectl (with OSOK)

Run <code>sh create_atp.sh pricemeshdb &lt;YOUR ADB PASSWORD HERE&gt;</code>

<p>
e.g. <code>sh create_atp.sh pricemeshdb RockenRoll123#!</code>

<p>
<code>&lt;YOUR ADB PASSWORD HERE&gt;</code> needs to be a valid Autonomous database password, see <a href="https://docs.public.oneportal.content.oci.oraclecloud.com/en-us/iaas/exadata/doc/adb-managing-adb.html#GUID-F6EF6907-3694-4655-AEA1-2691ADFC8E39">here for details</a>.

## Create registry (Optional) using oci cli or Cloud UI

Run
<pre>
oci artifacts container repository create -c ${mesh_compartment} --display-name ${mesh_name}-homesvc
oci artifacts container repository create -c ${mesh_compartment} --display-name ${mesh_name}-pricesvc
</pre>

<p>
Additonally use <code>--is-public</code> flag in the statements above if you want to use <i>public</i> repos.

## Build services and push to OCIR

Build will build and push 2 microservices, <code>home</code> and <code>price</code>.

<p>
<code>home</code> is the application's Homepage that has two versions, <code>v1</code> and <code>v2</code> that will be load balanced by the mesh with <b>20/80</b> <code>rule</code> later. <code>v1</code> is a static homepage and <code>v2</code> is  a dynamic one that will then access prices from Autonomous Database using <code>price</code> service with JSON.

<p>
Before building services download <a href="https://download.oracle.com/otn_software/linux/instantclient/217000/instantclient-basic-linux.x64-21.7.0.0.0dbru.zip">https://download.oracle.com/otn_software/linux/instantclient/217000/instantclient-basic-linux.x64-21.7.0.0.0dbru.zip</a> to this project's root directory.

<p>
e.g. <code>wget https://download.oracle.com/otn_software/linux/instantclient/217000/instantclient-basic-linux.x64-21.7.0.0.0dbru.zip</code>
    
<p>
This is needed for the NodeJS <code>oracledb</code> library to access the Autonomous database from the <code>price</code> microservice.

<p>
Run <code>sh build_services.sh pricemeshdb &lt;YOUR ADB PASSWORD HERE&gt;</code>
    
<p>
e.g. <code>sh build_services.sh pricemeshdb RockenRoll321#!</code>

## Deploy services to OKE using kubectl

Run <code>sh deploy_services.sh</code>

<p>
View the pods created <code>kubectl get pods -n ${mesh_name}</code>
   
<p>
View services created <code>kubectl get services -n ${mesh_name}</code>

## Create Service Mesh using the built and deployed services using kubectl

Run <code>sh meshify_app.sh</code>

<p>
Monitor pods being updated - this will take several minutes to happen
<p>
<code>kubectl get pods -n ${mesh_name} --watch</code>
   
<p>
View services being updated <code>kubectl get services -n ${mesh_name} --watch</code>

## Create Monitoring (Optional) using oci cli and kubectl
Create Logging Dynamic Group and the Log Object
<p>
See <a href="https://docs.oracle.com/en-us/iaas/Content/service-mesh-tutorials/service-mesh-overview/00-overview.htm">https://docs.oracle.com/en-us/iaas/Content/service-mesh-tutorials/service-mesh-overview/00-overview.htm</a>
<p>
Monitoring pods and services will be created in <code>monitoring</code> namespace

<p>
<pre>
export log_object_ocid=ocid1.log.oc1.eu-amsterdam-1.amaaaa.....
export logging_dynamicgroup_ocid=ocid1.dynamicgroup.oc1..
</pre>

Run <code>sh create_monitoring.sh</code>

<p>
Minitor services being created <code>kubectl get services -n monitoring --watch</code>
<p>
Once the Grafana <code>EXTERNAL-IP</code> shows up, copy it and open in browser to monitor the mesh using Grafana.

## Create/Update DNS using oci cli (Optional)

By default DNS zone will run in the same compartment as the mesh. However, if you want to specify another compartment for the DSN, run
<pre>
export dns_compartment=ocid1.compartment.oc1..
</pre>

<p>
Pick up the LodBalancer <code>EXTERNAL-IP</code> addresses and them to DNS Zone by running
<p>
<code>kubectl get services -n ${mesh_name}</code>

<p>
Then create/update DNS by running
<pre>
sh update_dns.sh home eu-frankfurt-1 <i>mesh-ingress-ip</i>
sh update_dns.sh admin eu-frankfurt-1 <i>mesh-ingress-admin-ip</i>
</pre>

<p>
Alternatively open your local <code>/etc/hosts</code> file and add the following to acesss the mesh (example)
<pre>
158.101.210.63 home.mymesh.mysite.com
158.101.211.252 admin.mymesh.mysite.com
</pre>

<p>
Access the <code>home.&lt;YOUR MESH DNS DOMAIN HERE&gt;</code> from browser.

<p>
<p>
Access "price admin" of <code>price</code> microservice from the <i>Admin</i> -link on the homepage.
Admin <b>user</b> is <code>priceadmin</code> and <b>password</b> is <code>&lt;YOUR ADB PASSWORD&gt;</code>
Edit prices and options and then save and reload the homepage to see the values on Homepage chancing.
