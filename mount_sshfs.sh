#!/bin/bash

# 사용자 설정 변수
REMOTE_USER="user"                     # 원격 서버의 사용자명
REMOTE_HOST="127.0.0.1"                # 원격 서버의 IP 주소 또는 도메인
REMOTE_PORT="2222"                     # 포트 번호
REMOTE_PATH="/remote/path"             # 원격 경로 수정 (서버)
LOCAL_MOUNT_POINT="/local/mount/point" # 마운트할 로컬 디렉토리 (내 컴퓨터)

# 마운트 함수
mount_sshfs() {
  # 마운트할 디렉토리가 존재하지 않으면 생성
  if [ ! -d "$LOCAL_MOUNT_POINT" ]; then
    echo "로컬 마운트 디렉토리 생성 중: $LOCAL_MOUNT_POINT"
    mkdir -p "$LOCAL_MOUNT_POINT"
    if [ $? -ne 0 ]; then
      echo "디렉토리 생성 실패!"
      exit 1
    fi
  fi

  echo "SSHFS로 원격 파일 시스템을 마운트 중입니다..."
  sshfs -p "$REMOTE_PORT" "$REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH" "$LOCAL_MOUNT_POINT"
  if [ $? -eq 0 ]; then
    echo "마운트 성공: $LOCAL_MOUNT_POINT"
  else
    echo "마운트 실패!"
    exit 1
  fi
}

# 마운트 해제 함수
unmount_sshfs() {
  echo "SSHFS로 마운트된 파일 시스템을 해제 중입니다..."
  fusermount -u "$LOCAL_MOUNT_POINT"
  if [ $? -eq 0 ]; then
    echo "마운트 해제 성공: $LOCAL_MOUNT_POINT"

    # 마운트 해제 후 디렉토리 삭제
    echo "로컬 마운트 디렉토리 삭제 중: $LOCAL_MOUNT_POINT"
    rmdir "$LOCAL_MOUNT_POINT"
    if [ $? -eq 0 ]; then
      echo "디렉토리 삭제 성공: $LOCAL_MOUNT_POINT"
    else
      echo "디렉토리 삭제 실패! (비어있지 않거나 사용 중일 수 있습니다)"
    fi
  else
    echo "마운트 해제 실패!"
    exit 1
  fi
}

# 사용자의 선택에 따라 마운트 또는 해제
echo "1. 마운트"
echo "2. 마운트 해제"
read -p "선택 (1 또는 2): " choice

case $choice in
1)
  mount_sshfs
  ;;
2)
  unmount_sshfs
  ;;
*)
  echo "잘못된 입력입니다. 1 또는 2를 선택하세요."
  exit 1
  ;;
esac
