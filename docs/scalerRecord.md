---
layout: default
title: Scaler Record
nav_order: 3
---

# Scaler Record
{: .no_toc}

## Table of contents
{: .no_toc .text-delta }

- TOC
{:toc}

## Overview

The scaler record provides support for a bank of up to 64 32-bit
counters (scaler channels) controlled by a common start/stop mechanism.

### Channel Types

If the hardware is capable of preset-counter operation, the record
divides scaler channels into two groups according to the values of each
channel's gate-control field (**Gn**):

- **Simple counters** (Gn = "N"): Zeroed immediately before counting
  begins, and count upwards.
- **Preset counters** (Gn = "Y"): Simple counters that will not count
  higher than a preset value. The first preset counter to reach its
  preset value stops all counters.

The hardware may actually implement a preset counter by loading in the
preset value and counting down to zero. If so, device support is
expected to maintain the fiction that all counters count up from zero.
Hardware that does not support preset counting (e.g., Joerger VS) will
have Gn forced to "N" by device support.

### Channel 1 and Time Base

Scaler channel 1 receives special treatment: it is presumed to count a
reference-frequency clock signal and its value indicates the time
interval during which counting was enabled. The fields **T** (time),
**TP** (time preset), **S1** (channel 1 value), **PR1** (channel 1
preset), and **FREQ** (clock frequency) satisfy:

```
T  = S1  / FREQ
TP = PR1 / FREQ
```

### Hardware Time Base Management

The manner in which the time base is managed differs by hardware type:

**Joerger VSC scalers** -- The user must connect a clock signal to the
channel-1 input and set **FREQ** to its frequency. The 10 MHz signal
available on the front panel is normally used for this purpose.

**SIS3801 scalers** -- The hardware connects an internally generated
25 MHz clock to channel 1 via a software switch. Any external signal
connected to channel 1 will be ignored. It is possible to use an
externally generated clock; in any case the user must ensure **FREQ**
contains the correct value. The SIS3801 does not support hardware
presets. Presets are emulated using a FIFO that buffers counts in 0.01 s
dwell periods. The driver reads the FIFO at the scaler polling rate
(**RATE**) and compares total counts against presets. Counting may
extend up to 0.01 s beyond the requested time, but all channels count
for exactly the same period, so counts per second remain accurate.

**SIS3820 scalers** -- The hardware connects an internally generated
50 MHz clock to channel 1 via a software switch. The SIS3820 supports
hardware presets, but with a limitation: there is only a single preset
register for channels 1-16 and a second for channels 17-32. Only one
channel from each group can serve as a preset at the same time. The
driver uses the highest numbered channel in each group that has a
non-zero preset (**PRn**) and active gate (**Gn** = "Y"). For example,
if PR1, PR3, PR18, and PR22 are all non-zero with their gates active,
counting stops when S3 = PR3 or S22 = PR22, whichever comes first.

**Joerger VS scalers** -- This hardware does not implement preset
counters. An internal 16-bit gate-time counter sets the counting time.
Device support chooses a reference frequency and configures the
hardware to generate it, then sets and posts the **FREQ** field
accordingly. The user must still connect the reference signal to the
channel-1 input so that the record and clients can treat channel 1 as
the time base.

### Counting Operation

1. The user sets **FREQ** to the frequency of the clock signal input to
   scaler channel 1 (Joerger VSC, SIS3801, and SIS3820 only).
2. The user sets **TP** (time preset) and/or **PRn** (preset value for
   channel n). For Joerger VS scalers, only TP or PR1 may be set.
3. The user sets **CNT** to "Count" (1), initiating counting.
4. Counting continues until any preset counter reaches its preset
   value, at which point the record resets **CNT** to "Done" (0). The
   user may also manually set **CNT** to "Done" to stop counting at
   any time.

### Background Counting (AutoCount)

The scaler record supports two counting modes: normal and background
(AutoCount).

Normal counting is controlled by the **CNT** field, the time preset,
and possibly other presets as described above. Background counting is
controlled by the **CONT** ("OneShot/AutoCount") field and is intended
to give the user continuous updates whenever the scaler would otherwise
be idle.

When **CONT** = "AutoCount" (1) and no normal counting operation is in
progress, the scaler waits for the AutoCount delay (**DLY1**), counts
for the AutoCount period (**TP1**), and displays the result. If **TP1**
is less than 0.001 s, the normal preset criteria are used instead. If
the AutoCount Display Rate (**RAT1**) is greater than zero, scaler
values are displayed at that rate while background counting is in
progress.

