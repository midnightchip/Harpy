ARCHS = armv7 arm64 arm64e
TARGET = iphone::10.3:8.0
include $(THEOS)/makefiles/common.mk

TOOL_NAME = horizon
horizon_FILES = main.c
horizon_INSTALL_PATH = /Applications/harpy.app
horizon_CODESIGN_FLAGS = -Sent.plist

include $(THEOS_MAKE_PATH)/tool.mk
