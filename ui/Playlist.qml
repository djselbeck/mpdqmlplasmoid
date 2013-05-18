import QtQuick 1.0
import Qt 4.7
import org.kde.plasma.graphicswidgets 0.1 as PlasmaWidgets
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.graphicslayouts 4.7 as GraphicsLayouts
import org.kde.plasma.components 0.1

Rectangle{
    id:playlistpagerect
    property alias model: playlist_list_view.model
    property alias songid: playlist_list_view.currentIndex
    color:Qt.rgba(1,1,1,0);


    states: [
        State {
            name: "HIDDEN"
            when: playlistpagerect.visible == false
            PropertyChanges { target: playlistpagerect; opacity: 0 }
        },
        State {
            name: "VISIBLE"
            when: playlistpagerect.visible == true
            PropertyChanges { target: playlistpagerect; opacity: 1 }
        }
    ]
    onStateChanged:{
        console.debug("State changed:"+state);
    }

    transitions: Transition {
        PropertyAnimation {target:playlistpagerect; properties: "opacity"; easing.type: Easing.InOutQuad 	}
    }
    ScrollBar
    {
        id:playlistscroll
        z:1
        flickableItem: playlist_list_view
        anchors {right:playlist_list_view.right;top:playlist_list_view.top;bottom:playlist_list_view.bottom}
    }
    ListView{
        id: playlist_list_view
        anchors {left:parent.left;right:parent.right;top:parent.top;bottom:buttonrow.top}
        visible:true;
        highlightFollowsCurrentItem:true
        delegate:playlistdelegate;
        clip: true
        highlightMoveDuration: 300
    }
    ButtonRow{
        id:buttonrow;
        exclusive:false
        spacing : 0
        anchors {right:parent.right;left:parent.left;bottom:parent.bottom}
        height: hideelements.containsMouse||!hiding ? backbutton.height:0
        opacity: hideelements.containsMouse||!hiding ? 1 : 0
        Behavior on opacity {  PropertyAnimation {  easing.type: Easing.Linear;duration:200;}}
        Behavior on height { PropertyAnimation {} }
        Button{
            id:backbutton
            iconSource: "edit-delete"
            height:24
            width:parent.width/4
            onClicked: {
                deletePlaylist();
            }
        }
        Button{
            id:addbutton
            iconSource: "document-save"
            height:24
            width:parent.width/4
            onClicked: {
                savenamedialog.visible=true;
            }
        }
        Button{
            id:playbutton
            iconSource: "document-open"
            height:24
            width:parent.width/4
            onClicked: {
                requestSavedPlaylists();
            }
        }
        Button{
            id:jumpbutton
            iconSource: "go-jump"
            height:24
            width:parent.width/4
            onClicked: {
                songid = -1;
                songid = lastsongid;
            }
        }
    }
    Component {
        id:playlistdelegate;
        Rectangle{
            color:(index%2 ? Qt.rgba(1,1,1,0):Qt.rgba(1,1,1,0.3));
            height:textcolumpl.height;
            width:parent.width
            MouseArea{
                anchors.fill: parent
                onClicked:{
		  console.log("Playlist item clicked");
                    if(!playing)
                    {
                        parseClickedPlaylist(index);
                    }
                    else {
			playlist.visible=false;
			console.log ("Show current song page");
			currentsongpage.visible = true;
		    }
                }
            }
            Row{
                Image {
                    visible: playing
                    source: "icons/play.svg"
                    height: parent.height
                    width: parent.height
                }
                Column{
                    id:textcolumpl;
                    Row{
                        Text {text: (index+1)+". ";}
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

    Rectangle
    {
        id: savenamedialog
        color: Qt.rgba(1,1,1,0.8);
        z:1
        anchors {top:parent.top;left:parent.left;right:parent.right;bottom:parent.bottom}
        visible:false
        Column {
            z:2
            id:savenamecolumn
            onVisibleChanged: playlistname.text="";
            visible:true
            y: parent.height/2
            anchors {left: parent.left;right:parent.right;bottom:parent.bottom}
            Text{text: "Enter name for playlist:";color:"black" }
            TextInput{ id:playlistname;
                color:"black"
                focus:visible
                text:"";
                anchors {left: parent.left;right:parent.right}
                Keys.onPressed: {if(event.key==Qt.Key_Enter){
                        window.savePlaylist(playlistname.text);
                        savenamedialog.visible=false;
                        playlist_list_view.visible=true;
                    }
                }
                inputMethodHints: Qt.ImhNoPredictiveText
            }
            ButtonRow{anchors {left: parent.left;right:parent.right}
                exclusive:false
                spacing : 0
                Button{text:"Ok"
                    width:parent.width/2
                    onClicked: {
                        savePlaylist(playlistname.text);
                        savenamedialog.visible=false;
                        playlist_list_view.visible=true;
                    }}
                Button{text:"Cancel"
                    width:parent.width/2
                    onClicked: {
                        savenamedialog.visible=false;
                        playlist_list_view.visible=true;
                    }}
            }
        }
    }
}

