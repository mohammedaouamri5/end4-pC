import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions
import qs.modules.ii.launcher

Scope {
    id: root

    Loader {
        id: launcherLoader
        active: GlobalStates.launcherOpen

        sourceComponent: PanelWindow {
            id: launcherWindow

            screen: GlobalStates.launcherScreen ?? Quickshell.screens[0]
            color: "transparent"
            exclusionMode: ExclusionMode.Ignore
            exclusiveZone: 0
            WlrLayershell.namespace: "quickshell:launcher"
            WlrLayershell.layer: WlrLayer.Overlay
            // The launcher is modal: take the keyboard from whatever was focused
            // before so typing always lands in the search field.
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }

            readonly property bool dimBackground: Config.options.launcher.dimBackground
            readonly property real contentY: {
                if (!content)
                    return 0
                if (Config.options.launcher.position === "center")
                    return Math.max(16, Math.min(launcherWindow.height - content.height - 16, (launcherWindow.height - content.height) / 2))
                return Math.max(56, Math.min(launcherWindow.height * 0.09, launcherWindow.height - content.height - 16))
            }

            Rectangle {
                anchors.fill: parent
                color: launcherWindow.dimBackground
                    ? LauncherStyle.backdropColor(Config.options.launcher.style, Config.options.launcher.dimAmount)
                    : "transparent"
                Behavior on color {
                    ColorAnimation { duration: 140 }
                }
            }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                onClicked: LauncherController.hide()
            }

            // Consume clicks on the card itself so they don't reach the backdrop.
            MouseArea {
                x: content.x
                y: content.y
                width: content.width
                height: content.height
                acceptedButtons: Qt.AllButtons
                onClicked: {}
            }

            LauncherContent {
                id: content
                y: launcherWindow.contentY
                anchors.horizontalCenter: parent.horizontalCenter

                opacity: 0
                scale: 0.97
                transformOrigin: Item.Center

                Component.onCompleted: {
                    opacity = 1
                    scale = 1
                    Qt.callLater(() => content.focusSearch())
                }

                Behavior on opacity {
                    NumberAnimation {
                        duration: Appearance.animation.elementMoveFast.duration
                        easing.type: Appearance.animation.elementMoveFast.type
                        easing.bezierCurve: Appearance.animation.elementMoveFast.bezierCurve
                    }
                }
                Behavior on scale {
                    NumberAnimation {
                        duration: Appearance.animation.elementMoveEnter.duration
                        easing.type: Appearance.animation.elementMoveEnter.type
                        easing.bezierCurve: Appearance.animation.elementMoveEnter.bezierCurve
                    }
                }
            }

            Component.onCompleted: {
                Qt.callLater(() => content.focusSearch())
            }
        }
    }

    IpcHandler {
        target: "launcher"

        function toggle(): void {
            LauncherController.toggle()
        }

        function open(): void {
            LauncherController.show()
        }

        function close(): void {
            LauncherController.hide()
        }

        function openWith(prefix: string): void {
            LauncherController.openWith(prefix)
        }
    }

    CompositorGlobalShortcut {
        name: "launcherToggle"
        description: "Toggles the application launcher"
        onPressed: LauncherController.toggle()
    }
}
