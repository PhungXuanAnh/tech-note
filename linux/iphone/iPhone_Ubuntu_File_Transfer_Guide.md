How to Transfer Photos and Videos from iPhone to Ubuntu
---

This guide provides step-by-step instructions for connecting your iPhone to an Ubuntu machine, accessing your photos and videos, and troubleshooting common issues.

- [How to Transfer Photos and Videos from iPhone to Ubuntu](#how-to-transfer-photos-and-videos-from-iphone-to-ubuntu)
- [Part 1: Initial Setup (One-Time Only)](#part-1-initial-setup-one-time-only)
- [Part 2: Connecting and Mounting Your iPhone](#part-2-connecting-and-mounting-your-iphone)
- [Part 3: Copying Your Photos and Videos](#part-3-copying-your-photos-and-videos)
- [Part 4: Safely Unmounting the iPhone](#part-4-safely-unmounting-the-iphone)
- [Part 5: Troubleshooting](#part-5-troubleshooting)
  - [Problem: "Trust This Computer" prompt does not appear.](#problem-trust-this-computer-prompt-does-not-appear)
  - [Problem: I can see my iPhone in the file manager, but there are no photos.](#problem-i-can-see-my-iphone-in-the-file-manager-but-there-are-no-photos)


## Part 1: Initial Setup (One-Time Only)

First, you need to install the necessary software that allows Ubuntu to communicate with your iPhone.

1.  **Update your package list:**
    Open a terminal and run the following command to ensure you have the latest package information.
    ```bash
    sudo apt update
    ```

2.  **Install the required packages:**
    This command installs `ifuse` and other essential utilities for handling iPhone devices.
    ```bash
    sudo apt install ifuse libimobiledevice6 libimobiledevice-utils gvfs-backends gvfs-fuse
    ```

---

## Part 2: Connecting and Mounting Your iPhone

Follow these steps each time you want to transfer files.

1.  **Connect Your iPhone:**
    *   Plug your iPhone into your Ubuntu computer using a USB cable.
    *   If prompted on your iPhone, tap **"Trust This Computer"** and enter your passcode.

2.  **Create a Mount Point:**
    This is a folder on your computer where the iPhone's files will be accessible. You only need to create this folder once.
    ```bash
    mkdir ~/iphone
    ```

3.  **Mount the iPhone's Media Folder:**
    This command makes the iPhone's photos and videos accessible in the `~/iphone` folder.
    ```bash
    ifuse ~/iphone
    ```
    After running this, the contents of your iPhone's media directory will appear in the `iphone` folder in your home directory.

---

## Part 3: Copying Your Photos and Videos

1.  **Create a Backup Folder:**
    It's good practice to create a dedicated folder on your computer to store the files you're copying. This example uses a folder named `iPhone_Backup` inside your `Pictures` directory.
    ```bash
    mkdir -p ~/Pictures/iPhone_Backup
    ```

2.  **Copy the Files:**
    Your photos and videos are stored in a folder named `DCIM` on the iPhone. This command copies the entire `DCIM` folder to your backup location.
    ```bash
    cp -r ~/iphone/DCIM ~/Pictures/iPhone_Backup
    ```
    This process may take some time, depending on how many photos and videos you have.

---

## Part 4: Safely Unmounting the iPhone

Once the copy process is complete, you should unmount the iPhone to ensure the connection is closed properly.

```bash
fusermount -u ~/iphone
```

You can now safely unplug your iPhone.

---

## Part 5: Troubleshooting

Here are solutions to common problems you might encounter.

### Problem: "Trust This Computer" prompt does not appear.

If your iPhone is charging but the "Trust" prompt doesn't show up and commands like `idevicepair pair` fail with "No device found":

*   **Solution 1: Check Hardware**
    *   Try a different USB port on your computer.
    *   Use a different, high-quality USB cable (preferably an official Apple one). Some cables only support charging and not data transfer.

*   **Solution 2: Restart the Connection Service**
    Run this command to restart the service that manages USB connections for Apple devices.
    ```bash
    sudo systemctl restart usbmuxd
    ```
    Then, unplug and reconnect your iPhone.

*   **Solution 3: Reset iPhone's Trust Settings**
    This will clear all previous trust settings on your iPhone.
    1.  Go to **Settings > General > Transfer or Reset iPhone**.
    2.  Tap **Reset**.
    3.  Tap **Reset Location & Privacy**.
    4.  Enter your passcode to confirm.
    5.  Reconnect the iPhone to your computer. You should be prompted to trust it again.

### Problem: I can see my iPhone in the file manager, but there are no photos.

The default connection often mounts the iPhone's "Documents" storage, not the media partition where photos are stored.

*   **Solution:** You must use the `ifuse` command-line method described in **Part 2** to specifically mount the media partition. This will give you access to the `DCIM` folder containing your photos and videos.
