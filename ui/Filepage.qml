import QtQuick 1.0
import Qt 4.7
import org.kde.plasma.graphicswidgets 0.1 as PlasmaWidgets
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.graphicslayouts 4.7 as GraphicsLayouts
import org.kde.plasma.components 0.1

Rectangle{
  id:pagerect
  property alias model: file_list_view.model
  property string filepath;
  color:Qt.rgba(1,1,1,0);
  
states: [
         State {
             name: "HIDDEN"
	     when: pagerect.visible == false
	     PropertyChanges { target: pagerect; opacity: 0 }
         },
         State {
             name: "VISIBLE"
	     when: pagerect.visible == true
	      PropertyChanges { target: pagerect; opacity: 1 }
         }
     ]
     onStateChanged:{
      console.debug("State changed:"+state); 
     }
     
     transitions: Transition {
         PropertyAnimation { properties: "opacity"; easing.type: Easing.InOutQuad}
     }
     ScrollBar
     {
       id:filescroller
       z:1
	flickableItem: file_list_view
	anchors {right:file_list_view.right;top:file_list_view.top;bottom:file_list_view.bottom}
     }
ListView{	        
        id: file_list_view
        anchors {left:parent.left;right:parent.right;top:parent.top;bottom:buttonrow.top}

        visible:true;

         delegate:filesdelegate;
        clip: true
        highlightMoveDuration: 300
    }
    ButtonRow{
      id:buttonrow;
      spacing : 0
      exclusive:false
           anchors {right:parent.right;left:parent.left;bottom:parent.bottom}
  Button{
     id:backbutton 
     iconSource: "arrow-left"
     height:24
     width:parent.width/3
     onClicked: {
       console.debug("Clicked Filepath:"+filepath);
       if(filepath!=="/"){
       hideAllViews();
       console.debug("before");
        popfilemodelstack();
	console.debug("after");
       }
       else{
	 hideAllViews();
       console.debug("before");
        popfilemodelstack();
	console.debug("after");	
	model=0;
	hideAllViews();
	playlist.visible=true;
       }
     }
  }
     
        Button{
     id:addbutton 
     iconSource: "list-add"
     height:24
     width:parent.width/3
     onClicked: {
       console.debug("add dir:"+filepath);
       addFiles(filepath);       
     }
    }
    Button{
     id:playbutton 
     iconSource: "media-playback-start"
     height:24
     width:parent.width/3
     onClicked: {
       console.debug("play dir:"+artistname);
       playFiles(filepath);
     }
    }
    }
    Component {
	 id:filesdelegate;
Rectangle{
color:(index%2 ? Qt.rgba(1,1,1,0):Qt.rgba(1,1,1,0.3));
  height:24;
  width:parent.width
            MouseArea{
	     anchors.fill: parent 
	     onClicked:{
	       console.debug("clicked");
	       if(isDirectory){
		 hideAllViews();
                    filesClicked((prepath=="/"? "": prepath+"/")+name);
                }
                if(isFile) {
		  hideAllViews();
                    albumTrackClicked(title,album,artist,length,path,year,tracknr,"file");
                }
	     }
	    }
	    Rectangle{
	      color:Qt.rgba(1,1,1,0);
	        height:parent.height
  anchors.fill: parent;
        Image {
                    id: fileicon
                    source: (isDirectory===true ? "icons/folder.svg":"icons/music_file.svg");
                    height:parent.height
                    width: height
                    anchors.verticalCenter: parent.verticalCenter
                }
                Column{
		  id:textcolumpl;
                    anchors{left: fileicon.right;right:parent.right;verticalCenter:parent.verticalCenter;}
                Text{
                    id:filenametext
                    text: name
                    wrapMode: "NoWrap"
                    anchors {left: parent.left;right:parent.right}
                    elide: Text.ElideMiddle;
                }
                Text
                {
                    visible: isDirectory===false
                    text: (isDirectory===true ? "" : (title==="" ?"" : title+ " - ") + (artist==="" ?  "" : artist) );
		    font.pointSize:6;
                    anchors {left: parent.left;right:parent.right;}
                }
                } }
            
     }
	}
}

