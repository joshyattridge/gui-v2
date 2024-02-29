/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	readonly property string bindPrefix: Global.systemSettings.serviceUid

	property DataPoint _backupRestoreAction: DataPoint {
		source: "com.victronenergy.vebusbr/Action"
	}

	property DataPoint _backupName: DataPoint {
		source: "com.victronenergy.vebusbr/BackupName"
	}

	property DataPoint _backupRestoreInfo: DataPoint {
		source: "com.victronenergy.vebusbr/Info"
		onValueChanged: {
			if (valid){
				Global.showToastNotification(VenusOS.Notification_Info, value, 10000)
			}
		}
	}

	property DataPoint _backupRestoreError: DataPoint {
		source: "com.victronenergy.vebusbr/Error"
		onValueChanged: {
			if (valid){
				Global.showToastNotification(VenusOS.Notification_Warning, value, 10000)
			}
		}
	}

	GradientListView {
		model: ObjectModel {

			ListButton {
				//% "Backup"
				text: qsTrId("backup")
				//% "Press to backup"
				secondaryText: qsTrId("vebus_device_press_to_backup")
				visible: _backupRestoreAction.valid
				enabled: _backupRestoreAction.value === 0
				onClicked: {
					_backupRestoreAction.setValue(1)
				}
			}
			ListButton {
				//% "Restore"
				text: qsTrId("restore")
				//% "Press to restore"
				secondaryText: qsTrId("vebus_device_press_to_restore") + " " + _backupName.value
				visible: _backupRestoreAction.valid
				enabled: _backupRestoreAction.value === 0
				onClicked: {
					_backupRestoreAction.setValue(2)
				}
			}
			ListButton {
				//% "Delete backup file"
				text: qsTrId("delete_backup_file")
				//% "Press to delete backup file"
				secondaryText: qsTrId("vebus_device_press_to_delete_backup_file")
				visible: _backupRestoreAction.valid
				enabled: _backupRestoreAction.value === 0
				onClicked: {
					_backupRestoreAction.setValue(3)
				}
			}
		}
	}
}
