This script create a virtual camera, then show an image in this camera

```bash
Usage: ./setup-virtual-camera.sh

Commands:
  setup                 Run all pre-flight checks and install dependencies.
  start    Load module and start streaming image (default: sun.png).
  stop                  Stop streaming and unload the module.
  status                Show detailed status of the virtual camera.
  list                  List all V4L2 devices on the system.
  --help                Show this help message.

Example Workflow:
  1. ./setup-virtual-camera.sh setup
  2. ./setup-virtual-camera.sh start my_photo.jpg
  3. (Use in browser)
  4. ./setup-virtual-camera.sh stop
```