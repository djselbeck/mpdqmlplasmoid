import QtQuick 1.0
import Qt 4.7
import org.kde.plasma.graphicswidgets 0.1 as PlasmaWidgets
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.graphicslayouts 4.7 as GraphicsLayouts
import org.kde.plasma.components 0.1

Rectangle{
    color:Qt.rgba(1,1,1,0);
    Button
    {
        id:refreshlibrary
        text:"Update Library"
        anchors {left:parent.left;right:parent.right}
        onClicked:{
            updateDB();
        }
    }
}

