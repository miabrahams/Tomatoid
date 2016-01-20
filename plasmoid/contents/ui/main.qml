/*
 *   Copyright 2013 Arthur Taborda <arthur.hvt@gmail.com>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2 or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import QtQuick 2.2
import QtMultimedia 5.5
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

import "plasmapackage:/code/logic.js" as Logic

Item {
	id: tomatoid

	//************ OPTIONS ************

	property string appName: "Tomatoid"

	property int minimumWidth: 600
	property int minimumHeight: 800

	property bool playNotificationSound: plasmoid.configuration.playNotificationSound
	property bool playTickingSound: plasmoid.configuration.playTickingSound
  property bool playTickingSoundOnBreaks: false
  property bool continuousMode: plasmoid.configuration.continuousMode
  property bool inPomodoro: false
  property bool inBreak: false
  property bool timerActive: inPomodoro || inBreak

	property bool popupNotification: plasmoid.configuration.popupNotification
	property bool kdeNotification: plasmoid.configuration.kdeNotification
	property bool noNotification: plasmoid.configuration.noNotification

	property int pomodoroLength: plasmoid.configuration.pomodoroLength
	property int shortBreakLength: plasmoid.configuration.shortBreakLength
	property int longBreakLength: plasmoid.configuration.longBreakLength
	property int pomodorosPerLongBreak: plasmoid.configuration.pomodorosPerLongBreak

	property string actionStartTimer: plasmoid.configuration.actionStartTimer
	property string actionStartBreak: plasmoid.configuration.actionStartBreak
	property string actionEndBreak: plasmoid.configuration.actionEndBreak
	property string actionEndCycle: plasmoid.configuration.actionEndCycle

	property int completedPomodoros: 0

	property int tickingVolume: plasmoid.configuration.tickingVolume

	//************ /OPTIONS ************

	//list of tasks
	ListModel { id: completeTasks }
	ListModel { id: incompleteTasks }

	property Item currentView: toolBarLayout.currentTab

	Component.onCompleted: {

		Logic.parseConfig(plasmoid.configuration.completeTasks, completeTasks)
		Logic.parseConfig(plasmoid.configuration.incompleteTasks, incompleteTasks)

		plasmoid.setBackgroundHints(0);
		tomatoid.forceActiveFocus();
	}

	property Component compactRepresentation: Component {
		TomatoidIcon {
			id: iconComponent
		}
	}

	PlasmaComponents.ToolBar {
		id: toolBar
		property alias query: topBar.query

		tools: TopBar {
			id: topBar
		}
	}

	PlasmaComponents.TabBar {
		id: tabBar
		height: units.gridUnit * 35

		currentTab: incompleteTaskList
		onCurrentTabChanged: tomatoid.forceActiveFocus();

		PlasmaComponents.TabButton { tab: incompleteTaskList; text: i18n("Tasks") }
		PlasmaComponents.TabButton { tab: completeTaskList; text: i18n("Done") }

		anchors {
			top: toolBar.bottom
			left: parent.left
			right: parent.right
			margins: units.gridUnit * 7
			leftMargin: units.gridUnit * 10
			rightMargin: units.gridUnit * 10
		}
	}


	PlasmaCore.FrameSvgItem {
		id: taskFrame
		anchors.fill: toolBarLayout
		imagePath: "widgets/frame"
		prefix: "sunken"
	}


	PlasmaComponents.TabGroup {
		id: toolBarLayout

		anchors {
			top: tabBar.bottom
			left: parent.left
			right: parent.right
			bottom: parent.bottom
			bottomMargin: units.gridUnit * (timerActive ? 32 : 5)
			margins: units.gridUnit * 5

			Behavior on bottomMargin {
				NumberAnimation {
					duration: 400
					easing.type: Easing.OutQuad
				}
			}
		}


		TaskList {
			id: incompleteTaskList

			model: incompleteTasks
			done: false

			onDoTask: Logic.doTask(taskIdentity)
			onRemoveTask: Logic.removeIncompleteTask(taskIdentity)
			onStartTask: Logic.startTask(taskIdentity, taskName)
			onRenameTask: Logic.renameTask(taskIdentity, newName)
		}

		TaskList {
			id: completeTaskList

			model: completeTasks
			done: true

			onDoTask: Logic.undoTask(taskIdentity)
			onRemoveTask: Logic.removeCompleteTask(taskIdentity)
		}
	}

	Keys.forwardTo: [tabBar.layout]

	Keys.onPressed: {
		switch(event.key) {
			case Qt.Key_Up: {
				console.log("root up")
				currentView.decrementCurrentIndex();
				event.accepted = true;
				break;
			}
			case Qt.Key_Down: {
				console.log("root down")
				currentView.incrementCurrentIndex();
				event.accepted = true;
				break;
			}
			case Qt.Key_Escape: {
				plasmoid.togglePopup();
				event.accepted = true;
				break;
			}
			case Qt.Key_Tab: {
				console.log("root tab")
				toolBar.query.focus = true;
				event.accepted = true;
				break;
			}
			case Qt.Key_Space: {
				if(tomatoid.timerActive)
					timer.running = !timer.running
				event.accepted = true;
				break;
			}
			case Qt.Key_S: {
				if(tomatoid.timerActive)
					Logic.stop()
				event.accepted = true;
				break;
			}
			default: {
				console.log(event.key);
			}
		}
	}


	SoundEffect {
		id: notificationSound
		source: plasmoid.file("data", "notification.wav")
	}

	SoundEffect {
		id: tickingSound
		source: plasmoid.file("data", "tomatoid-ticking.wav")
		volume: tickingVolume / 100 //volume from 0.1 to 1.0
	}

	//Actual timer. This will store the remaining seconds, total seconds and will return a timeout in the end.
	property QtObject timer: TomatoidTimer {
		id: timer

		onTick: {
			if(playTickingSound){
                                if(inBreak){
                                        if(playTickingSoundOnBreaks){
                                                tickingSound.play();
                                        }
                                } else {
                                        tickingSound.play();
                                }
                        }
		}
		onTimeout: {
			if(playNotificationSound)
				notificationSound.play();
			if(popupNotification)
				plasmoid.showPopup(5000)

			if(inPomodoro) {
				console.log(taskId)
				Logic.completePomodoro(taskId)
				Logic.startBreak()

				if(kdeNotification)
					Logic.notify(i18n("Pomodoro completed"), i18n("Great job! Now take a break and relax for a moment."));
			} else if(inBreak) {
				Logic.endBreak()
				if(kdeNotification)
					Logic.notify(i18n("Relax time is over"), i18n("Get back to work. Choose a task and start again."));
				if(continuousMode && completedPomodoros % pomodorosPerLongBreak) //if continuous mode and long break
					Logic.startTask(timer.taskId, timer.taskName)
			}
		}
	}

	//chronometer with action buttons and regressive progress bar in the bottom. This will get the time from TomatoidTimer
	Chronometer {
		id: chronometer
		height: units.gridUnit * 22
		seconds: timer.seconds
		totalSeconds: timer.totalSeconds
		opacity: timerActive * 1 //only show if timer is running

		onPlayPressed: {
			timer.running = true
		}

		onPausePressed: {
			timer.running = false
		}

		onStopPressed: {
			Logic.stop()
		}

		anchors {
			left: tomatoid.left
			right: tomatoid.right
			bottom: tomatoid.bottom
			leftMargin: units.gridUnit * 5
			bottomMargin: units.gridUnit * 5
		}
	}
}
