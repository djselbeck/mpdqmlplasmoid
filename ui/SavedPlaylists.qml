import QtQuick 1.0
import Qt 4.7
import org.kde.plasma.graphicswidgets 0.1 as PlasmaWidgets
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.graphicslayouts 4.7 as GraphicsLayouts
import org.kde.plasma.components 0.1

Rectangle{
    property alias model: playlists_list_view.model
    color:Qt.rgba(1,1,1,0);
    ScrollBar
    {
        id:savedplscroller
        z:1
        flickableItem: playlists_list_view
        anchors {right:playlists_list_view.right;top:playlists_list_view.top;bottom:playlists_list_view.bottom}
    }
    ListView{
        id: playlists_list_view
        anchors {left:parent.left;right:parent.right;top:parent.top;bottom:buttonrow.top}

        visible:true;

        delegate:playlistsdelegate;
        clip: true
        highlightMoveDuration: 300
    }
    ButtonRow{
        id:buttonrow;
	spacing : 0
        anchors {right:parent.right;left:parent.left;bottom:parent.bottom}
        exclusive:false
        Button{
            id:backbutton
            iconSource: "arrow-left"
            height:24
            width:parent.width
            onClicked: {
                hideAllViews();
                playlist.visible=true;
            }
        }

    }
    Component {
        id:playlistsdelegate;
        Rectangle{
            color:(index%2 ? Qt.rgba(1,1,1,0):Qt.rgba(1,1,1,0.3));
            //   height:textcolumpl.height;
            height:20
            width:parent.width
            MouseArea{
                anchors.fill: parent
                onClicked:{
                    savedPlaylistClicked(modelData);
                }
            }
            Text {text: modelData;}

        }

    }
}