Background counting is interrupted immediately when a normal counting
operation starts. After normal counting finishes, the results are held
for ten seconds before background counting resumes. This hold period
can be changed by setting the variable `scaler_wait_time` to the
desired number of seconds, either at the IOC console or in the startup
script.

Background counting never affects the state of the **CNT** field, so
this field can always be used to determine when a normal counting
operation has begun and finished.

### Record Processing

The scaler record is unlike most other EPICS records in that its
processing is neither "synchronous" nor "asynchronous" as these terms
are used in the EPICS Application Developer's Guide. The **PACT** field
is always FALSE after record processing has completed, even though the
scaler may still be counting. This means the record always responds to
Channel Access puts, and counting can be stopped at any time. The
record's forward link is not executed until the scaler has stopped
counting.

## Field Descriptions

In addition to fields common to all record types (see the [EPICS Record Reference Manual](https://docs.epics-controls.org/projects/base/en/latest/dbCommonRecord.html) for these) the scaler record has the fields described below.

| Name | Access | Prompt | Data type | Comment |
|---|---|---|---|---|
| [ CNT ](#Fields_control) | R/W\* | Count | RECCHOICE | (0:"Done", 1:"Count") |
| [ CONT ](#Fields_control) | R/W\* | OneShot/AutoCount | RECCHOICE | (0:"OneShot", 1:"AutoCount") |
| [ COUT ](#Fields_link) | R/W | CNT Output | OUTLINK | Link to PV |
| [ COUTP ](#Fields_link) | R/W | Prompt COUT | OUTLINK | Link to PV |
| [ D1...D64](#Fields_private) | R/W | Count Direction n | RECCHOICE | (0:"Up", 1:"Dn") |
| [ DLY ](#Fields_control) | R/W | Delay | FLOAT | before counting |
| [ DLY1 ](#Fields_control) | R/W | Auto-mode Delay | FLOAT | before counting |
| [ EGU ](#Fields_misc) | R/W | Units Name | STRING | 8 characters |
| [ FREQ ](#Fields_data) | R/W | Time base freq | DOUBLE | e.g., 1e7 |
| [ G1...G64](#Fields_control) | R/W | Gate Control n | RECCHOICE | preset? (0:"N", 1:"Y") |
| [ NCH ](#Fields_misc) | R | Number of Channels | SHORT | from device |
| [ NM1...NM64](#Fields_misc) | R/W | Scaler n name | STRING | user's field |
| [ OUT ](#Fields_link) | R | Output Specification | OUTLINK | link to hardware |
| [ PCNT ](#Fields_private) | R | Prev Count | RECCHOICE | private |
| [ PREC ](#Fields_misc) | R/W | Display Precision | SHORT | num decimal places |
| [ PR1...PR64](#Fields_control) | R/W | Preset n | ULONG | preset values |
| [ RATE ](#Fields_control) | R/W | Display Rate (Hz) | FLOAT | in \[0..60\] Hz |
| [ RAT1 ](#Fields_control) | R/W | Auto Display Rate | FLOAT | in \[0..60\] Hz |
| [ RPVT ](#Fields_private) | r | private | void \* | private |
| [ S1...S64](#Fields_data) | R | Scaler n | ULONG | results |
| [ SS](#Fields_private) | r | Scaler state | SHORT | state of hardware |
| [ T ](#Fields_data) | R | Timer | DOUBLE | elapsed time |
| [ TP ](#Fields_control) | R/W | Time Preset | DOUBLE | preset time |
| [ TP1 ](#Fields_control) | R/W | Time Preset | DOUBLE | preset time (auto mode) |
| [ US](#Fields_private) | r | User state | SHORT | state of user request |
| [ VAL ](#Fields_private) | R/W | Result | DOUBLE | posted when counting is done |
| [ VERS ](#Fields_misc) | R | Code Version | FLOAT | code version |


### Alphabetical list of record-specific fields 

NOTE: Hot links in this table take you only to the *section* in which the linked item is described in detail. You'll probably have to scroll down to find the actual item. 

Note: In the __Access__ column above: 

| R | Read only |  
| r | Read only, not posted | 
| R/W | Read and write are allowed | 
| R/W\* | Read and write are allowed; write triggers record processing if the record's SCAN field is set to "Passive." | 
| N | No access allowed |


### Control/status fields

| Name | Access | Prompt | Data type | Comments |
|---|---|---|---|---|
| CNT | R/W\* | Count | RECCHOICE | (0:"Done", 1:"Count") |
| User sets this field to "Count" (1) to start counting. When a preset is reached, counting will stop, this field will be reset to "Done" (0), and the forward link will be fired. If this field is set to "Done" (0) while counting is in progress, counting will be stopped, the accumulated counts will be reported, and the forward link will be fired. |
| CONT | R/W\* | OneShot/AutoCount | RECCHOICE | (0:"OneShot", 1:"AutoCount") |
| User sets this field to "AutoCount" (1) to enable background counting. (See also autocount delay (DLY1), autocount display rate (RAT1), and autocount time presetTP1.) |
| G1...G64 | R/W | Gate control | RECCHOICE | (0:"N", 1:"Y") |
| There are 64 of these fields, one per channel. These fields determine whether the associated scalers are to be used as simple scalers (Gn=0) or preset scalers (Gn=1), assuming the hardware is capable. When Gn is set to 1, the record will ensure than PRn is nonzero (will set it to 1000, if it was zero). When PRn is set to any positive value, the record will set Gn to 1. If the hardware does not implement preset scalers, device support will set these fields to 0 whenever it notices that they have been set to 1. |
| PR1...PR64 | R/W | Preset n | ULONG |
| Preset values for the associated scalers. If scaler n has been designated as a preset scaler (i.e., if Gn=1), then when the scaler reaches the count PRn, all scalers will be disabled, and the record will report counting has completed by setting CNT=0. If scaler n has not been designated as a preset scaler, the PRn is ignored. When PRn changes to any positive value, the record will set Gn to 1. |
| TP | R/W | Time preset | DOUBLE |
| This field specifies for how long, in seconds, the scaler is to count if no other preset stops it. TP is effectively a proxy for the preset field, PR1, associated with scaler 1. Whenever TP changes, the record will set PR1 = TP\*FREQ, and otherwise behave as though the user had changed PR1. |
| TP1 | R/W | AutoCount Time preset | DOUBLE |
| This field specifies the background-counting period in seconds. |
| DLY | R/W | Delay (sec) | FLOAT |
| The delay, in seconds, that the record is to wait after CNT goes to 1 before actually causing counting to begin. |
| DLY1 | R/W | AutoCount Delay (sec) | FLOAT |
| The delay, in seconds, between successive background-counting periods. |
| RATE | R/W | Display rate (Hz) | FLOAT |
| This field specifies the rate in Hz at which the scaler record posts scaler information while counting is in progress. If this field is zero, counts are displayed only after counting has stopped. Max. rate: 60 Hz |
| RAT1 | R/W | AutoCount Display rate (Hz) | FLOAT |
| This field specifies the rate in Hz at which the scaler record posts scaler information while background counting is in progress. If this field is zero, counts are displayed only after background counting has stopped. Max. rate: 60 Hz |
|  |  |  |  |  |


### Data fields

| Name | Access | Prompt | Data type | Comments |
|---|---|---|---|---|
| FREQ | R/W | Time base freq. (EGU) | DOUBLE |
| The frequency (in Hz) of the clock signal counted by scaler 1. The record uses this field to convert between time values (T and TP, in seconds) and values associated with scaler 1 (S1 and PR1). It is the user's responsibility to ensure that this field has the correct value. |
| S1...S64 | R | Scaler n value (EGU) | ULONG |
| The counts accumulated by the scalers. These are posted periodically (at RATE Hz) while counting is in progress, and once after counting stops. |
| T | R | Timer (EGU) | DOUBLE |
| This field is a proxy for the value field, S1, associated with scaler 1. Whenever S1 changes, the record will set T = S1/FREQ. |


### Link fields

| Name | Access | Prompt | Data type | Comments |
|---|---|---|---|---|
| COUT | R/W | CNT Output | OUTLINK | link to EPICS PV to which CNT field's value is written when a user count sequence has just started, or has just finished. |
| COUTP | R/W | Prompt CNT Output | OUTLINK | link to EPICS PV to which CNT field's value is written when a user count sequence has just been commanded, or has just finished. This outlink is not delayed, as is COUT, by the DLY field. |
| OUT | R | Output Specification | OUTLINK | This field specifies the hardware to be controlled. |


### Miscellaneous fields

| Name | Access | Prompt | Data type | Comments |
|---|---|---|---|---|
| NM1...NM64 | R/W | Scaler n name | STRING | Names the user has given to individual scaler channels. |
| PREC | R/W | Display Precision | SHORT | The number of digits to the right of the decimal that are to be displayed by MEDM and other channel-access clients. |
| EGU | R/W | Engineering Units | STRING | String sent to channel-access clients who ask for engineering units. |
| VERS | R | Code Version | FLOAT | Version number of the recScaler.c code. |
| NCH | R | Number of channels | SHORT | The number of channels actually supported by the underlying hardware, as reported by device support. |

### Private fields

| Name | Access | Prompt | Data type | Comments |
|---|---|---|---|---|
| D1...D64 | R/W | Count direction | RECCHOICE | (0:"Up", 1:"Dn") |
| These fields are intended for the private use of the record, and may disappear or become read-only in the future. For scaler n, Dn is direction in which the hardware actually counts. |
| PCNT | R/W | Previous count | RECCHOICE | (0:"Done", 1:"Count") |
| Previous value of CNT. |
| SS | r | Scaler state | SHORT | state of hardware |
|  |
| US | r | User state | SHORT | state of user's request |
|  |
| VAL | R/W | Result | DOUBLE | Set to value of the T field, and posted when counting is done, after all other fields have been posted. |



## Files and Device Support

The following table briefly describes the files required to implement and use the scaler record.

| SOURCE CODE | |
|---|---|
| scalerRecord.c | Record support for the scaler record |
| devScalerAsyn.c | Device support for asyn scaler drivers |
| devScaler.h | Header included by record and device support |
| devScaler.c | Device support for Joerger VSC scalers |
| devScaler\_VS.c | Device support for Joerger VS scalers |
| devScalerSTR7201.c | Device support for Struck 7201 and SIS3801 |
| drvMcaSIS3820Asyn.c | Device support for Struck 7201 and SIS3801 |
| scalerRecord.dbd | This file defines all of the fields menus, etc. for the scaler record. |


### Include.dbd

This file is loaded at ioc-boot time, and by database-configuration tools, and describes the scaler-record fields and the kinds of devices that may be associated with the scaler record. Normally the file contains the following scaler-related information:

```
# Database definition for scaler record
include "scalerRecord.dbd"
# Device support for scaler
device(scaler,INST_IO,devScalerAsyn,"Asyn Scaler")
device(scaler,VME_IO,devScaler,"Joerger VSC8/16")
device(scaler,VME_IO,devScaler_VS,"Joerger VS")
device(scaler,VME_IO,devScalerSTR7201,"Struck STR7201 Scaler")
device(scaler,VME_IO,devScalerCamac,"CAMAC scaler")
```


| DATABASE and AUTOSAVE-REQUEST FILES | |
|---|---|
| scaler.db | database used for all device types. |
| scaler\_settings.req | copy of scaler\_64ch\_settings.req |
| scaler\_8ch\_settings.req | settings for 8-channel scaler |
| scaler\_16ch\_settings.req | settings for 16-channel scaler |
| scaler\_32ch\_settings.req | settings for 32-channel scaler |
| scaler\_64ch\_settings.req | settings for 64-channel scaler |
| scaler\_channelN\_settings.req | included by other .req files |

| MEDM DISPLAY FILES | |
|---|---|
| scaler.adl | tiny operator screen for 8-channel scaler |
| scaler16.adl | same, but for 16-channel scaler |
| scaler32.adl | same, but for 32-channel scaler |
| scaler\_more.adl | medium operator screen |
| scaler16\_more.adl | same, but for 16-channel scaler |
| scaler32\_more.adl | same, but for 32-channel scaler |
| scaler\_full.adl | big operator screen |
| scaler16\_full.adl | same, but for 16-channel scaler |
| scaler32\_full.adl | same, but for 32-channel scaler |
| scaler\_full\_calc.adl | big operator screen with user calculations |
| scaler16\_full\_calc.adl | same, but for 16-channel scaler |
| scaler32\_full\_calc.adl | same, but for 32-channel scaler |

These files build `medm` screens to access the scaler record and related process variables. To use one of them from the command line, type, for example:

```
medm -x -macro "P=XXX:,S=scaler1" scaler.adl
```

where `XXX:scaler1` is the name of a scaler record in an IOC. These files can also be used as related displays from other `medm` screens by passing the argument `"P=XXX:,S=scaler1"`. 


### EPICS Startup File

This file is not included in the distribution. Here are annotated excerpts from a startup file that supports scalers:

```
# Tell EPICS all about the record types, device-support modules, drivers,
# etc. in the software we just loaded (xxxApp)
dbLoadDatabase("dbd/xxxApp.dbd")

# scalers
dbLoadRecords("$(SCALER)/db/scaler16m.db","P=xxx:,S=scaler1,OUT=#C0 S0 @,DTYP=Joerger VSC8/16,FREQ=10000000")
dbLoadRecords("$(SCALER)/db/scaler16m.db","P=xxx:,S=scaler2,OUT=#C0 S0 @,DTYP=Joerger VS,FREQ=10000000")
dbLoadRecords("$(SCALER)/db/scaler16m.db","P=xxx:,S=scaler3,OUT=#C0 S0 @,DTYP=Struck STR7201 Scaler,FREQ=25000000")
dbLoadRecords("$(SCALER)/db/scaler32.db", "P=xxx:,S=scaler5,OUT=@asyn($(PORT)),DTYP=Asyn Scaler,FREQ=50000000")

# VSCSetup(int nCards, char *baseAddress, unsigned intVectBase)
VSCSetup(2, 0xB0000000, 200)
```

| Parameter | Description |
| - | - |
| nCards | The actual number of cards may be less than, but not greater than this. |
| baseAddress | The base address of the first card. Must agree with address jumpers on the card(s). Joerger VSC8 and VSC16 use A32 addresses on a 256-byte (0x100) boundary. Cards must be addressed contiguously (e.g., 0xB0000000, 0xB0000100, ...). |
| intVectBase | The interrupt vector loaded into the first card. Succeeding cards use intVectBase+1, intVectBase+2, etc. Use the range 64-255. The interrupt level is read from the hardware. |

```
# scalerVS_Setup(int nCards, char *baseAddress, unsigned intVectBase, int intLevel)
scalerVS_Setup(1, 0x2000, 205, 5)
```

| Parameter | Description |
| - | - |
| nCards | The actual number of cards may be less than, but not greater than this. |
| baseAddress | The base address of the first card. Joerger VS scalers use A16 addresses on a 2048-byte (0x800) boundary. Cards must be addressed contiguously (e.g., 0x2000, 0x2800, ...). |
| intVectBase | The interrupt vector loaded into the first card. Succeeding cards use intVectBase+1, intVectBase+2, etc. Use the range 64-255. |
| intLevel | The interrupt level this board should use. |

```
drvSIS3801Config(Port, baseAddress, intVectBase, intLevel, 2048, 32)
drvSIS3801Config($(PORT), 0xA0000000, 220, 6, $(MAX_CHANS), $(MAX_SIGNALS))
```

| Parameter | Description |
| - | - |
| Port | Name to give to the asyn port defined by drvSIS3801Config(). |
| baseAddress | The base address of the first card. SIS3801 scalers use A32 addresses on a 2048-byte (0x800) boundary. Cards must be addressed contiguously (e.g., 0x90000000, 0x90000800, ...). |
| intVectBase | The interrupt vector loaded into the first card. Succeeding cards use intVectBase+1, intVectBase+2, etc. Use the range 64-255. |
| intLevel | The interrupt level this board should use. |
| channels | Number of channels for each signal. |
| signals | Number of signals (i.e., counter inputs). |


| BACKUP/RESTORE (BURT) REQUEST FILES | |
|---|---|
| scalerSettings.req | sample request file to save settings of one scaler database. Edit this file, supplying names of the scaler records whose settings you want saved. (The sample file also saves the states of other records in the sample database, Jscaler.db, that control calculations done when the scaler finishes counting.) |
| yyScalerSettings.req | save settings of a specified scaler record. This file is `#include`'d (once for each scaler) by scalerSettings.req. |

These files tell the backup/restore tool how to save scaler settings. To use them from the command line, type, for example:

```
burtrb -f scalerSettings.req -o myScalerSettings.snap
```

To restore the scaler settings saved by the above commands, type:

```
burtwb -f myScalerSettings.snap
```

## Restrictions

When AutoCount is enabled, with a very short counting time (TP1) and delay time (DLY1), the scaler can swamp the network with data.
