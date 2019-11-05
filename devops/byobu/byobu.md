- [1. Session](#1-session)
  - [1.1. Create](#11-create)
  - [1.2. List](#12-list)
  - [1.3. Attach](#13-attach)
  - [1.4. Clear](#14-clear)
  - [1.5. Rename](#15-rename)
- [2. Shortcut key](#2-shortcut-key)

# 1. Session

## 1.1. Create

```shell
byobu new -s 'session name'
# ex:
byobu new -s 'test s1'
byobu new -s 'test s2'
```

## 1.2. List

```shell
byobu list-session
```

output:

```
test s1: 1 windows (created Fri Nov  9 16:16:25 2018) [146x30]
test s2: 1 windows (created Fri Nov  9 16:16:27 2018) [146x30]
```

## 1.3. Attach

```shell
byobu-select-session
```

output:

```
Byobu sessions...

  1. tmux: test s1: 1 windows (created Fri Nov  9 16:16:25 2018) [146x30]
  2. tmux: test s2: 1 windows (created Fri Nov  9 16:16:27 2018) [146x30]
  3. Create a new Byobu session (tmux)
  4. Run a shell without Byobu (/usr/bin/zsh)

Choose 1-4 [1]:
```

Then choose session that you want to attach


## 1.4. Clear 

```shell
byobu kill-server
```

## 1.5. Rename

Press Ctrl + F8

# 2. Shortcut key
```shell

  F1                             * Used by X11 *
    Shift-F1                     Display this help
  F2                             Create a new window
    Shift-F2                     Create a horizontal ( - ) split
    Ctrl-F2                      Create a vertical ( | ) split
    Ctrl-Shift-F2                Create a new session
  F3/F4                          Move focus among windows
    Alt-Left/Right               Move focus among windows
    Alt-Up/Down                  Move focus among sessions
    Shift-Left/Right/Up/Down     Move focus among splits
    Shift-F3/F4                  Move focus among splits
    Ctrl-F3/F4                   Move a split
    Ctrl-Shift-F3/F4             Move a window
    Shift-Alt-Left/Right/Up/Down Resize a split
  F5                             Reload profile, refresh status
    Alt-F5                       Toggle UTF-8 support, refresh status
    Shift-F5                     Toggle through status lines
    Ctrl-F5                      Reconnect ssh/gpg/dbus sockets
    Ctrl-Shift-F5                Change status bar's color randomly
  F6                             Detach session and then logout
    Shift-F6                     Detach session and do not logout
    Alt-F6                       Detach all clients but yourself
    Ctrl-F6                      Kill split in focus
  F7                             Enter scrollback history
    Alt-PageUp/PageDown          Enter and move through scrollback
    Shift-F7                     Save history to $BYOBU_RUN_DIR/printscreen
  F8                             Rename the current window
    Ctrl-F8                      Rename the current session
    Shift-F8                     Toggle through split arrangements
    Alt-Shift-F8                 Restore a split-pane layout
    Ctrl-Shift-F8                Save the current split-pane layout
  F9                             Launch byobu-config window
    Ctrl-F9                      Enter command and run in all windows
    Shift-F9                     Enter command and run in all splits
    Alt-F9                       Toggle sending keyboard input to all splits
  F10                            * Used by X11 *
  F11                            * Used by X11 *
    Alt-F11                      Expand split to a full window
    Shift-F11                    Zoom into a split, zoom out of a split
    Ctrl-F11                     Join window into a vertical split
  F12                            Escape sequence
    Shift-F12                    Toggle on/off Byobu's keybindings
    Alt-F12                      Toggle on/off Byobu's mouse support
    Ctrl-Shift-F12               Mondrian squares
```

