- [1. debug shell script](#1-debug-shell-script)
- [2. if-else](#2-if-else)
- [3. date](#3-date)
- [auto answer interactive prompt](#auto-answer-interactive-prompt)
  - [pass answer directly multiple question with different answer](#pass-answer-directly-multiple-question-with-different-answer)
  - [using 'yes' commmand to answer question with same answer](#using-yes-commmand-to-answer-question-with-same-answer)
  - [using `expect` command](#using-expect-command)

# 1. debug shell script

Add 2 below lines to top of script:

```shell
set -x
trap read debug
```

Sample here: [../../sample/programming/shell-script/debug-shell-script.sh](../../sample/programming/shell-script/debug-shell-script.sh)

# 2. if-else

[../../sample/programming/shell-script/if-else.sh](../../sample/programming/shell-script/if-else.sh)

In Bash, the test command takes one of the following syntax forms:

```shell
[ EXPRESSION ]
[[ EXPRESSION ]]
```

- To make the script portable, prefer using the old test `[` command which is available on all POSIX shells. 
- The new upgraded version of the test command `[[` (double brackets) is supported on most modern systems using **Bash**, **Zsh**, and **Ksh** as a default shell.
- To negate the test expression, use the logical NOT `(!)` operator. 
- When comparing strings , always use single `'` or double quotes `"` to avoid word splitting and globbing issues.

Below are some of the most commonly used operators:

    -n VAR - True if the length of VAR is greater than zero.
    -z VAR - True if the VAR is empty.
    STRING1 = STRING2 - True if STRING1 and STRING2 are equal.
    STRING1 != STRING2 - True if STRING1 and STRING2 are not equal.
    INTEGER1 -eq INTEGER2 - True if INTEGER1 and INTEGER2 are equal.
    INTEGER1 -gt INTEGER2 - True if INTEGER1 is greater than INTEGER2.
    INTEGER1 -lt INTEGER2 - True if INTEGER1 is less than INTEGER2.
    INTEGER1 -ge INTEGER2 - True if INTEGER1 is equal or greater than INTEGER2.
    INTEGER1 -le INTEGER2 - True if INTEGER1 is equal or less than INTEGER2.
    -h FILE - True if the FILE exists and is a symbolic link.
    -r FILE - True if the FILE exists and is readable.
    -w FILE - True if the FILE exists and is writable.
    -x FILE - True if the FILE exists and is executable.
    -d FILE - True if the FILE exists and is a directory.
    -e FILE - True if the FILE exists and is a file, regardless of type (node, directory, socket, etc.).
    -f FILE - True if the FILE exists and is a regular file (not a directory or device).


Reference: https://linuxize.com/post/bash-if-else-statement/

# 3. date

sample

Sample: [../../sample/programming/shell-script/date-time.sh](../../sample/programming/shell-script/date-time.sh)

# auto answer interactive prompt

## pass answer directly multiple question with different answer

```shell
echo "Xuan Anh\n11\n" | ~/repo/tech-note/programming/shell-scripts/sample/read_user_input.sh
printf 'Xuan Anh\n11\n' | ~/repo/tech-note/programming/shell-scripts/sample/read_user_input.sh
printf "%s\n" "Xuan Anh" 11 | ~/repo/tech-note/programming/shell-scripts/sample/read_user_input.sh 
```

## using 'yes' commmand to answer question with same answer

```shell
yes [answer] |./your_script
yes Xuan Anh | ~/repo/tech-note/programming/shell-scripts/sample/read_user_input.sh
```

## using `expect` command

```shell

expect -c '''
spawn -noecho ~/repo/tech-note/programming/shell-scripts/sample/read_user_input.sh
expect "Hello, what is your name ?" { send -- "Xuan Anh\r" }
expect "how old are you ?" { send -- "11\r" }
interact
'''

```

or in shell script file

```shell
#!/usr/bin/env expect
#!/usr/bin/expect
spawn -noecho /tmp/foo.sh
expect "Hello, what is your name ?" { send -- "Xuan Anh\r" }
expect "how old are you ?" { send -- "11\r" }
interact
```
