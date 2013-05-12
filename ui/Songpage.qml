import QtQuick 1.0
import Qt 4.7
import org.kde.plasma.graphicswidgets 0.1 as PlasmaWidgets
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.graphicslayouts 4.7 as GraphicsLayouts
import org.kde.plasma.components 0.1


Rectangle {
    id: currentsong_page
    property alias title: titleText.text;
    property alias album: albumText.text;
    property alias artist: artistText.text;
    property alias lengthtext:lengthText.text;
    property alias date: dateText.text;
    property alias nr: nrText.text;
    property alias filename: fileText.text;
    property string lastpage;
    property bool playing;
    color:Qt.rgba(1,1,1,0);
    
    states: [
        State {
            name: "HIDDEN"
            when: currentsong_page.visible == false
            PropertyChanges { target: currentsong_page; opacity: 0 }
        },
        State {
            name: "VISIBLE"
            when: currentsong_page.visible == true
            PropertyChanges { target: currentsong_page; opacity: 1 }
        }
    ]
    onStateChanged:{
        console.debug("State changed:"+state);
    }

    transitions: Transition {
        PropertyAnimation { properties: "opacity"; easing.type: Easing.InOutQuad;}
    }
    Flickable{
        anchors {left:parent.left; right: parent.right;bottom:buttonrow.top;top: parent.top}
        contentHeight: infocolumn.height
        clip: true
        Column {
            id: infocolumn
            anchors {left:parent.left; right: parent.right;}
            Text{text: "Title:";color:"black"}
            Text{id:titleText ;text: "";color:"black";font.pointSize:8;wrapMode: "WordWrap";anchors {left:parent.left; right: parent.right;}}
            Text{text: "Album:";color:"black"}
            Text{id:albumText ;text: "";color:"black";font.pointSize:8;wrapMode: "WordWrap";anchors {left:parent.left; right: parent.right;}}
            Text{text: "Artist:";color:"black"}
            Text{id:artistText ;text: "";color:"black";font.pointSize:8;wrapMode: "WordWrap";anchors {left:parent.left; right: parent.right;}}
            Text{text: "Length:";color:"black"}
            Text{id:lengthText ;text: "";color:"black";font.pointSize:8;wrapMode: "WordWrap";anchors {left:parent.left; right: parent.right;}}
            Text{text: "Date:";color:"black"}
            Text{id:dateText ;text: "";color:"black";font.pointSize:8;wrapMode: "WordWrap";anchors {left:parent.left; right: parent.right;}}
            Text{text: "Nr.:";color:"black"}
            Text{id:nrText ;text: "";color:"black";font.pointSize:8;wrapMode: "WordWrap";anchors {left:parent.left; right: parent.right;}}
            Text{text: "FileUri:";color:"black"}
            Text{id:fileText ;text: "";color:"black";font.pointSize:8;wrapMode:"WrapAnywhere" ;anchors {left:parent.left; right: parent.right;}}
            clip: true;
        }
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
                console.debug("add artist:"+artistname);
                hideAllViews();
                if(lastpage==="album") {
                    albumsongs.visible=true;
                }
                else if (lastpage==="file") {
                    filepage.visible=true;
                }
                else if (lastpage==="savedplaylist") {
                    savedplaylisttracks.visible=true;
                }
            }
        }

        Button{
            id:addbutton
            iconSource: "list-add"
            height:24
            width:parent.width/3
            onClicked: {
                console.debug("add artist:"+artistname);
                addSong(filename);
                hideAllViews();
                if(lastpage==="album") {
                    albumsongs.visible=true;
                }
                else if (lastpage==="file") {
                    filepage.visible=true;
                }
                else if (lastpage==="savedplaylist") {
                    savedplaylisttracks.visible=true;
                }
            }
        }
        Button{
            id:playbutton
            iconSource: "media-playback-start"
            height:24
            width:parent.width/3
            onClicked: {
                playSong(filename);
                hideAllViews();
                if(lastpage==="album") {
                    albumsongs.visible=true;
                }
                else if (lastpage==="file") {
                    filepage.visible=true;
                }
                else if (lastpage==="savedplaylist") {
                    savedplaylisttracks.visible=true;
                }
            }
        }
    }

}
