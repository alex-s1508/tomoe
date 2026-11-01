#!/usr/bin/env bash
set -euo pipefail

mode="${1:-apply}"
script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
shell_root="${XDG_CONFIG_HOME:-$HOME/.config}/quickshell/shell/modules/bar"
patch_file="$script_dir/sumi.patch"
workspace_patch_file="$script_dir/workspaces-kanji.patch"
notifications_patch_file="$script_dir/notifications.patch"
clock_calendar_patch_file="$script_dir/clock-calendar.patch"
clock_calendar_popouts_patch_file="$script_dir/clock-calendar-popouts.patch"

reload_shell() {
    if ! command -v ryoku >/dev/null 2>&1; then
        printf 'Patch alterado, mas o comando ryoku não foi encontrado; recarregue a shell manualmente com: ryoku reload\n' >&2
        return 1
    fi
    ryoku reload
}

is_base_applied() {
    grep -Fq -- 'let hasToplevelState = false;' "$shell_root/Frame.qml"
}

is_workspace_patch_applied() {
    grep -Fq -- 'function kanjiForWorkspace(name)' "$shell_root/framebars/widgets/RailWorkspaces.qml" \
        && grep -Fq -- 'text: pill.wsLabel' "$shell_root/framebars/widgets/RailWorkspaces.qml" \
        && grep -Fq -- 'required property string monitorName' "$shell_root/framebars/widgets/RailWorkspaces.qml" \
        && grep -Fq -- 'monitorName: root.monitorName' "$shell_root/BarWidgetHost.qml" \
        && grep -Fq -- 'monitorName: root.modelData ? root.modelData.name : ""' "$shell_root/Frame.qml" \
        && grep -Fq -- 'font.pixelSize: 15 * root.scale' "$shell_root/framebars/widgets/RailWorkspaces.qml" \
        && grep -Fq -- ': hover.hovered ? Theme.onSurface' "$shell_root/framebars/widgets/RailWorkspaces.qml"
}

has_workspace_kanji() {
    grep -Fq -- 'function kanjiForWorkspace(name)' "$shell_root/framebars/widgets/RailWorkspaces.qml"
}

is_notifications_patch_applied() {
    grep -Fq -- 'root.menuRequested("notifications"' "$shell_root/framebars/widgets/RailStatus.qml" \
        && { grep -Fq -- 'if (!out.some(row => row.id === "notifications"))' "$shell_root/FrameMenuManager.qml" \
            || is_clock_calendar_popouts_patch_applied; }
}

is_clock_calendar_patch_applied() {
    grep -Fq -- 'root.menuRequested("clock"' "$shell_root/framebars/widgets/RailClock.qml" \
        && { grep -Fq -- 'if (!out.some(row => row.id === "clock"))' "$shell_root/FrameMenuManager.qml" \
            || is_clock_calendar_popouts_patch_applied; }
}

is_clock_calendar_popouts_patch_applied() {
    grep -Fq -- '{ id: "clock", kind: "calendar"' "$shell_root/FrameMenuManager.qml" \
        && grep -Fq -- '{ id: "notifications", kind: "notifications"' "$shell_root/FrameMenuManager.qml" \
        && grep -Fq -- 'id: calendarBody' "$shell_root/FrameSurface.qml" \
        && grep -Fq -- 'id: notificationsBody' "$shell_root/FrameSurface.qml" \
        && grep -Fq -- 'growOriginAlong:' "$shell_root/FrameSurface.qml" \
        && grep -Fq -- 'readonly property real originOffsetY:' "$shell_root/popouts/Popout.qml"
}

is_applied() {
    is_base_applied && is_workspace_patch_applied && is_notifications_patch_applied \
        && is_clock_calendar_patch_applied \
        && is_clock_calendar_popouts_patch_applied
}

verify_workspace_apply() (
    local temp_root
    temp_root="$(mktemp -d)"
    trap 'rm -r -- "$temp_root"' EXIT
    mkdir -p "$temp_root/framebars/widgets"
    cp "$shell_root/Bar.qml" "$temp_root/Bar.qml"
    cp "$shell_root/BarWidgetHost.qml" "$temp_root/BarWidgetHost.qml"
    cp "$shell_root/Frame.qml" "$temp_root/Frame.qml"
    cp "$shell_root/framebars/widgets/RailWorkspaces.qml" "$temp_root/framebars/widgets/RailWorkspaces.qml"

    if ! is_workspace_patch_applied; then
        patch --dry-run --batch -p1 -d "$temp_root" < "$workspace_patch_file"
    fi
)

