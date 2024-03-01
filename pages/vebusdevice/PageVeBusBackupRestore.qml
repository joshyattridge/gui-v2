/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	readonly property string serviceUid: BackendConnection.serviceUidForType("vebusbr")
	property string serialVbus

	VeQuickItem {
		id: _backupRestoreAction
		uid: root.serviceUid + "/Action"
	}

	VeQuickItem {
		id: _backupRestoreSerial
		uid: root.serviceUid + "/Serial"
		Component.onCompleted: {
			setValue(root.serialVbus)
		}
	}

	VeQuickItem {
		id: _backupName
		uid: root.serviceUid + "/BackupName"
	}

	VeQuickItem {
		id: _backupRestoreInfo
		uid: root.serviceUid + "/Info"
	}

	VeQuickItem {
		id: _backupRestoreError
		uid: root.serviceUid + "/Error"
		onValueChanged: {
			if (isValid){
				Global.showToastNotification(VenusOS.Notification_Warning, value, 10000)
			}
		}
	}

	VeQuickItem {
		id: _backupRestoreNotify
		uid: root.serviceUid + "/Notify"
		onValueChanged: {
			if (isValid){
				Global.showToastNotification(VenusOS.Notification_Info, value, 10000)
			}
		}
	}

	GradientListView {
		model: ObjectModel {

			ListButton {
				//% "Backup"
				text: qsTrId("backup")
				secondaryText: (
					//% "Press to backup"
					(_backupRestoreAction.value !== 1)? qsTrId("vebus_device_press_to_backup")
					//% "Backing up..."
					: qsTrId("backing_up") + (_backupRestoreInfo.isValid? " " + _backupRestoreInfo.value: "")
				)
				visible: _backupRestoreAction.isValid
				enabled: _backupRestoreAction.value === 0
				onClicked: {
					_backupRestoreAction.setValue(1)
				}
			}
			ListButton {
				//% "Restore"
				text: qsTrId("restore")
				secondaryText: (
					//% "Press to restore"
					(_backupRestoreAction.value !== 2)? (qsTrId("vebus_device_press_to_restore") + (_backupName.isValid ? " " + _backupName.value : ""))
					//% "Restoring..."
					: qsTrId("restoring") + (_backupRestoreInfo.isValid? " " + _backupRestoreInfo.value: "")
				)
				visible: _backupRestoreAction.isValid && _backupName.isValid
				enabled: _backupRestoreAction.value === 0
				onClicked: {
					_backupRestoreAction.setValue(2)
				}
			}
			ListButton {
				//% "Delete"
				text: qsTrId("delete")
				//% "Press to delete backup file"
				secondaryText: qsTrId("vebus_device_press_to_delete_backup_file")
				visible: _backupRestoreAction.isValid && _backupName.isValid
				enabled: _backupRestoreAction.value === 0
				onClicked: {
					_backupRestoreAction.setValue(3)
				}
			}
		}
	}
}
