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

# Install cfg-deps declaration file
CFG += SCALER_DEPS

#=============================

LIBRARY_IOC += scaler

scaler_SRCS += scalerRecord.c
scaler_SRCS += devScalerAsyn.c
scaler_SRCS += drvScalerSoft.c
scaler_SRCS += drvScaler974.cpp

# Install headers
INC += devScaler.h
INC += devScalerAsyn.h

scaler_LIBS += asyn
scaler_LIBS += $(EPICS_BASE_IOC_LIBS)

#===========================

include $(TOP)/configure/RULES
#----------------------------------------
#  ADD RULES AFTER THIS LINE

# Make dependences on scalerRecord.h
scalerRecord$(OBJ):        $(COMMON_DIR)/scalerRecord.h
devScalerAsyn$(OBJ):       $(COMMON_DIR)/scalerRecord.h
