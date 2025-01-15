
---

### 1-3. `roles/nfs/README.md`

```markdown
# 📁 NFS Role

이 Role은 **NFS 서버**(주로 마스터 노드)에 `nfs-kernel-server`를 설치하고, **나머지 노드**(워커)는 `nfs-common` 패키지를 설치하여 NFS 공유 디렉터리를 사용할 수 있게 해줍니다.

## 🚀 주요 기능

1. **마스터 노드**: `nfs-kernel-server` 설치, 공유 디렉터리 생성, `/etc/exports` 설정 후 `exportfs -r`
2. **워커 노드(비마스터 노드)**: `nfs-common` 설치
3. **공유 디렉터리/서브디렉토리**: `nfs_shared_dir_path` 경로를 만들고 하위 디렉토리를 생성
4. **권한/소유자 설정**: 공유 디렉터리에 대한 UID/GID와 퍼미션을 설정

## 🔑 주요 태스크

- **Install NFS kernel server on masters**: `nfs-kernel-server`
- **Install NFS common on non-master nodes**: `nfs-common`
- **Create Dir**: `{{ nfs_shared_dir_path }}`
- **Create NFS shared subDirectories**: `{{ subDirPath }}`
- **Configure /etc/exports**: `{dir_path} {cluster_node_CIDR}(rw,sync,no_root_squash,no_subtree_check)`

## 📦 변수

- **nfs_shared_dir_path**: NFS 공유 디렉토리 루트 (기본값: `/srv/nfsv4/shared`)
- **subDirPath**: NFS 하위 디렉토리 목록 (예: `['jenkins_home', 'vault', ...]`)
- **cluster_node_CIDR**: NFS를 허용할 CIDR (예: `192.168.0.0/16`)

## 🧩 사용 예시

```yaml
- hosts: masters
  become: true
  roles:
    - role: nfs
  vars:
    nfs_shared_dir_path: /srv/nfsv4/shared
    cluster_node_CIDR: 192.168.0.0/16
    subDirPath:
      - jenkins_home
      - vault

## ⚠️ 참고사항

- 이 Role은 **NFS 서버**를 마스터 노드에서만 구동한다고 가정합니다.
    - 만약 별도의 NFS 전용 노드가 있다면, `when` 조건을 조정해 해당 노드에서만 `nfs-kernel-server`를 설치하도록 수정하세요.
- NFS를 사용하기 위해 워커 노드 측에서 마운트 작업(`mount -t nfs`)을 별도로 진행해야 합니다.

궁금한 점이나 버그 제보는 언제든 환영합니다! 🙏
