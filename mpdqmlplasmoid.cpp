/***************************************************************************
 *   Copyright (C) %{CURRENT_YEAR} by %{AUTHOR} <%{EMAIL}>                            *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA .        *
 ***************************************************************************/

#include "mpdqmlplasmoid.h"
//Qt
#include <QtDeclarative>
#include <QtDeclarative/qdeclarative.h>
#include <QtDeclarative/QDeclarativeEngine>
#include <QtDeclarative/QDeclarativeContext>
#include <QtDeclarative/QDeclarativeItem>
#include <QtGui/QGraphicsLinearLayout>
#include <QStandardItemModel>
#include <QSizeF>

//KDE
#include <KDebug>
#include <KStandardDirs>
#include <kdebug.h>

//Plasma
#include <Plasma/Containment>
#include <Plasma/DeclarativeWidget>
#include <Plasma/Package>
#include <Plasma/ToolTipContent>
#include <Plasma/ToolTipManager>

#include "wheelarea.h"

mpdqmlplasmoid::mpdqmlplasmoid(QObject *parent, const QVariantList &args)
        : Plasma::Applet(parent, args),
        m_icon("document"),
        m_containment(0),
        m_mainWidget(0)
{
    setAspectRatioMode(Plasma::IgnoreAspectRatio);


    m_declarativeWidget = new Plasma::DeclarativeWidget(this);
    m_layout = new QGraphicsLinearLayout(this);
    m_layout->addItem(m_declarativeWidget);
    m_layout->setSizePolicy(QSizePolicy::Ignored,QSizePolicy::Ignored);
    m_declarativeWidget->setSizePolicy(QSizePolicy::Ignored,QSizePolicy::Ignored);
    this->setSizePolicy(QSizePolicy::Ignored,QSizePolicy::Ignored);

    qmlRegisterType<QSlider>("Qt",0,1,"QSlider");
    qmlRegisterType<WheelArea>("MyTools", 1, 0, "WheelArea");

    Plasma::PackageStructure::Ptr structure = Plasma::PackageStructure::load("Plasma/Generic");
    m_package = new Plasma::Package(QString(), "org.kde.plasma.applet.mpdqmlplasmoid", structure);
    m_declarativeWidget->setQmlPath(KGlobal::dirs()->findResource("data",QString("plasma/plasmoids/org.kde.plasma.applet.mpdqmlplasmoid/ui/mainhorizontal.qml")));
    qDebug("QML Path:");
    qDebug(KGlobal::dirs()->findResource("data",QString("plasma/plasmoids/org.kde.plasma.applet.mpdqmlplasmoid/ui/mainhorizontal.qml")).toUtf8());
    if (m_declarativeWidget->engine()) {
        QDeclarativeContext *ctxt = m_declarativeWidget->engine()->rootContext();
// 	qmlRegisterType("org.kde.plasma.graphicswidgets",0,1,"QSlider");
        m_mainWidget = qobject_cast<QDeclarativeItem *>(m_declarativeWidget->rootObject());
        qDebug(m_declarativeWidget->rootObject()->objectName().toUtf8());
        if (m_mainWidget) {
        }
        else {
            kDebug() << "No m_mainWidget";
        }
    }
    maincontroller = new Controller(m_declarativeWidget->engine()->rootContext(),m_mainWidget);
    connect(maincontroller,SIGNAL(connectedToServer()),this,SLOT(connectedToServer()));
    connect(maincontroller,SIGNAL(disconnectedFromServer()),this,SLOT(disconnectedFromServer()));
    connect(maincontroller,SIGNAL(statusReady(status_struct)),this,SLOT(updateStatus(status_struct)));
    connected = false;
}

void mpdqmlplasmoid::init()
{
    Plasma::Applet::init();
    CommonDebug("INIT");
    setHasConfigurationInterface(true);
    configChanged();
}



mpdqmlplasmoid::~mpdqmlplasmoid()
{
    if (hasFailedToLaunch()) {
        // Do some cleanup here
    } else {
        // Save settings
    }
}

