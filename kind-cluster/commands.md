
# Terminal Command History for K8s Kind Voting App

## 1. Creating and Managing Kubernetes Cluster with Kind

- Clear terminal:
  ```bash
  clear
  ```

- Create a 3-node Kubernetes cluster using Kind:
  ```bash
  kind create cluster --config=config.yml
  ```

- Check cluster information:
  ```bash
  kubectl cluster-info --context kind-kind
  kubectl get nodes
  kind get clusters
  ```


## 2. Deleting Kubernetes Cluster

- Delete the Kind cluster:
  ```bash
  kind delete cluster --name=kind
  ```

---