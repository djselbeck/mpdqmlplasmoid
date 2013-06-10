import QtQuick 1.0
import Qt 4.7
import org.kde.plasma.graphicswidgets 0.1 as PlasmaWidgets
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.graphicslayouts 4.7 as GraphicsLayouts
import org.kde.plasma.components 0.1

Rectangle{
    color:Qt.rgba(1,1,1,0);
    property alias title: titleText.text;
    property alias album: albumText.text;
    property alias artist: artistText.text;
    property alias bitrate: bitrateText.text;
    property alias nr: nrText.text;
    property alias uri: fileText.text;
    property alias audioproperties: audiopropertiesText.text;
    property bool playing;
    property int fontsize:8;
    property int fontsizeblack:7;


    Flickable{
        id: infoFlickable
        anchors {fill:parent}
        contentHeight: infocolumn.height
        clip: true
        Column {
            id: infocolumn
            //anchors {left:parent.left; right: parent.right; top:parent.top; bottom:parent.bottom}
            anchors {left:parent.left; right: parent.right;}
	    Image{
                id: coverImage
                height: infoFlickable.height - (titleText.height + albumText.height + artistText.height)
                width: height
                anchors.horizontalCenter: parent.horizontalCenter
                fillMode: Image.PreserveAspectCrop
                source: coverimageurl
            }
            Text{id:titleText ;text: "";color:"black";font.pointSize:fontsize;wrapMode: "WordWrap";anchors {horizontalCenter:parent.horizontalCenter}}
            Text{id:albumText ;text: "";color:"black";font.pointSize:fontsize;wrapMode: "WordWrap";anchors {horizontalCenter:parent.horizontalCenter}}
            Text{id:artistText ;text: "";color:"black";font.pointSize:fontsize;wrapMode: "WordWrap";anchors {horizontalCenter:parent.horizontalCenter}}
            Text{text: "Nr.:";color:"black";font.pointSize: fontsizeblack}
            Text{id:nrText ;text: "";color:"black";font.pointSize:fontsize;wrapMode: "WordWrap";anchors {left:parent.left; right: parent.right;}}
            Text{text: "Bitrate:";color:"black";font.pointSize: fontsizeblack}
            Text{id:bitrateText ;text: "";color:"black";font.pointSize:fontsize;wrapMode: "WordWrap";anchors {left:parent.left; right: parent.right;}}
            Text{text: "Properties:";color:"black";font.pointSize: fontsizeblack}
            Text{id:audiopropertiesText ;text: "";color:"black";font.pointSize:fontsize;wrapMode: "WordWrap";anchors {left:parent.left; right: parent.right;}}
            Text{text: "FileUri:";color:"black";font.pointSize: fontsizeblack}
            Text{id:fileText ;text: "";color:"black";font.pointSize:fontsize;wrapMode:"WrapAnywhere" ;anchors {left:parent.left; right: parent.right;}}
            clip: true;
        }
    }
}

