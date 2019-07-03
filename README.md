# Build instructions for the Organnery GNU/Linux distribution

If you are an Organnery user, you do not need to build the image yourself, as ready-made images are available. This  _organnery-distro_ repository is intended for Organnery developers who need to build new images.

Building this project has been tested on Debian Stretch and Debian Sid. Your user will need sudo rights on the distro build host.

The tool `dibby` is used to build this image. This _organnery-distro_ repository is a dibby workspace, with custom packages in the `debs` directory and a `Makefile` used to simplify some routine dibby commands.

The source code for dibby and instructions for installation of dibby on a Debian host are available here: https://github.com/64studio/dibby

## Makefile commands

To clean this workspace of previously generated files, run the command:
```
make clean
```

Next, you will probably want to increment the version number `v*.img` in the `Makefile` to avoid overwriting your previously generated image.
For example, before building image version 999, you would bump the value of `IMAGE` to:
```
IMAGE := "organnery_v999.img"
```

To build a fresh image after modifying the custom packages in the `debs` directory, image `config`, `postinst.sh` or `preseed.conf` files:
```
make image
```

To checksum and compress the image for release:
```
make release
```

That's it, your compressed image `organnery_v*.img.gz` and checksum file `organnery_v*.img.md5sum` are ready to be downloaded!

## Flashing the image

The compressed image `organnery_v*.img.gz` can be flashed to a microSD card in the usual way, using `dd` for example.
First, uncompress and verify the image has not been corrupted by comparing it to the checksum file `organnery_v*.img.md5sum` with these commands:
```
gunzip organnery_v*.img.gz
md5sum -c organnery_v*.img.md5sum
```

If the download is good, `md5sum` will report:
```
organnery_v*.img: OK
```

Then you can proceed to flash the image:
```
sudo dd if=organnery_v*.img of=/dev/sdX bs=4M status=progress
sync
```

...where `/dev/sdX` is the microSD writer device identified by `lsblk` after insertion.

After running the `sync` command it should be safe to unplug the microSD card or a USB writer device.
Watch out for desktop systems that will mount the new microSD card partitions for you automatically, as these may need to be unmounted manually.

## Verifying the image

Immediately after flashing, before the microSD card has been booted or modified, it is possible to check that the flashing worked correctly, using the `cmp` command. For example:
```
sudo cmp organnery_v*.img /dev/sdX
cmp: EOF on organnery_v*.img
```

The response `EOF on organnery_v*.img` means the end of the image was reached without finding any differences between the image and the microSD card /dev/sdX.

## Troubleshooting the flashing process

In case of a corrupted download, `md5sum` should report:
```
organnery_v*.img: FAILED
md5sum: WARNING: 1 computed checksum did NOT match
```

Try downloading, uncompressing and verifying again. If the problem persists, the person who built the image should be contacted for assistance.

If the md5sum check passes but the microSD card does not match the image file after flashing, the output from the `cmp` command will differ, for example:
```
sudo cmp organnery_v*.img /dev/sdX
organnery_v*.img /dev/sdX differ: byte 441, line 1
```

This is typically caused by a faulty card writer device or a worn-out microSD card.
Flash the microSD card again and use the `cmp` command to verify the flashing worked correctly before booting it.
If the problem persists, switch card writer device and/or microSD card for replacements known to work.

## Troubleshooting the first boot

If both the md5sum and cmp checks pass, but the image will not boot from the microSD card, this could be caused by faulty hardware on the target device.
Check that the target device will boot other images and that the power supply is providing sufficient voltage under load (the lightning bolt icon is not shown on any display of the target device, and there are no voltage errors in dmesg).
If the image will not boot after using a known-working card writer and microSD card, and the target device will boot other images, confirm with the person who built the image that this version does in fact boot on the target hardware.

## Remounting the root filesystem read-write

By default, the root filesystem is mounted read-only, with an overlay filesystem so that applications behave as normal but write to temporary files.
Any changes made to the software are reset when the device is rebooted, for consistent results.
If you want to commit any software changes, for example to application scripts, don't forget to do this before you reboot the device!

Start-up scripts are less easy to modify and test with an overlay filesystem, and any extra Debian packages, kernels, applications or tools installed will vanish on reboot.
If you wish to change the root filesystem of the target device so that it behaves in a persistent way, you can run the following command from a terminal on the target device:
```
organnery-config overlayfs-disable
```

To return the root filesystem to read-only with an overlay filesystem, you can run the command:
```
organnery-config overlayfs-enable
```

To check the current state of the overlay filesystem, run the command:
```
organnery-config overlayfs-check
```

This will either return `overlayfs is enabled for current session`, in which case any filesystem changes will be lost on reboot of the device, or `overlayfs is disabled for current session` indicating that any filesystem changes will be persistent.
The state of the system after the next reboot will also be reported, as either `overlayfs is enabled for the next session` or `overlayfs is disabled for the next session`.

If you only want the /boot partition mounted read-write, and the rest of the filesystem unchanged, you can run the command:
```
organnery-config mount-boot
```
