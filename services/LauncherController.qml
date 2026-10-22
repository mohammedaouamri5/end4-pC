pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Hyprland
import qs
import qs.services
import qs.modules.common
import qs.modules.common.models
import qs.modules.common.functions

/**
 * Owns the app launcher window state and the actions that should happen when
 * an entry is selected. Keeping the launch/dismiss path here means every
 * style and every input method (mouse, Enter, IPC) behaves identically.
 */
Singleton {
    id: root

    readonly property bool enabled: Config.options.launcher.enable
    readonly property int recentLimit: 12

    readonly property var emptyEntries: {
        const result = []
        const pinnedIds = Config.options.launcher.showPinnedApps
            ? (Config.options.launcher.pinnedApps ?? [])
            : []
        const recentIds = Config.options.launcher.showRecentApps
            ? (Persistent.states?.launcher?.recent ?? []).map(item => item.id)
            : []

        const seen = new Set()
        for (const id of pinnedIds) {
            if (seen.has(id)) continue
            const entry = root.desktopEntryFor(id)
            if (!entry) continue
            seen.add(id)
            result.push(root.desktopEntryResult(entry, Translation.tr("Pinned")))
        }
        for (const id of recentIds) {
            if (seen.has(id)) continue
            const entry = root.desktopEntryFor(id)
            if (!entry) continue
            seen.add(id)
            result.push(root.desktopEntryResult(entry, Translation.tr("Recent")))
        }
        return result
    }

    function desktopEntryFor(id) {
        if (!id) return null
        return DesktopEntries.byId(id) ?? DesktopEntries.heuristicLookup(id)
    }

    function desktopEntryResult(entry, section) {
        return {
            id: entry.id,
            name: entry.name,
            iconName: entry.icon,
            iconType: LauncherSearchResult.IconType.System,
            type: Translation.tr("App"),
            comment: entry.comment ?? "",
            genericName: entry.genericName ?? "",
            keywords: entry.keywords ?? [],
            isApp: true,
            section: section,
            runInTerminal: entry.runInTerminal ?? false,
            execute: () => root.launchDesktopEntry(entry)
        }
    }

    function launchDesktopEntry(entry) {
        if (!entry) return
        if (!entry.runInTerminal) {
            entry.execute()
            return
        }
        Quickshell.execDetached(["bash", "-c", `${Config.options.apps.terminal} -e '${StringUtils.shellSingleQuoteEscape(entry.command.join(" "))}'`])
    }

    function targetScreen() {
        const focusedName = Hyprland.focusedMonitor?.name ?? WM.focusedMonitor?.name
        return Quickshell.screens.find(screen => screen.name === focusedName) ?? Quickshell.screens[0]
    }

    function show(prefix) {
        if (!root.enabled) return
        GlobalStates.overviewOpen = false
        GlobalStates.desktopMenuOpen = false
        GlobalStates.dropShelfOpen = false
        LauncherSearch.surface = "launcher"
        LauncherSearch.query = root.enabled && Config.options.launcher.keepQuery && prefix === undefined
            ? LauncherSearch.query
            : ""
        if (prefix !== undefined) LauncherSearch.query = prefix
        GlobalStates.launcherScreen = root.targetScreen()
        GlobalStates.launcherOpen = true
    }

    function hide() {
        GlobalStates.launcherOpen = false
        if (!Config.options.launcher.keepQuery) LauncherSearch.query = ""
        LauncherSearch.surface = "overview"
    }

    function toggle() {
        GlobalStates.launcherOpen ? root.hide() : root.show()
    }

    function openWith(prefix) {
        root.show(prefix)
    }

    function recordRecent(entry) {
        if (!entry?.id) return

        const current = (Persistent.states?.launcher?.recent ?? []).slice()
        const next = current.filter(item => item.id !== entry.id)
        next.unshift({
            id: entry.id,
            lastUsed: Date.now()
        })
        Persistent.states.launcher.recent = next.slice(0, root.recentLimit)
    }

    function run(entry, action) {
        if (!entry && !action) return

        const execute = action ? action.execute : entry.execute
        const shouldDismiss = action
            ? action.keepOpen !== true
            : entry.dismissOnExecute !== false && Config.options.launcher.closeOnPick

        if (!action) root.recordRecent(entry)
        if (shouldDismiss) root.hide()

        Qt.callLater(() => {
            if (typeof execute === "function") execute()
        })
    }
}
