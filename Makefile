TARGET = arpGUI

.PHONY: all clean

install:
	xcodebuild ARCHS=arm64 clean build CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO -sdk iphoneos -configuration Debug
	cp -R build/Debug-iphoneos/$(TARGET).app ./Payload/
	# strip Payload/$(TARGET).app/$(TARGET)
	find . -name '.DS_Store' -type f -delete
	ldid -Sent.plist Payload/$(TARGET).app/$(TARGET)
	scp -P 22 -r Payload/$(TARGET).app root@192.168.1.2:/Applications
	ssh -p 22 root@192.168.1.2 'uicache'

package:
	find . -name '.DS_Store' -type f -delete
	xcodebuild ARCHS=arm64 clean build CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO -sdk iphoneos -configuration Debug
	rm -rf ./Deb-Layout/Applications/$(TARGET).app/
	cp -R build/Debug-iphoneos/$(TARGET).app ./Deb-Layout/Applications/
	ldid -Sent.plist Deb-Layout/Applications/$(TARGET).app/$(TARGET)
	dpkg-deb -b -Zgzip ./Deb-Layout $(TARGET).deb

clean:
	rm -rf build Payload/$(TARGET).app Deb-Layout/Applications/$(TARGET).app Payload/Debug-iphoneos 
