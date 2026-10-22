import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs
import qs.services
import qs.modules.common
import qs.modules.common.models
import qs.modules.common.widgets
import qs.modules.common.functions

Item {
    id: root

    property var entry: null
    property bool selected: false
    property string styleId: "grid"

    signal activated()
    signal actionsRequested()
    signal pointerEntered()

    readonly property bool isHovered: mouseArea.containsMouse
    readonly property color foreground: root.selected
        ? LauncherStyle.selectionTextColor(root.styleId)
        : LauncherStyle.textColor(root.styleId)
    readonly property int tileIconSize: root.styleId === "grid" ? 46 : 38

    implicitHeight: LauncherStyle.tileHeight(root.styleId)

    Rectangle {
        anchors.fill: parent
        anchors.margins: 3
        radius: Appearance.rounding.large
        color: root.selected
            ? LauncherStyle.selectionColor(root.styleId)
            : (root.isHovered ? LauncherStyle.hoverColor(root.styleId) : "transparent")
        border.width: root.selected ? 0 : 1
        border.color: ColorUtils.transparentize(Appearance.colors.colOutlineVariant, 0.82)
        Behavior on color {
            ColorAnimation { duration: 120 }
        }
    }

    ColumnLayout {
        anchors {
            fill: parent
            margins: 10
        }
        spacing: 4

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            Loader {
                anchors.centerIn: parent
                sourceComponent: {
                    const type = root.entry?.iconType
                    if (type === LauncherSearchResult.IconType.Material)
                        return materialIcon
                    if (type === LauncherSearchResult.IconType.System)
                        return systemIcon
                    if (type === LauncherSearchResult.IconType.Text)
                        return textIcon
                    return null
                }
            }
        }

        StyledText {
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            text: root.entry?.name ?? ""
            color: root.foreground
            font.pixelSize: Appearance.font.pixelSize.small
            elide: Text.ElideRight
            maximumLineCount: 2
            wrapMode: Text.Wrap
        }
    }

    Component {
        id: materialIcon
        MaterialSymbol {
            text: root.entry?.iconName ?? ""
            iconSize: root.tileIconSize
            color: root.selected ? root.foreground : LauncherStyle.accentColor(root.styleId)
        }
    }

    Component {
        id: systemIcon
        IconImage {
            implicitSize: root.tileIconSize
            source: SystemAppearance.iconPath(root.entry?.iconName ?? "", "application-x-executable")
        }
    }

    Component {
        id: textIcon
        StyledText {
            text: root.entry?.iconName ?? ""
            color: root.foreground
            font.pixelSize: Appearance.font.pixelSize.huge
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onEntered: root.pointerEntered()
        onClicked: event => {
            if (event.button === Qt.RightButton && (root.entry?.actions?.length ?? 0) > 0)
                root.actionsRequested()
            else if (event.button === Qt.LeftButton)
                root.activated()
        }
    }
}
