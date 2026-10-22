import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.services
import qs.modules.common
import qs.modules.common.widgets

ContentPage {
    id: page
    forceWidth: true
    bottomContentPadding: 15

    readonly property var pinnedApps: Config.options.launcher.pinnedApps ?? []
    readonly property var availableApps: {
        const pinned = new Set(page.pinnedApps)
        return Array.from(DesktopEntries.applications.values)
            .filter(entry => entry?.id && entry?.name && !pinned.has(entry.id))
            .sort((a, b) => a.name.localeCompare(b.name))
            .map(entry => ({
                displayName: entry.name,
                icon: entry.icon,
                value: entry.id
            }))
    }

    function addPinned(id) {
        if (!id || page.pinnedApps.includes(id)) return
        Config.options.launcher.pinnedApps = [...page.pinnedApps, id]
    }

    function removePinned(id) {
        Config.options.launcher.pinnedApps = page.pinnedApps.filter(appId => appId !== id)
    }

    function movePinned(index, delta) {
        const next = [...page.pinnedApps]
        const target = index + delta
        if (target < 0 || target >= next.length) return
        const [item] = next.splice(index, 1)
        next.splice(target, 0, item)
        Config.options.launcher.pinnedApps = next
    }

    function appFor(id) {
        return DesktopEntries.byId(id) ?? DesktopEntries.heuristicLookup(id)
    }

    ColumnLayout {
        Layout.fillWidth: true
        Layout.fillHeight: true
        spacing: 20

        ContentSection {
            icon: "apps"
            shape: MaterialShape.Shape.Cookie6Sided
            title: Translation.tr("Launcher")

            GroupedList {
                ConfigSwitch {
                    buttonIcon: "toggle_on"
                    text: Translation.tr("Enable the application launcher")
                    checked: Config.options.launcher.enable
                    onCheckedChanged: Config.options.launcher.enable = checked
                }

                ConfigComboBox {
                    buttonIcon: "palette"
                    text: Translation.tr("Style")
                    description: LauncherStyle.description(Config.options.launcher.style)
                    model: LauncherStyle.styles.map(style => ({
                        displayName: style.name,
                        icon: style.icon,
                        value: style.id
                    }))
                    currentValue: Config.options.launcher.style
                    onSelected: newValue => Config.options.launcher.style = newValue
                }

                ConfigComboBox {
                    buttonIcon: "vertical_align_top"
                    text: Translation.tr("Position")
                    model: [
                        { displayName: Translation.tr("Top"), icon: "vertical_align_top", value: "top" },
                        { displayName: Translation.tr("Center"), icon: "vertical_align_center", value: "center" }
                    ]
                    currentValue: Config.options.launcher.position
                    onSelected: newValue => Config.options.launcher.position = newValue
                }

                ConfigSpinBox {
                    icon: "width"
                    text: Translation.tr("Window width (px)")
                    value: Config.options.launcher.width
                    from: 420
                    to: 1000
                    stepSize: 20
                    onValueChanged: {
                        if (value !== Config.options.launcher.width)
                            Config.options.launcher.width = value
                    }
                }

                ConfigSpinBox {
                    icon: "format_list_numbered"
                    text: Translation.tr("Maximum results")
                    value: Config.options.launcher.maxResults
                    from: 5
                    to: 20
                    stepSize: 1
                    onValueChanged: {
                        if (value !== Config.options.launcher.maxResults)
                            Config.options.launcher.maxResults = value
                    }
                }
            }
        }

        ContentSection {
            icon: "tune"
            shape: MaterialShape.Shape.Gem
            title: Translation.tr("Behaviour")

            GroupedList {
                ConfigSwitch {
                    buttonIcon: "close"
                    text: Translation.tr("Close the launcher after launching an app")
                    checked: Config.options.launcher.closeOnPick
                    onCheckedChanged: Config.options.launcher.closeOnPick = checked
                }
                ConfigSwitch {
                    buttonIcon: "history"
                    text: Translation.tr("Keep the last query when reopening")
                    checked: Config.options.launcher.keepQuery
                    onCheckedChanged: Config.options.launcher.keepQuery = checked
                }
                ConfigSwitch {
                    buttonIcon: "push_pin"
                    text: Translation.tr("Show pinned apps when the query is empty")
                    checked: Config.options.launcher.showPinnedApps
                    onCheckedChanged: Config.options.launcher.showPinnedApps = checked
                }
                ConfigSwitch {
                    buttonIcon: "schedule"
                    text: Translation.tr("Show recently used apps when the query is empty")
                    checked: Config.options.launcher.showRecentApps
                    onCheckedChanged: Config.options.launcher.showRecentApps = checked
                }
                ConfigSwitch {
                    buttonIcon: "subject"
                    text: Translation.tr("Show descriptions under results")
                    checked: Config.options.launcher.showDescriptions
                    onCheckedChanged: Config.options.launcher.showDescriptions = checked
                }
                ConfigSwitch {
                    buttonIcon: "dark_mode"
                    text: Translation.tr("Dim the background while the launcher is open")
                    checked: Config.options.launcher.dimBackground
                    onCheckedChanged: Config.options.launcher.dimBackground = checked
                }
                ConfigSwitch {
                    buttonIcon: "blur_on"
                    text: Translation.tr("Translucent launcher background (compositor blur)")
                    checked: Config.options.launcher.blurBackground
                    onCheckedChanged: Config.options.launcher.blurBackground = checked
                }
                ConfigSpinBox {
                    icon: "opacity"
                    text: Translation.tr("Background dim amount (%)")
                    enabled: Config.options.launcher.dimBackground
                    value: Math.round(Config.options.launcher.dimAmount * 100)
                    from: 0
                    to: 60
                    stepSize: 5
                    onValueChanged: {
                        const amount = value / 100
                        if (amount !== Config.options.launcher.dimAmount)
                            Config.options.launcher.dimAmount = amount
                    }
                }
            }
        }

        ContentSection {
            icon: "manage_search"
            shape: MaterialShape.Shape.Puffy
            title: Translation.tr("Search sources")

            GroupedList {
                ConfigSwitch {
                    buttonIcon: "apps"
                    text: Translation.tr("Applications")
                    checked: Config.options.launcher.sources.apps
                    onCheckedChanged: Config.options.launcher.sources.apps = checked
                }
                ConfigSwitch {
                    buttonIcon: "select_window_2"
                    text: Translation.tr("Open windows")
                    checked: Config.options.launcher.sources.windows
                    onCheckedChanged: Config.options.launcher.sources.windows = checked
                }
                ConfigSwitch {
                    buttonIcon: "content_paste"
                    text: Translation.tr("Clipboard history")
                    checked: Config.options.launcher.sources.clipboard
                    onCheckedChanged: Config.options.launcher.sources.clipboard = checked
                }
                ConfigSwitch {
                    buttonIcon: "mood"
                    text: Translation.tr("Emojis")
                    checked: Config.options.launcher.sources.emojis
                    onCheckedChanged: Config.options.launcher.sources.emojis = checked
                }
                ConfigSwitch {
                    buttonIcon: "emoji_symbols"
                    text: Translation.tr("Material symbols")
                    checked: Config.options.launcher.sources.symbols
                    onCheckedChanged: Config.options.launcher.sources.symbols = checked
                }
                ConfigSwitch {
                    buttonIcon: "calculate"
                    text: Translation.tr("Math results")
                    checked: Config.options.launcher.sources.math
                    onCheckedChanged: Config.options.launcher.sources.math = checked
                }
                ConfigSwitch {
                    buttonIcon: "terminal"
                    text: Translation.tr("Shell commands")
                    checked: Config.options.launcher.sources.shellCommand
                    onCheckedChanged: Config.options.launcher.sources.shellCommand = checked
                }
                ConfigSwitch {
                    buttonIcon: "travel_explore"
                    text: Translation.tr("Web search")
                    checked: Config.options.launcher.sources.webSearch
                    onCheckedChanged: Config.options.launcher.sources.webSearch = checked
                }
                ConfigSwitch {
                    buttonIcon: "settings"
                    text: Translation.tr("Settings")
                    checked: Config.options.launcher.sources.settings
                    onCheckedChanged: Config.options.launcher.sources.settings = checked
                }
                ConfigSwitch {
                    buttonIcon: "keyboard"
                    text: Translation.tr("Keybinds")
                    checked: Config.options.launcher.sources.keybinds
                    onCheckedChanged: Config.options.launcher.sources.keybinds = checked
                }
                ConfigSwitch {
                    buttonIcon: "bolt"
                    text: Translation.tr("Actions")
                    checked: Config.options.launcher.sources.actions
                    onCheckedChanged: Config.options.launcher.sources.actions = checked
                }
            }
        }

        ContentSection {
            icon: "push_pin"
            shape: MaterialShape.Shape.Sunny
            title: Translation.tr("Pinned apps")

            StyledText {
                Layout.fillWidth: true
                visible: page.pinnedApps.length === 0
                text: Translation.tr("No pinned apps yet. Add one below.")
                color: Appearance.colors.colSubtext
                font.pixelSize: Appearance.font.pixelSize.small
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 6

                Repeater {
                    model: page.pinnedApps

                    delegate: Rectangle {
                        required property int index
                        required property var modelData

                        Layout.fillWidth: true
                        implicitHeight: 48
                        radius: Appearance.rounding.normal
                        color: Appearance.colors.colLayer1

                        RowLayout {
                            anchors {
                                fill: parent
                                leftMargin: 10
                                rightMargin: 6
                            }
                            spacing: 10

                            IconImage {
                                implicitSize: 24
                                source: SystemAppearance.iconPath(page.appFor(modelData)?.icon ?? "", "application-x-executable")
                            }

                            StyledText {
                                Layout.fillWidth: true
                                text: page.appFor(modelData)?.name ?? modelData
                                color: Appearance.colors.colOnLayer1
                                font.pixelSize: Appearance.font.pixelSize.small
                                elide: Text.ElideRight
                            }

                            IconToolbarButton {
                                text: "arrow_upward"
                                enabled: index > 0
                                implicitWidth: 30
                                implicitHeight: 30
                                onClicked: page.movePinned(index, -1)
                            }
                            IconToolbarButton {
                                text: "arrow_downward"
                                enabled: index < page.pinnedApps.length - 1
                                implicitWidth: 30
                                implicitHeight: 30
                                onClicked: page.movePinned(index, 1)
                            }
                            IconToolbarButton {
                                text: "close"
                                implicitWidth: 30
                                implicitHeight: 30
                                colText: Appearance.colors.colError
                                onClicked: page.removePinned(modelData)
                            }
                        }
                    }
                }
            }

            ConfigComboBox {
                Layout.fillWidth: true
                Layout.topMargin: 4
                buttonIcon: "add"
                text: Translation.tr("Add an app")
                description: page.availableApps.length > 0
                    ? Translation.tr("Choose an installed application to pin")
                    : Translation.tr("All installed applications are already pinned")
                model: page.availableApps
                textRole: "displayName"
                searchable: true
                currentValue: undefined
                enabled: page.availableApps.length > 0
                onSelected: newValue => page.addPinned(newValue)
            }

            StyledText {
                Layout.fillWidth: true
                text: Translation.tr("Pinned apps are the first entries you see when the launcher opens with an empty query.")
                color: Appearance.colors.colSubtext
                font.pixelSize: Appearance.font.pixelSize.smaller
                wrapMode: Text.Wrap
            }
        }

        ContentSection {
            icon: "keyboard"
            shape: MaterialShape.Shape.Slanted
            title: Translation.tr("Shortcut")

            StyledText {
                Layout.fillWidth: true
                text: Translation.tr("Bind this command in your compositor to open the launcher:")
                color: Appearance.colors.colSubtext
                font.pixelSize: Appearance.font.pixelSize.small
                wrapMode: Text.Wrap
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 44
                radius: Appearance.rounding.normal
                color: Appearance.colors.colLayer1

                RowLayout {
                    anchors {
                        fill: parent
                        leftMargin: 12
                        rightMargin: 6
                    }
                    spacing: 10

                    StyledText {
                        Layout.fillWidth: true
                        text: "qs -c end4-pC ipc call launcher toggle"
                        color: Appearance.colors.colOnLayer1
                        font.family: Appearance.font.family.monospace
                        font.pixelSize: Appearance.font.pixelSize.small
                        elide: Text.ElideRight
                    }

                    IconToolbarButton {
                        text: "content_copy"
                        implicitWidth: 32
                        implicitHeight: 32
                        onClicked: Quickshell.clipboardText = "qs -c end4-pC ipc call launcher toggle"
                    }
                }
            }

            StyledText {
                Layout.fillWidth: true
                text: Translation.tr("The global shortcut name is “quickshell:launcherToggle”. The IPC target is “launcher”.")
                color: Appearance.colors.colSubtext
                font.pixelSize: Appearance.font.pixelSize.smaller
                wrapMode: Text.Wrap
            }

            RippleButton {
                Layout.fillWidth: true
                implicitHeight: 40
                buttonRadius: Appearance.rounding.normal
                colBackground: Appearance.colors.colPrimaryContainer
                colBackgroundHover: Appearance.colors.colPrimaryContainerHover
                colRipple: Appearance.colors.colPrimaryContainerActive
                onClicked: LauncherController.show()

                contentItem: RowLayout {
                    spacing: 8
                    MaterialSymbol {
                        text: "open_in_new"
                        iconSize: Appearance.font.pixelSize.larger
                        color: Appearance.colors.colOnPrimaryContainer
                    }
                    StyledText {
                        Layout.fillWidth: true
                        text: Translation.tr("Test the launcher")
                        color: Appearance.colors.colOnPrimaryContainer
                        font.pixelSize: Appearance.font.pixelSize.small
                    }
                }
            }
        }
    }
}
