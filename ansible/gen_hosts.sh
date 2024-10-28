#!/bin/bash

STATE_FILE="output.tfstate"
OUTPUT_FILE="hosts.ini"

# 기존 hosts.ini 파일 삭제
rm -f $OUTPUT_FILE

# 모든 aws_instance 리소스 추출
jq -c '.resources[] | select(.type=="aws_instance")' $STATE_FILE | while read -r resource; do
    name=$(echo $resource | jq -r '.name')
    public_ip=$(echo $resource | jq -r '.instances[] | .attributes.public_ip')
    
    # 그룹 이름을 추출 (예: 이름이 'web'이면 [web] 그룹)
    group=$name
    
    # 그룹이 이미 hosts.ini에 존재하는지 확인
    if ! grep -q "^\[$group\]" $OUTPUT_FILE; then
        echo "[$group]" >> $OUTPUT_FILE
    fi
    
    # 호스트 추가
    echo "$public_ip" >> $OUTPUT_FILE
    echo "" >> $OUTPUT_FILE  # 그룹 간 공백 라인 추가
done

