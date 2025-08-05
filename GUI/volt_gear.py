#!/usr/bin/env python3
"""
rc_control.py
------------

리모컨 주행 + 배터리 전압 & 기어 상태 모니터링
- 카메라 스트리밍 제거
- 콘솔에 배터리 전압과 기어 상태 출력
- Flask로 JSON API (/status) 제공

실행:
    chmod +x rc_control.py
    ./rc_control.py
"""

import threading
import time
from flask import Flask, jsonify
from evdev import InputDevice, ecodes, list_devices

# PiRacer SDK import
try:
    from piracer.vehicles import PiRacerPro, PiRacerStandard
except ImportError:
    raise RuntimeError("PiRacer SDK가 설치되지 않았습니다. 'pip install piracer' 로 설치하세요.")

# 게임패드 디바이스 검색
def find_gamepad():
    for path in list_devices():
        dev = InputDevice(path)
        if "Microsoft X-Box 360 pad" in dev.name:
            print(f"[INFO] Using gamepad: {path}")
            return dev
    raise RuntimeError("XBox 360 pad 입력 디바이스를 찾을 수 없습니다.")

# 전역 상태
state = {
    "voltage": 0.0,  # V
    "gear": "N"     # D, R, N
}
state_lock = threading.Lock()

# 배터리 모니터링 스레드
def battery_monitor_loop(piracer, stop_event):
    print("[INFO] Battery monitor started")
    while not stop_event.is_set():
        voltage = round(piracer.get_battery_voltage(), 2)
        with state_lock:
            state["voltage"] = voltage
        time.sleep(1.0)
    print("[INFO] Battery monitor stopped")

# RC 제어 스레드
def rc_control_loop(piracer, dev, stop_event):
    print("[INFO] RC control loop started")
    throttle = 0.0
    steering = 0.0
    prev_gear = "N"

    for event in dev.read_loop():
        if stop_event.is_set():
            break

        # 버튼 입력
        if event.type == ecodes.EV_KEY:
            if event.code == ecodes.BTN_SOUTH:
                throttle = 0.5 if event.value == 1 else 0.0
            elif event.code == ecodes.BTN_EAST:
                throttle = -0.5 if event.value == 1 else 0.0

        # 조이스틱 입력
        elif event.type == ecodes.EV_ABS and event.code == ecodes.ABS_X:
            steering = -event.value / 32767.0

        # 기어 상태 계산
        gear = "D" if throttle > 0 else ("R" if throttle < 0 else "N")
        with state_lock:
            state["gear"] = gear

        # 기어 변경 시 디버그 출력 및 상태 갱신
        if gear != prev_gear:
            print(f"[Gear] {prev_gear} → {gear}", flush=True)
            prev_gear = gear

        piracer.set_throttle_percent(throttle)
        piracer.set_steering_percent(steering)
        time.sleep(0.01)

    # 종료 시 정지
    piracer.set_throttle_percent(0.0)
    piracer.set_steering_percent(0.0)
    print("[INFO] RC control loop stopped")

# Flask 앱
app = Flask(__name__)

@app.route('/status')
def status():
    with state_lock:
        return jsonify(state)

# 메인 함수
def main():
    # 차량 객체 생성
    try:
        piracer = PiRacerPro()
    except ValueError:
        piracer = PiRacerStandard()

    dev = find_gamepad()
    stop_event = threading.Event()

    # 스레드 시작
    t_batt = threading.Thread(target=battery_monitor_loop, args=(piracer, stop_event), daemon=True)
    t_rc   = threading.Thread(target=rc_control_loop, args=(piracer, dev, stop_event), daemon=True)
    t_batt.start()
    t_rc.start()

    # Flask 서버 실행
    try:
        app.run(host='192.168.86.54', port=5000, threaded=True)
    finally:
        stop_event.set()
        t_batt.join()
        t_rc.join()

if __name__ == '__main__':
    main()
