//====================================================================
// OneEuroFilter.js   (QML용 JavaScript Singleton)
// -------------------------------------------------------------------
//  * Hervé M. & Georges W. 의 “One Euro Filter” 알고리즘을 QML에서
//    바로 쓸 수 있도록 최소 구현한 버전입니다.
//  * 사용법:
//      import "OneEuroFilter.js" as OEF
//      var res = OEF.filter(prevY, prevDy, x, dt,
//                           minCutoff, beta, dCutoff);
//      filteredValue = res.y;
//      prevDy        = res.dx;
//
//  * 파라미터:
//      minCutoff : 기본 차단 주파수   (Hz)  → 낮을수록 부드럽다
//      beta      : 변화량에 따른 cutoff 가산 계수
//      dCutoff   : 1차 LPF 로 dx/dt 추정 시 cutoff (Hz)
//====================================================================
pragma Singleton
import QtQuick 2.15

QtObject {
    //----------------------------------------------------------------
    // 내부: 보조 함수  α = 1 / (1 + τ / dt) ,  τ = 1/(2π·cutoff)
    //----------------------------------------------------------------
    function alpha(cutoff, dt) {
        var tau = 1.0 / (2.0 * Math.PI * cutoff);
        return 1.0 / (1.0 + tau / dt);
    }

    //----------------------------------------------------------------
    // filter(...)
    //  prevX  : 이전 출력값 (y_{k-1})
    //  prevDX : 이전 미분값 (dx_{k-1})
    //  x      : 새 입력값   (x_k)
    //  dt     : 샘플 간격   (초)
    //----------------------------------------------------------------
    function filter(prevX, prevDX, x, dt,
                    minCutoff /*Hz*/, beta /*0~1*/, dCutoff /*Hz*/) {

        //----- 1단계: 입력 변화량 미분 & LPF ---------------------------------
        var dx      = (x - prevX) / dt;
        var a_d     = alpha(dCutoff, dt);
        var edx     = prevDX + a_d * (dx - prevDX);      // smoothed dx

        //----- 2단계: 적응형 cutoff 계산 -------------------------------------
        var cutoff  = minCutoff + beta * Math.abs(edx);

        //----- 3단계: 최종 LPF 적용 -----------------------------------------
        var a       = alpha(cutoff, dt);
        var y       = prevX + a * (x - prevX);

        return { y: y, dx: edx };
    }
}
