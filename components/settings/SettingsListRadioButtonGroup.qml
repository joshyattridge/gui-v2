/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import QtQuick.Controls
import QtQuick.Controls.impl as CP
import Victron.VenusOS

// Each item in the model is expected to have at least 2 values:
//      - "display": the text to display for this option
//      - "value": some backend value associated with this option
//
// The default behaviour supports a simple array-based model. When using a ListModel or C++ model,
// set the currentIndex and secondaryText properties manually.

SettingsListNavigationItem {
	id: root

	property alias source: dataPoint.source
	property var model: []
	property int currentIndex

	signal optionClicked(index: int)

	secondaryText: currentIndex >= 0 && model.length !== undefined && currentIndex < model.length
			? model[currentIndex].display
			: ""

	currentIndex: {
		if (!model || model.length === undefined || source.length === 0 || dataPoint.value === undefined) {
			return -1
		}
		for (let i = 0; i < model.length; ++i) {
			if (model[i].value === dataPoint.value) {
				return i
			}
		}
		return -1
	}

	onClicked: {
		Global.pageManager.pushPage(optionsPageComponent)
	}

	DataPoint {
		id: dataPoint
	}

	Component {
		id: optionsPageComponent

		Page {
			SettingsListView {
				model: root.model

				delegate: SettingsListRadioButton {
					id: radioButton

					text: Array.isArray(root.model)
						  ? modelData.display || ""
						  : model.display || ""
					checked: root.currentIndex === model.index
					buttonGroup: radioButtonGroup

					onClicked: {
						if (source.length > 0) {
							dataPoint.setValue(Array.isArray(root.model) ? modelData.value : model.value)
						}
						root.currentIndex = model.index
						root.optionClicked(model.index)
					}
				}

				ButtonGroup {
					id: radioButtonGroup
				}
			}
		}
	}
}