
Unlocking the Beast: A Final Technical Guide to Optimizing the Lenovo Legion 5 16IRX9 on Ubuntu


Introduction: A High-Performance Conundrum

The Lenovo Legion 5 16IRX9, equipped with a cutting-edge Intel Core i9-14900HX processor and an NVIDIA RTX 4070 graphics card, is engineered for elite performance. However, the initial experience of system hangs, lags, and instability after installing Ubuntu 22.04 highlighted a complex challenge. This was not a single bug but a multi-layered issue stemming from a "hardware enablement gap," where bleeding-edge hardware outpaces the default software support of a long-term support OS.
Through a systematic process of diagnosis and configuration, we identified and resolved the root causes. The instability was traced to a combination of three factors: an outdated kernel ill-equipped for the 14th Gen CPU, suboptimal graphics driver configuration, and, most critically, a hardware-level lock caused by the laptop's Embedded Controller (EC) getting stuck in a low-power state.
This final report documents the complete, successful procedure to transform the unstable system into a high-performance, reliable Linux workstation. It serves as a definitive guide, incorporating all the steps from our investigation.

Section 1: The Definitive 5-Step Solution

This protocol outlines the precise, sequential steps required to resolve the instability. Following this order is crucial as it addresses the problem from the foundational hardware layer up to the operating system and its drivers.

Step 1: Update and Configure System BIOS

The BIOS is the foundation of the system. Ensuring it is up-to-date and correctly configured is the first priority.
A. Update BIOS via Windows:
Boot into your pre-installed Windows 11 installation.
Navigate to the Lenovo support page for the Legion Pro 5 16IRX9.
Download the main BIOS update file, identified from your screenshot as N0CN31WW.exe.
Right-click the downloaded file, select "Run as administrator," and follow the on-screen wizard to flash the update. The system will reboot automatically to complete the process.
B. Configure BIOS Settings:
Reboot and press the F2 key repeatedly during the Lenovo splash screen to enter the BIOS setup.
Based on the images you provided, confirm the following critical settings are applied:
Graphics Device: Set to Discrete Graphics. This is the single most important setting for stability, bypassing the problematic NVIDIA Optimus switching logic.1
Secure Boot: Set to Disabled. This is mandatory to allow Ubuntu to load the proprietary NVIDIA drivers.2

Step 2: Perform an Embedded Controller (EC) Reset

This was the ultimate key to unlocking your system's performance. The EC, a low-level controller for power and fans, was stuck in a "Quiet Mode," forcing the CPU to run at its lowest speed regardless of OS settings. This reset clears that bad state.
Shut down the laptop completely.
Disconnect the AC power adapter and all peripheral devices (monitors, mice, USB drives, etc.).
Press and hold the power button for a continuous 60 seconds to drain all residual power and reset the EC.3
Release the power button, reconnect only the AC adapter, and turn the laptop on.

Step 3: Set Hardware Performance Mode

With the EC now functioning correctly, you can control the laptop's hardware power profiles.
After booting into Ubuntu, press the Fn+Q key combination.
Cycle through the modes until the LED on your power button turns red. This confirms the laptop is in its hardware Performance Mode, giving the OS permission to use the full power of the CPU and fans.

Step 4: Install the Correct Linux Kernel and setup performance mode for all cpu

To ensure Ubuntu has the proper software support for the modern i9-14900HX CPU, the OEM kernel is required.
Open a terminal and run the following command:
Bash
# search 
apt-cache search linux-image-.*oem
# install oem kernel
# Example using 6.5.0-1023, but use YOUR highest version!
sudo apt install linux-image-6.5.0-1023-oem linux-headers-6.5.0-1023-oem
Update grub config: sudo vim /etc/default/grub
Find : 
GRUB_DEFAULT=0
Change to:
GRUB_DEFAULT=saved
GRUB_SAVEDEFAULT=true
Then: sudo update-grub
After reboot, go into Advanced Options in GRUB, select 6.5.0-1027-oem once. From then on, GRUB will remember and always boot it.
Intall cpupower tool (NOTE: based on command, you can see that it need to install after changing kernel):
sudo apt-get update && sudo apt-get install -y linux-tools-common linux-tools-$(uname -r)

Step 5: Install the Correct NVIDIA Driver
The final software step is to install the optimal proprietary driver for the RTX 4070.
Run the command: sudo ubuntu-drivers autoinstall
Alternatively:
Open the "Software & Updates" application.
Navigate to the "Additional Drivers" tab.
Based on your screenshot of the available drivers, select the highest-numbered, tested version: Using NVIDIA driver metapackage from nvidia-driver-575 (proprietary, tested).
Click "Apply Changes" and reboot the computer when prompted.

Section 2: Post-Fix Validation Plan

This checklist confirms that all fixes have been successfully applied and the system is performing as expected.

