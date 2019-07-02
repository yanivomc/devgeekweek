# DEVGEEK WEEK  REPO


## Table of contents

**Code examples for:**

 -  Configure ELK and Prometheus using HELM to log and monitoring K8S infra & services
    - Prom and grafna installed
 -  Authentication in K8S
	 -  Basic
	 - OpenLD
 - Authorization
	 -  RBAC
 - HELM
	 - Code examples
 - Job resource management in k8s
 - Scheduling
	 - Scheduling with CronJobs
 - Deploying to k8s with Spinnaker
 - Ingress controllers and API GW
 - 


TODO:
Install Helm
kubectl -n kube-system create serviceaccount tiller
 kubectl create clusterrolebinding tiller --clusterrole cluster-admin --serviceaccount=kube-system:tiller
 helm init --service-account=tiller


> Written with [StackEdit](https://stackedit.io/).


