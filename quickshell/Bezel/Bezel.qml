import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import qs

Scope {
	id: root

	Variants {
		model: Quickshell.screens

		PanelWindow {
			id: panelTop
			property var modelData
			screen: modelData

			property int bezelThickness: 10
			property var bezelColor: Global.appearance.primaryColor
			
			color: "transparent"
			anchors.top: true
			anchors.bottom: true
			anchors.left: true
			anchors.right: true
			

			mask: Region {
				item: mask
				intersection: Intersection.Subtract
			}

			Rectangle {
				id: rectTop
				implicitHeight: bezelThickness
				anchors.top: parent.top
				anchors.left: parent.left
				anchors.right: parent.right
				color: bezelColor
			}
			Rectangle {
				id: rectLeft
				implicitWidth: bezelThickness
				anchors.top: rectTop.bottom
				anchors.left: parent.left
				anchors.bottom: parent.bottom
				color: bezelColor
			}
			Rectangle {
				id: rectRight
				implicitWidth: bezelThickness
				anchors.top: rectTop.bottom
				anchors.bottom: parent.bottom
				anchors.right: parent.right
				color: bezelColor
			}
			Rectangle {
				id: rectBottom
				implicitHeight: bezelThickness
				anchors.bottom: parent.bottom
				anchors.left: rectLeft.right
				anchors.right: rectRight.left
				color: bezelColor
			}
			Rectangle {
				id: mask
				anchors.top: rectTop.bottom
				anchors.left: rectLeft.right
				anchors.right: rectRight.left
				anchors.bottom: rectBottom.top
				//anchors.centerIn: parent
				//width: 1900
				//height: 1000
				radius: 25
				color: "transparent"
			}
		}
	}
}
