#ifndef NETWORKACCESS_H
#define NETWORKACCESS_H

#include <QObject>
#include <QtNetwork>
#include "mpdalbum.h"
#include "mpdartist.h"
#include "mpdtrack.h"
#include "mpdfileentry.h"
#include "mpdoutput.h"
#include "common.h"
#include "commondebug.h"
#define READYREAD 15000

class MpdAlbum;
class MpdArtist;
class MpdTrack;
class MpdFileEntry;

struct status_struct {
    quint32 playlistversion;
    qint32 id;
    quint16 bitrate;
    int tracknr;
    int albumtrackcount;
    quint8 percent;
    quint8 volume;
    QString info;
    QString title;
    QString album;
    QString artist;
    QString fileuri;
    quint8 playing;
    bool repeat;
    bool shuffle;
    quint32 length;
    quint32 currentpositiontime;
    quint32 playlistlength;
    quint16 samplerate;
    quint8 channelcount;
    quint8 bitdepth;
};


class NetworkAccess : public QThread
{
    Q_OBJECT

public:
    enum State {PAUSE,PLAYING,STOP};
    explicit NetworkAccess(QObject *parent = 0);
    Q_INVOKABLE bool connectToHost(QString hostname, quint16 port,QString password);




    bool authenticate(QString passwort);
    void suspendUpdates();
    void resumeUpdates();
    void setUpdateInterval(quint16 ms);
    Q_INVOKABLE bool connected();
    void seekPosition(int id,int pos);
    status_struct getStatus();
    void setConnectParameters(QString hostname,int port, QString password);



signals:
  /** Gets send when connection is successfully established */
    void connectionestablished();
    /** Gets send when connection is successfully disconnected */
    void disconnected();
    /** Gets send when status was updated
     Contains all information of current track and server status
     */
    void statusUpdate(status_struct status);
    /** Gets send when an connection error occured */
    void connectionError(QString);
    /** Gets send when an updated playlist is ready
     The current visible playlist SHOULD be replaced by this one */
    void currentPlayListReady(QList<QObject*>*);
    /** Gets send when an artist list was requested and is now ready */
    void artistsReady(QList<QObject*>*);
    /** Gets send when an album list was requested and is now ready */
    void albumsReady(QList<QObject*>*);
    /** Gets send when an file list was requested and is now ready */
    void filesReady(QList<QObject*>*);
    /** Gets send when an artistAlbums list was requested and is now ready */
    void artistAlbumsReady(QList<QObject*>*);
    /** Gets send when an albumTrack list was requested and is now ready */
    void albumTracksReady(QList<QObject*>*);
    /** Gets send when an saveplaylistS list was requested and is now ready */
    void savedPlaylistsReady(QStringList*);
    /** Gets send when an saved Playlist was requested and is now ready */
    void savedplaylistTracksReady(QList<QObject*>*);
    /** Gets send when an output list was requested and is now ready */
    void outputsReady(QList<QObject*>*);
    /** Gets send when an searched tracks list was requested and is now ready */
    void searchedTracksReady(QList<QObject*>*);

    /** Deprecated */
    void startupdateplaylist();
    /** Deprecated */
    void finishupdateplaylist();
    /** Marks that the Networkstack is busy with an MPD request */
    void busy();
    /** Marks that the Networkstack is finished with an MPD request */
    void ready();
    /** Marks that the Networkstack is ready to get destroyed */
    void requestExit();
public slots:
    /** Adds an Track with an URI (ex. "file://") to current playlist */
    void addTrackToPlaylist(QString fileuri);
    /** Adds an album with an album to current playlist */
    void addAlbumToPlaylist(QString album);
    /** Adds an album with an album to current playlist and start playing */
    void playAlbum(QString album);
    /** Adds an album with an album and artist to current playlist */
    void addArtistAlbumToPlaylist(QString artist,QString album);
    /** Adds an album with an to current playlist Variant:QStringlist[artist,album] */
    void addArtistAlbumToPlaylist(QVariant albuminfo);
    /** Adds an album with an album and artist to current playlist and start playing*/
    void playArtistAlbum(QString artist, QString album);
    /** Adds an album with an to current playlist Variant:QStringlist[artist,album] and start playing*/
    void playArtistAlbum(QVariant albuminfo);
    /** Adds all albums from "artist" to playlist */
    void addArtist(QString artist);
    /** Adds all albums from "artist" to playlist and start playing*/
    void playArtist(QString artist);
    void playFiles(QString fileuri);
    void playTrack(QString fileuri);
    void playTrackByNumber(int nr);
    void deleteTrackByNumer(int nr);
    void socketConnected();
    void pause();
    void next();
    void previous();
    void stop();
    void updateDB();
    void clearPlaylist();
    void setVolume(int volume);
    void setRandom(bool);
    void setRepeat(bool);
    void disconnect();
    void connectToHost();
    quint32 getPlayListVersion();
    void getAlbums();
    void getArtists();
    void getTracks();
    void getArtistsAlbums(QString artist);
    void getAlbumTracks(QString album);
    void getAlbumTracks(QString album, QString cartist);
    //Variant [Artist,Album]
    void getAlbumTracks(QVariant albuminfo);
    void getCurrentPlaylistTracks();
    void getPlaylistTracks(QString name);
    void getDirectory(QString path);
    void getSavedPlaylists();
    void seek(int pos);
    void savePlaylist(QString name);
    void addPlaylist(QString name);
    void deletePlaylist(QString name);
    void setUpdateInterval(int ms);
    void exitRequest();
    void enableOutput(int nr);
    void disableOutput(int nr);
    void getOutputs();
    void searchTracks(QVariant request);

    void setConnectParameters(QStringList parameters);


protected slots:
    void connectedtoServer();
    void disconnectedfromServer();
    void updateStatusInternal();
    void errorHandle();

protected:
//   void run();


private:

    QString hostname;
    quint16 port;
    QString password;
    QTcpSocket* tcpsocket;
    QString mpdversion;
    QTimer *statusupdater;
    quint16 updateinterval;
    quint32 mPlaylistversion;
    QList<MpdTrack*>* parseMPDTracks(QString cartist);
    QList<MpdTrack*>* getAlbumTracks_prv(QString album);
    QList<MpdTrack*>* getAlbumTracks_prv(QString album, QString cartist);
    QList<MpdAlbum*>* getArtistsAlbums_prv(QString artist);
};

#endif // NETWORKACCESS_H
