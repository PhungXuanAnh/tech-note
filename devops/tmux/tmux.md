- [1.1. Session](#11-session)
  - [1.1.1. Create session](#111-create-session)
  - [1.1.2. Escape a session but keep it alive](#112-escape-a-session-but-keep-it-alive)
  - [1.1.3. Delete session](#113-delete-session)
  - [1.1.4. Attach session](#114-attach-session)
  - [1.1.5. List session](#115-list-session)
- [1.2. Window tab](#12-window-tab)
  - [1.2.1. Create window tab](#121-create-window-tab)
  - [1.2.2. Delete window tab](#122-delete-window-tab)
  - [1.2.3. Change window tab name](#123-change-window-tab-name)
  - [1.2.4. Move between window tab](#124-move-between-window-tab)
  - [1.2.5. Move to window tab just accessed before](#125-move-to-window-tab-just-accessed-before)
  - [1.2.6. Move to next window tab](#126-move-to-next-window-tab)
- [1.3. Pane](#13-pane)
  - [1.3.1. Create pane](#131-create-pane)
  - [1.3.2. Delete pane](#132-delete-pane)
  - [1.3.3. Move between pane](#133-move-between-pane)
  - [1.3.4. Full screen/ un-full screen](#134-full-screen-un-full-screen)
  - [1.3.5. Change size pane](#135-change-size-pane)
  - [1.3.6. Change location of pane in a window](#136-change-location-of-pane-in-a-window)
  - [1.3.7. Change layout pane (change from horizontal to vertical)](#137-change-layout-pane-change-from-horizontal-to-vertical)
- [1.4. Copy mode](#14-copy-mode)
  - [1.4.1. Enter copy mode](#141-enter-copy-mode)
  - [1.4.2. Escape copy mode](#142-escape-copy-mode)
  - [1.4.3. Move in copy mode](#143-move-in-copy-mode)
  - [1.4.4. Copy](#144-copy)
  - [1.4.5. Increase buffer size of copy mode](#145-increase-buffer-size-of-copy-mode)
- [1.5. Custom status bar](#15-custom-status-bar)
- [1.6. Tmux config file](#16-tmux-config-file)
  - [1.6.1. Update config](#161-update-config)
  - [1.6.2. Change prefix](#162-change-prefix)
  - [1.6.3. Pane switching with Alt+arrow](#163-pane-switching-with-altarrow)
  - [1.6.4. Activity Monitoring](#164-activity-monitoring)
  - [1.6.5. Highlighting Current Window Using Specified Colour](#165-highlighting-current-window-using-specified-colour)
  - [1.6.6. Pane Switching Using Mouse](#166-pane-switching-using-mouse)
- [1.7. Reference](#17-reference)


## 1.1. Session

### 1.1.1. Create session

```shell
tmux new -s <session-name>
```

### 1.1.2. Escape a session but keep it alive

prefix + d

### 1.1.3. Delete session

```shell
exit
```

or

press prefix, then enter command: **:kill-session**

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

## 1.2. Window tab

### 1.2.1. Create window tab

prefix + c

### 1.2.2. Delete window tab

prefix + &

### 1.2.3. Change window tab name

prefix + ,

### 1.2.4. Move between window tab

prefix + number-of-window-tab

**Note**: ..

### 1.2.5. Move to window tab just accessed before

prefix + p

### 1.2.6. Move to next window tab

prefix + n

## 1.3. Pane

### 1.3.1. Create pane

- Chia đôi 1 pane thành 2 pane theo chiều dọc:

prefix + %

- Chia đôi 1 pane thành 2 pane theo chiều ngang:

prefix + "

### 1.3.2. Delete pane

```shell
exit
```

### 1.3.3. Move between pane

- Way 1: prefix + q + number-of-pane
- Way 2: move as vim style
  - move to left pane: alt + h
  - move to right pane: alt + l
  - move to above pane: alt + k
  - move to below pane: alt + j
  - move to just acessed pane: prefix + tab

### 1.3.4. Full screen/ un-full screen

prefix + z

### 1.3.5. Change size pane

- Way 1: using hot key

  - hold prefix + up-arrow
  - hold prefix + down-arrow
  - hold prefix + left-arrow
  - hold prefix + right-arrow

- Way 2: using command

```shell
:resize-pane

# ex: change hight to 8 line
:resize-pane -y8
```

### 1.3.6. Change location of pane in a window

prefix + {

prefix + }

### 1.3.7. Change layout pane (change from horizontal to vertical)

prefix + space

## 1.4. Copy mode

### 1.4.1. Enter copy mode

prefix + [

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
- 5: Paste text: prefix + ]

### 1.4.5. Increase buffer size of copy mode

Change file **.tmux.conf** at line:

set-option -g history-limit 5000

## 1.5. Custom status bar

- Thanh trạng thái theo file .tmux.conf mẫu có thể hiển thị:

  - Phía bên trái:

    - tên window tab
    - window tab hiện tại (màu xanh lá cây đậm)
    - window tab trước đó (có dấu trừ ở trước tên window tab)
    - số thứ tự window tab

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

### 1.6.2. Change prefix

open file **.tmux.conf** and add:

```conf
unbind C-b
set -g prefix C-a
```

### 1.6.3. Pane switching with Alt+arrow

```conf
bind -n M-Left select-pane -L
bind -n M-Right select-pane -R
bind -n M-Up select-pane -U
bind -n M-Down select-pane -D
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

### 1.6.6. Pane Switching Using Mouse

**Note**: if using this function, you can not copy text

```conf
# version 2.1 and later
set-option -g mouse on

# version 2.0 and older
set-option -g mouse-select-pane on
```

## 1.7. Reference

[https://lukaszwrobel.pl/blog/tmux-tutorial-split-terminal-windows-easily/](https://lukaszwrobel.pl/blog/tmux-tutorial-split-terminal-windows-easily/)
