TARGET := iphone:clang:latest:13.0
INSTALL_TARGET_PROCESSES = SpringBoard

ARCHS = arm64 arm64e

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = CalculatorHistory

CalculatorHistory_FILES = Tweak.x
CalculatorHistory_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
