/*
    <one line to give the program's name and a brief idea of what it does.>
    Copyright (C) 2011  Hendrik Borghorst <hendrikborghorst@googlemail.com>

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/


#include "controller.h"

Controller::Controller(QDeclarativeContext *con,QDeclarativeItem *rootobj)
{
    netaccess = new NetworkAccess(0);
    netaccess->setUpdateInterval(1000);
    networkthread = new QThreadEx(0);
    netaccess->moveToThread(networkthread);
    networkthread->start();
    m_rootcontext = con;
    m_rootobject = rootobj;
    if (!m_rootobject)
        qDebug("NO ROOT OBJECT");
    playlist=0;
    artistmodelold = 0;
    albumsmodelold = 0;

    reconnecttimer = new QTimer();
    reconnecttimer->setInterval(3000);
    reconnecttimer->setSingleShot(false);
    filemodels = new QStack<QList<QObject*>*>();
    filepathstack = new QStack<QString>();
    connectSignals();

}

Controller::~Controller()
{

}

void Controller::updatePlaylistModel(QList<QObject*>* list)
{
    CommonDebug("PLAYLIST  UPDATE REQUIRED\n");
    if (playlist==0) {
        currentsongid=0;
    } else {
        QList<MpdTrack*>::iterator i;
        for (i = playlist->begin();i!=playlist->end();i++) {
            delete(*i);
        }
        delete(playlist);
        // viewer->rootContext()->setContextProperty("playlistModel",QVariant::fromValue(0));
        playlist=0;
    }
    currentsongid = -1;
    playlist = (QList<MpdTrack*>*)(list);
    m_rootcontext->setContextProperty("playlistModel",QVariant::fromValue(*list));
    CommonDebug("Playlist length:"+QString::number(playlist->length())+"\n");
    emit playlistUpdated();
}

void Controller::updateFilesModel(QList<QObject*>* list)
{
    CommonDebug("FILES UPDATE REQUIRED");
    if (list->length()>0)
    {
        m_rootcontext->setContextProperty("filesModel",QVariant::fromValue(*list));
        filemodels->push(list);
        emit filesModelReady();
    }

}

void Controller::updateSavedPlaylistsModel(QStringList *list)
{
    m_rootcontext->setContextProperty("savedPlaylistsModel",QVariant::fromValue(*list));
    emit savedPlaylistsReady();

}

void Controller::updateSavedPlaylistModel(QList<QObject*>* list)
{
    m_rootcontext->setContextProperty("savedPlaylistModel",QVariant::fromValue(*list));
    emit savedPlaylistReady();
}

void Controller::updateArtistsModel(QList<QObject*>* list)
{
    CommonDebug("ARTISTS UPDATE REQUIRED");
    if (artistmodelold!=0)
    {
        delete(artistmodelold);
    }
    //ArtistModel *model = new ArtistModel((QList<MpdTrack*>*)list,this);
    artistlist = (QList<MpdArtist*>*)list;
    ArtistModel *model = new ArtistModel((QList<MpdArtist*>*)list);
    artistmodelold = model;
    m_rootcontext->setContextProperty("artistsModel",model);
    emit artistsReady();
}

//void Controller::updateArtistAlbumsModel(QList<QObject*>* list)
//{
//    CommonDebug("ARTIST ALBUMS UPDATE REQUIRED");
//    viewer->rootContext()->setContextProperty("albumsModel",QVariant::fromValue(*list));
//    emit artistAlbumsReady();
//}

void Controller::updateAlbumsModel(QList<QObject*>* list)
{
    CommonDebug("ALBUMS UPDATE REQUIRED");
    if (albumsmodelold!=0)
    {
        delete(albumsmodelold);
    }
    AlbumModel *model = new AlbumModel((QList<MpdAlbum*>*)list);
    albumsmodelold = model;

    m_rootcontext->setContextProperty("albumsModel",model);
    emit albumsReady();
}

void Controller::updateAlbumTracksModel(QList<QObject*>* list)
{
    CommonDebug("ALBUM TRACKS UPDATE REQUIRED");
    m_rootcontext->setContextProperty("albumTracksModel",QVariant::fromValue(*list));
    emit albumTracksReady();
}


void Controller::connectSignals()
{
    qRegisterMetaType<status_struct>("status_struct");
    qRegisterMetaType<QList<MpdTrack*>*>("QList<MpdTrack*>*");
    qRegisterMetaType<QList<MpdAlbum*>*>("QList<MpdAlbum*>*");
    qRegisterMetaType<QList<MpdArtist*>*>("QList<MpdArtist*>*");
    qRegisterMetaType<QList<MpdFileEntry*>*>("QList<MpdFileEntry*>*");
    //Reconnection timer
    connect(reconnecttimer,SIGNAL(timeout()),this,SLOT(reconnectTimed()));

    connect(this,SIGNAL(connectionParametersChanged(QStringList)),netaccess,SLOT(setConnectParameters(QStringList)));
    connect(m_rootobject,SIGNAL(requestConnect()),netaccess,SLOT(connectToHost()));
    connect(m_rootobject,SIGNAL(requestDisconnect()),netaccess,SLOT(disconnect()));
    connect(netaccess,SIGNAL(statusUpdate(status_struct)),this,SLOT(updateStatus(status_struct)));
    connect(this,SIGNAL(statusReady(QVariant)),m_rootobject,SLOT(updateCurrentPlaying(QVariant)));
    connect(m_rootobject,SIGNAL(stop()),netaccess,SLOT(stop()));
    connect(m_rootobject,SIGNAL(play()),netaccess,SLOT(pause()));
    connect(m_rootobject,SIGNAL(next()),netaccess,SLOT(next()));
    connect(m_rootobject,SIGNAL(prev()),netaccess,SLOT(previous()));
    connect(m_rootobject,SIGNAL(seek(int)),netaccess,SLOT(seek(int)));
    connect(netaccess,SIGNAL(currentPlayListReady(QList<QObject*>*)),this,SLOT(updatePlaylistModel(QList<QObject*>*)));
    connect(this,SIGNAL(playlistUpdated()),m_rootobject,SLOT(updatePlaylist()));
    connect(m_rootobject,SIGNAL(playPlaylistTrack(int)),netaccess,SLOT(playTrackByNumber(int)));
    connect(m_rootobject,SIGNAL(requestArtists()),netaccess,SLOT(getArtists()));
    connect(netaccess,SIGNAL(artistsReady(QList<QObject*>*)),this,SLOT(updateArtistsModel(QList<QObject*>*)));
    connect(this,SIGNAL(artistsReady()),m_rootobject,SLOT(updateArtistModel()));
    //Albums
    connect(m_rootobject,SIGNAL(requestAlbums()),netaccess,SLOT(getAlbums()));
    connect(netaccess,SIGNAL(albumsReady(QList<QObject*>*)),this,SLOT(updateAlbumsModel(QList<QObject*>*)));
    connect(this,SIGNAL(albumsReady()),m_rootobject,SLOT(updateAlbumsModel()));
    //ArtistAlbums
    connect(m_rootobject,SIGNAL(requestArtistAlbums(QString)),netaccess,SLOT(getArtistsAlbums(QString)));
    connect(netaccess,SIGNAL(artistAlbumsReady(QList<QObject*>*)),this,SLOT(updateAlbumsModel(QList<QObject*>*)));
    connect(this,SIGNAL(requestDisconnect()),netaccess,SLOT(disconnect()));
    connect(this,SIGNAL(requestConnect()),netaccess,SLOT(connectToHost()));
    connect(netaccess,SIGNAL(disconnected()),this,SLOT(disconnected()));
    connect(netaccess,SIGNAL(connectionestablished()),this,SLOT(connected()));
    //Albumsongs
    connect(m_rootobject,SIGNAL(requestAlbum(QVariant)),netaccess,SLOT(getAlbumTracks(QVariant)));
    connect(netaccess,SIGNAL(albumTracksReady(QList<QObject*>*)),this,SLOT(updateAlbumTracksModel(QList<QObject*>*)));
    connect(this,SIGNAL(albumTracksReady()),m_rootobject,SLOT(updateAlbumModel()));

    connect(m_rootobject,SIGNAL(addArtist(QString)),netaccess,SLOT(addArtist(QString)));
    connect(m_rootobject,SIGNAL(addAlbum(QVariant)),netaccess,SLOT(addArtistAlbumToPlaylist(QVariant)));
    connect(m_rootobject,SIGNAL(playAlbum(QVariant)),netaccess,SLOT(playArtistAlbum(QVariant)));
    connect(m_rootobject,SIGNAL(addSong(QString)),netaccess,SLOT(addTrackToPlaylist(QString)));
    connect(m_rootobject,SIGNAL(playSong(QString)),netaccess,SLOT(playTrack(QString)));
    //Files Page
    connect(m_rootobject,SIGNAL(popfilemodelstack()),this,SLOT(fileStackPop()));
    connect(m_rootobject,SIGNAL(requestFilesModel(QString)),netaccess,SLOT(getDirectory(QString)));
    connect(m_rootobject,SIGNAL(requestFilesModel(QString)),this,SLOT(requestPath(QString)));
    connect(netaccess,SIGNAL(filesReady(QList<QObject*>*)),this,SLOT(updateFilesModel(QList<QObject*>*)));
    connect(this,SIGNAL(filesModelReady()),m_rootobject,SLOT(receiveFilesPage()));
    connect(m_rootobject,SIGNAL(cleanFileStack()),this,SLOT(cleanFileStack()));
    connect(m_rootobject,SIGNAL(playFiles(QString)),netaccess,SLOT(playFiles(QString)));
    connect(m_rootobject,SIGNAL(addFiles(QString)),netaccess,SLOT(addTrackToPlaylist(QString)));
    connect(m_rootobject,SIGNAL(setVolume(int)),netaccess,SLOT(setVolume(int)));

    connect(m_rootobject,SIGNAL(deletePlaylist()),netaccess,SLOT(clearPlaylist()));

    connect(netaccess,SIGNAL(connectionestablished()),m_rootobject,SLOT(slotConnected()));
    connect(netaccess,SIGNAL(disconnected()),m_rootobject,SLOT(slotDisconnected()));
    connect(m_rootobject,SIGNAL(savePlaylist(QString)),netaccess,SLOT(savePlaylist(QString)));
    connect(m_rootobject,SIGNAL(requestSavedPlaylists()),netaccess,SLOT(getSavedPlaylists()));
    connect(netaccess,SIGNAL(savedPlaylistsReady(QStringList*)),this,SLOT(updateSavedPlaylistsModel(QStringList*)));
    connect(this,SIGNAL(savedPlaylistsReady()),m_rootobject,SLOT(updateSavedPlaylistsModel()));

    connect(m_rootobject,SIGNAL(requestSavedPlaylist(QString)),netaccess,SLOT(getPlaylistTracks(QString)));
    connect(netaccess,SIGNAL(savedplaylistTracksReady(QList<QObject*>*)),this,SLOT(updateSavedPlaylistModel(QList<QObject*>*)));
    connect(this,SIGNAL(savedPlaylistReady()),m_rootobject,SLOT(updateSavedPlaylistModel()));

    connect(m_rootobject,SIGNAL(addPlaylist(QString)),netaccess,SLOT(addPlaylist(QString)));
    connect(m_rootobject,SIGNAL(deleteSavedPlaylist(QString)),netaccess,SLOT(deletePlaylist(QString)));
    connect(m_rootobject,SIGNAL(updateDB()),netaccess,SLOT(updateDB()));

    connect(m_rootobject,SIGNAL(setShuffle(bool)),netaccess,SLOT(setRandom(bool)));
    connect(m_rootobject,SIGNAL(setRepeat(bool)),netaccess,SLOT(setRepeat(bool)));
    
    connect(netaccess,SIGNAL(connectionestablished()),this,SIGNAL(connectedToServer()));
    connect(netaccess,SIGNAL(disconnected()),this,SIGNAL(disconnectedFromServer()));
    connect(netaccess,SIGNAL(statusUpdate(status_struct)),this,SIGNAL(statusReady(status_struct)));
}



void Controller::setConnectionParameters(QString hostname, int port, QString password)
{
    QStringList parameters;
    parameters.append(hostname);
    parameters.append(QString::number(port));
    parameters.append(password);
    emit connectionParametersChanged(parameters);
}

void Controller::updateStatus(status_struct status)
{
    QStringList strings;

    if (currentsongid != status.id)
    {
        if (playlist!=0&&playlist->length()>status.id&&playlist->length()>currentsongid
                &&status.id>=0&&currentsongid>=0) {
            CommonDebug("1Changed playlist "+QString::number(status.id)+":"+QString::number(currentsongid));
            playlist->at(currentsongid)->setPlaying(false);
            playlist->at(status.id)->setPlaying(true);
            CommonDebug("2Changed playlist");

        }
        if (currentsongid==-1&&(playlist!=0&&playlist->length()>status.id&&playlist->length()>currentsongid
                                &&status.id>=0))
        {
            if (playlist)
                playlist->at(status.id)->setPlaying(true);
        }
    }
    if (lastplaybackstate!=status.playing)
    {
        CommonDebug("Playback state changed");
        if (status.playing==NetworkAccess::STOP&&playlist!=0&&currentsongid>=0&&currentsongid<playlist->length())
        {
            if (playlist)
                playlist->at(currentsongid)->setPlaying(false);
        }
    }
    lastplaybackstate = status.playing;
    currentsongid = status.id;
    if (playlist==0)
        currentsongid = -1;
    strings.append(status.title);
    strings.append(status.album);
    strings.append(status.artist);
    strings.append(QString::number(status.currentpositiontime));
    strings.append(QString::number(status.length));
    strings.append(QString::number(status.bitrate));
    switch (status.playing) {
    case NetworkAccess::PLAYING:
    {
        strings.append("playing");
        break;
    }
    case NetworkAccess::PAUSE:
    {
        strings.append("pause");
        break;
    }
    case NetworkAccess::STOP:
    {
        strings.append("stop");
        break;
    }
    default:
        strings.append("stop");
    }
    strings.append(QString::number(status.volume));
    strings.append(QString::number(status.repeat));
    strings.append(QString::number(status.shuffle));
    strings.append(QString::number(status.tracknr));
    strings.append(status.fileuri);
    strings.append(QString::number(status.id));
    volume = status.volume;

    emit statusReady(strings);
}

void Controller::disconnect()
{
    emit requestDisconnect();
}

void Controller::setReconnect(bool autoconnect)
{
    this->autoconnect = autoconnect;
    if (!reconnecttimer->isActive()&&autoconnect)
    {
        reconnecttimer->start();
    }
}

void Controller::disconnected()
{
    if (!reconnecttimer->isActive()&&autoconnect)
    {
        reconnecttimer->start();
    }
    if(playlist!=0)
    {
      delete(playlist);
      playlist = 0;
    }
}
void Controller::connected()
{
    if (reconnecttimer->isActive())
    {
        reconnecttimer->stop();
    }
}


void Controller::reconnectTimed()
{
  qDebug() << "reconnect requested";
    emit requestConnect();
}

void Controller::requestPath(QString path)
{
    qDebug()<< ("Path: "+ path + " added to stack");
    filepathstack->push(path);
    m_rootcontext->setContextProperty("lastpath",QVariant::fromValue(QString(filepathstack->top())));
    qDebug()<< ("Property lastPath: "+ filepathstack->top() + " added to stack");
}


void Controller::fileStackPop()
{
    QString path;
    QList<MpdFileEntry*> *list=0;
    if (!filemodels->isEmpty()) {
        CommonDebug("file model stack not empty");
        list = (QList<MpdFileEntry*>*)filemodels->pop();
    }
    if (!filepathstack->isEmpty()) {
        CommonDebug("path stack not empty");
        path = filepathstack->pop();
    }
    CommonDebug("Lastpath:" + path);
    for (int i=0;i<list->length();i++)
    {
        delete(list->at(i));
    }
    delete(list);
    if (!filemodels->empty()&&!filepathstack->empty())
    {
        CommonDebug("Currentpath:" + filepathstack->top());
        m_rootcontext->setContextProperty("filesModel",QVariant::fromValue(*(filemodels->top())));
        m_rootcontext->setContextProperty("lastpath",QVariant::fromValue(QString(filepathstack->top())));
        emit filesModelReady();
    }
}

void Controller::cleanFileStack()
{
    QList<MpdFileEntry*> *list;
    while (!filemodels->empty())
    {
        CommonDebug("Cleaning file stack");
        list = (QList<MpdFileEntry*>*)filemodels->pop();
        for (int i=0;i<list->length();i++)
        {
            delete(list->at(i));
        }
        delete(list);
    }
    while (!filepathstack->empty())
    {
        filepathstack->pop();
    }
}

void Controller::setAutoHide(bool hide)
{
    qDebug("autohide set to"+QString::number(hide).toUtf8());
    autohide = hide;
    m_rootcontext->setContextProperty("hiding",QVariant(autohide));

}

void Controller::changeQMLFile(QDeclarativeContext* con, QDeclarativeItem* rootobj)
{
    //Disconnect old signals/slots
    //delete(m_rootobject);
    bool timerrunning = reconnecttimer->isActive();
    //reconnecttimer->stop();
    //emit requestDisconnect();
    m_rootcontext = con;
    m_rootobject = rootobj;
    if (!m_rootobject)
        qDebug("NO ROOT OBJECT");
   

    connect(m_rootobject,SIGNAL(requestConnect()),netaccess,SLOT(connectToHost()));
    connect(m_rootobject,SIGNAL(requestDisconnect()),netaccess,SLOT(disconnect()));
    connect(this,SIGNAL(statusReady(QVariant)),m_rootobject,SLOT(updateCurrentPlaying(QVariant)));
    connect(m_rootobject,SIGNAL(stop()),netaccess,SLOT(stop()));
    connect(m_rootobject,SIGNAL(play()),netaccess,SLOT(pause()));
    connect(m_rootobject,SIGNAL(next()),netaccess,SLOT(next()));
    connect(m_rootobject,SIGNAL(prev()),netaccess,SLOT(previous()));
    connect(m_rootobject,SIGNAL(seek(int)),netaccess,SLOT(seek(int)));
    connect(this,SIGNAL(playlistUpdated()),m_rootobject,SLOT(updatePlaylist()));
    connect(m_rootobject,SIGNAL(playPlaylistTrack(int)),netaccess,SLOT(playTrackByNumber(int)));
    connect(m_rootobject,SIGNAL(requestArtists()),netaccess,SLOT(getArtists()));
    connect(this,SIGNAL(artistsReady()),m_rootobject,SLOT(updateArtistModel()));
    //Albums
    connect(m_rootobject,SIGNAL(requestAlbums()),netaccess,SLOT(getAlbums()));
    connect(this,SIGNAL(albumsReady()),m_rootobject,SLOT(updateAlbumsModel()));
    //ArtistAlbums
    connect(m_rootobject,SIGNAL(requestArtistAlbums(QString)),netaccess,SLOT(getArtistsAlbums(QString)));
    //Albumsongs
    connect(m_rootobject,SIGNAL(requestAlbum(QVariant)),netaccess,SLOT(getAlbumTracks(QVariant)));
    connect(this,SIGNAL(albumTracksReady()),m_rootobject,SLOT(updateAlbumModel()));

    connect(m_rootobject,SIGNAL(addArtist(QString)),netaccess,SLOT(addArtist(QString)));
    connect(m_rootobject,SIGNAL(addAlbum(QVariant)),netaccess,SLOT(addArtistAlbumToPlaylist(QVariant)));
    connect(m_rootobject,SIGNAL(playAlbum(QVariant)),netaccess,SLOT(playArtistAlbum(QVariant)));
    connect(m_rootobject,SIGNAL(addSong(QString)),netaccess,SLOT(addTrackToPlaylist(QString)));
    connect(m_rootobject,SIGNAL(playSong(QString)),netaccess,SLOT(playTrack(QString)));
    //Files Page
    connect(m_rootobject,SIGNAL(popfilemodelstack()),this,SLOT(fileStackPop()));
    connect(m_rootobject,SIGNAL(requestFilesModel(QString)),netaccess,SLOT(getDirectory(QString)));
    connect(m_rootobject,SIGNAL(requestFilesModel(QString)),this,SLOT(requestPath(QString)));
    connect(this,SIGNAL(filesModelReady()),m_rootobject,SLOT(receiveFilesPage()));
    connect(m_rootobject,SIGNAL(cleanFileStack()),this,SLOT(cleanFileStack()));
    connect(m_rootobject,SIGNAL(playFiles(QString)),netaccess,SLOT(playFiles(QString)));
    connect(m_rootobject,SIGNAL(addFiles(QString)),netaccess,SLOT(addTrackToPlaylist(QString)));
    connect(m_rootobject,SIGNAL(setVolume(int)),netaccess,SLOT(setVolume(int)));

    connect(m_rootobject,SIGNAL(deletePlaylist()),netaccess,SLOT(clearPlaylist()));

    connect(netaccess,SIGNAL(connectionestablished()),m_rootobject,SLOT(slotConnected()));
    connect(netaccess,SIGNAL(disconnected()),m_rootobject,SLOT(slotDisconnected()));
    connect(m_rootobject,SIGNAL(savePlaylist(QString)),netaccess,SLOT(savePlaylist(QString)));
    connect(m_rootobject,SIGNAL(requestSavedPlaylists()),netaccess,SLOT(getSavedPlaylists()));
    connect(this,SIGNAL(savedPlaylistsReady()),m_rootobject,SLOT(updateSavedPlaylistsModel()));

    connect(m_rootobject,SIGNAL(requestSavedPlaylist(QString)),netaccess,SLOT(getPlaylistTracks(QString)));
    connect(this,SIGNAL(savedPlaylistReady()),m_rootobject,SLOT(updateSavedPlaylistModel()));

    connect(m_rootobject,SIGNAL(addPlaylist(QString)),netaccess,SLOT(addPlaylist(QString)));
    connect(m_rootobject,SIGNAL(deleteSavedPlaylist(QString)),netaccess,SLOT(deletePlaylist(QString)));
    connect(m_rootobject,SIGNAL(updateDB()),netaccess,SLOT(updateDB()));

    connect(m_rootobject,SIGNAL(setShuffle(bool)),netaccess,SLOT(setRandom(bool)));
    connect(m_rootobject,SIGNAL(setRepeat(bool)),netaccess,SLOT(setRepeat(bool)));
    
    connect(netaccess,SIGNAL(busy()),m_rootobject,SLOT(busy()));
    connect(netaccess,SIGNAL(ready()),m_rootobject,SLOT(ready()));
    if (timerrunning)
        reconnecttimer->start();

}

