/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.Velib
import Victron.VenusOS
import "/components/Utils.js" as Utils
import "../data"

ArcGauge {
	width: Theme.geometry.briefPage.edgeGauge.width
	alignment: Qt.AlignRight
	direction: PathArc.Counterclockwise
	startAngle: 90 + 24
	endAngle: 90 + 3
	radius: Theme.geometry.briefPage.edgeGauge.radius
	strokeWidth: Theme.geometry.arc.strokeWidth
	value: system ? system.loads.power / Utils.maximumValue("system.loads.power") * 100 : 0
	arcY: -radius + strokeWidth/2

	ValueDisplay {
		anchors {
			right: parent.right
			rightMargin: Theme.geometry.loadMiniGauge.label.rightMargin
			top: parent.top
			topMargin: Theme.geometry.loadMiniGauge.label.topMargin
		}
		title.text: qsTrId("brief_loads")
		physicalQuantity: Units.Power
		value: system ? system.loads.power : 0
		icon.source: "qrc:/images/consumption.svg"
		alignment: Qt.AlignRight
		fontSize: Theme.briefPage.gauge.label.font.size
	}
}