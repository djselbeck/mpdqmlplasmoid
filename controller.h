/*
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


#ifndef CONTROLLER_H
#define CONTROLLER_H
#include "networkaccess.h"
#include "qthreadex.h"

#include <QDeclarativeContext>
#include <QDeclarativeItem>
#include <QList>
#include <QTimer>
#include <QStack>

// Own includes
#include "mpdtrack.h"
#include "albummodel.h"
#include "artistmodel.h"

class Controller : public QObject
{
    Q_OBJECT
public:
    Controller(QDeclarativeContext *con,QDeclarativeItem *rootobj);
    virtual ~Controller();
    void setConnectionParameters(QString hostname,int port,QString password);
    void setReconnect(bool);
    void disconnect();
    void setAutoHide(bool hide);
    bool getAutoHide(){return autohide;}
    void changeQMLFile(QDeclarativeContext *con,QDeclarativeItem *rootobj);

private:
    void connectSignals();
    NetworkAccess *netaccess;
    QThreadEx *networkthread;
    QDeclarativeContext *m_rootcontext;
    QDeclarativeItem *m_rootobject;
    int currentsongid;
    int lastplaybackstate;
    int volume;
    QList<MpdAlbum*> *albumlist;
    QList<MpdArtist*> *artistlist;
    ArtistModel *artistmodelold;
    AlbumModel *albumsmodelold;
    QList<MpdTrack*> *trackmodel;
    QList<MpdTrack*> *playlist;
    QStack<QList<QObject*>*> *filemodels;
    QStack<QString> *filepathstack;
    QTimer *reconnecttimer;
    //Connectionparameters
    QString hostname,password;
    int port;
    bool autoconnect;
    bool autohide;


signals:
    void connectionParametersChanged(QStringList parameters);
    void statusReady(QVariant);
    void albumsReady();
    void artistsReady();
    void albumTracksReady();
    void artistAlbumsReady();
    void savedPlaylistsReady();
    void savedPlaylistReady();
    void serverProfilesUpdated();
    void playlistUpdated();
    void filesModelReady();
    void requestConnect();
    void requestDisconnect();
    void statusReady(status_struct);
    void connectedToServer();
    void disconnectedFromServer();

public slots:
    void updateStatus(status_struct status);

private slots:
    void updateAlbumsModel(QList<QObject*>* list);
    void updateArtistsModel(QList<QObject*>* list);
//    void updateArtistAlbumsModel(QList<QObject*>* list);
    void updatePlaylistModel(QList<QObject*>* list);
    void updateFilesModel(QList<QObject*>* list);
    void updateAlbumTracksModel(QList<QObject*>* list);
    void updateSavedPlaylistsModel(QStringList*);
    void updateSavedPlaylistModel(QList<QObject*>* list);
    void disconnected();
    void connected();
    void reconnectTimed();
    void requestPath(QString);
    void fileStackPop();
    void cleanFileStack();


};

#endif // CONTROLLER_H
