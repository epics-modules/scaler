# This is a demonstration startup for scalerTestApp on non-vxWorks systems

< envPaths

cd "${TOP}"

# Tell EPICS all about the record types, device-support modules, drivers,
# etc. in this build from scalerTestApp
dbLoadDatabase("dbd/scalerTestApp.dbd")
scalerTestApp_registerRecordDeviceDriver(pdbbase)

# Set up 2 serial ports
drvAsynSerialPortConfigure("serial1", "/dev/ttyS0", 0, 0, 0)
asynSetOption("serial1", 0, "baud", "9600")
asynSetOption("serial1", 0, "parity", "none")
asynSetOption("serial1", 0, "bits", "8")
asynSetOption("serial1", 0, "stop", "1")

drvAsynSerialPortConfigure("serial2", "/dev/ttyS1", 0, 0, 0)
asynSetOption("serial1", 0, "baud", "19200")
asynSetOption("serial1", 0, "parity", "none")
asynSetOption("serial1", 0, "bits", "8")
asynSetOption("serial1", 0, "stop", "1")

# soft scaler
iocshLoad "$(SCALER)/iocsh/softScaler.iocsh", "PREFIX=test:,INSTANCE=scaler1"

iocInit

cd "${TOP}/iocBoot/${IOC}"

# This support module isn't built with autosave
