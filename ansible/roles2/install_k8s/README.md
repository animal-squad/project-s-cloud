### 1-1. `roles/install_k8s/README.md`

```markdown
# 🛠️ install_k8s Role

이 Role은 **마스터/워커 노드 공통**으로 필요한 Kubernetes 구성 요소를 설치하고, 사전 준비 작업을 수행합니다.

## 🔑 주요 작업

1. **시스템 시간 동기화**: `systemd-timesyncd` 설치/활성화, Timezone 설정, NTP 동기화
2. **Swap 비활성화**: `swapoff -a`, `/etc/fstab`에서 swap 항목 주석 처리
3. **커널 모듈 설정**: `overlay`, `br_netfilter` 로딩 및 `sysctl` 파라미터 적용
4. **패키지 업그레이드**: `apt`를 통해 시스템 패키지 최신화
5. **컨테이너 런타임(containerd)** 설치/설정
6. **Kubernetes 패키지(kubeadm, kubelet, kubectl)** 설치 및 버전 고정

## 📂 태스크 흐름

- **Install systemd-timesyncd** → **Disable swap** → **Load kernel modules** → **Configure iptables** → **Install containerd** → **Install Kubernetes packages** → **Start kubelet**

## 🎯 변수

- **k8s_version**: (예: `v1.32`)
  `vars/main.yml`에서 관리되며, `/etc/apt/sources.list.d/kubernetes.list`에 이 값이 반영됩니다.
- **arch_mapping_var**: 시스템 아키텍처별 매핑 (x86_64 → amd64 등)

## 💡 사용 예시

```yaml
- hosts: all_worker
  become: true
  roles:
    - role: install_k8s
  vars:
    k8s_version: v1.32

## 📢 유의사항

- `install_k8s` Role 실행 후, 마스터 노드에서는 추가로 `init_k8s` Role이 실행되어야 **클러스터가 완성**됩니다.
- Worker 노드에서는 `kubeadm join` 명령을 통해 실제 클러스터에 합류하게 됩니다.
- 만약 Docker를 사용하려면 `containerd` 설치 대신 Docker 엔진을 설치하도록 Role 수정이 필요합니다.

모든 궁금점은 Issues에 남겨주세요! 😄
