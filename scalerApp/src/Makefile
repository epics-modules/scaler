TOP=../..

include $(TOP)/configure/CONFIG
#----------------------------------------
#  ADD MACRO DEFINITIONS AFTER THIS LINE
#=============================

# For base-7
USR_CPPFLAGS += -DUSE_TYPED_RSET

#=============================
# Create scalerRecord.h from scalerRecord.dbd
DBDINC += scalerRecord

# Install DBD file
DBD += scalerSupport.dbd

#=============================

LIBRARY_IOC += scaler

scaler_SRCS += scalerRecord.c
scaler_SRCS += devScalerAsyn.c
scaler_SRCS += drvScalerSoft.c
scaler_SRCS += drvScaler974.cpp

# Install headers
INC += devScaler.h
INC += devScalerAsyn.h

std_LIBS += asyn
std_LIBS += $(EPICS_BASE_IOC_LIBS)

#=============================
# build an IOC for testing

ifdef CALC
PROD_IOC = scalerApp

# Generate DBD file
DBD += scalerApp.dbd
scalerApp_DBD += base.dbd
scalerApp_DBD += asyn.dbd
scalerApp_DBD += drvAsynSerialPort.dbd
scalerApp_DBD += drvAsynIPPort.dbd
scalerApp_DBD += scalerSupport.dbd
scalerApp_DBD += calcSupport.dbd

# <name>_registerRecordDeviceDriver.cpp will be created from <name>.dbd
scalerApp_SRCS += scalerApp_registerRecordDeviceDriver.cpp
scalerApp_SRCS_DEFAULT += scalerAppMain.cpp
scalerApp_SRCS_vxWorks += -nil-

scalerApp_LIBS += scaler
scalerApp_LIBS += calc
scalerApp_LIBS += asyn
scalerApp_LIBS += $(EPICS_BASE_IOC_LIBS)
endif

#===========================

include $(TOP)/configure/RULES
#----------------------------------------
#  ADD RULES AFTER THIS LINE

# Make dependences on scalarRecord.h
scalerRecord$(OBJ):        $(COMMON_DIR)/scalerRecord.h
devScalerAsyn$(OBJ):       $(COMMON_DIR)/scalerRecord.h
