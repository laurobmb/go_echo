# Go Echo NodePort Demo

Este projeto é uma aplicação simples em Go projetada para demonstrar como expor serviços via **NodePort** no OpenShift/Kubernetes. A aplicação responde com informações sobre o Pod, como hostname e o horário atual.

## 🚀 Como Executar Localmente

Se você tem o Go instalado:

1. Inicie o módulo: `go mod init echo-app`
2. Execute: `go run main.go`
3. Teste: `curl http://localhost:8080`

---

## 📦 Build da Imagem (Docker/Podman)

Para buildar a imagem e enviá-la para o repositório especificado:

```bash
# Build da imagem
podman build -t quay.io/lagomes/go-echo:latest .

# Login no Quay.io
podman login quay.io

# Push da imagem
podman push quay.io/lagomes/go-echo:latest

```

---

## ☸️ Configuração no OpenShift (YAML)

Para colocar a aplicação no ar usando o **NodePort**, aplique os seguintes recursos:

### 1. Deployment e Service

Salve o conteúdo abaixo como `deploy.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: go-echo
spec:
  replicas: 2
  selector:
    matchLabels:
      app: go-echo
  template:
    metadata:
      labels:
        app: go-echo
    spec:
      containers:
      - name: go-echo
        image: quay.io/lagomes/go-echo:latest
        ports:
        - containerPort: 8080
---
apiVersion: v1
kind: Service
metadata:
  name: go-echo-nodeport
spec:
  type: NodePort
  selector:
    app: go-echo
  ports:
    - protocol: TCP
      port: 80          # Porta do serviço interno
      targetPort: 8080  # Porta da aplicação Go
      nodePort: 30007   # Porta exposta em todos os nós do cluster

```

Aplique com: `oc apply -f deploy.yaml`

---

## 🛠️ Build diretamente no OpenShift (S2I / Docker Strategy)

Se você tem o código em um repositório Git e quer que o OpenShift faça o build:

```bash
# Cria um novo build baseado no Dockerfile do repositório
oc new-app https://github.com/SEU_USUARIO/SEU_REPO.git --name=go-echo-internal

# Acompanhe o log do build
oc logs -f bc/go-echo-internal

```

---

## 🔍 Como Testar o NodePort

O NodePort expõe a porta em **todos os nós do cluster**. Para testar:

1. **Descubra o IP de um dos nós:**
```bash
oc get nodes -o wide

```


2. **Teste com o Curl:**
Use o IP interno de qualquer nó (ou o IP público, se estiver em cloud e o Security Group permitir):
```bash
curl http://<NODE_IP>:30007

```



**Saída esperada:**

```text
--- OpenShift NodePort Demo ---
Time: Tue, 03 Feb 2026 14:30:00 -03
Pod Hostname: go-echo-xxxxx-xxxx
Remote Addr: 10.128.x.x:xxxxx

```

---

## ⚠️ Observações de Segurança

No OpenShift, o tráfego externo geralmente entra via **Routes** (Porta 80/443). O uso de **NodePort** abre uma porta alta (30000-32767) diretamente nos nós. Certifique-se de que as regras de firewall (Security Groups) da sua infraestrutura permitem tráfego na porta `30007`.