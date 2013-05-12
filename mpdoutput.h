#ifndef MPDOUTPUT_H
#define MPDOUTPUT_H

#include <QObject>
#include <QDebug>

class MPDOutput : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool outputenabled READ getEnabled WRITE setEnabled NOTIFY enabledChanged)
    Q_PROPERTY(QString outputname READ getName )
    Q_PROPERTY(int id READ getID )


public:
    MPDOutput(QString name, bool enab, int nr,QObject *parent = 0){
        outputname = name;
        enabled = enab;
        id = nr;
        qDebug() << "output with " << name << ":"<< id << ":"<<enabled << "created";
    }

    QString getName(){return outputname;}
    bool getEnabled(){ return enabled;}
    int getID(){return id;}
    void setEnabled(bool value){enabled = value;emit enabledChanged();}

    
signals:
    void enabledChanged();
    
public slots:

private:
    QString outputname;
    bool enabled;
    int id;

    
};

#endif // MPDOUTPUT_H
