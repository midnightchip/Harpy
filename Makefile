TARGET = arpGUI

.PHONY: all clean

install:
	find . -name '.DS_Store' -type f -delete
	xcodebuild clean build CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO -sdk iphoneos -configuration Debug
	rm -rf ./Deb-Layout/Applications/$(TARGET).app/
	cp -R build/Debug-iphoneos/$(TARGET).app ./Deb-Layout/Applications/
	ldid -Sent.plist Deb-Layout/Applications/$(TARGET).app/$(TARGET)
	dpkg-deb -b -Zgzip ./Deb-Layout $(TARGET).deb
	scp -P 2222 -r  $(TARGET).deb root@127.0.0.1:
	ssh -p 2222 root@127.0.0.1 'dpkg -i $(TARGET).deb'

package:
	find . -name '.DS_Store' -type f -delete
	xcodebuild ARCHS=arm64 clean build CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO -sdk iphoneos -configuration Debug
	rm -rf ./Deb-Layout/Applications/$(TARGET).app/
	cp -R build/Debug-iphoneos/$(TARGET).app ./Deb-Layout/Applications/
	ldid -Sent.plist Deb-Layout/Applications/$(TARGET).app/$(TARGET)
	dpkg-deb -b -Zgzip ./Deb-Layout $(TARGET).deb

#clean:
	#rm -rf build Payload/$(TARGET).app Deb-Layout/Applications/$(TARGET).app Payload/Debug-iphoneos 
