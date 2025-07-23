To update a Git commit, you have a few options depending on **what** you want to update and **whether the commit has been pushed**.

---

### 🛠️ 1. **Update the Last Commit (Not Pushed)**

If you **haven’t pushed** the commit yet, you can modify it using:

```bash
git commit --amend
```

This lets you:

* Edit the commit message.
* Include new file changes.

#### Example:

```bash
# Stage your changes first
git add myfile.py

# Amend the last commit
git commit --amend
```

It will open an editor to change the commit message. Save and close to finish.

---

### 🛠️ 2. **Update a Commit Deeper in History**

If the commit you want to update is **not the last one**, use **interactive rebase**:

```bash
git rebase -i HEAD~n
```

Where `n` is the number of commits back you want to edit. For example, to go back 3 commits:

```bash
git rebase -i HEAD~3
```

* Mark the commit you want to edit by changing `pick` to `edit`.
* Git will pause at that commit.
* Then you can change files and commit again using `--amend`:

```bash
# Make your changes
git add myfile.py

# Amend the commit
git commit --amend

# Continue the rebase
git rebase --continue
```

---

### ⚠️ 3. **If the Commit Was Pushed**

* If you've **already pushed** the commit, amending it and rebasing will require a **force push**:

```bash
git push --force
```

**Be careful** with this, especially on shared branches, as it can overwrite history and disrupt your teammates' work.

---

Would you like help with a specific kind of update (e.g., changing a message, adding files, or modifying an old commit)?
