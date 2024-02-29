/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	readonly property string bindPrefix: Global.systemSettings.serviceUid

	VeQuickItem {
		id: _backupRestoreAction
		uid: "com.victronenergy.vebusbr/Action"
	}

	VeQuickItem {
		id: _backupName
		uid: "com.victronenergy.vebusbr/BackupName"
	}

	VeQuickItem {
		id: _backupRestoreInfo
		uid: "com.victronenergy.vebusbr/Info"
		onValueChanged: {
			if (valid){
				Global.showToastNotification(VenusOS.Notification_Info, value, 10000)
			}
		}
	}

	VeQuickItem {
		id: _backupRestoreError
		uid: "com.victronenergy.vebusbr/Error"
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
