import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import qs
import qs.services
import qs.modules.common
import qs.modules.common.models
import qs.modules.common.widgets
import qs.modules.common.functions

Item {
    id: root

    property var screen: GlobalStates.launcherScreen
    property string styleId: Config.options.launcher.style

    property string query: LauncherSearch.query ?? ""
    readonly property bool hasQuery: root.query.trim().length > 0
    readonly property bool gridMode: LauncherStyle.layout(root.styleId) === "grid" && !root.hasQuery
    readonly property bool splitMode: LauncherStyle.layout(root.styleId) === "split"
    readonly property var entries: {
        if (root.hasQuery)
            return (LauncherSearch.results ?? []).slice(0, Config.options.launcher.maxResults)
        return LauncherController.emptyEntries
    }
    readonly property var currentEntry: root.entries[root.selectedIndex] ?? null
    readonly property var actionEntry: root.actionsOpen ? root.actionEntryInternal : null

    property int selectedIndex: 0
    property bool actionsOpen: false
    property var actionEntryInternal: null
    property int actionIndex: 0

    readonly property real availableWidth: (root.screen?.width ?? 1920) - 48
    readonly property real panelWidth: Math.min(root.availableWidth, Math.max(LauncherStyle.panelWidth(root.styleId), Config.options.launcher.width))
    readonly property real maxListHeight: Math.max(LauncherStyle.rowHeight(root.styleId) * 4,
        Math.min((root.screen?.height ?? 1080) * 0.52, LauncherStyle.rowHeight(root.styleId) * Config.options.launcher.maxResults + 24))
    readonly property real cardPadding: LauncherStyle.padding(root.styleId)

    implicitWidth: root.panelWidth
    implicitHeight: card.implicitHeight

    Component.onCompleted: {
        root.focusSearch()
    }

    // Fallback for when the search field is not the focused item.
    Keys.onPressed: event => {
        if (event.key === Qt.Key_Escape) {
            if (root.actionsOpen) {
                root.closeActions()
            } else {
                LauncherController.hide()
            }
            event.accepted = true
        }
    }

    // Only a query change resets the selection; async result refreshes must not.
    onQueryChanged: {
        root.selectedIndex = 0
        if (root.actionsOpen)
            root.closeActions()
    }

    onEntriesChanged: {
        if (root.selectedIndex >= root.entries.length)
            root.selectedIndex = Math.max(0, root.entries.length - 1)
    }

    onSelectedIndexChanged: {
        if (root.resultList)
            root.resultList.positionViewAtIndex(root.selectedIndex, ListView.Contain)
        if (root.gridView)
            root.gridView.positionViewAtIndex(root.selectedIndex, GridView.Contain)
    }

    function focusSearch() {
        Qt.callLater(() => {
            // Keep the field in sync with a preserved query (keepQuery option).
            if (searchInput.text !== (LauncherSearch.query ?? ""))
                searchInput.text = LauncherSearch.query ?? ""
            searchInput.forceActiveFocus()
            searchInput.cursorPosition = searchInput.text.length
        })
    }

    function moveSelection(delta) {
        if (root.actionsOpen) {
            const count = (root.actionEntryInternal?.actions ?? []).length
            if (count === 0) return
            root.actionIndex = (root.actionIndex + delta + count) % count
            return
        }
        if (root.entries.length === 0) return
        root.selectedIndex = (root.selectedIndex + delta + root.entries.length) % root.entries.length
    }

    function activateCurrent() {
        if (root.actionsOpen) {
            root.activateAction()
            return
        }
        const entry = root.currentEntry
        if (entry)
            LauncherController.run(entry)
    }

    function activateAction() {
        const actions = root.actionEntryInternal?.actions ?? []
        const action = actions[root.actionIndex]
        if (action && root.actionEntryInternal)
            LauncherController.run(root.actionEntryInternal, action)
    }

    function openActions() {
        const entry = root.currentEntry
        if (!entry || (entry.actions ?? []).length === 0) return
        root.actionEntryInternal = entry
        root.actionsOpen = true
        root.actionIndex = 0
        searchInput.forceActiveFocus()
    }

    function closeActions() {
        root.actionsOpen = false
        root.actionEntryInternal = null
        root.actionIndex = 0
        searchInput.forceActiveFocus()
    }

    function completeSelection() {
        const entry = root.currentEntry
        if (!entry) return
        searchInput.text = entry.name
        searchInput.cursorPosition = searchInput.text.length
    }

    Rectangle {
        id: card
        anchors.fill: parent
        implicitWidth: root.panelWidth
        implicitHeight: contentColumn.implicitHeight + root.cardPadding * 2
        radius: LauncherStyle.cardRadius(root.styleId)
        color: LauncherStyle.cardColor(root.styleId)
        border.width: LauncherStyle.borderWidth(root.styleId)
        border.color: LauncherStyle.borderColor(root.styleId)

        ColumnLayout {
            id: contentColumn
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: root.cardPadding
            }
            spacing: 0

            Rectangle {
                id: searchField
                Layout.fillWidth: true
                Layout.preferredHeight: LauncherStyle.headerHeight(root.styleId)
                radius: LauncherStyle.fieldRadius(root.styleId)
                color: LauncherStyle.fieldColor(root.styleId)

                RowLayout {
                    anchors {
                        fill: parent
                        leftMargin: root.styleId === "spotlight" ? 0 : 16
                        rightMargin: root.styleId === "spotlight" ? 0 : 10
                    }
                    spacing: 10

                    MaterialSymbol {
                        Layout.alignment: Qt.AlignVCenter
                        text: LauncherStyle.searchIcon(root.styleId)
                        iconSize: root.styleId === "spotlight"
                            ? Appearance.font.pixelSize.huge
                            : Appearance.font.pixelSize.larger
                        color: LauncherStyle.accentColor(root.styleId)
                    }

                    TextField {
                        id: searchInput
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        padding: 0
                        leftPadding: 0
                        rightPadding: 0
                        verticalAlignment: TextInput.AlignVCenter
                        placeholderText: LauncherStyle.placeholder(root.styleId)
                        placeholderTextColor: LauncherStyle.subtextColor(root.styleId)
                        color: LauncherStyle.textColor(root.styleId)
                        selectionColor: LauncherStyle.selectionColor(root.styleId)
                        selectedTextColor: LauncherStyle.selectionTextColor(root.styleId)
                        background: null
                        font {
                            family: LauncherStyle.fontFamily(root.styleId)
                            pixelSize: LauncherStyle.searchTextSize(root.styleId)
                            hintingPreference: Font.PreferFullHinting
                            variableAxes: root.styleId === "terminal" ? ({}) : Appearance.font.variableAxes.main
                        }
                        renderType: Text.NativeRendering
                        clip: true
                        onTextChanged: {
                            if (LauncherSearch.query !== text)
                                LauncherSearch.query = text
                        }

                        Keys.onPressed: event => {
                            if (root.actionsOpen) {
                                if (event.key === Qt.Key_Down) {
                                    root.moveSelection(1)
                                    event.accepted = true
                                } else if (event.key === Qt.Key_Up) {
                                    root.moveSelection(-1)
                                    event.accepted = true
                                } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                    root.activateAction()
                                    event.accepted = true
                                } else if (event.key === Qt.Key_Escape) {
                                    root.closeActions()
                                    event.accepted = true
                                }
                                return
                            }

                            switch (event.key) {
                                case Qt.Key_Down:
                                case Qt.Key_PageDown:
                                    root.moveSelection(1)
                                    event.accepted = true
                                    break
                                case Qt.Key_Up:
                                case Qt.Key_PageUp:
                                    root.moveSelection(-1)
                                    event.accepted = true
                                    break
                                case Qt.Key_Return:
                                case Qt.Key_Enter:
                                    if (event.modifiers & Qt.ControlModifier)
                                        root.openActions()
                                    else
                                        root.activateCurrent()
                                    event.accepted = true
                                    break
                                case Qt.Key_Tab:
                                    root.completeSelection()
                                    event.accepted = true
                                    break
                                case Qt.Key_Escape:
                                    LauncherController.hide()
                                    event.accepted = true
                                    break
                            }
                        }
                    }

                    RippleButton {
                        Layout.alignment: Qt.AlignVCenter
                        visible: searchInput.text.length > 0
                        implicitWidth: 30
                        implicitHeight: 30
                        buttonRadius: Appearance.rounding.full
                        colBackground: "transparent"
                        colBackgroundHover: LauncherStyle.hoverColor(root.styleId)
                        onClicked: {
                            searchInput.text = ""
                            searchInput.forceActiveFocus()
                        }

                        contentItem: MaterialSymbol {
                            anchors.centerIn: parent
                            text: "close"
                            iconSize: 18
                            color: LauncherStyle.subtextColor(root.styleId)
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.topMargin: 8
                Layout.bottomMargin: 6
                height: 1
                visible: root.styleId !== "spotlight"
                color: LauncherStyle.separatorColor(root.styleId)
            }

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: root.actionsOpen
                    ? Math.min(root.maxListHeight, Math.max(1, actionsList.contentHeight))
                    : (root.gridMode
                        ? Math.min(root.maxListHeight, Math.max(1, gridView.contentHeight))
                        : (root.entries.length === 0
                            ? 116
                            : Math.min(root.maxListHeight, Math.max(1, resultList.contentHeight))))

                RowLayout {
                    id: resultsRow
                    anchors.fill: parent
                    visible: !root.actionsOpen && !root.gridMode && root.entries.length > 0
                    spacing: 12

                    ListView {
                        id: resultList
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        model: root.entries
                        currentIndex: root.selectedIndex
                        spacing: LauncherStyle.rowSpacing(root.styleId)
                        clip: true
                        boundsBehavior: Flickable.StopAtBounds
                        interactive: contentHeight > height

                        delegate: LauncherItem {
                            required property int index
                            required property var modelData

                            width: resultList.width
                            entry: modelData
                            selected: index === root.selectedIndex
                            styleId: root.styleId
                            showSection: index === 0
                                || (root.entries[index - 1]?.section ?? "") !== (modelData?.section ?? "")

                            onPointerEntered: root.selectedIndex = index
                            onActivated: {
                                root.selectedIndex = index
                                LauncherController.run(modelData)
                            }
                            onActionsRequested: {
                                root.selectedIndex = index
                                root.openActions()
                            }
                        }
                    }

                    LauncherPreview {
                        visible: root.splitMode
                        Layout.preferredWidth: 268
                        Layout.fillHeight: true
                        entry: root.currentEntry
                        styleId: root.styleId
                    }
                }

                GridView {
                    id: gridView
                    anchors.fill: parent
                    visible: !root.actionsOpen && root.gridMode && root.entries.length > 0
                    model: root.entries
                    cellWidth: width / LauncherStyle.gridColumns(root.styleId)
                    cellHeight: LauncherStyle.tileHeight(root.styleId)
                    currentIndex: root.selectedIndex
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds
                    interactive: contentHeight > height

                    delegate: LauncherTile {
                        required property int index
                        required property var modelData

                        width: gridView.cellWidth
                        height: gridView.cellHeight
                        entry: modelData
                        selected: index === root.selectedIndex
                        styleId: root.styleId

                        onPointerEntered: root.selectedIndex = index
                        onActivated: {
                            root.selectedIndex = index
                            LauncherController.run(modelData)
                        }
                        onActionsRequested: {
                            root.selectedIndex = index
                            root.openActions()
                        }
                    }
                }

                ListView {
                    id: actionsList
                    anchors.fill: parent
                    visible: root.actionsOpen
                    model: root.actionEntryInternal?.actions ?? []
                    currentIndex: root.actionIndex
                    spacing: LauncherStyle.rowSpacing(root.styleId)
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds

                    delegate: LauncherItem {
                        required property int index
                        required property var modelData

                        width: actionsList.width
                        entry: modelData
                        selected: index === root.actionIndex
                        styleId: root.styleId
                        showSection: false

                        onPointerEntered: root.actionIndex = index
                        onActivated: {
                            root.actionIndex = index
                            root.activateAction()
                        }
                    }
                }

                ColumnLayout {
                    anchors {
                        left: parent.left
                        right: parent.right
                        top: parent.top
                    }
                    visible: !root.actionsOpen && root.entries.length === 0
                    spacing: 6

                    StyledText {
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        text: root.hasQuery
                            ? Translation.tr("No results")
                            : Translation.tr("No pinned or recent apps")
                        color: LauncherStyle.textColor(root.styleId)
                        font.pixelSize: Appearance.font.pixelSize.large
                        font.weight: Font.DemiBold
                    }

                    StyledText {
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        text: root.hasQuery
                            ? Translation.tr("Try another search, or use a prefix like “/” or “>”")
                            : Translation.tr("Pin apps in Settings → Launcher to see them here")
                        color: LauncherStyle.subtextColor(root.styleId)
                        font.pixelSize: Appearance.font.pixelSize.small
                        wrapMode: Text.Wrap
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: 8
                visible: LauncherStyle.showFooter(root.styleId)
                spacing: 14

                StyledText {
                    text: "↑↓"
                    color: LauncherStyle.subtextColor(root.styleId)
                    font.pixelSize: Appearance.font.pixelSize.smaller
                }
                StyledText {
                    text: root.actionsOpen ? Translation.tr("Enter run · Esc back") : Translation.tr("Enter open · Ctrl+Enter actions · Esc close")
                    color: LauncherStyle.subtextColor(root.styleId)
                    font.pixelSize: Appearance.font.pixelSize.smaller
                }

                Item { Layout.fillWidth: true }

                StyledText {
                    text: root.actionsOpen
                        ? (root.actionEntryInternal?.name ?? "")
                        : `${root.entries.length}`
                    color: LauncherStyle.subtextColor(root.styleId)
                    font.pixelSize: Appearance.font.pixelSize.smaller
                    elide: Text.ElideRight
                    Layout.maximumWidth: 260
                }
            }
        }
    }

    StyledRectangularShadow {
        target: card
        visible: LauncherStyle.shadow(root.styleId)
    }
}
