If you need to amend the message for multiple commits or an older commit, you can use interactive rebase, then force push to change the commit history.

- [1. Steps](#1-steps)
  - [1.1. On the command line, navigate to the repository that contains the commit you want to amend.](#11-on-the-command-line-navigate-to-the-repository-that-contains-the-commit-you-want-to-amend)
  - [1.2. Use the git rebase -i HEAD~n command to display a list of the last n commits in your default text editor.](#12-use-the-git-rebase--i-headn-command-to-display-a-list-of-the-last-n-commits-in-your-default-text-editor)
  - [1.3. Replace pick with reword before each commit message you want to change.](#13-replace-pick-with-reword-before-each-commit-message-you-want-to-change)
  - [1.4. Save and close the commit list file.](#14-save-and-close-the-commit-list-file)
  - [1.5. In each resulting commit file, type the new commit message, save the file, and close it.](#15-in-each-resulting-commit-file-type-the-new-commit-message-save-the-file-and-close-it)
  - [1.6. When you're ready to push your changes to GitHub, use the push --force command to force push over the old commit.](#16-when-youre-ready-to-push-your-changes-to-github-use-the-push---force-command-to-force-push-over-the-old-commit)
- [2. reference](#2-reference)

# 1. Steps

## 1.1. On the command line, navigate to the repository that contains the commit you want to amend.

## 1.2. Use the git rebase -i HEAD~n command to display a list of the last n commits in your default text editor.

```shell
## Displays a list of the last 3 commits on the current branch
$ git rebase -i HEAD~3
```

The list will look similar to the following:


```shell
pick e499d89 Delete CNAME
pick 0c39034 Better README
pick f7fde4a Change the commit message but push the same commit.

## Rebase 9fdb3bd..f7fde4a onto 9fdb3bd
##
## Commands:
## p, pick = use commit
## r, reword = use commit, but edit the commit message
## e, edit = use commit, but stop for amending
## s, squash = use commit, but meld into previous commit
## f, fixup = like "squash", but discard this commit's log message
## x, exec = run command (the rest of the line) using shell
##
## These lines can be re-ordered; they are executed from top to bottom.
##
## If you remove a line here THAT COMMIT WILL BE LOST.
##
## However, if you remove everything, the rebase will be aborted.
##
## Note that empty commits are commented out
```

## 1.3. Replace pick with reword before each commit message you want to change.


```shell
pick e499d89 Delete CNAME
reword 0c39034 Better README
reword f7fde4a Change the commit message but push the same commit.
```

## 1.4. Save and close the commit list file.

## 1.5. In each resulting commit file, type the new commit message, save the file, and close it.

## 1.6. When you're ready to push your changes to GitHub, use the push --force command to force push over the old commit.

```shell
git push --force origin EXAMPLE-BRANCH
```

# 2. reference

https://docs.github.com/en/pull-requests/committing-changes-to-your-project/creating-and-editing-commits/changing-a-commit-message
