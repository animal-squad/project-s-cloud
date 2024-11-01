# README.md

이 README는 클러스터에 **ingress-nginx**를 배포하기 위해 사용되는 각 Kubernetes 매니페스트에 대한 설명을 제공합니다. 각 매니페스트는 ingress-nginx의 다양한 구성 요소를 설정하고 필요한 권한과 서비스를 제공합니다. 🚀

---

## Namespace 생성 🗂️

```yaml
apiVersion: v1
kind: Namespace
metadata:
  labels:
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/name: ingress-nginx
  name: ingress-nginx
```

**역할**: `ingress-nginx` 네임스페이스를 생성하여 ingress-nginx 관련 리소스를 격리하고 조직화합니다.

---

## ServiceAccount 생성 🔑

### ingress-nginx ServiceAccount

```yaml
apiVersion: v1
automountServiceAccountToken: true
kind: ServiceAccount
metadata:
  labels:
    app.kubernetes.io/component: controller
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/part-of: ingress-nginx
    app.kubernetes.io/version: 1.11.2
  name: ingress-nginx
  namespace: ingress-nginx
```

**역할**: ingress-nginx 컨트롤러가 사용할 ServiceAccount를 생성하여 필요한 권한을 부여합니다.

### ingress-nginx-admission ServiceAccount

```yaml
apiVersion: v1
automountServiceAccountToken: true
kind: ServiceAccount
metadata:
  labels:
    app.kubernetes.io/component: admission-webhook
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/part-of: ingress-nginx
    app.kubernetes.io/version: 1.11.2
  name: ingress-nginx-admission
  namespace: ingress-nginx
```

**역할**: Admission 웹훅이 사용할 ServiceAccount를 생성하여 필요한 권한을 부여합니다.

---

## Role 및 ClusterRole 생성 🛡️

### ingress-nginx Role

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: ingress-nginx
  namespace: ingress-nginx
  labels:
    app.kubernetes.io/component: controller
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/part-of: ingress-nginx
    app.kubernetes.io/version: 1.11.2
```

**역할**: 네임스페이스 내에서 ingress-nginx 컨트롤러가 필요한 리소스에 접근할 수 있는 권한을 정의합니다.

### ingress-nginx-admission Role

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: ingress-nginx-admission
  namespace: ingress-nginx
  labels:
    app.kubernetes.io/component: admission-webhook
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/part-of: ingress-nginx
    app.kubernetes.io/version: 1.11.2
```

**역할**: 네임스페이스 내에서 ingress-nginx Admission 웹훅이 필요한 리소스에 접근할 수 있는 권한을 정의합니다.

### ingress-nginx ClusterRole

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: ingress-nginx
  labels:
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/part-of: ingress-nginx
    app.kubernetes.io/version: 1.11.2
```

**역할**: 클러스터 범위에서 ingress-nginx 컨트롤러가 필요한 리소스에 접근할 수 있는 권한을 정의합니다.

### ingress-nginx-admission ClusterRole

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: ingress-nginx-admission
  labels:
    app.kubernetes.io/component: admission-webhook
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/part-of: ingress-nginx
    app.kubernetes.io/version: 1.11.2
```

**역할**: 클러스터 범위에서 ingress-nginx Admission 웹훅이 필요한 리소스에 접근할 수 있는 권한을 정의합니다.

---

## RoleBinding 및 ClusterRoleBinding 생성 🔗

### ingress-nginx RoleBinding

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: ingress-nginx
  namespace: ingress-nginx
  labels:
    app.kubernetes.io/component: controller
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/part-of: ingress-nginx
    app.kubernetes.io/version: 1.11.2
```

**역할**: `ingress-nginx` Role을 `ingress-nginx` ServiceAccount에 바인딩하여 네임스페이스 내에서 권한을 부여합니다.

### ingress-nginx-admission RoleBinding

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: ingress-nginx-admission
  namespace: ingress-nginx
  labels:
    app.kubernetes.io/component: admission-webhook
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/part-of: ingress-nginx
    app.kubernetes.io/version: 1.11.2
```

**역할**: `ingress-nginx-admission` Role을 `ingress-nginx-admission` ServiceAccount에 바인딩합니다.

### ingress-nginx ClusterRoleBinding

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: ingress-nginx
  labels:
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/part-of: ingress-nginx
    app.kubernetes.io/version: 1.11.2
```

**역할**: `ingress-nginx` ClusterRole을 `ingress-nginx` ServiceAccount에 바인딩하여 클러스터 범위의 권한을 부여합니다.

### ingress-nginx-admission ClusterRoleBinding

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: ingress-nginx-admission
  labels:
    app.kubernetes.io/component: admission-webhook
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/part-of: ingress-nginx
    app.kubernetes.io/version: 1.11.2
```

**역할**: `ingress-nginx-admission` ClusterRole을 `ingress-nginx-admission` ServiceAccount에 바인딩합니다.

---

## ConfigMap 생성 ⚙️

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: ingress-nginx-controller
  namespace: ingress-nginx
  labels:
    app.kubernetes.io/component: controller
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/part-of: ingress-nginx
    app.kubernetes.io/version: 1.11.2
