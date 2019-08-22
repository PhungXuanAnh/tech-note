

# Sự khác biệt giữa ‘git merge’ và ‘git rebase’ là gì?

Giả sử ban đầu đã có 3 commit **A, B, C**:

![Unsplash image 9](../../images/devops/git/2018-07-10-difference-between-git-merge-and-git-rebase-00.png)

sau đó developer Dung tạo commit **D**, và developer Egg tạo commit **E**:

![Unsplash image 9](../../images/devops/git/2018-07-10-difference-between-git-merge-and-git-rebase-01.png)

rõ ràng, cuộc xung đột này nên được giải quyết bằng cách nào đó. Đối với điều này, có 2 cách:

MERGE :

![Unsplash image 9](../../images/devops/git/2018-07-10-difference-between-git-merge-and-git-rebase-02.png)

Cả hai commit **D** và **E** vẫn còn ở đây, nhưng chúng tôi tạo ra phối commit **M** mà thay đổi thừa hưởng từ cả hai **D** và **E**. Tuy nhiên, điều này tạo ra hình dạng kim cương, mà nhiều người thấy rất khó hiểu. Nếu bạn có hàng chục commit **D** và **E** thì bạn có có hàng chục viên kim cương **M** lúc này bạn sẽ thấy log rối đến mức nào!?

REBASE :

![Unsplash image 9](../../images/devops/git/2018-07-10-difference-between-git-merge-and-git-rebase-03.png)

# Một so sánh log của rebase và merge 1 branch trong một mini project

![Unsplash image 9](../../images/devops/git/2018-07-10-difference-between-git-merge-and-git-rebase-04.png)

- History dùng rebase nhìn clear và dễ dàng tracking do chính bạn tạo ra một cách hệ thống và logic!
- History dùng merge nhìn khó hiểu và khi tracking bạn sẽ nói gì ngoài bullshit do chính bạn commit và merge vô tội vạ!
- Transport plan của git, những chổ dùng rebase sẽ thằng hàng còn merge sẽ chỉa qua lại nhìn chung là ảnh hưởng các branch.

# Kết Luận

- Chú ý vào **rebase**, mọi người sẽ thấy commit của **rebase** nằm phía trên commit mới nhất của **master**. Còn ở **merge**, mọi người sẽ thấy commit của **master** và commit của **merge** sẽ được trộn lẫn với nhau theo thời gian, commit id nào có trước sẽ xuất hiện trước, ngoài ra một commit **Merge branch** cũng được tạo ra.
- Ban sử dụng **git rebase** nếu như bạn muốn các sự thay đổi thuộc về branch của bạn luôn luôn là mới nhất. Và bạn có thể log một cách có hệ thống dễ nhìn, dễ tracking sao này.
- Bạn sử dụng **git merge** nếu bạn muốn sắp xếp các commit theo mặc định. Bạn không biết về những gì mình làm gì trên branch đó thì dùng merge cho đảm bảo việc tracking sao này có thể tốn nhiều thời gian lần mò.

# Một số vấn đề cần lưu ý

