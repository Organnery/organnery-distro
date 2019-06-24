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

To build a fresh image after modifying the custom packages in the `debs` directory, image `config`, `postinst.sh` or `preseed.conf` files:

```
make image
```

To checksum and compress the image for release:

```
make release
```

That's it, your compressed image `out.img.gz` and checksum file `out.img.md5sum` are ready to be downloaded!

## Flashing the image

The compressed image `out.img.gz` can be flashed to a microSD card in the usual way, using `dd` for example. First, uncompress and verify the image has not been corrupted by comparing it to the checksum file `out.img.md5sum` with these commands:

```
gunzip out.img.gz
md5sum -c out.img.md5sum
```

If the download is good, `md5sum` will report:

```
out.img: OK
```

Then you can proceed to flash the image:

```
sudo dd if=/path/to/out.img of=/dev/sdX bs=4M status=progress
sync
```

...where `/dev/sdX` is the microSD writer device identified by `lsblk` after insertion.

After running the `sync` command it should be safe to unplug the microSD card or a USB writer device.
Watch out for desktop systems that will mount the new microSD card partitions for you automatically, as these may need to be unmounted manually.

## Troubleshooting the flashing process

In case of a corrupted download, `md5sum` should report:

```
out.img: FAILED
md5sum: WARNING: 1 computed checksum did NOT match
```

Try downloading, uncompressing and verifying again. If the problem persists, the person who built the image should be contacted for assistance.

## Troubleshooting the first boot

If the md5sum check passes, but the image will not boot from the microSD card, this is typically caused by a faulty card writer device or a worn-out microSD card.
If the image will not boot after using a known-working card writer and microSD card, and the target device will boot other images, confirm with the person who built the image that this version does in fact boot on the target hardware.

## Remounting the root filesystem read-write

By default, the root filesystem is mounted read-only with an overlay filesystem so that applications behave as normal, but write to temporary files.
Any changes made to the software are reset when the device is rebooted, for consistent results.
If you want to commit any software changes, for example to application scripts, don't forget to do this before you reboot the device!

Start-up scripts are less easy to modify and test with an overlay filesystem, and any extra applications and tools installed will vanish on reboot.
If you wish to change the root filesystem of the target device so that it behaves in a persistent way, you can run the following command from a terminal on the target device:
```
organnery-config overlayfs-disable
```

To return the root filesystem to read-only with an overlay filesystem, you can run the command:
```
organnery-config overlayfs-enable
```
