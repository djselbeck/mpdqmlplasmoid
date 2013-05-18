import QtQuick 1.1
import Qt 4.7
import org.kde.plasma.graphicswidgets 0.1 as PlasmaWidgets
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.graphicslayouts 4.7 as GraphicsLayouts
import MyTools 1.0
import org.kde.plasma.components 0.1

Item {
    id: page;
    property int minimumWidth : 326;
    property int minimumHeight: 300;
    property string artist;
    property string album;
    property string title;
    property string artistname;
    property string albumname;
    property string state:"stop";
    property bool random;
    property bool repeat;
    property int tracklength;
    property int trackposition;
    property int lastsongid;
    property bool connected:false;

    property int volume:0;

    BusyIndicator{

      id: busyindicator
      visible:false;
      anchors.centerIn: page
    }
    Component.onCompleted:
    {
        console.debug("onCompleted");
        var hiding = false;
        height = height +1;
        page.width = page.width -1;
        page.height = page.height -1;
    }
    MouseArea{
        id:hideelements
        anchors.fill: parent
        hoverEnabled:true
        z:1
        acceptedButtons:Qt.NoButton
    }
    Item{
        id:panelhorzontal
        anchors.fill: parent
        Row{

        }
    }
    Item{

        id:listrow
        anchors.top: parent.top;
        anchors.bottom:bottomcolumn.top
        anchors.right:parent.right;
        anchors.left: parent.left;


        Playlist{id:playlist
            anchors.fill: parent;
            visible:true;
        }
        Artists{
            id:artists
            anchors.fill: parent;
            visible:false;
        }
        Albums{
            id:albums
            anchors.fill: parent;
            visible:false;
        }
        Songlist{
            id:albumsongs;
            anchors.fill: parent;
            visible:false;
        }
        Songpage{
            id:songpage;
            anchors.fill:parent;
            visible:false;
        }
        Filepage{
            id: filepage;
            anchors.fill:parent;
            visible:false;
        }
        SavedPlaylists
        {
            id: savedplaylists ;
            anchors.fill: parent;
            visible:false;
        }
        SavedPlaylistTracks
        {
            id: savedplaylisttracks ;
            anchors.fill: parent;
            visible:false;
        }
        ServerSettings{
            id: serversettingspage;
            visible: false;
            anchors.fill: parent;
        }
        CurrentSong{
	    id: currentsongpage;
	    visible: false;
	    anchors.fill: parent;
	}
    }

    Column{
        id:bottomcolumn

        width: parent.width
        anchors.bottom: parent.bottom;
        Column{
            Behavior on y {  PropertyAnimation {  easing.type: Easing.InLinear;duration:200;}}
            Behavior on x { PropertyAnimation {} }
            PlasmaWidgets.Label
            {
                id: tracklabel;
                width: page.width;
                text: "Title: " +title;
                visible:false
            }
            PlasmaWidgets.Label
            {
                id: artistlabel;
                width: page.width;
                text: "Artist: " +artist;
                visible:false
            }
            PlasmaWidgets.Label
            {
                id: albumlabel;
                width: page.width;
                text: "Album: " + album;
                visible:false
            }
            PlasmaWidgets.Slider
            {
                id: positionslider
                minimum: 0
                maximum: tracklength;
                //value: trackposition;
                nativeWidget.value : 0;
                width:page.width
                visible:hideelements.containsMouse||!hiding
                height:hideelements.containsMouse||!hiding ? 15:0
                orientation: Qt.Horizontal;
                nativeWidget.onSliderPressed:{
                    timerposition.start();
                }
                nativeWidget.onSliderReleased:{
                    timerposition.stop();
                    seek(value);
                }
                Component.onCompleted:
                {
                    console.debug(nativeWidget.tracking)
                }

            }}

        ButtonRow{
            id:viewbuttonrow
            height: hideelements.containsMouse||!hiding ? playlistbutton.height:0
            opacity: hideelements.containsMouse||!hiding ? 1 : 0
            Behavior on opacity {  PropertyAnimation {  easing.type: Easing.Linear;duration:200;}}
            Behavior on height { PropertyAnimation {} }
            width:page.width
            spacing : 0
            exclusive:false;
            Button{
                id:playlistbutton;
                iconSource: "view-media-playlist";
                width:page.width/5;
                onClicked:
                {
                    hideAllViews();
                    filepage.model = 0;
                    cleanFileStack();
                    playlist.visible=true;
                }
            }
            Button{
                id:artistbutton;
                iconSource: "view-media-artist";
                width:page.width/5;
                onClicked: {
                    hideAllViews();
                    requestArtists();
                    filepage.model = 0;
                    cleanFileStack();
                }
            }
            Button{
                id:albumbutton;
                iconSource: "media-optical-mixed-cd";
                width:parent.width/5;
                onClicked: {

                    artistname = "";
                    hideAllViews();
                    requestAlbums();
                    filepage.model = 0;
                    cleanFileStack();
                }
            }
            Button{
                id:filebutton;
                iconSource: "system-file-manager";
                width:page.width/5;
                onClicked: {
                    filepage.model = 0;
                    cleanFileStack();
                    requestFilesModel("/");
                }
            }
            Button{
                id:settingsbutton;
                iconSource: "preferences-system";
                width:page.width/5;
                onClicked: {
                    hideAllViews();
                    serversettingspage.visible=true;
                }
            }
        }
        Component.onCompleted:{
            console.debug("pagewidth:"+page.width+" controlbuttonrow.width:"+controlbuttonrow.width+":"+nextbutton.width);+
                                                                                                                          controlbuttonrow.forceActiveFocus();
            viewbuttonrow.forceActiveFocus();
        }

        ButtonRow{
            id: controlbuttonrow
            height: hideelements.containsMouse||!hiding ? prevbutton.height:0
            width:page.width
            spacing : 0
            opacity: hideelements.containsMouse||!hiding ? 1 : 0
            Behavior on opacity {  PropertyAnimation {  easing.type: Easing.Linear;duration:200;}}
            Behavior on height { PropertyAnimation {} }
            exclusive:false;
            Button{
                id:prevbutton;
                iconSource: "media-skip-backward";
                width:page.width/8;
                height:24
                onClicked: prev();
            }
            Button{
                id:nextbutton;
                height:24
                iconSource: "media-skip-forward";
                width:page.width/8;
                onClicked: next();
            }
            Button{
                id:stopbutton;
                height:24
                iconSource: "media-playback-stop";
                width:page.width/8;
                onClicked: stop();
            }
            Button{
                id:playbutton;
                height:24
                //iconSource: state==="playing" ? "media-playback-start" : "media-playback-pause"
                iconSource: "media-playback-start";

                width:page.width/8;
                onClicked: play();
            }
            Button{
                id:connectbutton;
                height:24
                width:page.width/8;
                iconSource: (connected ?  "network-connect" : "network-disconnect");
                onClicked:{
                    if(!connected) {
                        console.debug("request connect");
                        requestConnect();
                    }
                    else
                        requestDisconnect();
                }
            }
            Button{
                id:randombutton;
                height:24
                checkable:true
                checked:random
                width:page.width/8;
                iconSource: "media-playlist-shuffle";
                onClicked:{
                    setShuffle(!random);
                }
            }
            Button{
                id:repeatbutton;
                height:24
                checkable:true
                checked:repeat
                width:page.width/8;
                iconSource: "media-playlist-repeat";
                onClicked:{
                    setRepeat(!repeat);
                }
            }
            Button{
                id:volumebutton;
                height:24
                width:page.width/8;
                iconSource: "audio-volume-high";
                onClicked:{
                    if(volumeslider.visible)
                    {
                        volumeblendout.start();
                    }
                    else{
                        volumeslider.visible=true;
                        volumeblendin.start();

                    }
                }

                PlasmaWidgets.Slider
                {
                    id:volumeslider;
                    orientation: Qt.Vertical
                    visible:false

                    minimum: 0
                    maximum: 100;
                    //value: trackposition;
                    nativeWidget.value : 0;
                    height:170
                    anchors {horizontalCenter:volumebutton.horizontalCenter;bottom:volumebutton.top}
                    nativeWidget.onSliderPressed:{
                        updatevolumetimer.start();
                        if(hidevolumeslidertimer.running)
                        {
                            hidevolumeslidertimer.stop();
                        }
                    }
                    nativeWidget.onSliderReleased:{
                        updatevolumetimer.stop();
                        hidevolumeslidertimer.start();
                        setVolume(value);
                    }
                    onVisibleChanged: {
                        if(!visible)
                        {
                            hidevolumeslidertimer.stop();
                        }
                        else{
                            hidevolumeslidertimer.start();
                        }
                    }
                }
            }

            WheelArea{
                id:volwheel
                anchors.fill:volumebutton
                onVerticalWheel: {
                    if(delta>0)
                    {
                        console.debug("volume plus");
                        setVolume(volume+1);
                        volume = volume+1;
                        volumeslider.value=volume;
                    }
                    else{
                        console.debug("volume minus");
                        setVolume(volume-1);
                        volume = volume-1;
                        volumeslider.value=volume;
                    }
                }
                onHorizontalWheel: console.log("Horizontal Wheel: " + delta)
            }

        }
    }


    
    PropertyAnimation {id: volumeblendin; target: volumeslider; properties: "opacity"; to: "1"; duration: 200
        onStarted: {
            volumeslider.opacity=0;
            volumeslider.visible=true;
        }
    }
    PropertyAnimation {id: volumeblendout
        target: volumeslider
        properties: "opacity"
        to: "0"
        duration: 500
        onCompleted: {
            volumeslider.visible=false;
        }

    }
    
    Timer{
        id:updatevolumetimer
        repeat: true
        interval: 200
        onTriggered: {
            setVolume(volumeslider.value);
        }
    }

    Timer{
        id:hidevolumeslidertimer
        repeat: false
        interval: 2900
        onTriggered: {
            volumeblendout.start();
        }
    }
    
    Timer
    {
        id:timerposition
        repeat:true;
        interval:400
        onTriggered: {
            seek(positionslider.value);
        }
    }


    // Signals
    signal setHostname(string hostname);
    signal setPort(int port);
    signal setPassword(string password);
    signal setVolume(int volume);
    signal setCurrentArtist(string artist);
    signal requestConnect();
    signal requestDisconnect();
    //Variant in format [artistname,albumname]
    signal addAlbum(variant album);
    signal addArtist(string artist);
    signal addFiles(string files);
    signal addSong(string uri);
    signal addPlaylist(string name);
    signal playAlbum(variant album);
    signal playArtist(string artist);


    signal requestSavedPlaylists();
    signal requestSavedPlaylist(string name);
    signal requestAlbums();
    signal requestAlbum(variant album);
    signal requestArtists();
    signal requestArtistAlbums(string artist);
    signal requestFilesPage(string files);
    signal requestFilesModel(string files);
    signal requestCurrentPlaylist();
    signal popfilemodelstack();
    signal cleanFileStack();

    // Control signals
    signal play();
    signal next();
    signal prev();
    signal stop();
    signal seek(int position);
    signal setRepeat(bool rep);
    signal setShuffle(bool shfl);
    signal updateDB();

    //Playlist signals
    signal savePlaylist(string name);
    signal deletePlaylist();
    signal deleteSavedPlaylist(string name);
    signal playPlaylistTrack(int index);
    signal deletePlaylistTrack(int index);
    signal newProfile();
    signal changeProfile(variant profile);
    signal deleteProfile(int index);
    signal connectProfile(int index);
    //appends song to playlist
    signal playSong(string uri);
    //Clears playlist before adding
    signal playFiles(string uri);
    
    // Slots
    function slotConnected()
    {
        connected = true;
        playlist.model=0;
        hideAllViews();
        playlist.visible=true;
    }

    function slotDisconnected()
    {
        connected = false;
        playlist.model=0;
        hideAllViews();

        profilename = "";
        playing = false;
    }

    function busy()
    {
        busyindicator.visible=true;
	busyindicator.running=true;
    }

    function ready()
    {
        busyindicator.visible=false;
	busyindicator.running=false;
    }

    function updateCurrentPlaying(list)
    {
        title = list[0];
        album = list[1];
        artist = list[2];
        trackposition = list[3];
        tracklength = list[4];
        if(!timerposition.running)
        {
            positionslider.nativeWidget.setValue(trackposition);
        }
        volume = list[7];
        if(volume==0)
        {
            volumebutton.iconSource = "audio-volume-muted";
        }
        else if(volume>0&&volume<=30)
        {
            volumebutton.iconSource = "audio-volume-low";
        }
        else if(volume>30&&volume<=60)
        {
            volumebutton.iconSource = "audio-volume-medium";
        }
        else if(volume>60)
        {
            volumebutton.iconSource = "audio-volume-high";
        }
        state = list[6];
        playbutton.iconSource = (list[6]=="playing") ? "media-playback-pause" : "media-playback-start";
        if(!updatevolumetimer.running){
            volumeslider.value = list[7];
        }
        repeat = (list[8]=="0" ?  false:true);
        random = (list[9]=="0" ?  false:true);
        if(list[12]!=lastsongid)
        {
            playlist.songid=-1;
            playlist.songid = list[12];
            lastsongid = list[12];
        }
        randombutton.checked = random;
	repeatbutton.checked = repeat;
	
	// Update currentsongpage
	currentsongpage.title = title;
	currentsongpage.album = album;
	currentsongpage.artist = artist;
	//currentsongpage.lengthtextcurrent = trackposition;
	//currentsongpage.lengthtextcomplete = tracklength;
	currentsongpage.uri = list[11];
	currentsongpage.nr = (list[10]===0? "":list[10]);
	currentsongpage.bitrate = list[5]+"kbps";
	currentsongpage.audioproperties = list[13]+ "Hz "+ list[14] + "Bits " + list[15]+ "Channels";
    }

    function savedPlaylistClicked(modelData)
    {
        savedplaylisttracks.playlistname = modelData;
        requestSavedPlaylist(modelData);
    }

    function updateSavedPlaylistModel()
    {
        hideAllViews();
        savedplaylisttracks.model = savedPlaylistModel;
        savedplaylisttracks.visible = true;
    }

    function updateSavedPlaylistsModel()
    {
        hideAllViews();
        savedplaylists.model = savedPlaylistsModel;
        savedplaylists.visible = true;
    }

    function filesClicked(path)
    {
        requestFilesModel(path);
    }

    function updatePlaylist()
    {
        console.debug("Got new playlist:"+ playlistModel);
        playlist.model = playlistModel;
    }

    function updateAlbumsModel(){
        hideAllViews();
        console.debug("Got albums list");
        albums.model=0;
        albums.model = albumsModel;
        albums.artistname = artistname;
        albums.visible=true;
    }

    function updateArtistModel(){
        hideAllViews();
        console.debug("Got artists list");
        artists.model=0;
        artists.model = artistsModel;
        artists.visible=true;
    }

    function updateAlbumModel()
    {
        //         pageStack.push(Qt.resolvedUrl("AlbumSongPage.qml"),{artistname:artistname,albumname:albumname,listmodel:albumTracksModel});
        console.debug("got album songs");
        hideAllViews();
        albumsongs.model = 0;
        albumsongs.model = albumTracksModel;
        albumsongs.artistname = artistname;
        albumsongs.albumname = albumname;
        albumsongs.visible=true;
    }

    function albumTrackClicked(title,album,artist,lengthformatted,uri,year,tracknr,lastpage)
    {
        //         pageStack.push(Qt.resolvedUrl("SongPage.qml"),{title:title,album:album,artist:artist,filename:uri,lengthtext:lengthformatted,date:year,nr:tracknr});
        hideAllViews();
        songpage.title =  title;
        songpage.album = album;
        songpage.artist = artist;
        songpage.filename = uri;
        songpage.lengthtext = lengthformatted;
        songpage.date = year;
        songpage.nr = tracknr;
        songpage.lastpage = lastpage;
        songpage.visible = true;

    }


    function receiveFilesModel()
    {
    }

    function receiveFilesPage()
    {
        console.debug("lastpath:"+lastpath+" filesModel:"+filesModel);
        //         pageStack.push(Qt.resolvedUrl("FilesPage.qml"), {listmodel: filesModel,filepath :lastpath});
        hideAllViews();
        filepage.model = 0;
        filepage.model = filesModel;
        filepage.filepath = lastpath;
        filepage.visible = true;
    }

    function formatLength(length)
    {
        var temphours = Math.floor(length/3600);
        var min = 0;
        var sec = 0;
        var temp="";
        if(temphours>1)
        {
            min=(length-(3600*temphours))/60;
        }
        else{
            min=Math.floor(length/60);
        }
        sec = length-temphours*3600-min*60;
        if(temphours===0)
        {
            temp=((min<10?"0":"")+min)+":"+(sec<10?"0":"")+(sec);
        }
        else
        {
            temp=((temphours<10?"0":"")+temphours)+":"+((min<10?"0":"")+min)+":"+(sec<10?"0":"")+(sec);
        }
        return temp;
    }

    function albumClicked(artist,albumstring)
    {
        requestAlbum([artist,albumstring]);
        artistname = artist;
        this.albumname = albumstring;
        console.debug("Album:"+albumstring+":"+artist);
    }

    function artistalbumClicked(artist, album)
    {
        requestAlbum([artist,album]);
        artistname = artistname;
        albumname = album;
    }

    function parseClickedPlaylist(index)
    {
        playPlaylistTrack(index);
    }

    function artistClicked(item)
    {
        artistname = item;
        requestArtistAlbums(item);
    }
    
    function hideAllViews()
    {
        playlist.visible=false;
        artists.visible=false;
        albums.visible=false;
        albumsongs.visible=false;
        songpage.visible=false;
        filepage.visible=false;
        savedplaylists.visible=false;
        savedplaylisttracks.visible=false;
        serversettingspage.visible=false;
	currentsongpage.visible=false;
    }
}

