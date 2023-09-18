# kubernetes Project

## Overview

[Kubernetes](https://kubernetes.io/docs/concepts/overview/), often abbreviated as K8s, is an open-source container orchestration platform designed to automate the deployment, scaling, and management of containerized applications. 

 [Kind](https://kind.sigs.k8s.io/docs/user/quick-start/) simplifies the process of setting up and managing Kubernetes clusters, making it easier for developers to work with Kubernetes in a controlled, reproducible environment without the need for complex virtualization.

------------------------------
## Prerequisites

You should have the following installed on your local machine.
For this project I used an Ubuntu 20.04.6 LTS OS
- go (v1.16+)
- Node (v20.6.1)
- Docker(v23.0.6)
- Kind (v0.11.1)
- Helm (v3.12.3)
- Terraform (v1.5.7)
- Make sure you have a DockerHub account for pushing the Docker image.
----------------------------------------------


### Now, let's get started:

### Step 1: 
Setup a Kubernetes Cluster using KIND. 
Install KIND if you haven't already by following the  [official documentation:](https://kind.sigs.k8s.io/docs/user/quick-start/#installation)


### Step 2: 
Write a Bash Script to create kind Cluster Locally and get the kubeconfig for the cluster:

```bash
# Create a new Kind cluster
kind create cluster --name my-kind-cluster

# Get the kubeconfig for the cluster
KUBECONFIG_PATH=~/.kube/config

# Set the kubeconfig context to use the new cluster
kubectl config use-context "my-kind-cluster" --kubeconfig "$KUBECONFIG_PATH"

# Verify cluster status
kubectl cluster-info

```

### Step 3

Dockerize a Simple Express App and Push to DockerHub:
- First, create an app.js file

```javascript
const express = require('express')
const app = express()
const port = 3000

app.get('/', (req, res) => {
  res.send('Hello World! Welcome to my Application!')
})

app.listen(port, () => {
  console.log(`Nodejs Application listening on port ${port}`)
})

 ```

- Install express dependencies needed for the application by running the following:

```bash
$ node install express
```
- Make sure to have your [package.json](https://docs.npmjs.com/creating-a-package-json-file) file. If not, run ```npm init --yes``` and answer the prompts by entering your details.



- Also Create a Dockerfile for your Express app.
```bash
# Use an official Node.js runtime as a parent image
FROM node:20

# Set the working directory in the container
WORKDIR /usr/src/app

# Copy package.json and package-lock.json to the working directory
COPY package*.json app.js ./

# Install app dependencies
RUN npm install

# Expose port 3000
EXPOSE 3000

#CMD ["node", "app.js"]
CMD ["node", "app.js"]
```


- Build the Docker image:

```bash
docker build -t your-dockerhub-username/express-application .
```
- login to your Dockerhub account

```bash
docker login -u your-dockerhub-username
```
- Push the image to DockerHub:

```bash
docker push your-dockerhub-username/express-application
```

- You can test your application locally by running: 

```bash
docker run -d -p 3000:3000 your-dockerhub-username/express-application
```

- Access application from browser at:

Browser: localhost:3000

Terminal: curl localhost:3000


### Step 4
Create a Kubernetes Deployment Manifest:

- Create a Kubernetes Deployment YAML file (e.g., deployment.yaml) for your Node.js application.
Define the deployment specifications, including the container image from DockerHub.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: node-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: node-app
  template:
    metadata:
      labels:
        app: node-app
    spec:
      containers:
      - name: node-app
        image: your-dockerhub-username/express-application
        ports:
        - containerPort: 3000
 
```
- Expose the deployment by creating a service manifest
```yaml
apiVersion: v1 
kind: Service 

metadata: 
  name: node-app-service 

spec: 
  type: ClusterIP

  selector:
    app: node-app # This selector matches Pods with the label "app" set to "node-app"

  ports:
    - name:  node-app
      protocol: TCP 
      port: 3000 
      targetPort: 3000 
```

### Step 5: Deploy manifest files to kubernetes kind cluster using kubectl terraform provider.

- Create a Terraform configuration file (e.g., k8s_deployment.tf) to deploy the Kubernetes manifest.

```hcl
resource "kubectl_manifest" "node-app" {
  yaml_body = file("${path.module}/K8s/deployment.yml")
}

resource "kubectl_manifest" "node-app-service" {
  yaml_body = file("${path.module}/K8s/service.yml")
}
 
```
- Use the kubectl Terraform provider to apply the manifest to your kind cluster. 

```hcl
terraform {
  required_version = ">= 0.13"

  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}


# Provider configuration block for helm
provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}
```


### Step 6
Setup Monitoring and Observability with kube-prometheus Stack:

- Install the kube-prometheus stack using Helm and Terraform Helm Provider:


```hcl
# Provider configuration block for helm
provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}
```

- Use the Terraform Helm provider to install the kube-prometheus stack:

```hcl
resource "helm_release" "kube-prometheus" {
  name       = "kube-prometheus"
  chart      = "kube-prometheus-stack"
  repository = "https://prometheus-community.github.io/helm-charts"
  namespace  = "monitoring"
  values     = [file("prometheus-values.yaml")]
}

```

- Apply Terraform Configurations:

Run ```terraform init``` to initialize the Terraform configuration.

Run ```terraform plan``` to view the deployment before application. 

Run ```terraform apply``` to apply the Terraform configurations and deploy your Kubernetes resources and monitoring stack.


### Commands to check deployment status

```bash
# APP DEPLOYMENT
-------------------------
kubectl get deployment
kubectl get pods
kubectl get service


# MONITORING
-------------------------------------
kubectl get deployments -n monitoring
kubectl get svc -n monitoring
```


PORT FORWARDING
--------------------------------------------------------
We can use port forwarding to reach our apps in the Kubernetes kind cluster. This helps with testing and fixing issues, so you can access your service on your computer without making it accessible to others on the internet.

```bash
$ kubectl port-forward svc/node-app-service 5000:3000 --namespace default

$ kubectl port-forward svc/kube-prometheus-grafana 3000:80 --namespace monitoring

$ kubectl port-forward svc/kube-prometheus-kube-prome-alertmanager 9093:9093 --namespace monitoring

$ kubectl port-forward svc/kube-prometheus-kube-prome-prometheus 9090:9090 --namespace monitoring

$ kubectl port-forward svc/kube-prometheus-prometheus-node-exporter 9100:9100 --namespace monitoring

$ kubectl port-forward svc/kube-prometheus-kube-state-metrics 8080:8080 --namespace monitoring
```

- Open a browser and go to: http://localhost:[PORT] to see the Node.js and Monitoring UI.


Now you should have a kind cluster running your Node.js application, and the kube-prometheus stack for monitoring and observability.