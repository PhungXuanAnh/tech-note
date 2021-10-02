- [1.1. Session](#11-session)
  - [1.1.1. Create session](#111-create-session)
  - [1.1.2. Escape a session but keep it alive](#112-escape-a-session-but-keep-it-alive)
  - [1.1.3. Delete sessions](#113-delete-sessions)
  - [1.1.4. Attach session](#114-attach-session)
  - [1.1.5. List session](#115-list-session)
- [1.2. Tab](#12-tab)
  - [1.2.1. Create Tab](#121-create-tab)
  - [1.2.2. Delete Tab](#122-delete-tab)
  - [1.2.3. Change Tab name](#123-change-tab-name)
  - [1.2.4. Move between Tab](#124-move-between-tab)
  - [1.2.5. Move to Tab just accessed before](#125-move-to-tab-just-accessed-before)
  - [1.2.6. Move to next Tab](#126-move-to-next-tab)
- [1.3. Window](#13-window)
  - [1.3.1. Create Window](#131-create-window)
  - [1.3.2. Delete Window](#132-delete-window)
  - [1.3.3. Move between Window](#133-move-between-window)
  - [1.3.4. Full screen/ un-full screen](#134-full-screen-un-full-screen)
  - [1.3.5. Change size Window](#135-change-size-window)
  - [1.3.6. Change location of Window in a window](#136-change-location-of-window-in-a-window)
  - [1.3.7. Change layout Window (change from horizontal to vertical)](#137-change-layout-window-change-from-horizontal-to-vertical)
- [1.4. Copy mode](#14-copy-mode)
  - [1.4.1. Enter copy mode](#141-enter-copy-mode)
  - [1.4.2. Escape copy mode](#142-escape-copy-mode)
  - [1.4.3. Move in copy mode](#143-move-in-copy-mode)
  - [1.4.4. Copy](#144-copy)
  - [1.4.5. Increase buffer size of copy mode](#145-increase-buffer-size-of-copy-mode)
- [1.5. Custom status bar](#15-custom-status-bar)
- [1.6. Tmux config file](#16-tmux-config-file)
  - [1.6.1. Update config](#161-update-config)
  - [start tmux with specified config file and command](#start-tmux-with-specified-config-file-and-command)
  - [1.6.2. Change Prefix_keys](#162-change-prefix_keys)
  - [1.6.3. Window switching using Alt+arrow](#163-window-switching-using-altarrow)
  - [1.6.4. Activity Monitoring](#164-activity-monitoring)
  - [1.6.5. Highlighting Current Window Using Specified Colour](#165-highlighting-current-window-using-specified-colour)
  - [1.6.6. Window Switching Using Mouse](#166-window-switching-using-mouse)


## 1.1. Session

### 1.1.1. Create session

```shell
tmux new -s <session-name>
```

### 1.1.2. Escape a session but keep it alive

Prefix_keys + d

### 1.1.3. Delete sessions

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

### 1.1.4. Attach session

```shell
tmux a -t <session-name>
# or
tmux attach -t <session-name-or-session-number>
```

### 1.1.5. List session

```shell
tmux ls
```

## 1.2. Tab

### 1.2.1. Create Tab

Prefix_keys + c

### 1.2.2. Delete Tab

Prefix_keys + &

### 1.2.3. Change Tab name

Prefix_keys + ,

### 1.2.4. Move between Tab

Prefix_keys + number-of-window-tab

**Note**: ..

### 1.2.5. Move to Tab just accessed before

Prefix_keys + p

### 1.2.6. Move to next Tab

Prefix_keys + n

## 1.3. Window

### 1.3.1. Create Window

- Chia đôi 1 Window thành 2 Window theo chiều dọc:

Prefix_keys + %

- Chia đôi 1 Window thành 2 Window theo chiều ngang:

Prefix_keys + "

### 1.3.2. Delete Window

```shell
exit
```

### 1.3.3. Move between Window

- Way 1: Prefix_keys + q + number-of-Window
- Way 2: move as vim style
  - move to left Window: alt + h
  - move to right Window: alt + l
  - move to above Window: alt + k
  - move to below Window: alt + j
  - move to just acessed Window: Prefix_keys + tab

### 1.3.4. Full screen/ un-full screen

Prefix_keys + z

### 1.3.5. Change size Window

- Way 1: using hot key

  - hold Prefix_keys + up-arrow
  - hold Prefix_keys + down-arrow
  - hold Prefix_keys + left-arrow
  - hold Prefix_keys + right-arrow

- Way 2: using command

```shell
:resize-Window

# ex: change hight to 8 line
:resize-Window -y8
```

### 1.3.6. Change location of Window in a window

Prefix_keys + {

Prefix_keys + }

### 1.3.7. Change layout Window (change from horizontal to vertical)

Prefix_keys + space

## 1.4. Copy mode

### 1.4.1. Enter copy mode

Prefix_keys + [

### 1.4.2. Escape copy mode

q

### 1.4.3. Move in copy mode

- Bằng vim key:

  - lên xuống qua lại: h/j/k/l
  - trang trước trang sau: Ctrl - b, Ctrl - f
  - đầu trang, cuối trang: gg, gG

- Hoặc là các phím mũi tên và PageUp, PageDown, Home, End

### 1.4.4. Copy

- 1: Start copy from mouse pointer: v
- 2: Move mouse pointer to choose text
- 3: Finish choose process and auto exit copy mode
- 4: Move to place where text is pasted
- 5: Paste text: Prefix_keys + ]

### 1.4.5. Increase buffer size of copy mode

Change file **.tmux.conf** at line:

set-option -g history-limit 5000

## 1.5. Custom status bar

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

## 1.6. Tmux config file

### 1.6.1. Update config

```shell
tmux source-file .tmux.conf
```

or restart server

### start tmux with specified config file and command

```shell
tmux -f myapp-tmux.conf new-session -d -s myapp 'python myapp.py' 
```

If you do want to use you existing server (so that changes made via the configuration file can affect your other sessions), then you might want to use source instead:

```shell
tmux source myapp-tmux.conf \; new-session -d -s myapp 'python myapp.py'
```

refer : https://stackoverflow.com/a/21902771/7639845https://stackoverflow.com/a/21902771/7639845

### 1.6.2. Change Prefix_keys

open file **.tmux.conf** and add:

```conf
unbind C-b  # default prefix keys are ctrl + b
set -g Prefix_keys C-a  # set new prefix keys are ctrl + a
```

### 1.6.3. Window switching using Alt+arrow

```conf
bind -n M-Left select-Window -L
bind -n M-Right select-Window -R
bind -n M-Up select-Window -U
bind -n M-Down select-Window -D
```

### 1.6.4. Activity Monitoring

```conf
setw -g monitor-activity on
set -g visual-activity on
```

### 1.6.5. Highlighting Current Window Using Specified Colour

```conf
set-window-option -g window-status-current-bg yellow
```

### 1.6.6. Window Switching Using Mouse

```conf
# version 2.1 and above
set-option -g mouse on

# version 2.0 and below
set-option -g mouse-select-Window on
set-option -g mouse-select-pane on
set-option -g mouse-resize-pane on
```

**Note**: if using this function, you can not copy text as normal, to copy text ([reference](https://stackoverflow.com/a/58340575/7639845)) :

    1. Hold down Shift and select with your mouse the text you want to copy.
    2. Now right click to copy the selected text