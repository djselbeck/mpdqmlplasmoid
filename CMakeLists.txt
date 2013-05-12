project(plasma-mpdqmlplasmoid)
 
# Find the required Libaries
find_package(KDE4 REQUIRED)
include(KDE4Defaults)
 
add_definitions (${QT_DEFINITIONS} ${KDE4_DEFINITIONS})
include_directories(
   ${CMAKE_SOURCE_DIR}
   ${CMAKE_BINARY_DIR}
   ${KDE4_INCLUDES}
   )
 
# We add our source code here
set(mpdqmlplasmoid_SRCS albummodel.cpp    mpdfileentry.cpp    networkaccess.cpp  wlifile.cpp
artistmodel.cpp  mpdalbum.cpp    mpdqmlplasmoid.cpp  qthreadex.cpp      wlitrack.cpp
commondebug.cpp  mpdartist.cpp   mpdtrack.cpp        serverprofile.cpp controller.cpp wheelarea.cpp mpdoutput.cpp)

kde4_add_ui_files(mpdqmlplasmoid_SRCS qmpdplasmoidconfig.ui qmpdplasmoidconfiggui.ui)
 

# Now make sure all files get to the right place
kde4_add_plugin(plasma_applet_mpdqmlplasmoid ${mpdqmlplasmoid_SRCS})
target_link_libraries(plasma_applet_mpdqmlplasmoid 
                      ${KDE4_PLASMA_LIBS} ${KDE4_KDEUI_LIBS} ${QT_QTDECLARATIVE_LIBRARY} ${QT_QTNETWORK_LIBRARY})
 
install(TARGETS plasma_applet_mpdqmlplasmoid
        DESTINATION ${PLUGIN_INSTALL_DIR})
 
install(FILES plasma-applet-mpdqmlplasmoid.desktop
        DESTINATION ${SERVICES_INSTALL_DIR})

install(DIRECTORY ui/
        DESTINATION ${DATA_INSTALL_DIR}/plasma/plasmoids/org.kde.plasma.applet.mpdqmlplasmoid/ui)

