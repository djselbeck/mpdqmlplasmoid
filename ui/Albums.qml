import QtQuick 1.0
import Qt 4.7
import org.kde.plasma.graphicswidgets 0.1 as PlasmaWidgets
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.graphicslayouts 4.7 as GraphicsLayouts
import org.kde.plasma.components 0.1 

Rectangle{
    id:albumpagerect
    property alias model: albums_list_view.model
    property string artistname;
    color:Qt.rgba(1,1,1,0);
    
    states: [
        State {
            name: "HIDDEN"
            when: albumpagerect.visible == false
            PropertyChanges { target: albumpagerect; opacity: 0 }
        },
        State {
            name: "VISIBLE"
            when: albumpagerect.visible == true
            PropertyChanges { target: albumpagerect; opacity: 1 }
        }
    ]
    onStateChanged:{
        console.debug("State changed:"+state);
    }

    transitions: Transition {
        PropertyAnimation { properties: "opacity"; easing.type: Easing.InOutQuad;}
    }
    ScrollBar
    {
        id:albumsscrollbar
        z:1
        flickableItem: albums_list_view
        anchors {right:albums_list_view.right;top:albums_list_view.top;bottom:albums_list_view.bottom}
    }
    ListView{
        id: albums_list_view
        anchors {left:parent.left;right:parent.right;top:parent.top;bottom:addbutton.top}
        visible:true;

        delegate:albumsdelegate;
        clip: true
        highlightMoveDuration: 300
    }
    Button{
        id:addbutton
        opacity: hideelements.containsMouse||!hiding ? 1 : 0.1
        Behavior on opacity {  PropertyAnimation {  easing.type: Easing.Linear;duration:200;}}
        iconSource: "list-add"
        height:artistname!=="" ? 24:0
        visible:artistname!==""
        anchors {right:parent.right;left:parent.left;bottom:parent.bottom}
        onClicked: {
            console.debug("add artist:"+artistname);
            addArtist(artistname);
        }
    }
    Component {
        id:albumsdelegate;
        Rectangle{
            height:topLayout.height;
            width:parent.width
            color:(index%2 ? Qt.rgba(1,1,1,0):Qt.rgba(1,1,1,0.3));
            Text{
                id: topLayout
                text: (title===""? "No Album Tag":title); color:"black";
            }
            MouseArea{
                anchors.fill:parent
                onClicked: {
                    albumClicked(artistname,title);
                }
            }
        }
    }
}

