- [1. Add](#1-add)
- [2. clone a project  with submodule](#2-clone-a-project--with-submodule)
- [3. pull submodules](#3-pull-submodules)
- [4. init/update/pull submodule](#4-initupdatepull-submodule)
- [5. Reference](#5-reference)

# 1. Add

```shell
# add submodule to specified folder
git submodule add https://github.com/tsarpaul/FBUnpinner sample/devops/ssl/FBUnpinner
# add to root folder
git submodule add https://github.com/tsarpaul/FBUnpinner
```

# 2. clone a project  with submodule

```shell
git clone --recurse-submodules git@github.com:PhungXuanAnh/tech-note.git
```

# 3. pull submodules

```shell
git pull --recurse-submodules
```

# 4. init/update/pull submodule

```shell
git submodule update --init --recursive
```

# 5. Reference

http://git-scm.com/book/en/v2/Git-Tools-Submodules
