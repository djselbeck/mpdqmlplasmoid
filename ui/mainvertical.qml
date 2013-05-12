import QtQuick 1.1
import Qt 4.7
import org.kde.plasma.graphicswidgets 0.1 as PlasmaWidgets
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.graphicslayouts 4.7 as GraphicsLayouts
import MyTools 1.0
import org.kde.plasma.components 0.1

Item {
    id: page;
    property int minimumWidth: 16;
    property int minimumHeight: 16*8;
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
    WheelArea{
        id:volwheel
        anchors.fill:page
        onVerticalWheel: {
            if(delta>0)
            {
                setVolume(volume+1);
                volume = volume+1;
            }
            else{
                setVolume(volume-1);
                volume = volume-1;
            }
        }
    }
    Component.onCompleted:
    {
        var hiding = false;
    }

    ButtonColumn{
        id: controlbuttonrow
        width: parent.width
        exclusive:false;
	spacing : 0
        Button{
            id:prevbutton;
            iconSource: "media-skip-backward";
            width:parent.width
            height:24;
            onClicked: prev();
        }
        Button{
            id:nextbutton;
            width:parent.width
            height:24;
            iconSource: "media-skip-forward";
            onClicked: next();
        }
        Button{
            id:stopbutton;
            width:parent.width
            height:24;
            iconSource: "media-playback-stop";
            onClicked: stop();
        }
        Button{
            id:playbutton;
            width:parent.width
            height:24;
            iconSource: "media-playback-start";
            onClicked: play();
        }
        Button{
            id:connectbutton;
            width:parent.width
            height:24;
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
            width:parent.width
            height:24;
            checkable:true
            checked:random
            iconSource: "media-playlist-shuffle";
            onClicked:{
                setShuffle(!random);
            }
        }
        Button{
            id:repeatbutton;
            width:parent.width
            height:24;
            checkable:true
            checked:repeat
            iconSource: "media-playlist-repeat";
            onClicked:{
                setRepeat(!repeat);
            }
        }
        Button{
            id:volumebutton;
            width:parent.width
            height:24;
            iconSource: "audio-volume-high";
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
    }

    function slotDisconnected()
    {
        connected = false;
        playing = false;
    }

    function busy()
    {
    }

    function ready()
    {
    }

    function updateCurrentPlaying(list)
    {
        title = list[0];
        album = list[1];
        artist = list[2];
        trackposition = list[3];
        tracklength = list[4];

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
        repeat = (list[8]=="0" ?  false:true);
        random = (list[9]=="0" ?  false:true);
        if(list[12]!=lastsongid)
        {

            lastsongid = list[12];
        }
        randombutton.checked = random;
	repeatbutton.checked = repeat;
    }

    function savedPlaylistClicked(modelData)
    {
    }

    function updateSavedPlaylistModel()
    {
    }

    function updateSavedPlaylistsModel()
    {
    }

    function filesClicked(path)
    {
        requestFilesModel(path);
    }

    function updatePlaylist()
    {
        playlist.model = playlistModel;
    }

    function updateAlbumsModel(){
    }

    function updateArtistModel(){
    }

    function updateAlbumModel()
    {
    }

    function albumTrackClicked(title,album,artist,lengthformatted,uri,year,tracknr,lastpage)
    {
    }


    function receiveFilesModel()
    {
    }

    function receiveFilesPage()
    {
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
    }

    function artistalbumClicked(artist, album)
    {
    }

}

