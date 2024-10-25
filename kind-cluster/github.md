## Instalación de un Self-Hosted GitHub Runner

### Paso 1: Instalar el controlador de escalado de runners

Primero, instala el controlador de escalado de runners en el namespace `arc-systems`:

```sh
NAMESPACE="arc-systems"
helm install arc \
    --namespace "${NAMESPACE}" \
    --create-namespace \
    oci://ghcr.io/actions/actions-runner-controller-charts/gha-runner-scale-set-controller
```

### Paso 2: Configurar e instalar el set de runners

Luego, configura e instala el set de runners en el namespace `arc-runners`:

```sh
INSTALLATION_NAME="arc-runner-set"
NAMESPACE="arc-runners"
GITHUB_CONFIG_URL="${REPOSITORY_URL}"
GITHUB_PAT="${GITHUB_TOKEN}"

helm upgrade -i "${INSTALLATION_NAME}" \
  oci://ghcr.io/actions/actions-runner-controller-charts/gha-runner-scale-set \
  --namespace "${NAMESPACE}" \
  -f values.yaml \
  --set githubConfigUrl="${GITHUB_CONFIG_URL}" \
  --set githubConfigSecret.github_token="${GITHUB_PAT}"

```

  ### Paso 3: Ejecutar RBAC para los permisos

  A continuación, aplica los permisos RBAC necesarios utilizando el archivo `rbac.yaml`:

  ```sh
  kubectl apply -f rbac.yaml
  ```

