cmake_minimum_required(VERSION 3.16)

project(Instrument_Cluster VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTORCC ON) ###필수###

find_package(Qt6 REQUIRED COMPONENTS Quick)

qt_standard_project_setup(REQUIRES 6.8)

qt_add_executable(appInstrument_Cluster
    main.cpp
    resources.qrc
)

qt_add_qml_module(appInstrument_Cluster
    URI Instrument_Cluster
    VERSION 1.0

    QML_FILES
        Main.qml
        Cluster.qml
        QML_FILES SpeedNeedle.qml
        QML_FILES BatteryNeedle.qml
        QML_FILES Gear.qml
        SOURCES
        SOURCES timeprovider.h timeprovider.cpp
)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(appInstrument_Cluster PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.appInstrument_Cluster
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appInstrument_Cluster
    PRIVATE Qt6::Quick
)

include(GNUInstallDirs)
install(TARGETS appInstrument_Cluster
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
