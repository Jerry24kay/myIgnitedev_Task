## Task Instructions

### Setup a kubernetes cluster using kind

1. Write a simple bash script that deploys a [kind](https://kind.sigs.k8s.io/docs/user/quick-start/) cluster locally
2. Download the kubeconfig for the cluster and store in a safe place, we will use it much later in the next steps

### Deploy a sample Node.js app using terraform

1. When kind is up and running, dockerize a simple hello world [express](https://expressjs.com/en/starter/hello-world.html) and deploy to dockerhub
2. create a kubernetes deployment manifest to deploy to deploy the Node.js to the kind cluste but don't apply it yet
3. using the [kubectl terraform provider](https://registry.terraform.io/providers/gavinbunney/kubectl/latest/docs), write a terraform code to deploy the kubectl manifest to the kind cluster



# My Installation process and steps. 


I began by initiating my Linux environment WSL2, concurrently using MobaXterm and WSL Ubuntu. I verified that Docker Desktop was running, and now I'm ready to commence the installation of "kind."

To install "kind," I executed the following command as specified in the documentation.

```
[ $(uname -m) = x86_64 ] && curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind
```

# Next, I proceeded to establish a directory for the laboratory, opting for "myIgnitedev_Task" as the folder name.

As per the requirement, I had to generate a YAML file named "cluster_config" for the deployment of the cluster

```
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
extraPortMappings:
- containerPort: 53
    hostPort: 53
    protocol: UDP
- containerPort: 53
    hostPort: 53
    protocol: TCP
```

# Afterward, I crafted a Bash script designed to streamline the process of deploying the cluster. This script also includes the functionality to fetch the kubeconfig for the cluster. I named it "ignite_cluster.sh."

```
{#!/bin/bash

# Using kind to Create a Kubernetes Cluster
kind create cluster --config ./cluster_config.yaml --name ignite-cluster

# Downloading the kubeconfig
mkdir -p ~/.kube
kind get kubeconfig --name ignite-cluster > ~/.kube/config}
```

## Subsequently, I needed to grant executable permissions to the file, following which I executed the Bash script to automate the cluster setup.


## Given that I had previously installed Node, npm, and Express on my WSL environment, and Docker Desktop on my machine.

## This is the straightforward app I obtained from the website, and I intend to utilize Node to execute it.
```
const express = require('express')
const app = express()
const port = 3000

app.get('/', (req, res) => {
  res.send('Hello World!')
})

app.listen(port, () => {
  console.log(`app listening on port ${port}`)
})
```

## After confirming that I had set the port to 3000, I proceeded to check the localhost to verify whether it was successfully receiving the requests.

## I then proceeded to create the Dockerfile for building the application to be used. I then established a directory to house the application and authored the JavaScript file for the simple app.

```
# Official Node.js runtime to be used as the base image
FROM node:20-alpine

# The working directory
WORKDIR /app

# Copy package.json and package-lock.json to the working directory
COPY package*.json ./

# Install the app dependencies
RUN npm install

# Copy the application code to the working directory
COPY . .

# Expose port 3000
EXPOSE 3000

# Define the command to run the application
CMD ["node", "igniteapp.js"]
```
## With the local development setup in place, I can now proceed to build the application and push it to my DockerHub repository.
It was successfull. 



## It's time to configure the Kubernetes deployment. Here's the YAML file I used for this purpose.

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: igniteapp
spec:
  replicas: 3
  selector:
    matchLabels:
      app: igniteapp
  template:
    metadata:
      labels:
        app: igniteapp
    spec:
      containers:
        - name: igniteapp
          image: jerry24kay/igniteapp:1.0.0
          ports:
            - containerPort: 3000
---
apiVersion: v1
kind: Service
metadata:
  name: igniteapp-service
spec:
  selector:
    app: igniteapp
  ports:
  - protocol: TCP
    port: 3000
    targetPort: 3000
```
##To deploy this, I employed Terraform. I followed these steps:

1.Executed helm repo add prometheus-community https://prometheus-community.github.io/helm-charts 
helm repo update
2. Executed terraform init to initialize the Terraform configuration.
3. Ran terraform plan to preview the changes and verify the deployment plan.
4. Finally, used terraform apply to initiate the deployment of the application into the "ignite_cluster."


##For the main.tf
```
   resource "kubectl_manifest" "igniteapp" {
  yaml_body = file("${path.module}/ignite_k8s_deployment.yaml")
}


resource "helm_release" "kube_prom" {
  name       = "kube-prometheus-stack"
  chart      = "prometheus-community/kube-prometheus-stack"

}
```

## For the Vairable.tf
```
variable "dockerhub_username" {}

variable "kube_config_path" {}
```

##For port forwarding in the context of monitoring, I used the following configuration:
kubectl port-forward deployment/kube-prometheus-stack-grafana 3260:3000
kubectl port-forward deployment/kube-prometheus-stack-prometheus 8000:8000


I accessed Grafana in my web browser using the URL http://localhost:3260, and I accessed Prometheus using http://localhost:8000 in my web browser as well.



    