Step 1: Verify Hardware State (EC and Power Mode)

Goal: Confirm the hardware is unlocked from the low-power state.
Action: Observe the LED on the laptop's power button.
Expected Result: The light is red, confirming the system is in Performance Mode.

Step 2: Verify Kernel Version

Goal: Confirm the correct, hardware-enabling kernel is active.
Command:
Bash
uname -r


Expected Result: The output is 6.5.0-1027-oem, matching your successful installation.

Step 3: Verify NVIDIA Driver

Goal: Confirm the proprietary driver is loaded and managing the RTX 4070 GPU.
Command:
Bash
nvidia-smi


Expected Result: A table appears showing "NVIDIA GeForce RTX 4070 Laptop GPU" and the driver version, confirming it is active.

Step 4: Verify Dynamic CPU Performance

Goal: Confirm the CPU is no longer stuck at low speeds and boosts correctly under load.
Action:
Open a demanding application (e.g., Google Chrome with a video call, multiple applications).
While under load, open a system monitor (like the btop tool in your screenshots).
Expected Result:
The system feels smooth and responsive, with no lag.
The monitor shows CPU frequencies dynamically increasing from idle (~800 MHz) to high-performance speeds (2.0 GHz to 5.6 GHz+), as seen in your final screenshot.
The fans are audible under load, indicating the EC is correctly managing thermals.

Step 5: Verify CPU Governor State

Goal: Confirm the CPU is using the optimal dynamic power management strategy.
Command:
Bash
cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor


Expected Result: The output shows powersave for all cores. With a functional EC, this is the correct and ideal state, allowing the CPU to idle efficiently and boost instantly when performance is needed.

Forcing Hardware Acceleration in Chrome
The last step is to configure Chrome to more aggressively use your GPU, which will offload work from the CPU and make the browser feel much smoother under heavy load. This is a common and necessary tuning step for Chrome on Linux.
Step 1: Open Chrome Flags
Open Google Chrome.
In the address bar, type chrome://flags and press Enter.
Step 2: Enable Critical GPU Flags
Use the search bar at the top of the flags page to find and Enable the following three settings. These are widely reported to fix performance issues on Linux with NVIDIA GPUs.
Override software rendering list
Search for: override software
Set to: Enabled
Why: This is the most important flag. It forces Chrome to use GPU acceleration even for components it thinks might be incompatible, which is often the case with NVIDIA on Linux.
GPU rasterization
Search for: rasterization
Set to: Enabled
Why: This offloads the task of rendering web page content from the CPU to the GPU, which is exactly what we need.1
Accelerated 2D canvas
Search for: canvas
Set to: Enabled
Why: This uses the GPU to render 2D elements on web pages, further reducing CPU load.
Step 3: Relaunch Chrome
After changing these settings, a "Relaunch" button will appear at the bottom of the screen. Click it to restart Chrome and apply the changes.
After relaunching, try your 50-tab test again. While it is still a very heavy workload, you should notice a significant improvement in responsiveness when switching tabs, as the GPU will now be handling a much larger share of the rendering work. This final, application-level tweak completes the optimization of your system.

Conclusion: A Fully Optimized System

The initial instability of your Lenovo Legion 5 was the result of a complex interaction between a hardware-level firmware lock and a software stack that was not yet optimized for such new components. The critical turning point in our investigation was the discovery that the Embedded Controller (EC) was stuck in a low-power "Quiet Mode," which prevented any software-level fixes from taking effect.
By executing a specific sequence of actions—updating the BIOS, performing a hardware-level EC reset, setting the correct power mode, and then installing the appropriate kernel and drivers—we successfully resolved the conflict at every layer. The final validation tests confirm that the system is now stable, responsive, and performing at its full potential. Your laptop is now the high-performance Ubuntu workstation it was meant to be.
Works cited
Stutter/Lag on Lenovo legion 5 16IRX9 i7-14700hx, and 4070 gpu : r ..., accessed September 7, 2025, https://www.reddit.com/r/LenovoLegion/comments/1j6kclg/stutterlag_on_lenovo_legion_5_16irx9_i714700hx/
Installing Ubuntu on Lenovo Legion | by Jayapriya Pai | Geek-Thoughts | Medium, accessed September 7, 2025, https://medium.com/geekthoughts/installing-ubuntu-on-lenovo-legion-8868d2a307c5
Community-Spotlight - One Language Community - LENOVO ..., accessed September 7, 2025, https://forums.lenovo.com/topic/findpost/2250/5323895/6450679
System freeze with fresh Ubuntu 22.04 install on Thinkpad T16 Gen 1, accessed September 7, 2025, https://forums.lenovo.com/t5/Ubuntu/System-freeze-with-fresh-Ubuntu-22-04-install-on-Thinkpad-T16-Gen-1/m-p/5261854
