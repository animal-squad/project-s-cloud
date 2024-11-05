#기존 이미지에 패키지를 더함 경우에 따라서 컨테이너 안에서 수정이 필요함
#jenkins custom image build 전용 Dockerfile 
# 1. 공식 Jenkins LTS 이미지를 베이스로 사용
FROM jenkins/jenkins:lts

# 2. 루트 사용자로 전환하여 추가 패키지 설치
USER root

# 3. 필요한 패키지 업데이트 및 설치
RUN apt-get update && \
    apt-get install -y \
    vim \
    sudo \
    apt-utils \
    curl \
    git \
    unzip \
    && \
    # 설치 후 캐시 정리하여 이미지 크기 최소화
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 4. Jenkins 사용자가 sudo 권한을 가지도록 설정 (선택 사항)
# 이 단계는 Jenkins 사용자가 루트 권한이 필요한 작업을 수행할 경우 유용합니다.
RUN echo "jenkins ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# 5. Jenkins 사용자로 다시 전환
USER jenkins

# 6. (선택 사항) Jenkins 플러그인 설치 자동화
# 플러그인 목록을 정의한 파일을 이미지에 추가하고 설치합니다.
# 예를 들어, plugins.txt 파일을 만들어 필요한 플러그인 목록을 작성할 수 있습니다.
# COPY plugins.txt /usr/share/jenkins/plugins.txt
# RUN jenkins-plugin-cli --plugin-file /usr/share/jenkins/plugins.txt

# 7. (선택 사항) 초기 Jenkins 설정 비활성화
# 자동 설정 마법사를 비활성화하려면 환경 변수를 설정할 수 있습니다.
# ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false

# 8. (선택 사항) 필요한 포트 노출
# 기본적으로 Jenkins는 8080 포트를 사용합니다.
# EXPOSE 8080 50000

# 9. (선택 사항) 커스텀 엔트리포인트 또는 명령어 설정
# 기본 Jenkins 시작 스크립트를 그대로 사용하려면 이 단계는 필요 없습니다.
# ENTRYPOINT ["/sbin/tini", "--", "/usr/local/bin/jenkins.sh"]