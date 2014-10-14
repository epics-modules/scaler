# This is a demonstration startup for for stdApp on non-vxWorks systems

# Tell EPICS all about the record types, device-support modules, drivers,
# etc. in this build from stdApp
dbLoadDatabase("../../dbd/std.dbd")
std_registerRecordDeviceDriver(pdbbase)

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
< softScaler.cmd

iocInit

### Start up the autosave task and tell it what to do.
#
# Load the list of search directories for request files
< ../requestFileCommands

# save positions every five seconds
create_monitor_set("auto_positions.req", 5)
# save other things every thirty seconds
create_monitor_set("auto_settings.req", 30)

