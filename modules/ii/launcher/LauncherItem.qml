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
    property string styleId: "material"
    property bool showSection: false

    signal activated()
    signal actionsRequested()
    signal pointerEntered()

    readonly property bool isHovered: mouseArea.containsMouse
    readonly property color foreground: selected
        ? LauncherStyle.selectionTextColor(root.styleId)
        : LauncherStyle.textColor(root.styleId)
    readonly property color secondary: selected
        ? ColorUtils.transparentize(root.foreground, 0.22)
        : LauncherStyle.subtextColor(root.styleId)
    readonly property int rowHeight: LauncherStyle.rowHeight(root.styleId)
    readonly property bool showDescription: Config.options.launcher.showDescriptions && LauncherStyle.showDescriptions(root.styleId)
    readonly property string section: root.entry?.section ?? ""
    readonly property bool sectionVisible: root.showSection && root.section.length > 0

    implicitHeight: contentColumn.implicitHeight + 6

    Rectangle {
        anchors.fill: parent
        radius: LauncherStyle.rowRadius(root.styleId)
        color: root.selected
            ? LauncherStyle.selectionColor(root.styleId)
            : (root.isHovered ? LauncherStyle.hoverColor(root.styleId) : "transparent")
        Behavior on color {
            ColorAnimation { duration: 120 }
        }
    }

    Column {
        id: contentColumn
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            leftMargin: LauncherStyle.rowHorizontalPadding(root.styleId)
            rightMargin: LauncherStyle.rowHorizontalPadding(root.styleId)
            topMargin: 1
        }
        spacing: 1

        Item {
            width: parent.width
            height: root.sectionVisible ? 22 : 0
            visible: root.sectionVisible

            StyledText {
                id: sectionLabel
                anchors {
                    left: parent.left
                    verticalCenter: parent.verticalCenter
                }
                text: root.section.toUpperCase()
                font.pixelSize: Appearance.font.pixelSize.smaller
                font.weight: Font.DemiBold
                font.letterSpacing: 1.2
                color: LauncherStyle.subtextColor(root.styleId)
            }

            Rectangle {
                anchors {
                    left: sectionLabel.right
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                    leftMargin: 10
                }
                height: 1
                color: LauncherStyle.separatorColor(root.styleId)
            }
        }

        RowLayout {
            width: parent.width
            height: root.rowHeight
            spacing: 10

            Loader {
                Layout.alignment: Qt.AlignVCenter
                Layout.preferredWidth: LauncherStyle.iconSize(root.styleId)
                Layout.preferredHeight: LauncherStyle.iconSize(root.styleId)
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

            ColumnLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                spacing: 0

                StyledText {
                    Layout.fillWidth: true
                    text: root.entry?.name ?? ""
                    color: root.foreground
                    font.pixelSize: LauncherStyle.titleSize(root.styleId)
                    font.family: LauncherStyle.fontFamily(root.styleId)
                    elide: Text.ElideRight
                    maximumLineCount: 1
                }

                StyledText {
                    Layout.fillWidth: true
                    visible: root.showDescription && (root.entry?.comment ?? "").length > 0
                    text: root.entry?.comment ?? ""
                    color: root.secondary
                    font.pixelSize: LauncherStyle.subtitleSize(root.styleId)
                    font.family: LauncherStyle.fontFamily(root.styleId)
                    elide: Text.ElideRight
                    maximumLineCount: 1
                }
            }

            StyledText {
                Layout.alignment: Qt.AlignVCenter
                Layout.maximumWidth: 140
                visible: (root.entry?.verb ?? "").length > 0 && (root.selected || root.entry?.type === Translation.tr("Keybind"))
                text: root.entry?.verb ?? ""
                color: root.secondary
                font.pixelSize: LauncherStyle.subtitleSize(root.styleId)
                elide: Text.ElideRight
            }
        }
    }

    Component {
        id: materialIcon
        MaterialSymbol {
            anchors.centerIn: parent
            text: root.entry?.iconName ?? ""
            iconSize: LauncherStyle.iconSize(root.styleId)
            color: root.selected ? root.foreground : LauncherStyle.accentColor(root.styleId)
        }
    }

    Component {
        id: systemIcon
        IconImage {
            anchors.centerIn: parent
            implicitSize: LauncherStyle.iconSize(root.styleId)
            source: SystemAppearance.iconPath(root.entry?.iconName ?? "", "application-x-executable")
        }
    }

    Component {
        id: textIcon
        StyledText {
            anchors.centerIn: parent
            text: root.entry?.iconName ?? ""
            color: root.foreground
            font.pixelSize: Appearance.font.pixelSize.larger
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onEntered: {
            root.pointerEntered()
        }
        onExited: {}
        onClicked: event => {
            if (event.button === Qt.RightButton && (root.entry?.actions?.length ?? 0) > 0)
                root.actionsRequested()
            else if (event.button === Qt.LeftButton)
                root.activated()
        }
    }
}
