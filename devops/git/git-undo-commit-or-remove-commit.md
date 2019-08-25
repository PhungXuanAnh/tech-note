3 WAY undo commit or remove commit
----------------------------------------------------------

- [1. Reset](#1-reset)
- [2. Revert](#2-revert)
- [3. –amend](#3-amend)
- [4. Kết luận](#4-kết-luận)


Khi bạn vừa thêm một commit vào git tree, và chợt nhận ra commit vừa rồi bị sai, không hoàn chỉnh hoặc có vấn đề, bạn sẽ muốn “undo” commit hoặc loại bỏ nó. Ở đây mình sẽ giới thiệu 3 cách undo commit hoặc loại bỏ commit cơ bản.

# 1. Reset

Nhảy HEAD về vị trí trước khi commit sai bằng **git reset** như sau

```shell
git reset --hard HEAD^
```

Ở đây có vài điểm cần lưu ý

- **HEAD^** có ý nghĩa giống với **HEAD~** hay **@^**, nghĩa là quay về trước 1 commit
- Muốn quay về trước n commit, VD 5 commit thì có thể thay bằng **HEAD~5**.
- **--hard** có nghĩa là bỏ commit đi và bỏ cả những thay đổi chưa được commit trong working space. Khi - này môi trường sẽ hoàn toàn “sạch sẽ” như thời điểm trước khi commit.
- **--soft** có nghĩa là bỏ commit đi nhưng giữ nguyên những thay đổi chưa được commit trong working space. **--soft** hữu dụng khi bạn muốn giữ lại những thay đổi chưa commit cho lần commit tiếp theo

# 2. Revert

**Git revert** có thể tạo một commmit với với nội dung đảo ngược lại một commit cũ. Giả sử commit cũ có hash là **(commit_hash)** thì câu lệnh sẽ là:

```shell
git revert (commit_hash)
```

**Git rever**t hay được sử dụng để đảo ngược một merge commit. Nếu sau khi **git revert** bạn lại muốn quay lại trạng thái trước khi đảo ngược thì sao ? Câu trả lời là **git revert** lại chính revert commit vừa mới tạo.

# 3. –amend

Bạn có thể ghi đè lại commit mới nhất bằng option --amend của git commit

```shell
git commit --amend
```

Lúc này git sẽ cho phép bạn viết lại commit message. Cách này hay dùng khi muốn sửa commit message. Nếu bạn chỉ muốn add thêm file mà không muốn sửa commit message thi có thể dùng option **--no-edit**

```shell
# Đây là commit sai / thiếu
git add home.php
git commit -m 'Add home'

# Nhận ra là add thiếu 1 file home.css và muốn thêm vào commit bên trên
git add home.css
git commit --amend --no-edit
```

# 4. Kết luận

3 cách bên trên đây có những trường hợp sử dụng cụ thể khác nhau

- Muốn bỏ hoàn toàn một commit sai, dùng git reset
- Muốn “undo” một merge commit và để lại lịch sử, dùng git revert
- Muốn thêm những thay đổi nhỏ không đáng kể và tránh bị lắt nhắt, dùng git commit --amend
