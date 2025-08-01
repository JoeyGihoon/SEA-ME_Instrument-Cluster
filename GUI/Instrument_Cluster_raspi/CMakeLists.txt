cmake_minimum_required(VERSION 3.14)

project(Practice LANGUAGES CXX)

# C++ 표준 설정
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Qt 자동 처리 설정
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

# 필요한 Qt 모듈 찾기
find_package(Qt5 REQUIRED COMPONENTS Quick Qml QuickControls2 SerialBus)

# 소스 파일 목록
set(SRC_FILES
    main.cpp
    timeprovider.cpp
    canreader.cpp
)

# 리소스 파일 목록
set(RESOURCE_FILES
    resources.qrc
)

# Qt 리소스 처리
qt5_add_resources(GENERATED_RCC ${RESOURCE_FILES})

# 실행 파일 생성 (프로젝트 이름 사용)
add_executable(${PROJECT_NAME}
    ${SRC_FILES}
    ${GENERATED_RCC}
)

# 라이브러리 연결
target_link_libraries(${PROJECT_NAME} PRIVATE
    Qt5::Quick
    Qt5::Qml
    Qt5::QuickControls2
    Qt5::SerialBus
)

# 설치 옵션 (선택)
include(GNUInstallDirs)
install(TARGETS ${PROJECT_NAME}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
