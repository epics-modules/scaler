---
layout: default
title: User Guide
nav_order: 4
---

# User Guide
{: .no_toc}

## Table of contents
{: .no_toc .text-delta }

- TOC
{:toc}

## Source Files

The following source files implement the scaler record and its device
support:

| File | Description |
| - | - |
| scalerRecord.c | Record support for the scaler record |
| devScalerAsyn.c | Device support for asyn scaler drivers |
| devScaler.h | Header included by record and device support |
| scalerRecord.dbd | Record type, menu, and field definitions |

External device support modules (not included in this module):

| File | Description |
| - | - |
| devScaler.c | Device support for Joerger VSC scalers |
| devScaler\_VS.c | Device support for Joerger VS scalers |
| devScalerSTR7201.c | Device support for Struck 7201 and SIS3801 |
| drvMcaSIS3820Asyn.c | Driver support for SIS3820 (in the mca module) |

## DBD Configuration

The module installs `scalerSupport.dbd`, which includes the scaler
record type definition and the built-in device support registrations:

```
include "scalerRecord.dbd"
device(scaler,INST_IO,devScalerAsyn,"Asyn Scaler")
registrar(drvScalerSoftRegister)
registrar(Scaler974Register)
```

IOCs using external device support (Joerger VSC, Joerger VS, SIS3801,
etc.) must add the appropriate device declarations to their DBD file:

```
device(scaler,VME_IO,devScaler,"Joerger VSC8/16")
device(scaler,VME_IO,devScaler_VS,"Joerger VS")
device(scaler,VME_IO,devScalerSTR7201,"Struck STR7201 Scaler")
```

## Database Files

| Database | Description |
| - | - |
| scaler.db | 16-channel scaler with user calculations |
| scaler16.db | 16-channel scaler |
| scaler16m.db | 16-channel scaler with modified end calculations |
| scaler32.db | 32-channel scaler |
| scalerSoftCtrl.db | Control database for the soft scaler driver |

## Autosave Request Files

| File | Description |
| - | - |
| scaler\_settings.req | Copy of scaler\_64ch\_settings.req |
| scaler\_8ch\_settings.req | Settings for 8-channel scaler |
| scaler\_16ch\_settings.req | Settings for 16-channel scaler |
| scaler\_32ch\_settings.req | Settings for 32-channel scaler |
| scaler\_64ch\_settings.req | Settings for 64-channel scaler |
| scaler\_channelN\_settings.req | Included by other .req files |

## Display Files

Display files are provided in MEDM (`.adl`), CSS-BOY (`.opi`),
caQtDM (`.ui`), and Phoebus (`.bob`) formats. The MEDM files are
listed below; equivalent files exist in the other formats.

| File | Description |
| - | - |
| scaler.adl | Compact operator screen for 8-channel scaler |
| scaler16.adl | Compact operator screen for 16-channel scaler |
| scaler32.adl | Compact operator screen for 32-channel scaler |
| scaler\_more.adl | Medium operator screen |
| scaler16\_more.adl | Medium operator screen for 16-channel scaler |
| scaler32\_more.adl | Medium operator screen for 32-channel scaler |
| scaler\_full.adl | Full operator screen |
| scaler16\_full.adl | Full operator screen for 16-channel scaler |
| scaler32\_full.adl | Full operator screen for 32-channel scaler |
| scaler\_full\_calc.adl | Full operator screen with user calculations |
| scaler16\_full\_calc.adl | Full screen with calculations for 16-channel scaler |
| scaler32\_full\_calc.adl | Full screen with calculations for 32-channel scaler |

To launch a display from the command line:

```
medm -x -macro "P=XXX:,S=scaler1" scaler.adl
```

where `XXX:scaler1` is the name of a scaler record in an IOC. These
files can also be used as related displays from other `medm` screens
by passing the argument `"P=XXX:,S=scaler1"`.

## IOC Startup Examples

