ARCHS = armv7 armv7s arm64
TARGET = iphone:clang
THEOS_BUILD_DIR = Packages
PACKAGE_VERSION = 1.0
FINALPACKAGE = 1
DEBUG = 0

include $(THEOS)/makefiles/common.mk

LIBRARY_NAME = CFXPreferences
CFXPreferences_FILES = CFXPreferences.m
CFXPreferences_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/library.mk
