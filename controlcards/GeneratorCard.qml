/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import QtQuick.Controls as C
import QtQuick.Controls.impl as CP
import Victron.VenusOS
import "/components/Utils.js" as Utils

ControlCard {
	id: root

	// data from Generators.qml.  TODO: hook up.
	property int state: Generators.GeneratorState.Running
	property int runtime: 3793 // seconds remaining?
	property int runningBy: Generators.GeneratorRunningBy.Manual

	title.icon.source: "qrc:/images/generator.svg"
	//% "Generator"
	title.text: qsTrId("controlcard_generator")
	status.text: root.state === Generators.GeneratorState.Error ?
					//% "ERROR"
					qsTrId("controlcard_generator_status_error")
				: root.state === Generators.GeneratorState.Stopped ?
					//% "Stopped"
					qsTrId("controlcard_generator_status_stopped")
				: /* Running */
					//% "Running"
					qsTrId("controlcard_generator_status_running")

	GeneratorIconLabel {
		id: timerDisplay
		anchors {
			right: parent.right
			rightMargin: 14
			top: parent.status.top
			topMargin: parent.status.topMargin
			bottom: parent.status.bottom
			bottomMargin: parent.status.bottomMargin
		}

		spacing: 5
		display: C.AbstractButton.TextBesideIcon

		icon.width: 24
		icon.height: 24
		icon.source: root.state !== Generators.GeneratorState.Running ? ""
				: root.runningBy === Generators.GeneratorRunningBy.Manual
					? root.runtime > 0
						? "qrc:/images/icon_manualstart_timer_24.svg"
						: "qrc:/images/icon_manualstart_24.svg"
				: "qrc:/images/icon_autostart_24.svg"
		text: Utils.formatAsHHMM(root.runtime)
		font.family: VenusFont.normal.name
		font.pixelSize: Theme.font.size.m
		color: root.runtime > 0 ? Theme.color.font.primary : Theme.color.font.tertiary
		state: root.state
		runtime: root.runtime
		runningBy: root.runningBy
	}

	Label {
		id: substatus
		anchors {
			top: timerDisplay.bottom
			left: parent.left
			leftMargin: Theme.geometry.controlCard.contentMargins
		}

		color: root.state === Generators.GeneratorState.Error ? Theme.color.critical
			: Theme.color.font.tertiary
		text: root.state !== Generators.GeneratorState.Running ?
				"" // not running, empty substatus.
			: root.runningBy === Generators.GeneratorRunningBy.Manual ?
				//% "Manual started"
				qsTrId("controlcard_generator_substatus_manualstarted")
			: root.runningBy === Generators.GeneratorRunningBy.TestRun ?
				//% "Test run"
				qsTrId("controlcard_generator_substatus_testrun")
			: ( //% "Auto-started"
				qsTrId("controlcard_generator_substatus_autostarted")
				+ " \u2022 " + substatusForRunningBy(root.runningBy))

		function substatusForRunningBy(runningBy) {
			switch (root.runningBy) {
			case Generators.GeneratorRunningBy.LossOfCommunication:
				//% "Loss of comm"
				return qsTrId("controlcard_generator_substatus_lossofcomm")
			case root.runningBy === Generators.GeneratorRunningBy.Soc:
				//% "State of charge"
				return qsTrId("controlcard_generator_substatus_stateofcharge")
			case root.runningBy === Generators.GeneratorRunningBy.Acload:
				//% "AC load"
				return qsTrId("controlcard_generator_substatus_acload")
			case root.runningBy === Generators.GeneratorRunningBy.BatteryCurrent:
				//% "Battery current"
				return qsTrId("controlcard_generator_substatus_batterycurrent")
			case root.runningBy === Generators.GeneratorRunningBy.BatteryVoltage:
				//% "Battery voltage"
				return qsTrId("controlcard_generator_substatus_batteryvoltage")
			case root.runningBy === Generators.GeneratorRunningBy.InverterHighTemp:
				//% "Inverter high temp"
				return qsTrId("controlcard_generator_substatus_inverterhigh_temp")
			case root.runningBy === Generators.GeneratorRunningBy.InverterOverload:
				//% "Inverter overload"
				return qsTrId("controlcard_generator_substatus_inverteroverload")
			default: return "" // unknown substatus.
			}
		}
	}

	SwitchControlValue {
		id: autostartSwitch

		property bool generatorAutostartValue: true // TODO: bind to data model

		anchors.top: substatus.bottom

		//% "Autostart"
		label.text: qsTrId("controlcard_generator_label_autostart")
		button.checkable: false
		button.checked: generatorAutostartValue

		onClicked: {
			if (generatorAutostartValue) {
				// check if they really want to disable
				dialogManager.generatorDisableAutostartDialog.open()
			} else {
				generatorAutostartValue = true
			}
		}
		Connections {
			target: dialogManager.generatorDisableAutostartDialog
			function onAccepted() {
				autostartSwitch.generatorAutostartValue = false
			}
		}
	}

	Item {
		id: subcard
		anchors {
			left: parent.left
			leftMargin: Theme.geometry.controlCard.subCard.margins
			right: parent.right
			rightMargin: Theme.geometry.controlCard.subCard.margins
			top: autostartSwitch.bottom
			topMargin: 2*Theme.geometry.controlCard.subCard.margins
			bottom: parent.bottom
			bottomMargin: Theme.geometry.controlCard.subCard.margins
		}

		Rectangle {
			id: subcardBgRect
			anchors.fill: parent
			color: Theme.color.background.tertiary
			radius: Theme.geometry.controlCard.radius
		}

		Label {
			id: subcardHeader
			anchors {
				left: parent.left
				leftMargin: Theme.geometry.controlCard.contentMargins
				right: parent.right
				rightMargin: Theme.geometry.controlCard.contentMargins
			}

			height: Theme.geometry.controlCard.subCard.header.height
			verticalAlignment: Text.AlignVCenter
			horizontalAlignment: Text.AlignLeft
			font.pixelSize: Theme.font.size.xs
			//% "Manual control"
			text: qsTrId("controlcard_generator_subcard_header_manualcontrol")
			color: Theme.color.font.tertiary
		}
		SeparatorBar {
			id: subcardHeaderSeparator
			anchors {
				top: subcardHeader.bottom
				left: parent.left
				right: parent.right
			}
		}
		SwitchControlValue {
			id: timedRunSwitch

			anchors.top: subcardHeaderSeparator.bottom
			//% "Timed run"
			label.text: qsTrId("controlcard_generator_subcard_label_timedrun")
		}
		ButtonControlValue {
			id: durationButton

			property int selectedRuntime: 0 // TODO: bind to data model

			anchors.top: timedRunSwitch.bottom
			//% "Duration"
			label.text: qsTrId("controlcard_generator_subcard_label_duration")

			button.height: Theme.geometry.generatorCard.durationButton.height
			button.width: Theme.geometry.generatorCard.durationButton.width
			button.enabled: timedRunSwitch.button.checked
			button.text: Utils.formatAsHHMM(durationButton.selectedRuntime)

			onClicked: dialogManager.generatorDurationSelectorDialog.open()

			Connections {
				target: dialogManager.generatorDurationSelectorDialog
				function onDurationChanged() {
					durationButton.selectedRuntime = dialogManager.generatorDurationSelectorDialog.duration
				}
			}
		}
		Button {
			id: startButton
			anchors {
				margins: Theme.geometry.controlCard.contentMargins
				bottom: parent.bottom
				left: parent.left
				right: parent.right
			}
			height: Theme.geometry.generatorCard.startButton.height

			enabled: root.state !== Generators.GeneratorState.Error

			text: root.state === Generators.GeneratorState.Running ?
					//% "Stop"
					qsTrId("controlcard_generator_subcard_button_stop")
				: /* stopped */
					//% "Start"
					qsTrId("controlcard_generator_subcard_button_start")

			backgroundColor: root.state === Generators.GeneratorState.Error
					? Theme.color.background.disabled
				: root.state === Generators.GeneratorState.Running
					? down ? Theme.color.critical : Theme.color.dimCritical
				: /* Stopped */
					  down ? Theme.color.go : Theme.color.dimGo
			color: root.state === Generators.GeneratorState.Error ? Theme.color.font.disabled
				: Theme.color.font.primary

			onClicked: {
				// TODO: hook up to data model.
				if (root.state === Generators.GeneratorState.Running) {
					root.state = Generators.GeneratorState.Stopped
					root.runtime = -1
				} else {
					root.state = Generators.GeneratorState.Running
					root.runtime = 7357
				}
			}
		}
	}
}