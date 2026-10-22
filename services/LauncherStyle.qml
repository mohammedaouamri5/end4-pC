pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import qs.services
import qs.modules.common
import qs.modules.common.functions

/**
 * Visual tokens for the standalone app launcher.
 *
 * Every color is resolved from Appearance at call time, so wallpaper/theme
 * changes update a running launcher without restarting the shell. Keep the
 * style differences in shape/density/layout here instead of hardcoding
 * palettes in the launcher components.
 */
Singleton {
    id: root

    readonly property var styles: [
        {
            id: "classic",
            name: Translation.tr("Classic"),
            icon: "terminal",
            description: Translation.tr("Flat rofi-style list with a thin border")
        },
        {
            id: "material",
            name: Translation.tr("Material"),
            icon: "palette",
            description: Translation.tr("Rounded Material You card with an elevated surface")
        },
        {
            id: "glass",
            name: Translation.tr("Glass"),
            icon: "blur_on",
            description: Translation.tr("Translucent card with compositor blur")
        },
        {
            id: "spotlight",
            name: Translation.tr("Spotlight"),
            icon: "search",
            description: Translation.tr("Wide, chrome-free search with large text")
        },
        {
            id: "grid",
            name: Translation.tr("Grid"),
            icon: "apps",
            description: Translation.tr("App-drawer grid; switches to a list while searching")
        },
        {
            id: "terminal",
            name: Translation.tr("Terminal"),
            icon: "code",
            description: Translation.tr("Dense monospace command-palette look")
        },
        {
            id: "split",
            name: Translation.tr("Split"),
            icon: "vertical_split",
            description: Translation.tr("List with a details/actions preview pane")
        }
    ]

    readonly property var styleIds: root.styles.map(style => style.id)

    function style(id) {
        return root.styles.find(entry => entry.id === id) ?? root.styles[1]
    }

    function name(id) {
        return root.style(id).name
    }

    function description(id) {
        return root.style(id).description
    }

    function layout(id) {
        switch (id) {
            case "grid": return "grid"
            case "split": return "split"
            default: return "list"
        }
    }

    function isCompact(id) {
        return id === "classic" || id === "terminal"
    }

    function panelWidth(id) {
        switch (id) {
            case "classic": return 560
            case "glass": return 620
            case "spotlight": return 720
            case "grid": return 760
            case "terminal": return 580
            case "split": return 860
            default: return 640
        }
    }

    function cardRadius(id) {
        switch (id) {
            case "classic": return 10
            case "material": return Appearance.rounding.verylarge
            case "glass": return Appearance.rounding.large
            case "spotlight": return 0
            case "grid": return Appearance.rounding.verylarge
            case "terminal": return 6
            case "split": return Appearance.rounding.large
            default: return Appearance.rounding.large
        }
    }

    function cardColor(id) {
        switch (id) {
            case "classic": return Appearance.colors.colLayer0
            case "material": return Appearance.colors.colUiSurfaceContainer
            case "glass": return Config.options.launcher.blurBackground
                ? ColorUtils.transparentize(Appearance.colors.colUiSurfaceContainer, 0.32)
                : Appearance.colors.colUiSurfaceContainer
            case "spotlight": return "transparent"
            case "grid": return Appearance.colors.colUiSurfaceContainer
            case "terminal": return Appearance.colors.colLayer0
            case "split": return Appearance.colors.colUiSurfaceContainer
            default: return Appearance.colors.colUiSurfaceContainer
        }
    }

    function borderColor(id) {
        switch (id) {
            case "spotlight": return "transparent"
            case "glass": return ColorUtils.transparentize(Appearance.colors.colOutlineVariant, 0.35)
            case "classic": return ColorUtils.transparentize(Appearance.colors.colOutlineVariant, 0.25)
            case "terminal": return ColorUtils.transparentize(Appearance.colors.colOutlineVariant, 0.15)
            default: return ColorUtils.transparentize(Appearance.colors.colOutlineVariant, 0.55)
        }
    }

    function borderWidth(id) {
        return (id === "spotlight") ? 0 : (id === "classic" || id === "terminal") ? 1 : 1
    }

    function shadow(id) {
        return id === "material" || id === "grid" || id === "split"
    }

    function textColor(id) {
        switch (id) {
            case "classic":
            case "terminal": return Appearance.colors.colOnLayer0
            case "spotlight": return Appearance.colors.colOnSurface
            default: return Appearance.colors.colOnSurface
        }
    }

    function subtextColor(id) {
        return id === "spotlight"
            ? ColorUtils.transparentize(Appearance.colors.colSubtext, 0.1)
            : Appearance.colors.colSubtext
    }

    function accentColor(id) {
        return Appearance.colors.colPrimary
    }

    function selectionColor(id) {
        switch (id) {
            case "classic": return Appearance.colors.colPrimary
            case "glass": return ColorUtils.transparentize(Appearance.colors.colPrimaryContainer, 0.18)
            case "spotlight": return ColorUtils.transparentize(Appearance.colors.colPrimary, 0.90)
            case "grid": return Appearance.colors.colSecondaryContainer
            case "terminal": return ColorUtils.mix(Appearance.colors.colPrimary, Appearance.colors.colLayer0, 0.78)
            default: return Appearance.colors.colPrimaryContainer
        }
    }

    function selectionTextColor(id) {
        switch (id) {
            case "classic": return Appearance.colors.colOnPrimary
            case "grid": return Appearance.colors.colOnSecondaryContainer
            case "spotlight": return Appearance.colors.colOnSurface
            case "terminal": return Appearance.colors.colOnSurface
            default: return Appearance.colors.colOnPrimaryContainer
        }
    }

    function hoverColor(id) {
        switch (id) {
            case "classic": return ColorUtils.transparentize(Appearance.colors.colPrimary, 0.88)
            case "spotlight": return ColorUtils.transparentize(Appearance.colors.colPrimary, 0.95)
            case "terminal": return ColorUtils.transparentize(Appearance.colors.colPrimary, 0.90)
            default: return ColorUtils.transparentize(Appearance.colors.colPrimaryContainer, 0.72)
        }
    }

    function fieldColor(id) {
        switch (id) {
            case "classic":
            case "spotlight":
            case "terminal": return "transparent"
            case "glass": return ColorUtils.transparentize(Appearance.colors.colLayer1, 0.42)
            case "grid": return ColorUtils.transparentize(Appearance.colors.colLayer2, 0.35)
            case "split": return Appearance.colors.colLayer2
            default: return Appearance.colors.colSurfaceContainerHigh
        }
    }

    function fieldRadius(id) {
        switch (id) {
            case "classic": return 6
            case "spotlight": return 0
            case "terminal": return 4
            case "glass": return Appearance.rounding.normal
            default: return Appearance.rounding.full
        }
    }

    function headerHeight(id) {
        switch (id) {
            case "classic": return 48
            case "spotlight": return 68
            case "terminal": return 46
            case "grid": return 58
            default: return 56
        }
    }

    function rowHeight(id) {
        switch (id) {
            case "classic": return 36
            case "terminal": return 30
            case "spotlight": return 44
            case "grid": return 44
            case "split": return 46
            default: return 48
        }
    }

    function rowRadius(id) {
        switch (id) {
            case "classic": return 5
            case "terminal": return 3
            case "spotlight": return 6
            default: return Appearance.rounding.normal
        }
    }

    function rowSpacing(id) {
        return (id === "terminal" || id === "classic") ? 1 : 2
    }

    function iconSize(id) {
        switch (id) {
            case "classic": return 22
            case "terminal": return 18
            case "spotlight": return 24
            case "grid": return 24
            default: return 28
        }
    }

    function titleSize(id) {
        switch (id) {
            case "classic": return Appearance.font.pixelSize.small
            case "spotlight": return Appearance.font.pixelSize.large
            case "terminal": return Appearance.font.pixelSize.smallie
            default: return Appearance.font.pixelSize.normal
        }
    }

    function subtitleSize(id) {
        return id === "spotlight" ? Appearance.font.pixelSize.small : Appearance.font.pixelSize.smaller
    }

    function searchTextSize(id) {
        switch (id) {
            case "spotlight": return Appearance.font.pixelSize.huge
            case "terminal": return Appearance.font.pixelSize.normal
            case "classic": return Appearance.font.pixelSize.small
            default: return Appearance.font.pixelSize.large
        }
    }

    function fontFamily(id) {
        return id === "terminal" ? Appearance.font.family.monospace : Appearance.font.family.main
    }

    function searchIcon(id) {
        return id === "terminal" ? "chevron_right" : "search"
    }

    function placeholder(id) {
        switch (id) {
            case "terminal": return Translation.tr("Run a command, app or search…")
            case "spotlight": return Translation.tr("Search apps, actions and settings")
            default: return Translation.tr("Search apps and actions…")
        }
    }

    function padding(id) {
        switch (id) {
            case "classic": return 10
            case "spotlight": return 18
            case "terminal": return 10
            case "grid": return 14
            default: return 14
        }
    }

    function rowHorizontalPadding(id) {
        return (id === "spotlight") ? 14 : 10
    }

    function separatorColor(id) {
        return ColorUtils.transparentize(Appearance.colors.colOutlineVariant, id === "spotlight" ? 0.72 : 0.55)
    }

    function showFooter(id) {
        return id !== "spotlight"
    }

    function showDescriptions(id) {
        return id !== "classic" && id !== "terminal"
    }

    function gridColumns(id) {
        return 5
    }

    function tileHeight(id) {
        return 108
    }

    function backdropColor(id, amount) {
        return ColorUtils.applyAlpha(Appearance.m3colors.m3scrim, amount)
    }
}
