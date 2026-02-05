cmake_minimum_required(VERSION 3.16)
project(TextInputOSKBug VERSION 1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)

find_package(Qt6 REQUIRED COMPONENTS Quick QuickControls2)

qt_add_executable(TextInputOSKBug main.cpp)

qt_add_qml_module(TextInputOSKBug
    URI App
    VERSION 1.0
    RESOURCE_PREFIX /
    QML_FILES
        Main.qml
        InputPanel.qml
        TapHoverBlocker.qml
        TextInputField.qml
        TextFieldWrapper.qml
)

target_link_libraries(TextInputOSKBug PRIVATE Qt6::Quick Qt6::QuickControls2)
