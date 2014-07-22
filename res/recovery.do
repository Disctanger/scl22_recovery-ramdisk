
on init-recovery
	mount /system
	
	unmount /cache	
	exec -f "/system/bin/e2fsck -v -y <dev_node:/cache>"
	
	mount -f /cache
	cat -f --no-exist /cache/recovery/command > /cache/recovery/last_command
	ls /cache/recovery/
	
	mount /data
	fcut --limited-file-size=256k -f /data/log/recovery_log.txt /tmp/recovery_backup.txt


on multi-csc
	echo 
	echo "-- Appling Multi-CSC..."
	mount /system	
	echo "Applied the CSC-code : <salse_code>"
	cp -y -f -r -v /system/csc/common /
	unmount /system
	mount /system
	cmp -r /system/csc/common /	
	cp -y -f -r -v /system/csc/<salse_code>/system /system
	rm -v /system/csc_contents
	ln -v -s /system/csc/<salse_code>/csc_contents /system/csc_contents
	unmount /system
	mount /system	
	cmp -r /system/csc/<salse_code>/system /system
	rm -v --limited-file-size=0 /system/app/*
	echo "Successfully applied multi-CSC."

on multi-csc-data
	unmount -f /system
	mount /data
	cp -y -f -r -v --with-fmode=0644 --with-dmode=0771 --with-owner=system.system /data/csc/common /
	cp -y -f -r -v --with-fmode=0644 --with-dmode=0771 --with-owner=system.system /data/csc/<salse_code> /
	rm -v --limited-file-size=0 /data/app/*	
	rm -v -r -f /data/csc
	unmount /data

on factory-out
  mount /efs
  write /efs/.currentlyFactoryReset "done"
  unmount /efs
  
	echo "-- Copying media files..."
	mount /data
	mount /system
	mkdir media_rw media_rw 0770 /data/media
	cp -y -r -v -f --with-fmode=0664 --with-dmode=0775 --with-owner=media_rw.media_rw /system/hidden/INTERNAL_SDCARD/ /data/media/
	unmount /data
	mount /data
	cmp -r /system/hidden/INTERNAL_SDCARD/ /data/media/
	

    
on post-recovery
	mount /cache
	mkdir system cache 0775 /cache/recovery
	cp -y -f -v /tmp/recovery_backup.txt /cache/recovery/last_recovery

	mount /data
	mkdir system log 0775 /data/log
	cp -y -f -v /tmp/recovery_backup.txt /data/log/recovery_log.txt


on resizing-data
	mount /system

	mount /data
	find -v --print=/tmp/data.list /data
	unmount /data
	
	loop_begin 2
		exec "/system/bin/e2fsck -y -f -e <dev_node:/data>"
		exec "/system/bin/resize2fs -R 16384 <dev_node:/data>"
	loop_end

	mount /data
	df /data
	verfiy_data <dev_node:/data> /data 5
	verfiy_data --size-from-file=/tmp/data.list
	unmount /data
	

on create-wipe-command
	mount /cache
	mkdir system cache 0770 /cache/recovery
	write /cache/recovery/command "--wipe_data\n"
	chmod -v 0777 /cache/recovery/command	
	chown -v system system /cache/recovery/command
	unmount /cache

on release-wipe-command
	mount /cache
	rm -f -v /cache/recovery/command
	unmount /cache
	
