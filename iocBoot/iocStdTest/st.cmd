# This is a demonstration startup for for stdApp on non-vxWorks systems

# Tell EPICS all about the record types, device-support modules, drivers,
# etc. in this build from stdApp
dbLoadDatabase("../../dbd/std.dbd")
registerRecordDeviceDriver(pdbbase)

routerInit
localMessageRouterStart(0)

showSymbol

# Set up 2 serial ports
initTtyPort("serial1", "/dev/ttyS0", 9600, "N", 1, 8, "N", 1000)
initTtyPort("serial2", "/dev/ttyS1", 19200, "N", 1, 8, "N", 1000)
initSerialServer("serial1", "serial1", 1000, 20, "")
initSerialServer("serial2", "serial2", 1000, 20, "")

iocInit

### Start up the autosave task and tell it what to do.
#
# Load the list of search directories for request files
< ../requestFileCommands

# save positions every five seconds
create_monitor_set("auto_positions.req", 5)
# save other things every thirty seconds
create_monitor_set("auto_settings.req", 30)

