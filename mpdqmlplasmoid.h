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

// Here we avoid loading the header multiple times
#ifndef MPDQMLPLASMOID_HEADER
#define MPDQMLPLASMOID_HEADER

#include <KIcon>
#include <KConfigDialog>
// We need the Plasma Applet headers
#include <Plasma/Applet>
#include <Plasma/Svg>
#include <Plasma/DeclarativeWidget>
#include <QGraphicsLinearLayout>

#include <QGraphicsWidget>
#include "controller.h"

//Config stuff
#include "ui_qmpdplasmoidconfig.h"
#include "ui_qmpdplasmoidconfiggui.h"

class QDeclarativeItem;

class PlasmaAppletItemModel;

namespace Plasma
{
class Containment;
class DeclarativeWidget;
class Package;
class ToolTipContent;
class ToolTipManager;
}


class QSizeF;

// Define our plasma Applet
class mpdqmlplasmoid : public Plasma::Applet
{
    Q_OBJECT
public:
    // Basic Create/Destroy
    mpdqmlplasmoid(QObject *parent, const QVariantList &args);
    ~mpdqmlplasmoid();
    void init();

    void setContainment(Plasma::Containment *cont);
    Plasma::Containment *containment() const;

private:
    KIcon m_icon;
    Plasma::Containment *m_containment;
    QDeclarativeItem *m_mainWidget;
    Plasma::DeclarativeWidget *m_declarativeWidget;
    Plasma::Package *m_package;
    QGraphicsLinearLayout *m_layout;
    Controller *maincontroller;
    //Config
    KConfigDialog *configdialog;
    Ui::qmpdplasmoidConfig configwidget;
    Ui::qmpdplasmoidConfigGUI guiconfigwidget;
    //Connection Data
    QString hostname,password;
    bool autoconnect;
    int port;
    QString artistname,albumname,trackname,fileuri;
    int tracktime,timecurrent;
    bool connected,playing;

protected:
    void createConfigurationInterface(KConfigDialog *parent);
    void constraintsEvent(Plasma::Constraints constraints);
    QString lengthString(quint32 length);




private Q_SLOTS:
    void configChanged();
    void onConfigAccepted();

public slots:
    void toolTipAboutToShow();
    void toolTipHidden();
    void updateStatus(status_struct statuslist);

private slots:

    void connectedToServer();
    void disconnectedFromServer();




};

// This is the command that links your applet to the .desktop file
K_EXPORT_PLASMA_APPLET(mpdqmlplasmoid, mpdqmlplasmoid)
#endif