void mpdqmlplasmoid::setContainment(Plasma::Containment *cont)
{
    m_containment = cont;
}

Plasma::Containment *mpdqmlplasmoid::containment() const
{
    return m_containment;
}

void mpdqmlplasmoid::createConfigurationInterface(KConfigDialog* parent)
{
    CommonDebug("createConfigurationInterface called");
    QWidget *widget = new QWidget();
    configwidget.setupUi(widget);
    configwidget.hostname->setText(hostname);
    configwidget.password->setText(password);
    configwidget.port->setValue(port);
    configwidget.autoconnect->setChecked(autoconnect);
    parent->addPage(widget, i18n("Network"), "network-server");

    QWidget *viewwidget = new QWidget();
    guiconfigwidget.setupUi(viewwidget);
    guiconfigwidget.autohide->setChecked(maincontroller->getAutoHide());
    parent->addPage(viewwidget,i18n("View"), "applications-graphics");


    connect(configwidget.password,SIGNAL(editingFinished()),parent, SLOT(settingsModified()));
    connect(configwidget.hostname,SIGNAL(editingFinished()),parent, SLOT(settingsModified()));
    connect(configwidget.port,SIGNAL(valueChanged(int)),parent, SLOT(settingsModified()));
    connect(parent,SIGNAL(applyClicked()),this,SLOT(onConfigAccepted()));
    connect(parent,SIGNAL(okClicked()),this,SLOT(onConfigAccepted()));

}

void mpdqmlplasmoid::configChanged()
{
    qDebug("configChanged called");
    KConfigGroup config = this->config();
    QString hhostname ="" ;
    hhostname = config.readEntry("hostname",QString());
    QString hpassword = "";
    hpassword = config.readEntry("password",QString());
    CommonDebug(hhostname+":"+hpassword);
    if (hhostname!="") {
        CommonDebug("Hostname loaded");
        hostname = hhostname;
    }
    else {
        CommonDebug("No hostname found");
        hostname ="localhost";
    }
    if (hpassword!="") {
        password = hpassword;
    }
    QString portstring ="" ;
    portstring = config.readEntry("port",QString());
    if (portstring!="") {
        port = portstring.toUInt();
    }
    else {
        port = 6600;
    };
    autoconnect = config.readEntry("autoconnect",false);
    maincontroller->setAutoHide(config.readEntry("autohide",false));
    maincontroller->disconnect();
    maincontroller->setConnectionParameters(hostname,port,password);
    maincontroller->setReconnect(autoconnect);
}

void mpdqmlplasmoid::onConfigAccepted()
{
    qDebug("Write config \n");
    KConfigGroup config = this->config();
    config.writeEntry("password",configwidget.password->text());
    config.writeEntry("hostname",configwidget.hostname->text());
    config.writeEntry("port",QString::number(configwidget.port->value()));
    config.writeEntry("autoconnect",configwidget.autoconnect->isChecked());
    config.writeEntry("autohide",guiconfigwidget.autohide->isChecked());
    hostname = configwidget.hostname->text();
    password = configwidget.password->text();
    port = configwidget.port->value();
    autoconnect = configwidget.autoconnect->isChecked();
    Q_EMIT configNeedsSaving();
}

