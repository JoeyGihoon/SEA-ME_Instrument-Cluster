
==============================================================================


# RUN Instrument Cluster #./startic

set -euo pipefail           # 스크립트 안정 옵션

LOGDIR="$HOME/logs"         # 로그 폴더

mkdir -p "$LOGDIR"


#1) CAN-BUS 인터페이스 up

sudo ip link set can1 up type can bitrate 500000



#2) 가상환경 활성화

source "$HOME/env_tf1/bin/activate"



#3) Python 스크립트 (백그라운드 + 로그)

nohup python3  "$HOME/SEA-ME/GUI/Instrument_Cluster/build/volt_gear.py" \

     >"$LOGDIR/volt_gear.log" 2>&1 &
     
PYTHON_PID=$!


#4) Qt 애플리케이션 (DISPLAY 지정 + 백그라운드 + 로그)

export DISPLAY=:0

nohup "$HOME/SEA-ME_Instrument-Cluster/GUI/Instrument_Cluster_raspi/build/Practice" \

     >"$LOGDIR/qt_practice.log" 2>&1 &
     
QT_PID=$!


echo "✓ launched   python=$PYTHON_PID   qt=$QT_PID"

exit 0


==============================================================================


# CLOSE Instrument Cluster #./killic

#!/usr/bin/env bash

set -e


#Python · Qt 프로세스 종료

sudo pkill -f volt_gear.py  || true

sudo pkill -f '/build/Practice' || true


#CAN 인터페이스 내리기

sudo ip link set can1 down  || true


echo "✔ 모든 프로세스 종료 & can1 down"


==============================================================================


# build and play QT



rm -rf build


mkdir build && cd build

cmake .. -DCMAKE_BUILD_TYPE=Release

make -j$(nproc)

==============================================================================

export DISPLAY=:0

./Practice

