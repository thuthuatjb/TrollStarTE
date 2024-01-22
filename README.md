# kfund (Post-Exploitation)
kfund, short for my [fun](kfd/fun) with kfd exploit. Original by @wh1te4ever, modify for TrollStore installation and called TrollStar by [34306 (me)](https://github.com/34306) and [straight-tamago](https://github.com/straight-tamago)

## What are the supported OS versions and devices?
Probably iOS 16.0 to 16.6.1 on all iOS/iPadOS (arm64/arm64e/M1/M2 supported)
---

## What you can do with this?
#### Install TrollStore Helper to Tips
---
## Preview
[](TrollStar/Preview.PNG)

# kfd

kfd, short for kernel file descriptor, is a project to read and write kernel memory on Apple
devices. It leverages various vulnerabilities that can be exploited to obtain dangling PTEs, which
will be referred to as a PUAF primitive, short for "physical use-after-free". Then, it reallocates
certain kernel objects inside those physical pages and manipulates them directly from user space
through the dangling PTEs in order to achieve a KRKW primitive, short for "kernel read/write". The
exploit code is fully contained in a library, [libkfd](kfd/libkfd.h), but the project also contains
simple executable wrappers for [iOS](kfd/ContentView.swift) and [macOS](macos_kfd.c).

##  How to build and run kfd on an iPhone?

In Xcode, open the root folder of the project and connect your iOS device.

- To build the project, select Product > Build (⌘B).
- To run the project, select Product > Run (⌘R), then click on the "kopen" button in the app.

---

## Where to find detailed write-ups for the exploits?

This README presented a high-level overview of the kfd project. Once a PUAF primitive has been
achieved, the rest of the exploit is generic. Therefore, I have hoisted the common part of the
exploits in a dedicated write-up:

- [Exploiting PUAFs](writeups/exploiting-puafs.md)

In addition, I have split the vulnerability-specific part of the exploits used to achieve the PUAF
primitive into distinct write-ups, listed below in chronological order of discovery:

-   [PhysPuppet](writeups/physpuppet.md)
-   [Smith](writeups/smith.md)

However, please note that these write-ups have been written for an audience that is already familiar
with the XNU virtual memory system.