### Soft Scaler

The module provides an iocsh script for loading a soft scaler:

```
iocshLoad "$(SCALER)/iocsh/softScaler.iocsh", "PREFIX=xxx:,INSTANCE=scaler1"
```

### Asyn-Based Hardware Scalers

Load the appropriate database with the device type and output link
for your hardware:

```
dbLoadRecords("$(SCALER)/db/scaler32.db", "P=xxx:,S=scaler1,OUT=@asyn($(PORT)),DTYP=Asyn Scaler,FREQ=50000000")
```

### Joerger VSC Scalers

```
dbLoadRecords("$(SCALER)/db/scaler16m.db","P=xxx:,S=scaler1,OUT=#C0 S0 @,DTYP=Joerger VSC8/16,FREQ=10000000")

# VSCSetup(int nCards, char *baseAddress, unsigned intVectBase)
VSCSetup(2, 0xB0000000, 200)
```

| Parameter | Description |
| - | - |
| nCards | The actual number of cards may be less than, but not greater than this. |
| baseAddress | The base address of the first card. Must agree with address jumpers on the card(s). Joerger VSC8 and VSC16 use A32 addresses on a 256-byte (0x100) boundary. Cards must be addressed contiguously (e.g., 0xB0000000, 0xB0000100, ...). |
| intVectBase | The interrupt vector loaded into the first card. Succeeding cards use intVectBase+1, intVectBase+2, etc. Use the range 64-255. The interrupt level is read from the hardware. |

### Joerger VS Scalers

```
dbLoadRecords("$(SCALER)/db/scaler16m.db","P=xxx:,S=scaler1,OUT=#C0 S0 @,DTYP=Joerger VS,FREQ=10000000")

# scalerVS_Setup(int nCards, char *baseAddress, unsigned intVectBase, int intLevel)
scalerVS_Setup(1, 0x2000, 205, 5)
```

| Parameter | Description |
| - | - |
| nCards | The actual number of cards may be less than, but not greater than this. |
| baseAddress | The base address of the first card. Joerger VS scalers use A16 addresses on a 2048-byte (0x800) boundary. Cards must be addressed contiguously (e.g., 0x2000, 0x2800, ...). |
| intVectBase | The interrupt vector loaded into the first card. Succeeding cards use intVectBase+1, intVectBase+2, etc. Use the range 64-255. |
| intLevel | The interrupt level this board should use. |

### SIS3801 Scalers

```
drvSIS3801Config($(PORT), 0xA0000000, 220, 6, $(MAX_CHANS), $(MAX_SIGNALS))

dbLoadRecords("$(SCALER)/db/scaler16m.db","P=xxx:,S=scaler1,OUT=@asyn($(PORT)),DTYP=Asyn Scaler,FREQ=25000000")
```

| Parameter | Description |
| - | - |
| Port | Name to give to the asyn port defined by drvSIS3801Config(). |
| baseAddress | The base address of the first card. SIS3801 scalers use A32 addresses on a 2048-byte (0x800) boundary. Cards must be addressed contiguously (e.g., 0x90000000, 0x90000800, ...). |
| intVectBase | The interrupt vector loaded into the first card. Succeeding cards use intVectBase+1, intVectBase+2, etc. Use the range 64-255. |
| intLevel | The interrupt level this board should use. |
| channels | Number of channels for each signal. |
| signals | Number of signals (i.e., counter inputs). |

## Backup and Restore (BURT)

| File | Description |
| - | - |
| scalerSettings.req | Sample request file to save settings of one scaler database. Edit this file, supplying names of the scaler records whose settings you want saved. |
| yyScalerSettings.req | Save settings of a specified scaler record. This file is included (once for each scaler) by scalerSettings.req. |

To save scaler settings:

```
burtrb -f scalerSettings.req -o myScalerSettings.snap
```

To restore:

```
burtwb -f myScalerSettings.snap
```
