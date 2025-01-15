### 1-2. `roles/init_k8s/README.md`

```markdown
# 🏁 init_k8s Role

이 Role은 **Kubernetes 마스터 노드**를 초기화하고, **Calico 네트워크 플러그인**을 설치하는 역할을 담당합니다.

## 📌 주요 기능

1. **kubeadm init**을 통해 클러스터를 초기화
2. **kubeconfig** 파일을 설정하여 마스터 노드에서 `kubectl` 사용 가능
3. **Calico** 네트워크 플러그인을 다운로드하고 적용
4. **kubeadm join** 명령어를 생성하여, 워커 노드가 클러스터에 조인할 수 있도록 호스트 변수로 전달

## ⚙️ 주요 태스크

- **Initialize Kubernetes Cluster**: `kubeadm init --pod-network-cidr={{ Pod_CIDR }} --apiserver-advertise-address={{ ansible_facts.default_ipv4.address }}`
- **Set up kubeconfig**: `/etc/kubernetes/admin.conf`를 복사하여 `$HOME/.kube/config` 설정
- **Download Calico manifest**: GitHub에서 Calico YAML 다운로드
- **Apply Calico network plugin**: `kubectl apply -f /tmp/calico.yaml`
- **Get join command**: `kubeadm token create --print-join-command`
- **Join command to hostvars**: 워커 그룹에 Delegate하여 `join_command_raw.stdout` 실행

## 📦 변수

- **Pod_CIDR**: 파드 네트워크 CIDR (예: `172.16.0.0/24`)
- **Calico_version**: Calico GitHub 레포에서 가져올 버전 (예: `v3.28.1`)

## 📝 사용 예시

```yaml
- hosts: masters
  become: true
  roles:
    - role: init_k8s
  vars:
    Pod_CIDR: 10.244.0.0/16
    Calico_version: v3.28.1

## ✅ 참고사항

- `kubeadm init` 후 자동으로 Worker 노드가 조인(join)되는 것은 아니며, **Join 명령을 Worker 노드에서 실행**해야 합니다.
- Calico 외에도 다른 CNI 플러그인(Fannel, Weave 등)을 사용하고 싶다면 `init_k8s/tasks/main.yml`를 커스터마이징하세요.

언제든지 이슈(issues)나 PR로 피드백 주세요! 감사합니다. 🙌
