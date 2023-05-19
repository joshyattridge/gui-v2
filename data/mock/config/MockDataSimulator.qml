/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import "/components/Utils.js" as Utils

QtObject {
	id: root

	property bool timersActive: !Global.splashScreenVisible
	property var mockDataValues: ({})

	signal setBatteryRequested(var config)
	signal setAcInputsRequested(var config)
	signal setDcInputsRequested(var config)
	signal setEnvironmentInputsRequested(var config)
	signal setSolarChargersRequested(var config)
	signal setSystemRequested(var config)
	signal setTanksRequested(var config)
	signal deactivateSingleAlarm()

	readonly property var _configs: ({
		"qrc:/pages/BriefPage.qml": briefAndOverviewConfig,
		"qrc:/pages/OverviewPage.qml": briefAndOverviewConfig,
		"qrc:/pages/LevelsPage.qml": levelsConfig,
		"qrc:/pages/SettingsPage.qml": settingsConfig,
	})

	function setConfigIndex(pageConfig, configIndex) {
		const configName = pageConfig.loadConfig(configIndex)
		if (configName) {
			pageConfig.configIndex = configIndex
			pageConfigTitle.text = configIndex+1 + ". " + configName || ""
		} else {
			pageConfigTitle.text = ""
		}
	}

	function nextConfig() {
		const pageConfig = _configs[Global.pageManager.navBar.currentUrl]
		const nextIndex = Utils.modulo(pageConfig.configIndex + 1, pageConfig.configCount())
		setConfigIndex(pageConfig, nextIndex)
	}

	function previousConfig() {
		const pageConfig = _configs[Global.pageManager.navBar.currentUrl]
		const prevIndex = Utils.modulo(pageConfig.configIndex - 1, pageConfig.configCount())
		setConfigIndex(pageConfig, prevIndex)
	}

	function keyPressed(event) {
		switch (event.key) {
		case Qt.Key_Escape:
			Global.pageManager.popPage()
			break
		case Qt.Key_1:
		case Qt.Key_2:
		case Qt.Key_3:
		case Qt.Key_4:
		case Qt.Key_5:
			Global.pageManager.navBar.currentIndex = event.key - Qt.Key_1
			event.accepted = true
			break
		case Qt.Key_Left:
			if (Global.pageManager.navBar.currentUrl in root._configs) {
				previousConfig()
				event.accepted = true
			}
			break
		case Qt.Key_Right:
			if (Global.pageManager.navBar.currentUrl in root._configs) {
				nextConfig()
				event.accepted = true
			}
			break
		case Qt.Key_Plus:
			if (Theme.screenSize !== Theme.SevenInch) {
				Theme.load(Theme.SevenInch, Theme.colorScheme)
				event.accepted = true
			}
			break
		case Qt.Key_Minus:
			if (Theme.screenSize !== Theme.FiveInch) {
				Theme.load(Theme.FiveInch, Theme.colorScheme)
				event.accepted = true
			}
			break
		case Qt.Key_C:
			if (Theme.colorScheme == Theme.Dark) {
				Theme.load(Theme.screenSize, Theme.Light)
			} else {
				Theme.load(Theme.screenSize, Theme.Dark)
			}
			event.accepted = true
			break
		case Qt.Key_G:
			if (event.modifiers & Qt.ShiftModifier) {
				let newValue = Global.mockDataSimulator.mockDataValues["com.victronenergy.modem/SignalStrength"] + 5
				if (newValue > 25) {
					newValue = 0
				}
				Global.mockDataSimulator.mockDataValues["com.victronenergy.modem/SignalStrength"] = newValue
			}
			else if (event.modifiers & Qt.ControlModifier) {
				var oldValue = Global.mockDataSimulator.mockDataValues["com.victronenergy.modem/Roaming"]
				Global.mockDataSimulator.mockDataValues["com.victronenergy.modem/Roaming"] = !oldValue
			}
			else if (event.modifiers & Qt.AltModifier) {
				var oldValue = Global.mockDataSimulator.mockDataValues["com.victronenergy.modem/NetworkType"]
				var newValue
				switch (oldValue) {
				case "NONE": newValue = "GSM"
					break
				case "GSM": newValue = "EDGE"
					break
				case "EDGE": newValue = "CDMA"
					break
				case "CDMA": newValue = "HSPAP"
					break
				case "HSPAP": newValue = "LTE"
					break
				case "LTE": newValue = "NONE"
					break
				}
				Global.mockDataSimulator.mockDataValues["com.victronenergy.modem/NetworkType"] = newValue
			}
			else if (event.modifiers & Qt.MetaModifier) {
				var oldValue = Global.mockDataSimulator.mockDataValues["com.victronenergy.modem/SimStatus"]
				Global.mockDataSimulator.mockDataValues["com.victronenergy.modem/SimStatus"] = oldValue === 1000 ? 11 : 1000
			}
			else {
				var oldValue = Global.mockDataSimulator.mockDataValues["com.victronenergy.modem/Connected"]
				Global.mockDataSimulator.mockDataValues["com.victronenergy.modem/Connected"] = oldValue === 1 ? 0 : 1
			}
			event.accepted = true
			break
		case Qt.Key_L:
			Language.current = (Language.current === Language.English ? Language.French : Language.English)
			pageConfigTitle.text = "Language: " + Language.toString(Language.current)
			event.accepted = true
			break
		case Qt.Key_N:
			if (event.modifiers & Qt.ShiftModifier) {
				Global.notifications.activeModel.deactivateSingleAlarm()
			} else {
				var n = notificationsConfig.getRandomAlarm()
				Global.notifications.activeModel.insertByDate(n.acknowledged, n.active, n.type, n.deviceName, n.dateTime, n.description)
			}
			event.accepted = true
			break
		case Qt.Key_O:
			const notifType = (event.modifiers & Qt.ShiftModifier)
				? VenusOS.Notification_Confirm
				: (event.modifiers & Qt.AltModifier)
				  ? VenusOS.Notification_Warning
				  : (event.modifiers & Qt.ControlModifier)
					? VenusOS.Notification_Alarm
					: VenusOS.Notification_Info
			notificationsConfig.showToastNotification(notifType)
			event.accepted = true
			break
		case Qt.Key_T:
			root.timersActive = !root.timersActive
			pageConfigTitle.text = "Timers on: " + root.timersActive
			event.accepted = true
			break
		case Qt.Key_U:
			Global.systemSettings.electricalQuantity.setValue(
					Global.systemSettings.electricalQuantity.value === VenusOS.Units_Watt
					? VenusOS.Units_Amp
					: VenusOS.Units_Watt)
			Global.systemSettings.temperatureUnit.setValue(
					Global.systemSettings.temperatureUnit.value === VenusOS.Units_Temperature_Celsius
					? VenusOS.Units_Temperature_Fahrenheit
					: VenusOS.Units_Temperature_Celsius)
			Global.systemSettings.volumeUnit.setValue(
					Global.systemSettings.volumeUnit.value === VenusOS.Units_Volume_CubicMeter
					? VenusOS.Units_Volume_Liter
					: Global.systemSettings.volumeUnit.value === VenusOS.Units_Volume_Liter
					  ? VenusOS.Units_Volume_GallonUS
					  : Global.systemSettings.volumeUnit.value === VenusOS.Units_Volume_GallonUS
						? VenusOS.Units_Volume_GallonImperial
						: VenusOS.Units_Volume_CubicMeter)

			pageConfigTitle.text = "Units: "
					+ (Global.systemSettings.electricalQuantity.value === VenusOS.Units_Watt
					   ? "Watts"
					   : "Amps") + " | "
					+ (Global.systemSettings.temperatureUnit.value === VenusOS.Units_Temperature_Celsius
					   ? "Celsius"
					   : "Fahrenheit") + " | "
					+ (Global.systemSettings.volumeUnit.value === VenusOS.Units_Volume_CubicMeter
					   ? "Cubic meters"
					   : Global.systemSettings.volumeUnit.value === VenusOS.Units_Volume_Liter
						 ? "Liters"
						 : Global.systemSettings.volumeUnit.value === VenusOS.Units_Volume_GallonUS
						   ? "Gallons (US)"
						   : "Gallons (Imperial)")
			event.accepted = true
			break
		case Qt.Key_Space:
			Global.allPagesLoaded = true
			Global.splashScreenVisible = false
			event.accepted = true
			break
		default:
			break
		}
	}

	property Rectangle _configLabel: Rectangle {
		parent: Global.pageManager.statusBar
		width: pageConfigTitle.width * 1.1
		height: pageConfigTitle.height * 1.1
		color: "white"
		opacity: 0.9
		visible: pageConfigTitleTimer.running

		Label {
			id: pageConfigTitle
			anchors.centerIn: parent
			color: "black"
			onTextChanged: pageConfigTitleTimer.restart()
		}

		Timer {
			id: pageConfigTitleTimer
			interval: 3000
		}
	}

	property BriefAndOverviewPageConfig briefAndOverviewConfig: BriefAndOverviewPageConfig {
		property int configIndex: -1
	}

	property LevelsPageConfig levelsConfig: LevelsPageConfig {
		property int configIndex: -1
	}

	property NotificationsPageConfig notificationsConfig: NotificationsPageConfig {
		id: notificationsConfig
	}

	property SettingsPageConfig settingsConfig: SettingsPageConfig {
		property int configIndex: -1
	}
}
