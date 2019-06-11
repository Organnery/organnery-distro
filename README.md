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
```

...where `/dev/sdX` is the microSD writer device identified by `lsblk` after insertion.

## Troubleshooting

In case of a corrupted download, `md5sum` should report:

```
out.img: FAILED
md5sum: WARNING: 1 computed checksum did NOT match
```

Try downloading, uncompressing and verifying again. If the problem persists, the person who built the image should be contacted for assistance.