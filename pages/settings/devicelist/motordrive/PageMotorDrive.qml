/*
** Copyright (C) 2023 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil
import "/components/Utils.js" as Utils
import "/components/Units.js" as Units

Page {
	id: root

	property string bindPrefix

	GradientListView {
		model: ObjectModel {
			ListQuantityItem {
				//% "Motor RPM"
				text: qsTrId("devicelist_motordrive_motorrpm")
				dataSource: root.bindPrefix + "/Motor/RPM"
				unit: VenusOS.Units_RevolutionsPerMinute
			}

			ListQuantityItem {
				//% "Motor Temperature"
				text: qsTrId("devicelist_motordrive_motortemperature")
				dataSource: root.bindPrefix + "/Motor/Temperature"
				unit: !!Global.systemSettings.temperatureUnit.value ? Global.systemSettings.temperatureUnit.value : VenusOS.Units_Temperature_Celsius
				value: dataValue === undefined ? NaN
					: unit === VenusOS.Units_Temperature_Celsius ? dataValue
					: Units.celsiusToFahrenheit(dataValue)
			}

			ListQuantityItem {
				text: CommonWords.power_watts
				dataSource: root.bindPrefix + "/Dc/0/Power"
				unit: VenusOS.Units_Watt
			}

			ListQuantityItem {
				text: CommonWords.voltage
				dataSource: root.bindPrefix + "/Dc/0/Voltage"
				unit: VenusOS.Units_Volt
				precision: 2
			}

			ListQuantityItem {
				text: CommonWords.current_amps
				dataSource: root.bindPrefix + "/Dc/0/Current"
				unit: VenusOS.Units_Amp
				precision: 2
			}

			ListQuantityItem {
				//% "Controller Temperature"
				text: qsTrId("devicelist_motordrive_controllertemperature")
				dataSource: root.bindPrefix + "/Controller/Temperature"
				unit: !!Global.systemSettings.temperatureUnit.value ? Global.systemSettings.temperatureUnit.value : VenusOS.Units_Temperature_Celsius
				value: dataValue === undefined ? NaN
					: unit === VenusOS.Units_Temperature_Celsius ? dataValue
					: Units.celsiusToFahrenheit(dataValue)
			}

			ListNavigationItem {
				text: CommonWords.device_info_title
				onClicked: {
					Global.pageManager.pushPage("/pages/settings/PageDeviceInfo.qml",
							{ "title": text, "bindPrefix": root.bindPrefix })
				}
			}
		}
	}
}
