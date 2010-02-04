TOP=../..

include $(TOP)/configure/CONFIG
#----------------------------------------
#  ADD MACRO DEFINITIONS AFTER THIS LINE
#=============================

# For Kate Feng's implementation of devScaler.c, which uses Till
# Straumann's basicIoOps.h to bridge any mismatch between endianness
# of Joerger scaler hardware and endianness of processor.
#USR_CFLAGS += -DHAS_IOOPS_H

#=============================
# xxxRecord.h will be created from xxxRecord.dbd

DBDINC += scalerRecord

# <name>.dbd will be created from <name>Include.dbd
DBD += std.dbd
DBD += stdVX.dbd
DBD += stdSupport.dbd

#=============================

LIBRARY_IOC += std

std_SRCS += scalerRecord.c
std_SRCS += devScalerAsyn.c
std_SRCS += drvScalerSoft.c
std_SRCS += drvScaler974.cpp

# publish this file so it can be included by device support for scaler
# built in the MCA module
INC += devScaler.h
INC += devScalerAsyn.h

std_LIBS += asyn
std_LIBS += $(EPICS_BASE_IOC_LIBS)

#=============================
# build an ioc application for testing

PROD_IOC = stdApp

# <name>_registerRecordDeviceDriver.cpp will be created from <name>.dbd
stdApp_SRCS_DEFAULT += std_registerRecordDeviceDriver.cpp
stdApp_SRCS_vxWorks += stdVX_registerRecordDeviceDriver.cpp
stdApp_SRCS_DEFAULT += stdMain.cpp
stdApp_SRCS_vxWorks += -nil-
#The following adds support from base/src/vxWorks
stdApp_OBJS_vxWorks += $(EPICS_BASE_BIN)/vxComLibrary

stdApp_LIBS += std
stdApp_LIBS += asyn
stdApp_LIBS += $(EPICS_BASE_IOC_LIBS)

#===========================

include $(TOP)/configure/RULES
#----------------------------------------
#  ADD RULES AFTER THIS LINE
