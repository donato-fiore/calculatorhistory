TARGET = iphone:clang:16.5:14.0
INSTALL_TARGET_PROCESSES = Calculator

THEOS_DEVICE_IP = localhost
THEOS_DEVICE_PORT = 2222
THEOS_PACKAGE_SCHEME = rootless

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = CalculatorHistory

CalculatorHistory_FILES = Tweak.x $(wildcard *.m)
CalculatorHistory_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
