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
    property string styleId: "split"

    readonly property bool hasEntry: root.entry !== null && root.entry !== undefined
    readonly property color foreground: LauncherStyle.textColor(root.styleId)
    readonly property color secondary: LauncherStyle.subtextColor(root.styleId)
    readonly property var actions: root.entry?.actions ?? []

    implicitWidth: 300

    Rectangle {
        anchors.fill: parent
        anchors.margins: 4
        radius: Appearance.rounding.large
        color: ColorUtils.transparentize(Appearance.colors.colLayer1, 0.35)
        border.width: 1
        border.color: ColorUtils.transparentize(Appearance.colors.colOutlineVariant, 0.65)
    }

    ColumnLayout {
        anchors {
            fill: parent
            margins: 18
        }
        spacing: 12

        StyledText {
            text: Translation.tr("Details")
            font.pixelSize: Appearance.font.pixelSize.smaller
            font.weight: Font.DemiBold
            font.letterSpacing: 1.2
            color: root.secondary
        }

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 84

            Rectangle {
                anchors.centerIn: parent
                width: 72
                height: 72
                radius: Appearance.rounding.large
                color: ColorUtils.transparentize(Appearance.colors.colPrimaryContainer, 0.15)

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
        }

        StyledText {
            Layout.fillWidth: true
            visible: root.hasEntry
            text: root.entry?.name ?? ""
            color: root.foreground
            font.pixelSize: Appearance.font.pixelSize.large
            font.weight: Font.DemiBold
            wrapMode: Text.Wrap
            maximumLineCount: 2
            elide: Text.ElideRight
        }

        StyledText {
            Layout.fillWidth: true
            visible: root.hasEntry && (root.entry?.type ?? "").length > 0
            text: root.entry?.type ?? ""
            color: LauncherStyle.accentColor(root.styleId)
            font.pixelSize: Appearance.font.pixelSize.smaller
            elide: Text.ElideRight
        }

        StyledText {
            Layout.fillWidth: true
            visible: root.hasEntry && (root.entry?.comment ?? "").length > 0
            text: root.entry?.comment ?? ""
            color: root.secondary
            font.pixelSize: Appearance.font.pixelSize.small
            wrapMode: Text.Wrap
            maximumLineCount: 5
            elide: Text.ElideRight
        }

        CliphistImage {
            Layout.fillWidth: true
            visible: root.hasEntry && root.entry?.clipboard === true && Cliphist.entryIsImage(root.entry?.rawValue ?? "")
            entry: root.entry?.rawValue ?? ""
            maxWidth: root.width - 36
            maxHeight: 140
        }

        StyledText {
            Layout.fillWidth: true
            visible: !root.hasEntry
            text: Translation.tr("Select an item to see its details")
            color: root.secondary
            font.pixelSize: Appearance.font.pixelSize.small
            wrapMode: Text.Wrap
        }

        StyledText {
            Layout.fillWidth: true
            visible: root.actions.length > 0
            text: Translation.tr("Actions")
            font.pixelSize: Appearance.font.pixelSize.smaller
            font.weight: Font.DemiBold
            font.letterSpacing: 1.2
            color: root.secondary
        }

        Repeater {
            model: root.actions

            delegate: RippleButton {
                required property var modelData

                Layout.fillWidth: true
                implicitHeight: 38
                buttonRadius: Appearance.rounding.normal
                colBackground: "transparent"
                colBackgroundHover: LauncherStyle.hoverColor(root.styleId)
                onClicked: LauncherController.run(root.entry, modelData)

                contentItem: RowLayout {
                    spacing: 10
                    MaterialSymbol {
                        text: modelData.iconName || "chevron_right"
                        iconSize: Appearance.font.pixelSize.larger
                        color: root.foreground
                    }
                    StyledText {
                        Layout.fillWidth: true
                        text: modelData.name ?? ""
                        color: root.foreground
                        font.pixelSize: Appearance.font.pixelSize.small
                        elide: Text.ElideRight
                    }
                }
            }
        }

        Item { Layout.fillHeight: true }
    }

    Component {
        id: materialIcon
        MaterialSymbol {
            text: root.entry?.iconName ?? ""
            iconSize: 42
            color: LauncherStyle.accentColor(root.styleId)
        }
    }

    Component {
        id: systemIcon
        IconImage {
            implicitSize: 48
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
}