verify_undo() (
    local temp_root
    temp_root="$(mktemp -d)"
    trap 'rm -r -- "$temp_root"' EXIT
    mkdir -p "$temp_root/framebars/widgets"
    cp "$shell_root/Bar.qml" "$temp_root/Bar.qml"
    cp "$shell_root/BarWidgetHost.qml" "$temp_root/BarWidgetHost.qml"
    cp "$shell_root/Frame.qml" "$temp_root/Frame.qml"
    cp "$shell_root/FrameMenuManager.qml" "$temp_root/FrameMenuManager.qml"
    cp "$shell_root/framebars/widgets/RailClock.qml" "$temp_root/framebars/widgets/RailClock.qml"
    cp "$shell_root/framebars/widgets/RailStatus.qml" "$temp_root/framebars/widgets/RailStatus.qml"
    cp "$shell_root/framebars/widgets/RailWorkspaces.qml" "$temp_root/framebars/widgets/RailWorkspaces.qml"
    cp "$shell_root/FrameSurface.qml" "$temp_root/FrameSurface.qml"
    mkdir -p "$temp_root/framebars/menus"
    cp "$shell_root/framebars/menus/MenuClock.qml" "$temp_root/framebars/menus/MenuClock.qml"
    cp "$shell_root/framebars/menus/QsCalendarEmbed.qml" "$temp_root/framebars/menus/QsCalendarEmbed.qml"
    cp "$shell_root/framebars/menus/MenuWeather.qml" "$temp_root/framebars/menus/MenuWeather.qml"
    mkdir -p "$temp_root/popouts"
    cp "$shell_root/popouts/Popout.qml" "$temp_root/popouts/Popout.qml"

    if is_clock_calendar_popouts_patch_applied; then
        patch --reverse --batch -p1 -d "$temp_root" < "$clock_calendar_popouts_patch_file"
    fi
    if is_clock_calendar_patch_applied; then
        patch --reverse --batch -p1 -d "$temp_root" < "$clock_calendar_patch_file"
    fi
    if is_notifications_patch_applied; then
        patch --reverse --batch -p1 -d "$temp_root" < "$notifications_patch_file"
    fi
    if is_workspace_patch_applied; then
        patch --reverse --batch -p1 -d "$temp_root" < "$workspace_patch_file"
    fi
    if is_base_applied; then
        patch --dry-run --reverse --batch -p1 -d "$temp_root" < "$patch_file"
    fi
)

verify_clock_calendar_apply() (
    local temp_root
    temp_root="$(mktemp -d)"
    trap 'rm -r -- "$temp_root"' EXIT
    mkdir -p "$temp_root/framebars/widgets"
    cp "$shell_root/Frame.qml" "$temp_root/Frame.qml"
    cp "$shell_root/FrameMenuManager.qml" "$temp_root/FrameMenuManager.qml"
    cp "$shell_root/framebars/widgets/RailStatus.qml" "$temp_root/framebars/widgets/RailStatus.qml"
    cp "$shell_root/framebars/widgets/RailClock.qml" "$temp_root/framebars/widgets/RailClock.qml"
    cp "$shell_root/FrameSurface.qml" "$temp_root/FrameSurface.qml"
    mkdir -p "$temp_root/framebars/menus"
    cp "$shell_root/framebars/menus/MenuClock.qml" "$temp_root/framebars/menus/MenuClock.qml"
    cp "$shell_root/framebars/menus/QsCalendarEmbed.qml" "$temp_root/framebars/menus/QsCalendarEmbed.qml"
    cp "$shell_root/framebars/menus/MenuWeather.qml" "$temp_root/framebars/menus/MenuWeather.qml"
    mkdir -p "$temp_root/popouts"
    cp "$shell_root/popouts/Popout.qml" "$temp_root/popouts/Popout.qml"

    if ! is_base_applied; then
        patch --batch -p1 -d "$temp_root" < "$patch_file"
    fi
    if ! is_notifications_patch_applied; then
        patch --batch -p1 -d "$temp_root" < "$notifications_patch_file"
    fi
    if ! is_clock_calendar_patch_applied; then
        patch --batch -p1 -d "$temp_root" < "$clock_calendar_patch_file"
    fi
    if ! is_clock_calendar_popouts_patch_applied; then
        patch --dry-run --batch -p1 -d "$temp_root" < "$clock_calendar_popouts_patch_file"
    fi
)

