  GNU nano 5.4                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    volt_gear.py                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              
#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
volt_gear.py
------------
- 게임패드로 RC 제어 (evdev)
- PiRacer 배터리 전압 읽기
- Flask JSON API
  - /status : {"voltage": float, "gear": "D|R|N"}
  - /debug  : I2C 맵 + 입력장치 목록 + 현재 state (진단용)

실행 전 체크:
  pip install flask evdev piracer-py
권장 실행:
  sudo python3 volt_gear.py
"""

import os
import time
import json
import threading
import subprocess
from flask import Flask, jsonify

# ------- 외부 라이브러리 -------
from evdev import InputDevice, ecodes, list_devices

try:
    from piracer.vehicles import PiRacerPro, PiRacerStandard
except ImportError as e:
    raise RuntimeError("PiRacer SDK 미설치. `pip install piracer-py`로 설치하세요.") from e

# ------- 전역 상태 -------
state = {
    "voltage": 0.0,   # V
    "gear": "N"       # D / R / N
}
state_lock = threading.Lock()

# =========================================================
# 진단 유틸
# =========================================================
def list_all_input_devices():
    devices = []
    for path in list_devices():
        try:
            dev = InputDevice(path)
            devices.append({"path": path, "name": dev.name})
        except Exception as e:
            devices.append({"path": path, "name": f"<open failed: {e}>"})
    return devices

def dump_diag():
    # I2C 디텍트 테이블
    try:
        i2c_str = subprocess.check_output(["i2cdetect", "-y", "1"], timeout=2).decode()
    except Exception as e:
        i2c_str = f"<i2cdetect error: {e}>"

    info = {
        "i2c_bus_1_map": i2c_str,
        "input_devices": list_all_input_devices(),
    }
    with state_lock:
        info["state"] = dict(state)
    return info

# =========================================================
# 입력 장치(게임패드) 탐색
# =========================================================
def find_gamepad():
    print("[INFO] ===== Input devices =====")
    devs = list_all_input_devices()
    for d in devs:
        print(f" - {d['path']}: {d['name']}")
    print("[INFO] =========================")

    # 이름 완화 매칭
    keywords = [
        "xbox", "x-box", "wireless controller",
        "gamepad", "controller", "logitech", "8bitdo", "dualshock"
    ]
    for path in list_devices():
        dev = InputDevice(path)
        name_l = (dev.name or "").lower()
        if any(k in name_l for k in keywords):
            print(f"[INFO] Using gamepad: {path} ({dev.name})")
            return dev

    # 마지막 수단: 첫번째 event 장치
    for path in list_devices():
        try:
            dev = InputDevice(path)
            print(f"[WARN] Fallback to: {path} ({dev.name})")
            return dev
        except Exception:
            pass

    raise RuntimeError("게임패드 입력 디바이스를 찾을 수 없습니다.")

# =========================================================
# 스레드: 배터리 모니터
# =========================================================
def battery_monitor_loop(piracer, stop_event):
    print("[INFO] Battery monitor started")
    while not stop_event.is_set():
        try:
            v = piracer.get_battery_voltage()
            voltage = round(float(v or 0.0), 2)
        except Exception as e:
            print(f"[ERR] get_battery_voltage(): {e}")
            voltage = 0.0

        with state_lock:
            state["voltage"] = voltage

        print(f"[BAT] voltage={voltage} V", flush=True)  # 진단 로그
        time.sleep(1.0)
    print("[INFO] Battery monitor stopped")

# =========================================================
# 스레드: RC 제어 (게임패드)
# =========================================================
def rc_control_loop(piracer, dev, stop_event):
    print("[INFO] RC control loop started")
    throttle = 0.0
    steering = 0.0
    prev_gear = "N"

    # 권한 문제 완화(루트일 때만)
    try:
        if os.geteuid() == 0:
            dev.grab()
    except Exception as e:
        print(f"[WARN] dev.grab() skipped: {e}")

    for event in dev.read_loop():
        if stop_event.is_set():
            break

        # 버튼/키
        if event.type == ecodes.EV_KEY:
            # 처음엔 어떤 코드가 들어오는지 로그 확인에 유용
            if event.value in (0, 1):
                print(f"[KEY] code={event.code} val={event.value}", flush=True)

            # A/RT 등 다양한 컨트롤러를 허용
            if event.code in (ecodes.BTN_SOUTH, ecodes.BTN_TR2, 311):   # 전진
                throttle = 0.5 if event.value == 1 else 0.0
            elif event.code in (ecodes.BTN_EAST, ecodes.BTN_TL2, 312):  # 후진
                throttle = -0.5 if event.value == 1 else 0.0

        # 축(조이스틱)
        elif event.type == ecodes.EV_ABS:
            if event.code == ecodes.ABS_X:
                steering = -event.value / 32767.0

        # 기어 계산
        gear = "D" if throttle > 0 else ("R" if throttle < 0 else "N")
        with state_lock:
            state["gear"] = gear

        if gear != prev_gear:
            print(f"[Gear] {prev_gear} → {gear}", flush=True)
            prev_ear = prev_gear
            prev_gear = gear

        try:
            piracer.set_throttle_percent(throttle)
            piracer.set_steering_percent(steering)
        except Exception as e:
            print(f"[ERR] piracer control: {e}")

        time.sleep(0.01)

    # 종료 시 정지
    try:
        piracer.set_throttle_percent(0.0)
        piracer.set_steering_percent(0.0)
    except Exception:
        pass
    print("[INFO] RC control loop stopped")

# =========================================================
# Flask 앱
# =========================================================
app = Flask(__name__)

@app.route("/status")
def status():
    with state_lock:
        return jsonify(state)

@app.route("/debug")
def debug():
    return jsonify(dump_diag())

# =========================================================
# 메인
# =========================================================
def main():
    # PiRacer 타입 선택
    try:
        piracer = PiRacerPro()
        print("[INFO] Using PiRacerPro")
    except ValueError:
        piracer = PiRacerStandard()
        print("[INFO] Using PiRacerStandard")

    # 권한 안내
    if os.geteuid() != 0:
        print("[WARN] 일반 사용자로 실행됨. /dev/input/event* 권한 문제 시 root 실행 또는 udev rule 설정 필요.")

    # 게임패드 오픈
    dev = find_gamepad()

    # 스레드 시작
    stop_event = threading.Event()
    t_batt = threading.Thread(target=battery_monitor_loop, args=(piracer, stop_event), daemon=True)
    t_rc   = threading.Thread(target=rc_control_loop, args=(piracer, dev, stop_event), daemon=True)
    t_batt.start()
    t_rc.start()

    try:
        # 외부 접속 허용(고정 IP 금지)
        host = "0.0.0.0"
        port = int(os.environ.get("PORT", "5000"))
        print(f"[INFO] Flask serving on http://{host}:{port}")
        app.run(host=host, port=port, threaded=True)
    finally:
        stop_event.set()
        t_batt.join()
        t_rc.join()

if __name__ == "__main__":
    main()




