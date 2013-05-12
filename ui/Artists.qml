import QtQuick 1.0
import Qt 4.7
import org.kde.plasma.graphicswidgets 0.1 as PlasmaWidgets
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.graphicslayouts 4.7 as GraphicsLayouts
import org.kde.plasma.components 0.1

Rectangle{
    id:artistsrect
    property alias model: artists_list_view.model
    color:Qt.rgba(1,1,1,0);

    states: [
        State {
            name: "HIDDEN"
            when: artistsrect.visible == false
            PropertyChanges { target: artistsrect; opacity: 0 }
        },
        State {
            name: "VISIBLE"
            when: artistsrect.visible == true
            PropertyChanges { target: artistsrect; opacity: 1 }
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
        id:artistscrollbar
        z:1
        flickableItem: artists_list_view
        anchors {right:artists_list_view.right;top:artists_list_view.top;bottom:artists_list_view.bottom}
    }
    ListView{
        id: artists_list_view
        anchors.fill: parent
        visible:true;

        delegate:artistsdelegate;
        clip: true
        highlightMoveDuration: 300
    }
    Component {
        id:artistsdelegate;
        Rectangle{
            height:topLayout.height;
            width:parent.width
            color:(index%2 ? Qt.rgba(1,1,1,0):Qt.rgba(1,1,1,0.3));
            Text{
                id: topLayout
                text: (artist===""? "No Artist Tag": artist); color:"black";
            }
            MouseArea{
                anchors.fill:parent
                onClicked: {
                    console.debug("artist clicked:"+artist);
                    artistClicked(artist);
                }
            }
        }
    }
}

