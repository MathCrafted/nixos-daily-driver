import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick

Scope {
	Variants {
		model: Quickshell.screens
		
		PanelWindow {
			property var modelData
			screen: modelData

			aboveWindows: false
			WlrLayershell.layer: WlrLayer.Background
			color: "transparent"
			implicitWidth: modelData.width
			implicitHeight: modelData.height
			anchors: {
				top: true
				bottom: true
				left: true
				right: true
			}

			Image {
				id: bg
				anchors.top: parent.top
				anchors.bottom: parent.bottom
				anchors.left: parent.left
				anchors.right: parent.right
				source: "assets/parallaxEevee_bg.png"
			}

			Image {
				id: mid
				source: "assets/parallaxEevee_mid.png"
			}

			Image {
				id: fg
				source: "assets/parallaxEevee_fg.png"
			}

			MouseArea {
				anchors.fill: parent
				enabled: true
				hoverEnabled: true
				onPositionChanged: e => {
					var parallaxScale = 5;
					var x = (e.x / parent.width - 0.5) * 2;
					var y = (e.y / parent.height - 0.5) * 2;
					
					mid.x = x * 2 * parallaxScale;
					mid.y = y * 2 * parallaxScale;
					
					fg.x = x * 5 * parallaxScale;
					fg.y = y * 5 * parallaxScale;
				}
			}
		}
	}
}
