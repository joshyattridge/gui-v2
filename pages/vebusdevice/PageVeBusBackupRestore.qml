/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

function get_mk2vsc_state(state) {
	switch (state) {
		case 10: return qsTrId("mk2vsc_state_init")
		case 11: return qsTrId("mk2vsc_state_query_products")
		case 12: return qsTrId("mk2vsc_state_done")
		case 21: return qsTrId("mk2vsc_state_read_setting_data")
		case 22: return qsTrId("Read assistants")
		case 23: return qsTrId("Read VE.Bus configuration")
		case 24: return qsTrId("Read grid info")
		case 30: return qsTrId("Write settings info")
		case 31: return qsTrId("Write Settings Data")
		case 32: return qsTrId("Write assistants")
		case 33: return qsTrId("Write VE.Bus configuration")
		case 40: return qsTrId("Resetting VE.Bus products")
		default: return qsTrId("Unknown")
	}
}

function get_mk2vsc_error(error) {
	switch (error) {
		case 30: return qsTrId("MK2/MK3 communication error")
		case 31: return qsTrId("Product address not reachable")
		case 32: return qsTrId("Incompatible MK2 firmware version")
		case 33: return qsTrId("No VE.Bus product was found")
		case 34: return qsTrId("Too many devices on the VE.Bus")
		case 35: return qsTrId("Timed out")
		case 36: return qsTrId("Wrong password")
		case 40: return qsTrId("Malloc error")
		case 45: return qsTrId("Uploaded file does not contain settings data for the connected unit")
		case 46: return qsTrId("Uploaded file does not match model and/or installed firmware version")
		case 47: return qsTrId("More than one unknown unit detected")
		case 48: return qsTrId("Updating a single unit with another unit's settings is not possible, even if they are of the same type")
		case 49: return qsTrId("The number of units in file does not match the number of units discovered")
		case 50: return qsTrId("File open error")
		case 51: return qsTrId("File write error")
		case 52: return qsTrId("File read error")
		case 53: return qsTrId("File checksum error")
		case 54: return qsTrId("File incompatible version number")
		case 55: return qsTrId("File section not found")
		case 56: return qsTrId("File format error")
		case 57: return qsTrId("Product number does not match file")
		case 58: return qsTrId("File expired")
		case 59: return qsTrId("Wrong file format. First open the file with VE.Bus System Configurator, then save it to a new file by closing VE.Configure")
		case 60: return qsTrId("VE.Bus write of assistant enable/disable setting failed")
		case 61: return qsTrId("Incompatible VE.Bus system configuration. Writing system configuration failed")
		case 62: return qsTrId("Cannot read settings. VE.Bus system not configured")
		case 70: return qsTrId("Assistants write failed")
		case 71: return qsTrId("Assistants read failed")
		case 72: return qsTrId("Grid info read failed")
		case 100: return qsTrId("OSerror, unknown application")
		case 201: return qsTrId("Failed to open com port(no response)")
		default: return qsTrId("Unknown")
	}
}

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
				Global.showToastNotification(VenusOS.Notification_Warning, get_mk2vsc_error(value), 10000)
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
					: qsTrId("backing_up") + (_backupRestoreInfo.isValid? " " + get_mk2vsc_state(_backupRestoreInfo.value): "")
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
					: qsTrId("restoring") + (_backupRestoreInfo.isValid? " " + get_mk2vsc_state(_backupRestoreInfo.value): "")
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