verify_notifications_apply() (
    local temp_root
    temp_root="$(mktemp -d)"
    trap 'rm -r -- "$temp_root"' EXIT
    mkdir -p "$temp_root/framebars/widgets"
    cp "$shell_root/FrameMenuManager.qml" "$temp_root/FrameMenuManager.qml"
    cp "$shell_root/framebars/widgets/RailStatus.qml" "$temp_root/framebars/widgets/RailStatus.qml"

    if ! is_notifications_patch_applied; then
        patch --dry-run --batch -p1 -d "$temp_root" < "$notifications_patch_file"
    fi
)

apply_workspace_patches() {
    if ! is_workspace_patch_applied; then
        patch --batch -p1 -d "$shell_root" < "$workspace_patch_file"
    fi
}

apply_notifications_patch() {
    if ! is_notifications_patch_applied; then
        patch --batch -p1 -d "$shell_root" < "$notifications_patch_file"
    fi
}

apply_clock_calendar_patch() {
    if ! is_clock_calendar_patch_applied; then
        patch --batch -p1 -d "$shell_root" < "$clock_calendar_patch_file"
    fi
}

apply_clock_calendar_popouts_patch() {
    if ! is_clock_calendar_popouts_patch_applied; then
        patch --batch -p1 -d "$shell_root" < "$clock_calendar_popouts_patch_file"
    fi
}

if [[ ! -d "$shell_root" ]]; then
    printf 'Ryoku Quickshell tree not found: %s\n' "$shell_root" >&2
    exit 1
fi

if has_workspace_kanji && ! is_workspace_patch_applied; then
    printf 'An older or custom Kanji workspace patch is present. Restore its original SUMI state before using this consolidated patch.\n' >&2
    exit 1
fi

case "$mode" in
    apply)
        if is_applied; then
            printf 'SUMI patches are already applied.\n'
            exit 0
        fi
        if ! is_base_applied; then
            patch --dry-run --batch -p1 -d "$shell_root" < "$patch_file"
        fi
        verify_workspace_apply
        verify_notifications_apply
        verify_clock_calendar_apply
        if ! is_base_applied; then
            patch --batch -p1 -d "$shell_root" < "$patch_file"
        fi
        apply_workspace_patches
        apply_notifications_patch
        apply_clock_calendar_patch
        apply_clock_calendar_popouts_patch
        printf 'Patch SUMI aplicado. Recarregando a shell Ryoku…\n'
        reload_shell
        ;;
    dry-run)
        if is_applied; then
            printf 'SUMI patches are already applied.\n'
        else
            if ! is_base_applied; then
                patch --dry-run --batch -p1 -d "$shell_root" < "$patch_file"
            fi
            verify_workspace_apply
            verify_notifications_apply
            verify_clock_calendar_apply
            printf 'SUMI patches can be applied cleanly.\n'
        fi
        ;;
    undo-dry-run)
        if ! is_base_applied && ! is_workspace_patch_applied && ! is_notifications_patch_applied \
            && ! is_clock_calendar_patch_applied \
            && ! is_clock_calendar_popouts_patch_applied; then
            printf 'SUMI patch is not active.\n'
        else
            verify_undo
            printf 'SUMI patches can be undone cleanly.\n'
        fi
        ;;
    undo)
        if ! is_base_applied && ! is_workspace_patch_applied && ! is_notifications_patch_applied \
            && ! is_clock_calendar_patch_applied \
            && ! is_clock_calendar_popouts_patch_applied; then
            printf 'SUMI patch is not active.\n'
            exit 0
        fi
        verify_undo
        if is_clock_calendar_popouts_patch_applied; then
            patch --reverse --batch -p1 -d "$shell_root" < "$clock_calendar_popouts_patch_file"
        fi
        if is_clock_calendar_patch_applied; then
            patch --reverse --batch -p1 -d "$shell_root" < "$clock_calendar_patch_file"
        fi
        if is_notifications_patch_applied; then
            patch --reverse --batch -p1 -d "$shell_root" < "$notifications_patch_file"
        fi
        if is_workspace_patch_applied; then
            patch --reverse --batch -p1 -d "$shell_root" < "$workspace_patch_file"
        fi
        if is_base_applied; then
            patch --reverse --batch -p1 -d "$shell_root" < "$patch_file"
        fi
        printf 'Patches SUMI removidos. Recarregando a shell Ryoku…\n'
        reload_shell
        ;;
    *)
        printf 'Usage: %s [apply|dry-run|undo|undo-dry-run]\n' "$0" >&2
        exit 2
        ;;
esac
