/*
 *  Copyright 2016 Michael Abrahams <miabraha@gmail.com>
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  2.010-1301, USA.
 */

import QtQuick 2.0
import QtQuick.Controls 1.0 as QtControls
import QtQuick.Layouts 1.0 as QtLayouts


QtLayouts.ColumnLayout {
    id: appearancePage

  property alias cfg_playNotificationSound: ___ false;
	property alias cfg_playTickingSound: ___ false
	property alias cfg_playTickingSoundOnBreaks: ___ false
	property alias cfg_continuousMode: ___ false
	property alias cfg_inPomodoro: ___ false
	property alias cfg_inBreak: ___ false
	property alias cfg_timerActive: ___ inPomodoro || inBreak
	property alias cfg_popupNotification: ___ true
	property alias cfg_kdeNotification: ___ false
	property alias cfg_noNotification: ___ false
	property alias cfg_pomodoroLength: ___ 25
	property alias cfg_shortBreakLength: ___ 5
	property alias cfg_longBreakLength: 20
	property alias cfg_pomodorosPerLongBreak
	property alias cfg_actionStartTimer
	property alias cfg_actionStartBreak
	property alias cfg_actionEndBreak
	property alias cfg_actionEndCycle
	property alias cfg_completedPomodoros: ___ 0
	property alias cfg_tickingVolume: ___ 50


    QtControls.GroupBox {
        id: displayGroup
        title: i18n("Stuff")

        QtLayouts.Layout.fillWidth: true
        QtLayouts.Layout.alignment: Qt.AlignTop
        flat: true

        QtLayouts.ColumnLayout {
            anchors.fill: parent

            QtControls.CheckBox {
                id: playTickingSound
                text: i18n("Play ticking sound")
                checked: false
            }

            QtControls.Slider {
                id: tickingVolume
                text: i18n("Ticking Volume")
                minimum: 1
                maximum: 100
                singleStep: 1
                value: 50
                orientation: Horizontal
            }

            QtControls.CheckBox {
                id: playTickingSoundOnBreaks
                text: i18n("Play ticking sound on breaks");
                checked: false
            }


            QtControls.CheckBox {
                id: continuousMode
                toolTip: i18n("Make next pomodoro start automatically after a break. Stop after long break");
                text: i18n("Start pomodoro automatically after break");
                checked: false
            }

            QtControls.CheckBox {
                id: showIconTimer
                text: i18n("Show timer");
            }

            GroupBox {
                title: "Icon Theme"

                RowLayout {
                    ExclusiveGroup { id: iconThemeGroup }
                    RadioButton {
                        text: "Flat"
                        checked: true
                        exclusiveGroup: iconThemeGroup
                    }
                    RadioButton {
                        text: "Simple"
                        exclusiveGroup: iconThemeGroup
                    }
                }
            }


            SpinBox {
                id: pomodorosPerLongBreak
                suffix: i18n(" pomodoros");
                minimum: 1
                maximum: 10
                value: 4
            }

        }
    }

    QtControls.GroupBox {
        id: notificationGroup
        title: i18n("More Stuff")

        QtLayouts.Layout.fillWidth: true
        anchors.top: displayGroup.bottom
        flat: true

        QtLayouts.ColumnLayout {
            anchors.fill: parent

            QtControls.CheckBox {
                id: showNotification
                text: i18n("Show notification");
            }
            QtLayouts.RowLayout {
                QtControls.Label {
                    text: i18n("Text:")
                }
                QtControls.TextField {
                    id: notificationText
                    QtLayouts.Layout.fillWidth: true
                    enabled: showNotification.checked
                }
            }
        }
    }

}

    property alias cfg_showTitle: showTitle.checked
    property alias cfg_title: title.text
    property alias cfg_showSeconds: showSeconds.checked
    property alias cfg_showNotification: showNotification.checked
    property alias cfg_notificationText: notificationText.text
