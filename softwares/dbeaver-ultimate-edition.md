> Download links point to the private [softwares repository](https://github.com/alexander1307xa/softwares). Sign in to GitHub with an account that has access; otherwise the links may return 404.

# DBeaver Ultimate Edition Installation Guide

---

## Version 24.3.0

### Download Files

Download the required files from the [GitHub Release](https://github.com/alexander1307xa/softwares/releases/tag/dbeaver-24.3):
- `dbeaver-ue_24.3.0_amd64.deb` - DBeaver Ultimate Edition installer
- `dvt-DBeaver-KeyMaker.jar` - License key generator

### Installation Steps

#### 1. Install DBeaver
Install the downloaded package `dbeaver-ue_24.3.0_amd64.deb`:

```bash
sudo dpkg -i dbeaver-ue_24.3.0_amd64.deb
```

#### 2. Set Up Java

**Windows:**
Install `jre-8u341-windows-x64`

**Ubuntu:**
Verify Java installation:
```bash
java --version
```

Expected output:
```
openjdk 11.0.20 2023-07-18
OpenJDK Runtime Environment (build 11.0.20+8-post-Ubuntu-1ubuntu122.04)
OpenJDK 64-Bit Server VM (build 11.0.20+8-post-Ubuntu-1ubuntu122.04, mixed mode, sharing)
```

#### 3. Generate License Key

Run the key generator file `dvt-DBeaver-KeyMaker.jar`:

**Windows:**
Right-click the file and run as Administrator.

**Ubuntu:**
```bash
sudo java -jar dvt-DBeaver-KeyMaker.jar
```

#### 4. Patch and Locate Installation Folder

1. Click **Patch** in the key generator
2. Select the installation folder:

**Windows:**
```
C:\Users\Xuan Anh\AppData\Local\DBeaverUltimate\Plugins
```

**Ubuntu:**
Default path:
```
/usr/share/dbeaver-ue/plugins
```

Custom path:
```
/home/xuananh/.dbeaver_ue/usr/share/dbeaver-ue/plugins
```

3. Select and copy the following files:
   - `com.dbeaver.model.license_*.jar`
   - `com.dbeaver.app.ultimate_*.jar`

#### 5. Activate License

1. Open DBeaver
2. Paste the serial key
3. Complete activation

---

## Version 23.1.0

### Download Files

Download the required files from the [GitHub Release](https://github.com/alexander1307xa/softwares/releases/tag/dbeaver-23.1.0):

**Installation Packages:**
- [dbeaver-ue_23.1.0_amd64.deb](https://github.com/alexander1307xa/softwares/releases/download/dbeaver-23.1.0/dbeaver-ue_23.1.0_amd64.deb) - Linux (Ubuntu/Debian)
- [dbeaver-ue-23.1.0-x86_64-setup.exe](https://github.com/alexander1307xa/softwares/releases/download/dbeaver-23.1.0/dbeaver-ue-23.1.0-x86_64-setup.exe) - Windows
- [dbeaver-ue-23.1.0-macos-x86_64.dmg](https://github.com/alexander1307xa/softwares/releases/download/dbeaver-23.1.0/dbeaver-ue-23.1.0-macos-x86_64.dmg) - macOS

**Keygen Files:**
- [dvt-DBeaver-KeyMaker.jar](https://github.com/alexander1307xa/softwares/releases/download/dbeaver-23.1.0/dvt-DBeaver-KeyMaker.jar) - License key generator
- [KeyMaker.and.Patch-DVT.rar](https://github.com/alexander1307xa/softwares/releases/download/dbeaver-23.1.0/KeyMaker.and.Patch-DVT.rar) - Alternative keygen package

### Installation Steps

#### 1. Install DBeaver

**Windows:**
Run the installer `dbeaver-ue-23.1.0-x86_64-setup.exe`

**Ubuntu/Linux:**
```bash
sudo dpkg -i dbeaver-ue_23.1.0_amd64.deb
```

**macOS:**
Open and install `dbeaver-ue-23.1.0-macos-x86_64.dmg`

#### 2. Set Up Java

**Windows:**
Install `jre-8u341-windows-x64`

**Ubuntu:**
Verify Java installation:
```bash
java --version
```

Expected output:
```
openjdk 11.0.20 2023-07-18
OpenJDK Runtime Environment (build 11.0.20+8-post-Ubuntu-1ubuntu122.04)
OpenJDK 64-Bit Server VM (build 11.0.20+8-post-Ubuntu-1ubuntu122.04, mixed mode, sharing)
```

#### 3. Generate License Key

Run the key generator file `dvt-DBeaver-KeyMaker.jar`:

**Windows:**
Right-click the file and run as Administrator.

**Ubuntu:**
```bash
sudo java -jar dvt-DBeaver-KeyMaker.jar
```

#### 4. Patch and Locate Installation Folder

1. Click **Patch** in the key generator
2. Select the installation folder:

**Windows:**
```
C:\Users\Xuan Anh\AppData\Local\DBeaverUltimate\Plugins
```

**Ubuntu:**
Default path:
```
/usr/share/dbeaver-ue/plugins
```

Custom path:
```
/home/xuananh/.dbeaver_ue/usr/share/dbeaver-ue/plugins
```

3. Select the following files:
   - `com.dbeaver.lm.core_*.jar`
   - `com.dbeaver.app.ultimate_*.jar`

#### 5. Activate License

1. Open DBeaver
2. Copy and paste the serial key
3. Complete activation

---

## References

- [VN-Z Forum: DBeaver Ultimate Edition v23.1](https://vn-z.vn/threads/dbeaver-ultimate-edition-v23-1-full-quan-ly-co-so-du-lieu.46941/)
- [RSLoad: DBeaver Ultimate Edition](https://rsload.net/soft/manager/35519-dbeaver-ultimate-edition.html)
