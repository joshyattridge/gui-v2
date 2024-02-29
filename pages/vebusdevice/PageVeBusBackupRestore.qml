/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	readonly property string bindPrefix: Global.systemSettings.serviceUid

	// property DataPoint _backuprestoreState: DataPoint {
	// 	source: "com.victronenergy.backuprestore/Quattromulti/State"
	// 	onValueChanged: {
	// 		if (value === 3) Global.showToastNotification(VenusOS.Notification_Warning, _backuprestoreError.value, 10000)
	// 		else if (value === 4) Global.showToastNotification(VenusOS.Notification_Info, backup_complete, 10000)
	// 		else if (value === 5) Global.showToastNotification(VenusOS.Notification_Info, restore_complete, 10000)
	// 	}
	// }

	GradientListView {
		model: ObjectModel {

			ListButton {
				//% "Backup"
				text: qsTrId("backup")
				//% "Press to backup"
				secondaryText: qsTrId("vebus_device_press_to_backup")
				// visible: _backuprestoreState.valid
				// onClicked: {
				// 	//% "Updating the MK3, values will reappear after the update is complete"
				// 	Global.showToastNotification(VenusOS.Notification_Info, qsTrId("vebus_device_updating_the_mk3"), 10000)
				// 	mk3firmware.doUpdate()
				// }
			}
		}
	}
}
