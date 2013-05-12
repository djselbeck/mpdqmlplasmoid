import QtQuick 1.0
import Qt 4.7
import org.kde.plasma.graphicswidgets 0.1 as PlasmaWidgets
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.graphicslayouts 4.7 as GraphicsLayouts
import org.kde.plasma.components 0.1

Rectangle{
    property alias model: playlisttracks_list_view.model
    property string playlistname;
    color:Qt.rgba(1,1,1,0);
    ScrollBar
    {
        id:savedplscroller
        z:1
        flickableItem: playlisttracks_list_view
        anchors {right:playlisttracks_list_view.right;top:playlisttracks_list_view.top;bottom:playlisttracks_list_view.bottom}
    }
    ListView{
        id: playlisttracks_list_view
        anchors {left:parent.left;right:parent.right;top:parent.top;bottom:buttonrow.top}

        visible:true;

        delegate:playlisttracksdelegate;
        clip: true
        highlightMoveDuration: 300
    }
    ButtonRow{
        id:buttonrow;
        exclusive:false
        spacing : 0
        anchors {right:parent.right;left:parent.left;bottom:parent.bottom}

        Button{
            id:backbutton
            iconSource: "arrow-left"
            height:24
            width:parent.width/3
            onClicked: {
                hideAllViews();
                savedplaylists.visible=true;
            }
        }
        Button{
            id:addbutton
            iconSource: "list-add"
            height:24
            width:parent.width/3
            onClicked: {
                addPlaylist(playlistname);
            }
        }
        Button{
            id:playbutton
            iconSource: "edit-delete"
            height:24
            width:parent.width/3
            onClicked: {
                deleteSavedPlaylist(playlistname);
                hideAllViews();
                playlist.visible=true;
            }
        }


    }
    Component {
        id:playlisttracksdelegate;

        Rectangle{
            color:(index%2 ? Qt.rgba(1,1,1,0):Qt.rgba(1,1,1,0.3));
            height:textcolumpl.height;
            width:parent.width
            MouseArea{
                anchors.fill: parent
                onClicked:{
                    albumTrackClicked(title,album,artist,lengthformated,uri,year,tracknr,"savedplaylist");
                }
            }
            Row{
                Column{
                    id:textcolumpl;
                    Row{
                        Text {text: ((tracknr===0 ? "":tracknr+"."));}
                        Text {clip: true; wrapMode: Text.WrapAnywhere; elide: Text.ElideRight; text:  (title==="" ? filename : title);font.italic:(playing) ? true:false;}
                        Text { text: (length===0 ? "": " ("+lengthformated+")");}
                    }
                    Text{text:(artist!=="" ? artist + " - " : "" )+(album!=="" ? album : "");
                        font.pointSize:6;
                    }
                }

            }
            
        }
    }

}

