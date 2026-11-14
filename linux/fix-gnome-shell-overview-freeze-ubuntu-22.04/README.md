# Fix GNOME Shell Overview freeze (Ubuntu 22.04, GNOME Shell 42.9, multi-monitor, X11)

## Problem

The Overview ("Activities", show all windows on all monitors) sometimes freezes for good.
gnome-shell then burns ~60% CPU and logs thousands of lines per minute:

```
Attempting to run a JS callback during garbage collection. ...
The offending callback was SourceFunc().
```

Recover without logging out (X11 keeps every app window open):

```bash
kill -TERM $(pgrep -x gnome-shell)
```

## Cause

Closing the Overview while the **pointer is on a secondary monitor** (Super, Esc, or clicking a
window preview there) makes Clutter repick while that monitor's `SecondaryMonitorDisplay` is
being destroyed:

- `SecondaryMonitorDisplay.vfunc_allocate` reads its `ThumbnailsBox`, which is already destroyed
  (`workspacesView.js:639/686`).
- The `WindowPreview` under the pointer gets a leave event after `_onDestroy` and starts a 750 ms
  timeout that runs on the destroyed preview (`windowPreview.js:566-570`).

Each time logs 5 `has been already disposed` errors and leaves orphan JS objects. The freeze
started with a `WindowPreview` enter event during a GC sweep, most likely one of those orphans.
Reproduce: open the Overview, move the pointer to a secondary monitor, close the Overview, then

```bash
journalctl --user -u org.gnome.Shell@x11.service --since -1min -o cat | grep -c 'already disposed'
```

Not caused by ubuntu-dock or `workspaces-only-on-primary` (tested both). Fixed in newer GNOME;
Ubuntu 22.04 gets no fix.

## Fix

`workspacesView.js` and `windowPreview.js` here are the GNOME Shell 42.9 files with a
`_destroying` flag set in `_onDestroy`; `SecondaryMonitorDisplay.vfunc_allocate` and
`WindowPreview.vfunc_enter_event`/`vfunc_leave_event` do nothing while it is set.

They are loaded over the built-in ones with `G_RESOURCE_OVERLAYS`; no system file is changed.
`orig.sha256` holds the hashes of the original 42.9 files: after a package update changes them,
the shell starts unpatched instead of loading stale copies.

Install with `fix_gnome_shell_overview_freeze_ubuntu_22_04` in
`~/Dropbox/Work/Other/conf.d/alias/new-os-install-Ubuntu.sh`.

Diff against the original files:

```diff
--- a/workspacesView.js
+++ b/workspacesView.js
@@ -675,6 +675,11 @@
     vfunc_allocate(box) {
         this.set_allocation(box);
 
+        // Closing the overview with the pointer on this monitor repicks while the children are
+        // being destroyed, which lands here after the thumbnails are already gone.
+        if (this._destroying)
+            return;
+
         const themeNode = this.get_theme_node();
         const contentBox = themeNode.get_content_box(box);
         const [width, height] = contentBox.get_size();
@@ -712,6 +717,8 @@
     }
 
     _onDestroy() {
+        this._destroying = true;
+
         if (this._settings)
             this._settings.run_dispose();
         this._settings = null;
--- a/windowPreview.js
+++ b/windowPreview.js
@@ -523,6 +523,7 @@
     }
 
     _onDestroy() {
+        this._destroying = true;
         this.metaWindow._delegate = null;
         this._delegate = null;
 
@@ -548,11 +549,19 @@
     }
 
     vfunc_enter_event(crossingEvent) {
+        // Crossing events still arrive while the preview is torn down; they must not
+        // touch the overlay or start a timeout that outlives the preview.
+        if (this._destroying)
+            return super.vfunc_enter_event(crossingEvent);
+
         this.showOverlay(true);
         return super.vfunc_enter_event(crossingEvent);
     }
 
     vfunc_leave_event(crossingEvent) {
+        if (this._destroying)
+            return super.vfunc_leave_event(crossingEvent);
+
         if ((crossingEvent.flags & Clutter.EventFlags.FLAG_GRAB_NOTIFY) !== 0 &&
             global.stage.get_grab_actor() === this._closeButton)
             return super.vfunc_leave_event(crossingEvent);
```
