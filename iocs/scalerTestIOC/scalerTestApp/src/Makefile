TOP=../..
include $(TOP)/configure/CONFIG

PROD_NAME = scalerTestApp
PROD_IOC = $(PROD_NAME)

DBD += $(PROD_NAME).dbd

$(PROD_NAME)_DBD += base.dbd
# scaler module (cfg-deps)
$(PROD_NAME)_DBD += $(SCALER_IOC_DBDS)
# calc module (cfg-deps)
$(PROD_NAME)_DBD += $(CALC_IOC_DBDS)
# asyn driver DBDs (asyn does not yet have cfg-deps)
$(PROD_NAME)_DBD += asyn.dbd
$(PROD_NAME)_DBD += drvAsynSerialPort.dbd
$(PROD_NAME)_DBD += drvAsynIPPort.dbd

$(PROD_NAME)_SRCS += $(PROD_NAME)_registerRecordDeviceDriver.cpp
$(PROD_NAME)_SRCS_DEFAULT += $(PROD_NAME)Main.cpp
$(PROD_NAME)_SRCS_vxWorks += -nil-

$(PROD_NAME)_LIBS += $(SCALER_IOC_LIBS)
$(PROD_NAME)_LIBS += $(CALC_IOC_LIBS)
# asyn (no cfg-deps yet)
$(PROD_NAME)_LIBS += asyn
$(PROD_NAME)_LIBS += $(EPICS_BASE_IOC_LIBS)

include $(TOP)/configure/RULES