data:
  allow-snippet-annotations: "false"
```

**역할**: ingress-nginx 컨트롤러의 설정을 정의하는 ConfigMap입니다. 예를 들어, `allow-snippet-annotations`를 `false`로 설정하여 보안을 강화합니다.

---

## Service 생성 🌐

### ingress-nginx-controller Service

```yaml
apiVersion: v1
kind: Service
metadata:
  name: ingress-nginx-controller
  namespace: ingress-nginx
  labels:
    app.kubernetes.io/component: controller
    ...
spec:
  type: LoadBalancer
  ...
```

**역할**: ingress-nginx 컨트롤러를 외부로 노출하기 위한 LoadBalancer 타입의 서비스입니다. AWS NLB(Network Load Balancer)를 사용하도록 주석이 추가되어 있습니다.

### ingress-nginx-controller-admission Service

```yaml
apiVersion: v1
kind: Service
metadata:
  name: ingress-nginx-controller-admission
  namespace: ingress-nginx
  labels:
    app.kubernetes.io/component: controller
    ...
spec:
  type: ClusterIP
  ...
```

**역할**: Admission 웹훅 서버에 대한 내부 통신을 위한 ClusterIP 타입의 서비스입니다.

---

## Deployment 생성 🚀

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ingress-nginx-controller
  namespace: ingress-nginx
  labels:
    app.kubernetes.io/component: controller
    ...
spec:
  ...
```

**역할**: ingress-nginx 컨트롤러를 배포합니다. 컨테이너 설정, 환경 변수, 포트, 보안 컨텍스트 등이 정의되어 있습니다.

---

## Job 생성 🛠️

### ingress-nginx-admission-create Job

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: ingress-nginx-admission-create
  namespace: ingress-nginx
  labels:
    app.kubernetes.io/component: admission-webhook
    ...
spec:
  ...
```

**역할**: Admission 웹훅에 필요한 인증서를 생성하는 Job입니다.

### ingress-nginx-admission-patch Job

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: ingress-nginx-admission-patch
  namespace: ingress-nginx
  labels:
    app.kubernetes.io/component: admission-webhook
    ...
spec:
  ...
```

**역할**: Admission 웹훅의 설정을 패치하여 인증서를 적용하는 Job입니다.

---

## IngressClass 생성 🏷️

```yaml
apiVersion: networking.k8s.io/v1
kind: IngressClass
metadata:
  name: nginx
  labels:
    app.kubernetes.io/component: controller
    ...
spec:
  controller: k8s.io/ingress-nginx
```

**역할**: ingress-nginx 컨트롤러를 사용하는 IngressClass를 정의하여 Ingress 리소스가 어떤 컨트롤러를 사용할지 지정합니다.

---

## ValidatingWebhookConfiguration 생성 🧩

```yaml
apiVersion: admissionregistration.k8s.io/v1
kind: ValidatingWebhookConfiguration
metadata:
  name: ingress-nginx-admission
  labels:
    app.kubernetes.io/component: admission-webhook
    ...
webhooks:
  ...
```

**역할**: Ingress 리소스의 생성 및 업데이트 시 유효성을 검사하기 위한 웹훅을 설정합니다. 유효하지 않은 구성이 적용되는 것을 방지합니다.

---

# 사용 방법 📝

1. **매니페스트 적용**: 각 매니페스트 파일을 순서대로 적용하여 ingress-nginx를 클러스터에 배포합니다.

   ```bash
   kubectl apply -f namespace.yaml
   kubectl apply -f serviceaccount.yaml
   kubectl apply -f role.yaml
   kubectl apply -f rolebinding.yaml
   kubectl apply -f configmap.yaml
   kubectl apply -f service.yaml
   kubectl apply -f deployment.yaml
   kubectl apply -f job.yaml
   kubectl apply -f ingressclass.yaml
   kubectl apply -f validatingwebhookconfiguration.yaml
   ```

2. **설정 확인**: 모든 리소스가 정상적으로 생성되었는지 확인합니다.

   ```bash
   kubectl get all -n ingress-nginx
   ```

3. **Ingress 리소스 생성**: 애플리케이션에 대한 Ingress 리소스를 생성하여 트래픽을 라우팅합니다.

---

# 참고 사항 ⚠️

- **권한 관리**: RBAC 설정은 클러스터의 보안을 유지하기 위해 중요합니다. 필요한 권한만 부여되었는지 확인하세요.

- **LoadBalancer 설정**: 클라우드 환경(AWS 등)에 따라 LoadBalancer 서비스의 주석(annotation)을 적절히 수정해야 할 수 있습니다.

- **Admission 웹훅**: Admission 웹훅은 리소스 유효성 검사를 위해 사용됩니다. 프로덕션 환경에서 안정성을 높입니다.

---

각 매니페스트의 역할을 이해함으로써 ingress-nginx의 배포 및 관리를 더욱 효과적으로 수행할 수 있습니다. 🌟
