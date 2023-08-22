/*
** Copyright (C) 2022 Victron Energy B.V.
*/
pragma Singleton

import QtQml

// QTBUG-66976: if a QML-defined singleton imports the QML module
// into which it is installed, it results in a cyclic dependency.
//
// So, to work around this issue:
// - declare the other types as non-singleton instances in main.qml
// - define a single singleton which does NOT import Victron.VenusOS
// - initialize the properties of this singleton to point to the
//   instance objects declared in main, in onCompleted or similar.

QtObject {
	property var main
	property var pageManager
	property var mainView
	property var mockDataSimulator    // only valid when mock mode is active
	property var dataManager
	property var locale: Qt.locale()  // TODO: read from settings
	property var dataServiceModel: null
	property var firmwareUpdate

	property var inputPanel
	property var dialogLayer
	property var notificationLayer

	// data sources
	property var acInputs
	property var batteries
	property var dcInputs
	property var environmentInputs
	property var ess
	property var evChargers
	property var generators
	property var inverters
	property var notifications
	property var pvInverters
	property var relays
	property var solarChargers
	property var system
	property var systemSettings
	property var tanks
	property var venusPlatform

	property bool splashScreenVisible: true
	property bool dataManagerLoaded
	property bool allPagesLoaded
	property bool changingLanguage

	signal aboutToFocusTextField(var textField, int toTextFieldY, var flickable)
	signal keyPressed(var event)

	function showToastNotification(category, text, autoCloseInterval = 0) {
		notificationLayer.showToastNotification(category, text, autoCloseInterval)
	}

	function deviceModelsForClass(deviceClass) {
		if (deviceClass === "com.victronenergy.battery") {
			return [batteries.model]
		} else if (deviceClass === "com.victronenergy.solarcharger" || deviceClass === "solarcharger") {
			return [solarChargers.model]
		} else if (deviceClass === "analog") {
			return Global.tanks.allTankModels.concat([Global.environmentInputs.model])
		}
		return []
	}

	function reset() {
		// note: we don't reset `main` or `changingLanguage`
		// as main will never be destroyed during the ui rebuild,
		// and we handle changingLanguage specially.
		pageManager = null
		mainView = null
		mockDataSimulator = null
		dataManager = null
		locale = Qt.locale()
		dataServiceModel = null
		firmwareUpdate = null
		inputPanel = null
		dialogLayer = null
		notificationLayer = null
		acInputs = null
		batteries = null
		dcInputs = null
		environmentInputs = null
		ess = null
		evChargers = null
		generators = null
		inverters = null
		notifications = null
		pvInverters = null
		relays = null
		solarChargers = null
		system = null
		systemSettings = null
		tanks = null
		venusPlatform = null

		// The last thing we do is set the splash screen visible.
		allPagesLoaded = false
		dataManagerLoaded = false
		splashScreenVisible = true
	}
}

