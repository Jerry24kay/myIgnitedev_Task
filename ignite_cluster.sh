#!/bin/bash

# Using kind to Create a Kubernetes Cluster
kind create cluster --config ./cluster_config.yaml --name ignite-cluster

# Downloading the kubeconfig
mkdir -p ~/.kube
kind get kubeconfig --name ignite-cluster > ~/.kube/config