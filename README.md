# OCI Service Mesh

## Create OCI Service Mesh for VueJS SPA, NodeJS microservices and Autonomous Database using OCI Cloud Shell

Have Oracle Oracle Kubernetes Engine (OKE) cluster up and running with <code>kubectl</code> access from OCI Cloud shell

<p>
Install Oracle Services Operator for Kubernetes (OSOK), see <a href="https://github.com/oracle/oci-service-operator/blob/main/docs/installation.md#install-operator-sdk">
https://github.com/oracle/oci-service-operator/blob/main/docs/installation.md#install-operator-sdk</a>

<p>
Open Cloud shell from OCI Console
    
<p>
Run: 
<pre>
git clone https://github.com/mikarinneoracle/oci-service-mesh.git
cd oci-service-mesh
</pre>

## Create OCI Service Mesh with sample services using kubectl

Run:
<pre>
export mesh_name=pricing
export mesh_compartment=ocid1.compartment.oc1..
export ca_ocid=ocid1.certificateauthority.oc1.eu-amsterdam-1.amaaaa...
export ocir=ams.ocir.io/&lt;YOUR TENANCY NAME HERE&gt;
</pre>

<p>
To user private OCIR images run (Optional):
<pre>
export docker_username='&lt;YOUR TENANCY NAME HERE&gt;/oracleidentitycloudservice/&lt;YOUR USER NAME HERE&gt;'
export docker_password='&lt;YOUR ACCESS TOKEN HERE&gt;'
</pre>

## Create Autonomous Database using kubectl (OSOK)

Run: <code>sh create_atp.sh pricemeshdb RockenRoll321#!</code>

<p>
Download <a href="https://download.oracle.com/otn_software/linux/instantclient/217000/instantclient-basic-linux.x64-21.7.0.0.0dbru.zip">https://download.oracle.com/otn_software/linux/instantclient/217000/instantclient-basic-linux.x64-21.7.0.0.0dbru.zip</a> to this project's root directory

## Create registry (Optional) using oci cli or Cloud UI

Run:
<pre>
oci artifacts container repository create -c ${mesh_compartment} --display-name ${mesh_name}-homesvc
oci artifacts container repository create -c ${mesh_compartment} --display-name ${mesh_name}-pricesvc
</pre>

## Build services and push to OCIR

Run <code>sh build_services.sh pricemeshdb RockenRoll321#! &lt;YOUR MESH DNS NAME HERE&gt;</code>

## Deploy service to OKE

Run:
<pre>
sh deploy_services.sh
kubectl get pods -n ${mesh_name}
kubectl get services -n ${mesh_name}
</pre>

## Create Service Mesh using the built and deployed services

Run:
<pre>
sh meshify_app.sh &lt;YOUR MESH DNS NAME HERE&gt;
kubectl get pods -n ${mesh_name} --watch
kubectl get services -n ${mesh_name}
</pre>

## Create Monitoring (Optional) using oci cli and kubectl
Create Logging Dynamic Group and the Log Object
<p>
See <a href="https://docs.oracle.com/en-us/iaas/Content/service-mesh-tutorials/service-mesh-overview/00-overview.htm">https://docs.oracle.com/en-us/iaas/Content/service-mesh-tutorials/service-mesh-overview/00-overview.htm</a>
<p>
<pre>
export log_object_ocid=ocid1.log.oc1.eu-amsterdam-1.amaaaa.....
export logging_dynamicgroup_ocid=ocid1.dynamicgroup.oc1..
</pre>

Run: <code>sh create_monitoring.sh</code>

<p>
Run: <code>kubectl get services -n monitoring --watch</code>
<p>
Once the Grafana <code>EXTERNAL-IP</code> shows up, copy it and open in browser to monitor the mesh using Grafana

## Create/Update DNS (Optional) using oci cli

By default DNS zone will run in the same compartment as the mesh.
However, if you want to specify another compartment for the DSN, run:
<pre>
export dns_compartment=ocid1.compartment.oc1..
</pre>

<p>

Pick up the LodBalancer <code>EXTERNAL-IP</code> addresses and them to DNS Zone by running:
<pre>
kubectl get services -n ${mesh_name}
sh update_dns.sh home &lt;YOUR MESH DNS NAME HERE&gt; eu-frankfurt-1 <i>ingress-ip</i>
sh update_dns.sh admin &lt;YOUR MESH DNS NAME HERE&gt; eu-frankfurt-1 <i>ingress-admin-ip</i>
</pre>

Access the <code>home.&lt;YOUR MESH DNS NAME HERE&gt;</code> from browser.
