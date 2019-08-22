# Fork a repository

Tại một thời điểm, chúng ta muốn phân phối project của ai đó, hay chúng ta muốn sử dụng project của một ai đố để bắt đầu. Điều này được định nghĩa là `forking`. Trong phần này, chúng ta sẽ forking một repo tên là awesome.

- Để forking một project, click vào button fork trong github repo.

![forking](../../images/devops/git/git-fork-1.png)

Sau khi fork một repo, tức là repo đó đã tồn tại trên github repo của chúng ta, chúng ta có thể clone repo đó về local repo. Sử dụng lệnh sau:

```shell
git clone https://github.com/your_username/repo_name.git
```

Khi một repo đã được clone, nó sẽ có một remote `origin` trỏ đến repo mà chúng ta fork về github của mình, chứ không phải là repo gốc. Để theo dõi (keep track) repo gốc mà đã fork, chúng ta cần add một remote khác có tên là `upstream`:

```shell
cd awesome
git remote add upstream https://github.com/your_username/repo_name.git
git fetch upstream
git merge upstream/master
```

Sau khi đã fork thành công một repo về local repo, chúng ta có thể làm gì tiếp theo:

- `git fetch upstream` Sao chép những thay đổi ở repo gốc
- `git merge upstream/master` Nhóm bất kì điều gì thay đổi vào local repo
