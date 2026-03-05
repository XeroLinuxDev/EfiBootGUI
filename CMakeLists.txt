cmake_minimum_required(VERSION 3.20)
project(efibootmgrgui VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)

find_package(Qt6 REQUIRED COMPONENTS Core Gui Qml Quick QuickControls2)
find_package(KF6WindowSystem REQUIRED)

qt_add_executable(efibootmgrgui
    src/main.cpp
    src/bootmanager.cpp
    src/bootentry.cpp
)

qt_add_qml_module(efibootmgrgui
    URI com.efibootmgrgui
    VERSION 1.0
    QML_FILES
        qml/main.qml
        qml/BootEntryDelegate.qml
        qml/ConfirmDialog.qml
        qml/AboutWindow.qml
    RESOURCES
        assets/logo.png
)

target_include_directories(efibootmgrgui PRIVATE src)

target_link_libraries(efibootmgrgui PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Qml
    Qt6::Quick
    Qt6::QuickControls2
    KF6::WindowSystem
)

install(TARGETS efibootmgrgui DESTINATION bin)
