import Quickshell
import Quickshell.Io
import QtQuick
pragma Singleton

Singleton {
	id: root

	property var monitors: []

	property var appearance: {
		property var primaryColor: "#dd9f3f"
	}


}
