ARCHS = arm64 arm64e
TARGET := iphone:clang:latest:14.0

INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = UniversalVIP
UniversalVIP_FILES = Tweak.x
UniversalVIP_CFLAGS = -fobjc-arc
UniversalVIP_LAYOUT = layout

include $(THEOS_MAKE_PATH)/tweak.mk
