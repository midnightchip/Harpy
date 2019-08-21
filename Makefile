include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/null.mk

all::
	xcodebuild -workspace harpy.xcworkspace/ CODE_SIGN_IDENTITY="" AD_HOC_CODE_SIGNING_ALLOWED=YES -quiet -scheme harpy archive -archivePath Harpy.xcarchive GCC_PREPROCESSOR_DEFINITIONS=PACKAGE_VERSION='@\"$(THEOS_PACKAGE_BASE_VERSION)\"'

after-stage::
	mv Harpy.xcarchive/Products/Applications $(THEOS_STAGING_DIR)/Applications
	rm -rf Harpy.xcarchive
	$(MAKE) -C horizon LEAN_AND_MEAN=1
	mkdir -p $(THEOS_STAGING_DIR)/usr/libexec/harpy
	mv $(THEOS_OBJ_DIR)/horizon $(THEOS_STAGING_DIR)/usr/libexec/harpy
	rm -rf $(THEOS_STAGING_DIR)/Applications/harpy.app/embedded.mobileprovision
	ldid -S $(THEOS_STAGING_DIR)/Applications/harpy.app/harpy
	#ldid -S $(THEOS_STAGING_DIR)/Applications/Zebra.app/Frameworks/SDWebImage.framework/SDWebImage
	ldid -Sent.plist $(THEOS_STAGING_DIR)/Applications/harpy.app/harpy

after-install::
	install.exec "killall \"harpy\"" || true