- [1. Session](#1-session)
  - [1.1. Create session](#11-create-session)
  - [1.2. Escape a session but keep it alive](#12-escape-a-session-but-keep-it-alive)
  - [1.3. Delete sessions](#13-delete-sessions)
  - [1.4. Attach session](#14-attach-session)
  - [1.5. List session](#15-list-session)
- [2. Tab](#2-tab)
  - [2.1. Create Tab](#21-create-tab)
  - [2.2. Delete Tab](#22-delete-tab)
  - [2.3. Change Tab name](#23-change-tab-name)
  - [2.4. Move between Tab](#24-move-between-tab)
  - [2.5. Move to Tab just accessed before](#25-move-to-tab-just-accessed-before)
  - [2.6. Move to next Tab](#26-move-to-next-tab)
- [3. pane](#3-pane)
  - [3.1. Create pane](#31-create-pane)
  - [3.2. Delete pane](#32-delete-pane)
  - [3.3. Move between pane](#33-move-between-pane)
  - [3.4. Full screen/ un-full screen](#34-full-screen-un-full-screen)
  - [3.5. Change size pane](#35-change-size-pane)
  - [3.6. Change location of pane in a pane](#36-change-location-of-pane-in-a-pane)
  - [3.7. Change layout pane (change from horizontal to vertical)](#37-change-layout-pane-change-from-horizontal-to-vertical)
- [4. Copy mode](#4-copy-mode)
  - [4.1. Enter copy mode](#41-enter-copy-mode)
  - [4.2. Escape copy mode](#42-escape-copy-mode)
  - [4.3. Move in copy mode](#43-move-in-copy-mode)
  - [4.4. Copy](#44-copy)
  - [4.5. Increase buffer size of copy mode](#45-increase-buffer-size-of-copy-mode)
- [5. Custom status bar](#5-custom-status-bar)
- [6. Tmux config file](#6-tmux-config-file)
  - [6.1. Update config](#61-update-config)
  - [6.2. start tmux with specified config file and command](#62-start-tmux-with-specified-config-file-and-command)
  - [6.3. Change Prefix_keys](#63-change-prefix_keys)
  - [6.4. pane switching using Alt+arrow](#64-pane-switching-using-altarrow)
  - [6.5. Activity Monitoring](#65-activity-monitoring)
  - [6.6. Highlighting Current pane Using Specified Colour](#66-highlighting-current-pane-using-specified-colour)
  - [6.7. pane Switching Using Mouse](#67-pane-switching-using-mouse)
- [7. tmux command to create panes in shell script](#7-tmux-command-to-create-panes-in-shell-script)


# 1. Session

## 1.1. Create session

```shell
tmux new -s <session-name>
```

## 1.2. Escape a session but keep it alive

Prefix_keys + d

## 1.3. Delete sessions

```shell
# delete current session
exit
```

or

press Prefix_keys, then enter command: **:kill-session**

kill all sessions

```shell
tmux kill-server
```

## 1.4. Attach session

```shell
tmux a -t <session-name>
# or
tmux attach -t <session-name-or-session-number>
```

## 1.5. List session

```shell
tmux ls
```

# 2. Tab

## 2.1. Create Tab

Prefix_keys + c

## 2.2. Delete Tab

Prefix_keys + &

## 2.3. Change Tab name

Prefix_keys + ,

## 2.4. Move between Tab

Prefix_keys + number-of-pane-tab

**Note**: ..

## 2.5. Move to Tab just accessed before

Prefix_keys + p

## 2.6. Move to next Tab

Prefix_keys + n

# 3. pane

## 3.1. Create pane

- Chia đôi 1 pane thành 2 pane theo chiều dọc:

Prefix_keys + %

- Chia đôi 1 pane thành 2 pane theo chiều ngang:

Prefix_keys + "

## 3.2. Delete pane

```shell
exit
```

## 3.3. Move between pane

- Way 1: Prefix_keys + q + number-of-pane
- Way 2: move as vim style
  - move to left pane: alt + h
  - move to right pane: alt + l
  - move to above pane: alt + k
  - move to below pane: alt + j
  - move to just acessed pane: Prefix_keys + tab

## 3.4. Full screen/ un-full screen

Prefix_keys + z

## 3.5. Change size pane

- Way 1: using hot key

  - hold Prefix_keys + up-arrow
  - hold Prefix_keys + down-arrow
  - hold Prefix_keys + left-arrow
  - hold Prefix_keys + right-arrow

- Way 2: using command

```shell
:resize-pane

# ex: change hight to 8 line
:resize-pane -y8
```

## 3.6. Change location of pane in a pane

Prefix_keys + {

Prefix_keys + }

## 3.7. Change layout pane (change from horizontal to vertical)

Prefix_keys + space

# 4. Copy mode

## 4.1. Enter copy mode

Prefix_keys + [

## 4.2. Escape copy mode

q

## 4.3. Move in copy mode

- Bằng vim key:

  - lên xuống qua lại: h/j/k/l
  - trang trước trang sau: Ctrl - b, Ctrl - f
  - đầu trang, cuối trang: gg, gG

- Hoặc là các phím mũi tên và PageUp, PageDown, Home, End

## 4.4. Copy

- 1: Start copy from mouse pointer: v
- 2: Move mouse pointer to choose text
- 3: Finish choose process and auto exit copy mode
- 4: Move to place where text is pasted
- 5: Paste text: Prefix_keys + ]

## 4.5. Increase buffer size of copy mode

Change file **.tmux.conf** at line:

set-option -g history-limit 5000

# 5. Custom status bar

- Thanh trạng thái theo file .tmux.conf mẫu có thể hiển thị:

  - Phía bên trái:

    - tên Tab
    - Tab hiện tại (màu xanh lá cây đậm)
    - Tab trước đó (có dấu trừ ở trước tên Tab)
    - số thứ tự Tab

  - Phía bên phải:
    - trạng thái bộ nhớ/ memory hiện tại (cần phải cài thêm chương trình tmux-mem-cpu-load)
    - ngày giờ

- Tham khảo những dự án sau để có thể tùy biến thanh trạng thái một cách đẹp đẽ và hữu dụng hơn:
  https://github.com/erikw/tmux-powerline

# 6. Tmux config file

## 6.1. Update config

```shell
tmux source-file .tmux.conf
```

or restart server

## 6.2. start tmux with specified config file and command

```shell
tmux -f myapp-tmux.conf new-session -d -s myapp 'python myapp.py' 
```

If you do want to use you existing server (so that changes made via the configuration file can affect your other sessions), then you might want to use source instead:

```shell
tmux source myapp-tmux.conf \; new-session -d -s myapp 'python myapp.py'
```

refer : https://stackoverflow.com/a/21902771/7639845https://stackoverflow.com/a/21902771/7639845

## 6.3. Change Prefix_keys

open file **.tmux.conf** and add:

```conf
unbind C-b  # default prefix keys are ctrl + b
set -g Prefix_keys C-a  # set new prefix keys are ctrl + a
```

## 6.4. pane switching using Alt+arrow

```conf
bind -n M-Left select-pane -L
bind -n M-Right select-pane -R
bind -n M-Up select-pane -U
bind -n M-Down select-pane -D
```

## 6.5. Activity Monitoring

```conf
setw -g monitor-activity on
set -g visual-activity on
```

## 6.6. Highlighting Current pane Using Specified Colour

```conf
set-pane-option -g pane-status-current-bg yellow
```

## 6.7. pane Switching Using Mouse

```conf
# version 2.1 and above
set-option -g mouse on

# version 2.0 and below
set-option -g mouse-select-pane on
set-option -g mouse-resize-pane on
```

**Note**: if using this function, you can not copy text as normal, to copy text ([reference](https://stackoverflow.com/a/58340575/7639845)) :

    1. Hold down Shift and select with your mouse the text you want to copy.
    2. Now right click to copy the selected text

# 7. tmux command to create panes in shell script

```shell

tmux new-session \; \
  send-keys 'focusing-to-pane-1"' C-m \; \
  split-pane -v \; \
  send-keys 'focusing-to-pane-2' C-m \; \
  split-pane -h \; \
  send-keys 'focusing-to-pane-3' C-m \; \
  select-pane -t 1 \; \
  send-keys 'focusing-to-pane-1 again' C-m \; \
  select-pane -t 2 \; \
  send-keys 'focusing-to-pane-2 again' C-m \; \
  select-pane -t 3 \; \
  send-keys 'focusing-to-pane-3 again' C-m \; \
  split-pane -v \; \
  send-keys 'focusing-to-pane-4' C-m \;

```

Reference: https://stackoverflow.com/a/40009032/7639845
