TARGET = arpGUI

.PHONY: all clean

install:
	xcodebuild ARCHS=arm64 clean build CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO -sdk iphoneos -configuration Debug
	cp -R build/Debug-iphoneos/$(TARGET).app ./Payload/
	# strip Payload/$(TARGET).app/$(TARGET)
	ldid -Sent.plist Payload/$(TARGET).app/$(TARGET)
	scp -P 22 -r Payload/$(TARGET).app root@192.168.1.4:/Applications
	ssh -p 22 root@192.168.1.4 'uicache'

package:
	xcodebuild ARCHS=arm64 clean build CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO -sdk iphoneos -configuration Debug
	cp -R build/Debug-iphoneos/$(TARGET).app ./Payload/Deb-Layout/Applications/
	ldid -Sent.plist Payload/Deb-Layout/Applications/$(TARGET).app/$(TARGET)
	#$(THEOS)/bin/dm.pl -z1 ./Payload/Deb-Layout ./Payload/Package/Installer.deb
	dpkg-deb -b -Zgzip ./Payload/Deb-Layout ./Payload/Package/$(TARGET).deb

clean:
	rm -rf build Payload/$(TARGET).app Payload/Deb-Layout/Applications/Installer.app Payload/Debug-iphoneos 
