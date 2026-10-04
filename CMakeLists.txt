cmake_minimum_required(VERSION 3.16)
project(VoidPass VERSION 1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

find_package(Qt6 COMPONENTS Quick Qml Sql Gui Network REQUIRED)
find_package(OpenSSL REQUIRED)

set(SOURCES
    src/main.cpp
    src/VaultManager.cpp
    src/PasswordGen.cpp
)

set(HEADERS
    src/VaultManager.h
    src/PasswordGen.h
)

# QML ve ikon dosyalarını QRC'ye ekle
set(RESOURCES resources.qrc)

set(EXTRA_SOURCES "")
if(WIN32)
    list(APPEND EXTRA_SOURCES app.rc)
endif()

add_executable(VoidPass WIN32 ${SOURCES} ${HEADERS} ${RESOURCES} ${EXTRA_SOURCES})

target_link_libraries(VoidPass PRIVATE 
    Qt6::Quick 
    Qt6::Qml 
    Qt6::Sql 
    Qt6::Gui
    Qt6::Network
    OpenSSL::SSL 
    OpenSSL::Crypto
)