- **Nguyên tắc vàng của Rebasing là không bao giờ sử dụng nó trên public branch**. Tham khảo [link](https://www.atlassian.com/git/tutorials/merging-vs-rebasing#the-golden-rule-of-rebasing) hoặc [link](https://medium.freecodecamp.org/git-rebase-and-the-golden-rule-explained-70715eccc372)
- Git rebase thì nên dùng trên branch riêng, nó sẽ đẩy history commit của branch lên, history commit sẽ tách biệt hẳn với những commit từ branch khác, rất tiện cho quản lý các branch. Đặt biệt khi các bạn có các branch master / develop / hot-fix / features / release …
- Cả rebase và merge sẽ conflict kinh khủng hơn nếu không update code thường xuyên chứ không phải chỉ có rebase như mọi người thường nói đâu nhé. Ví dụ: Nếu như master branch có time line hơn branch của bạn 1 tháng :trollface:. Lúc đó hãy rebase hay merge branch của bạn và sẽ thấy conflict 2 cái có khác gì nhau!
- Git merge là làm cho git commit list dài ra áp dụng cho branch riêng thì không phù hợp vì khó trace log vì nhiều commit dài thòn không phải do bạn tạo ra!?. Nhất là trong 1 dự án dài hơi, việc nhìn lại log của vài tháng trước có thể sẽ là vấn đề trong bầu trời đầy sao chổi với bạn.

# Tham khảo

[https://git-scm.com/book/vi/v1/Ph%C3%A2n-Nh%C3%A1nh-Trong-Git-Rebasing](https://git-scm.com/book/vi/v1/Ph%C3%A2n-Nh%C3%A1nh-Trong-Git-Rebasing)
[https://backlog.com/git-tutorial/vn/stepup/stepup1_4.html](https://backlog.com/git-tutorial/vn/stepup/stepup1_4.html)
[https://www.atlassian.com/git/tutorials/merging-vs-rebasing](https://www.atlassian.com/git/tutorials/merging-vs-rebasing)

# Practice

## merge and rebase without conflict

```shell
cp -r test-git-master test-git-merge
cd test-git-merge
cp -r test-git-master test-git-rebase
cd test-git-rebase
git checkout master
git checkout b-merge
git checkout b-rebase
git reset --hard fdd5485a21080e373b50fd847ca4f7ab4b7b136e
git push origin master --force
git push origin b-merge --force
git push origin b-rebase --force
git pull origin master
git pull origin b-merge
git pull origin b-rebase
git log
git branch
```

### Create master branch commit id

```shell
echo 1 > 1
git add 1
git commit -m 'MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM Master branch 1'
echo 2 > 2
git add 2
git commit -m 'MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM Master branch 2'
echo 3 > 3
git add 3
git commit -m 'MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM Master branch 3'
git push origin master
```

### create b-merge branch commit id

```shell
git checkout -b b-merge
git reset --hard fdd5485a21080e373b50fd847ca4f7ab4b7b136e
echo a > a
git add a
git commit -m 'mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm merge branch 1'
echo b > b
git add b
git commit -m 'mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm merge branch 2'
echo c > c
git add c
git commit -m 'mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm merge branch 3'
git push origin b-merge
```

### create b-rebase branch commit id

```shell
git checkout -b b-rebase
git reset --hard fdd5485a21080e373b50fd847ca4f7ab4b7b136e
echo A > A
git add A
git commit -m 'rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr rebase branch 1'
echo B > B
git add B
git commit -m 'rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr rebase branch 2'
echo C > C
git add C
git commit -m 'rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr rebase branch 3'
git push origin b-rebase
```

### merge branch b-merge into branch master

```shell
git checkout master
git merge b-merge # this command will create a merge commit, and commit id of b-merge branch and master branch will mix together
git log
git push origin master
```

### rebase master into b-rebase, then merge fast-forward b-rebase branch into master branch

```shell
git checkout master
git pull origin master
git checkout b-rebase
git rebase master   # after this command, all commit id of b-rebase branch will on top of master branch
git checkout master
git merge b-rebase # this command is merge fast-forward and don't create a merge commit
git log
git push origin master
```

## merge va rebase with conflict

```shell
cp -r test-git-master test-git-merge
cd test-git-merge
cp -r test-git-master test-git-rebase
cd test-git-rebase
git checkout master
git checkout b-merge
git checkout b-rebase
git reset --hard fdd5485a21080e373b50fd847ca4f7ab4b7b136e
git push origin master --force
git push origin b-merge --force
git push origin b-rebase --force
git pull origin master
git pull origin b-merge
git pull origin b-rebase
git log
git branch
```

### create Master branch

```shell
echo 'this is master branch' > README.md
git add README.md
git commit -m 'MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM Master branch 1'
git push origin master
```

### create merged branch

```shell
git checkout -b b-merge
git reset --hard fdd5485a21080e373b50fd847ca4f7ab4b7b136e
echo 'this is b-merge branch' > README.md
git add README.md
git commit -m 'mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm merge branch 1'
git push origin b-merge
```

## create rebased branch

```shell
git checkout -b b-rebase
git reset --hard fdd5485a21080e373b50fd847ca4f7ab4b7b136e
echo 'this is b-rebase branch' > README.md
git add README.md
git commit -m 'rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr rebase branch 1'
git push origin b-rebase
```

### merge branch b-merge into branch master

```shell
git checkout b-merge
git pull origin b-merge
git checkout master
git pull origin master
git merge b-merge # this command will create a merge commit, and commit id of b-merge branch and master branch will mix together
                  # after this command, merge conflict happen
vim README.md     # resolve conflict file
rm README_*.md    # remove all conflict track file
git commit -m 'Merge b-merge branch into master branch'
git log
git push origin master
```

### rebase master branch into b-rebase branch, then merge fast-forward b-rebase branch into master branch

```shell
git checkout master
git pull origin master
git checkout b-rebase
git pull origin b-rebase
git rebase master   # after this command, all commit id of b-rebase branch will on top of master branch
                    # after this command, a confict happen at file README.md
git am --show-current-patch  # run this command to show current conflicted file patch
vim README.md       # resolve conflicted file
git add README.md   # add conflicted file
git rebase --continue   # continue run rebase

git checkout master
git merge b-rebase # this command is merge fast-forward and don't create a merge commit
git log
git push origin master
```
