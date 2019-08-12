#Makefile at top of application tree
TOP = .
include $(TOP)/configure/CONFIG

DIRS += configure
DIRS += scalerApp
DIRS += iocBoot

stdApp_DEPEND_DIRS  = configure
iocBoot_DEPEND_DIRS = configure

include $(TOP)/configure/RULES_TOP
