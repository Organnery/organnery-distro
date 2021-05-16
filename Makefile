CONFIG_DEF := "config.default"
CONFIG_PIS := "config.pisound"
IMAGE_DEF := "organnery_v0.7.4_default.img"
IMAGE_PIS := "organnery_v0.7.4_pisound.img"


clean:
	if [ -f $(IMAGE_DEF) ]; then rm $(IMAGE_DEF); fi
	if [ -f $(IMAGE_DEF).md5sum ]; then rm $(IMAGE_DEF).md5sum; fi
	if [ -f $(IMAGE_DEF).gz ]; then rm $(IMAGE_DEF).gz; fi
	if [ -f $(IMAGE_PIS) ]; then rm $(IMAGE_PIS); fi
	if [ -f $(IMAGE_PIS).md5sum ]; then rm $(IMAGE_PIS).md5sum; fi
	if [ -f $(IMAGE_PIS).gz ]; then rm $(IMAGE_PIS).gz; fi

default:
	sudo /home/builder/dibby/dibby $(CURDIR) $(CONFIG_DEF) $(IMAGE_DEF)

pisound:
	sudo /home/builder/dibby/dibby $(CURDIR) $(CONFIG_PIS) $(IMAGE_PIS)

release:
	md5sum $(IMAGE) > $(IMAGE).md5sum
	gzip --force --keep $(IMAGE)
