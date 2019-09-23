- [1. Branch](#1-branch)
  - [1.1. Sync remote branch with local branch](#11-sync-remote-branch-with-local-branch)
  - [1.2. Delete](#12-delete)
    - [1.2.1. Delete local branch](#121-delete-local-branch)
    - [1.2.2. Delete remote branch](#122-delete-remote-branch)

# 1. Branch

## 1.1. Sync remote branch with local branch

```shell
git remote prune origin
```

## 1.2. Delete

### 1.2.1. Delete local branch

```shell
git branch -d {the_local_branch}
# force delete
git branch -D {the_local_branch}
```

### 1.2.2. Delete remote branch

```shell
git push origin --delete {the_remote_branch}
```

