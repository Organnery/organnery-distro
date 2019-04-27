CONFIG := "config"
IMAGE := "out.img"


clean:
	if [ -f $(IMAGE) ]; then rm $(IMAGE); fi
	if [ -f $(IMAGE).md5sum ]; then rm $(IMAGE).md5sum; fi
	if [ -f $(IMAGE).gz ]; then rm $(IMAGE).gz; fi

image:
	sudo ./debstrap/pdk2 $(CURDIR) $(CONFIG) $(IMAGE)

release:
	md5sum $(IMAGE) > $(IMAGE).md5sum
	gzip --force --keep $(IMAGE)
