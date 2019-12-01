Hướng dẫn sử dụng pyevn

# Install pyenv

```shell
curl https://pyenv.run | bash
```

Reference: https://github.com/pyenv/pyenv-installer

# Cài đặt một version python

```shell
pyenv install -v 2.7.10
pyenv install -v 3.6.8
pyenv install -v 3.7.0
```

# Danh sách các command:

```shell
➜  Downloads pyenv --help        
Usage: pyenv <command> [<args>]

Some useful pyenv commands are:
   commands    List all available pyenv commands
   local       Set or show the local application-specific Python version
   global      Set or show the global Python version  <=== NOTE: phải reset shell thì mới thấy thay đổi
   shell       Set or show the shell-specific Python version
   install     Cài đặt 1 version python
   uninstall   Gỡ bỏ một version python
   rehash      Rehash pyenv shims (run this after installing executables)
   version     Hiển thị version hiện tại
   versions    Liệt kê các version có sẵn
   which       Display the full path to an executable
   whence      List all Python versions that contain the given executable

See `pyenv help <command>' for information on a specific command.
For full documentation, see: https://github.com/pyenv/pyenv#readme
```

# Tạo virtualenv

**NOTE:**: phiên bản python bên dưới phải được cài trước bằng lệnh **pyenv install** bên trên

```shell
# tạo virtualenv với một version cụ thể
pyenv virtualenv <version> <folder-name>
# ex:
pyenv virtualenv 2.7.10 my-virtual-env-2.7.10

# tạo virtualenv từ version hiện tại
pyenv virtualenv my-virtual-env
```

# Liệt kê virtualenv có sẵn

```shell
pyenv virtualenvs

# output:
  2.7.10/envs/my-virtual-env-2.7.10 (created from /home/xuananh/.pyenv/versions/2.7.10)
  my-virtual-env-2.7.10 (created from /home/xuananh/.pyenv/versions/2.7.10)
  my-virtual-env1 (created from /usr)
```

# Activate virtualenv

```shell
pyenv activate <name>
# ex:
pyenv activate my-virtual-env-2.7.10
pyenv deactivate
```

# Remove an virtualenv

```shell
pyenv uninstall my-virtual-env-2.7.10
pyenv virtualenv-delete my-virtual-env-2.7.10
```