/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	property Instantiator objects: Instantiator {
		model: VeQItemTableModel {
			uids: ["mqtt/acsystem"]
			flags: VeQItemTableModel.AddChildren | VeQItemTableModel.AddNonLeaves | VeQItemTableModel.DontAddItem
		}
		delegate: AcSystemDevice {
			serviceUid: model.uid
		}
	}
}