void mpdqmlplasmoid::constraintsEvent(Plasma::Constraints constraints)
{
    Plasma::Applet::constraintsEvent(constraints);
    const Plasma::FormFactor form(formFactor());
    if ( constraints.testFlag(Plasma::FormFactorConstraint) )
    {
        m_layout->removeItem(m_declarativeWidget);
        if ( form == Plasma::Horizontal ) {
            Plasma::ToolTipManager::self()->registerWidget(this);

            m_declarativeWidget->setQmlPath(KGlobal::dirs()->findResource("data",QString("plasma/plasmoids/org.kde.plasma.applet.mpdqmlplasmoid/ui/mainhorizontal.qml")));
        }
        else if ( form == Plasma::Vertical ) {
            Plasma::ToolTipManager::self()->registerWidget(this);

            m_declarativeWidget->setQmlPath(KGlobal::dirs()->findResource("data",QString("plasma/plasmoids/org.kde.plasma.applet.mpdqmlplasmoid/ui/mainvertical.qml")));
        }
        else {
            Plasma::ToolTipManager::self()->unregisterWidget(this);

            m_declarativeWidget->setQmlPath(KGlobal::dirs()->findResource("data",QString("plasma/plasmoids/org.kde.plasma.applet.mpdqmlplasmoid/ui/main.qml")));
        }
        if (m_declarativeWidget->engine()) {
            QDeclarativeContext *ctxt = m_declarativeWidget->engine()->rootContext();
            delete(m_mainWidget);
            m_mainWidget = qobject_cast<QDeclarativeItem *>(m_declarativeWidget->rootObject());
            qDebug(m_declarativeWidget->rootObject()->objectName().toUtf8());
            if (m_mainWidget) {
            }
            else {
                kDebug() << "No m_mainWidget";
            }
        }
        maincontroller->changeQMLFile(m_declarativeWidget->engine()->rootContext(),m_mainWidget);
        m_layout->addItem(m_declarativeWidget);
        m_declarativeWidget->setSizePolicy(QSizePolicy::Ignored,QSizePolicy::Ignored);
        this->setSizePolicy(QSizePolicy::Preferred,QSizePolicy::Preferred);
    }
}

void mpdqmlplasmoid::toolTipAboutToShow()
{
    Plasma::ToolTipContent toolTip;
    QString subtext;
    if (trackname!="")
    {
        subtext = i18n("%1 (%2/%3) <b> on</b>\n %4<b> from</b>\n %5",trackname,lengthString(timecurrent),lengthString(tracktime),albumname,artistname);
    }
    else {
        subtext = i18n("%1 (%2/%3)",fileuri,lengthString(timecurrent),lengthString(tracktime));
    }
    if (playing==NetworkAccess::PLAYING) {
        toolTip.setMainText(i18n("Currently playing:"));
        toolTip.setSubText(subtext);
    }
    else if (playing==NetworkAccess::STOP) {
        toolTip.setMainText(i18n("Currently stopped"));
    }
    else if (playing==NetworkAccess::PAUSE) {
        toolTip.setMainText(i18n("Currently paused:"));
        toolTip.setSubText(subtext);
    }
    if (!connected)
    {
        toolTip.setSubText("");
        toolTip.setMainText(i18n("Currently not connected to server"));
    }
    toolTip.setImage(KIcon("applications-multimedia"));
    Plasma::ToolTipManager::self()->setContent(this, toolTip);


}

void mpdqmlplasmoid::toolTipHidden()
{
    Plasma::ToolTipManager::self()->clearContent(this);
}

void mpdqmlplasmoid::updateStatus(status_struct statuslist)
{
    albumname = statuslist.album;
    artistname = statuslist.artist;
    trackname = statuslist.title;
    tracktime = statuslist.length;
    timecurrent = statuslist.currentpositiontime;
    fileuri = statuslist.fileuri;
    playing = statuslist.playing;
}

void mpdqmlplasmoid::connectedToServer()
{
    connected = true;
}

void mpdqmlplasmoid::disconnectedFromServer()
{
    connected = false;
}

QString mpdqmlplasmoid::lengthString(quint32 length)
{
    QString temp;
    int hours=0,min=0,sec=0;
    hours = length/3600;
    if (hours>0)
    {
        min=(length-(3600*hours))/60;
    }
    else {
        min=length/60;
    }
    sec = length-hours*3600-min*60;
    if (hours==0)
    {
        temp=QString::number(min)+":"+(sec<10?"0":"")+QString::number(sec);
    }
    else
    {
        temp=QString::number(hours)+":"+QString::number(min)+":"+QString::number(sec);
    }
    return temp;
}



#include "mpdqmlplasmoid.moc"
