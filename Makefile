TARGET = iphone:clang:16.5:14.0
INSTALL_TARGET_PROCESSES = Calculator

THEOS_PACKAGE_SCHEME = rootless

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = CalculatorHistory

CalculatorHistory_FILES = Tweak.x $(shell find . \( -path "*/.theos/*" \) -prune -o -name "*.m" -print)
CalculatorHistory_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
