Scaler Record and related software
==================================

Tim Mooney

Contents
--------

- [Overview](#Overview)
- [Field Descriptions](#Fields)
- [Files, device-support](#Files)
- [Restrictions](#Restrictions)

Overview
--------

The scaler record provides support for a bank of up to 64 32-bit counters (scaler channels) controlled by a common start/stop mechanism. If the hardware is capable of preset-counter operation, the record divides scaler channels into two groups according to the values of each channel's gate-control field (Gn): simple counters \[Gn = "N" (0)\], and preset counters \[Gn = "Y" (1)\]. Simple counters are zeroed immediately before counting begins, and count upwards. Preset counters are simple counters that will not count higher than a preset value. The first preset counter to reach its preset value stop all counters. (The hardware may actually implement a preset counter by loading in the preset value, and counting down to zero. If so, device support is expected to maintain the fiction that all counters count up from zero.) Currently device support exists for the Joerger VSC 8 and 16 channel VME scalers; Joerger VS64 fly-counting scalers; the SIS3801 multichannel scaler, emulating a single scaler bank, and the SIS3820. Joerger VS scalers do not support preset counting, so the software sets the Gn fields to 0 and keeps them there.

Scaler channel 1 receives special treatment: it is presumed to count a reference-frequency clock signal and its value indicates the time interval during which counting was enabled. The fields

- T (time)
- TP (time preset)
- S1 (scaler channel 1 value)
- PR1 (scaler channel 1 preset value), and
- FREQ (clock frequency)

 satisfy the following equations: 
 
```
	T = S1 / FREQ
	TP = PR1 / FREQ
```

The manner in which the time base is managed is different for different kinds of scaler hardware. Joerger VSC scalers It is the user's job to make sure that a clock signal is presented to the channel-1 input, and that FREQ actually contains the frequency of the clock signal. The 10 MHz signal available on the front panel normally is used for this purpose. SIS3801 scalers Normally, the hardware is set up to connect an internally generated 25-MHz clock to channel 1, via a software switch. (Thus, any external signal connected to SIS3801 channel 1 will be ignored.) It is possible to use an externally generated clock, and in any case it is still the user's responsibility to ensure that FREQ contains the correct value. The SIS3801 does not support hardware presets. However, presets are emulated as follows. The scaler is uses a FIFO to buffer the counts in each dwell period. For the scaler record mode (as opposed to the MCS mode used with the MCA record) the dwell time is set to 0.01 seconds. Thus, every 0.01 seconds the counts for each channel are pushed into the FIFO stack. When the driver reads the FIFO at the scaler polling rate (.RATE) it compares the total counts for each channel with the preset counts. If any preset is reached then it signals that counting is complete. Thus, the counting could have extended for up to 0.01 second longer than requested, but each channel will have counted for exactly the same period of time, so the counts per second will be accurate. SIS3820 scalers  Normally the hardware is set up to connect an internally generated 50-MHz clock to channel 1, via a software switch. The SIS3820 supports hardware presets. However, there is only a single preset for channels 1-16, and a second preset for channels 17-32. This means that only one channel from 1-16 and one channel from 17-32 can be used as a preset at the same time. The driver handles this limitation by using the highest numbered channel in each group that has a non-zero preset (PRn) and active gate (Gn=Y). For example, if PR1, PR3, PR18 and PR22 are all non-zero and G1,G3,G18 and G22 are "Y", then the scaler will stop counting when S3=PR3 or S22=PR22, whichever comes first. Joerger VS scalers This hardware does not implement preset counters; an internal 16-bit gate-time counter is used to set the counting time. The device-support software will choose a reference frequency for this counter, and cause the hardware to generate and use it. Also, device-support will set and post the FREQ field according to the reference frequency it has chosen. But the reference signal still must be connected by the user to the channel-1 input, so that the record and any clients can treat channel 1 as the time base. This is how the scaler record is intended to be used:

1. The user sets FREQ to the frequency of the clock signal input to scaler channel 1. (Joerger VSC, SIS3801, and SIS3820 only)
2. The user sets TP (time preset) and/or PRn (preset value for scaler channel n). (For Joerger VS scalers, only TP or PR1 may be set.)
3. The user sets CNT to "Count" (1), initiating counting.
4. For Joerger VSC, SIS3801 and SIS3820 scalers, the counters count until any preset counter reaches its preset value, whereupon the record resets CNT to "Done" (0), or the user manually resets CNT to "Done" (0), causing counting to stop. For Joerger VS scalers, counters count until the internal gate-time counter reaches its preset, or the user manually resets CNT to "Done" (0).

This version of the scaler record maintains two counting modes: normal and background (also called AutoCount). Normal counting is controlled by the CNT ("Count/Done") field, the time preset, and possibly other presets, as described above. Background counting is controlled by the CONT ("OneShot/AutoCount") field, normally ignores user preset values, and is intended to give the user continuous updates whenever the scaler would otherwise be idle.

When CONT = "AutoCount" (1), and no normal counting operation is already in progress, the scaler waits for the AutoCount delay (DLY1); counts for the AutoCount period (TP1); and displays the result. If the AutoCount period (TP1) is less than .001 s, we default to the normal criteria for determining the count period. If the AutoCount Display Rate (RAT1) is greater than zero (Hz), then the scaler values are displayed at that rate while background counting is in progress.

Background counting is interrupted immediately whenever a normal counting operation is started with the CNT field, and the results of a normal counting operation are held for ten seconds after the scaler finishes normal counting, before background counting begins again. The ten-second data-hold period can be changed by setting the integer variable 'scaler\_wait\_time' to the desired hold time in seconds, either at the ioc console, or in the ioc-startup file, st.cmd.

Background counting never affects the state of the CNT field, so this field can always be used to determine when a normal counting operation has begun and finished.

The scaler record is unlike most other EPICS records in that its processing is neither "synchronous" nor "asynchronous", as these terms are used in the EPICS Application Developer' Guide. Currently, the PACT field is always FALSE after record processing has completed, even though the scaler may be counting. This means the record always responds to channel-access puts, and that counting can be stopped at any time. The record's forward link is not executed until the scaler has stopped counting. 

Field Descriptions
------------------


In addition to fields common to all record types (see the EPICS Record Reference Manual for these) the scaler record has the fields described below.

- [Alphabetical listing of all fields](#Fields_alphabetical)
- [Control/status fields:](#Fields_control)
- [Data fields](#Fields_data)
- [Link fields](#Fields_link)
- [Miscellaneous fields](#Fields_misc)
- [Private fields](#Fields_private)

- - - - - -

<a name="Fields_alphabetical"></a>
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


Alphabetical list of record-specific fields 
-------------------------------------------  

NOTE: Hot links in this table take you only to the *section* in which the linked item is described in detail. You'll probably have to scroll down to find the actual item. 

Note: In the __Access__ column above: 

| R | Read only |  
| r | Read only, not posted | 
| R/W | Read and write are allowed | 
| R/W\* | Read and write are allowed; write triggers record processing if the record's SCAN field is set to "Passive." | 
| N | No access allowed |


Control/status fields
---------------------
<a name="Fields_control"></a>

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


Data fields
-----------
<a name="Fields_data"></a>

| Name | Access | Prompt | Data type | Comments |
|---|---|---|---|---|
| FREQ | R/W | Time base freq. (EGU) | DOUBLE |
| The frequency (in Hz) of the clock signal counted by scaler 1. The record uses this field to convert between time values (T and TP, in seconds) and values associated with scaler 1 (S1 and PR1). It is the user's responsibility to ensure that this field has the correct value. |
| S1...S64 | R | Scaler n value (EGU) | ULONG |
| The counts accumulated by the scalers. These are posted periodically (at RATE Hz) while counting is in progress, and once after counting stops. |
| T | R | Timer (EGU) | DOUBLE |
| This field is a proxy for the value field, S1, associated with scaler 1. Whenever S1 changes, the record will set T = S1/FREQ. |


Link fields
-----------
<a name="Fields_link"></a>

| Name | Access | Prompt | Data type | Comments |
|---|---|---|---|---|
| COUT | R/W | CNT Output | OUTLINK | link to EPICS PV to which CNT field's value is written when a user count sequence has just started, or has just finished. |
| COUTP | R/W | Prompt CNT Output | OUTLINK | link to EPICS PV to which CNT field's value is written when a user count sequence has just been commanded, or has just finished. This outlink is not delayed, as is COUT, by the DLY field. |
| OUT | R | Output Specification | OUTLINK | This field specifies the hardware to be controlled. |


Miscellaneous fields
--------------------
<a name="Fields_misc"></a>

| Name | Access | Prompt | Data type | Comments |
|---|---|---|---|---|
| NM1...NM64 | R/W | Scaler n name | STRING | Names the user has given to individual scaler channels. |
| PREC | R/W | Display Precision | SHORT | The number of digits to the right of the decimal that are to be displayed by MEDM and other channel-access clients. |
| EGU | R/W | Engineering Units | STRING | String sent to channel-access clients who ask for engineering units. |
| VERS | R | Code Version | FLOAT | Version number of the recScaler.c code. |
| NCH | R | Number of channels | SHORT | The number of channels actually supported by the underlying hardware, as reported by device support. |

Private fields
--------------
<a name="Fields_private"></a>

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



Files, device support
---------------------

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
| \*Include.dbd | This file is loaded at ioc-boot time, and by database-configuration tools, and -- for purposes here -- describes the scaler-record fields, and the kinds of devices that may be associated with the scaler record. Normally the file contains the following scaler-related information: 
    ```  
    # Database definition for scaler record 
    include "scalerRecord.dbd" 
    # Device support for scaler 
    record device(scaler,INST_IO,devScalerAsyn,"Asyn Scaler") 
    device(scaler,VME_IO,devScaler,"Joerger VSC8/16") 
    device(scaler,VME_IO,devScaler_VS,"Joerger VS") 
    device(scaler,VME_IO,devScalerSTR7201,"Struck STR7201 Scaler") 
    device(scaler,VME_IO,devScalerCamac,"CAMAC scaler") 
    ``` 
    |

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
| These files build `medm` screens to access the scaler record and related process variables. To use one of them from the command line, type, for example 
    ```  
    medm -x -macro "P=XXX:,S=scaler1" scaler.adl 
    ```  
    
    where `XXX:scaler1` is the name of a scaler record in an IOC.  These files can also be used as related displays from other `medm`screens by passing the argument `"P=XXX:,S=scaler1"`. 
    |

#### EPICS STARTUP FILE

This file is not included in the distribution. Here are annotated excerpts from a startup file that supports scalers: 

```  
####################################################################### 
# vxWorks startup script to load and execute system (iocCore) software. 

# Tell EPICS all about the record types, device-support modules, drivers, 
# etc. in the software we just loaded (xxxApp) 
dbLoadDatabase("dbd/xxxApp.dbd")  
# scalers dbLoadRecords("$(SCALER)/db/scaler16m.db","P=xxx:,S=scaler1,OUT=#C0 S0 @,DTYP=Joerger VSC8/16,FREQ=10000000") 
dbLoadRecords("$(SCALER)/db/scaler16m.db","P=xxx:,S=scaler2,OUT=#C0 S0 @,DTYP=Joerger VS,FREQ=10000000") 
dbLoadRecords("$(SCALER)/db/scaler16m.db","P=xxx:,S=scaler3,OUT=#C0 S0 @,DTYP=Struck STR7201 Scaler,FREQ=25000000") 
dbLoadRecords("$(SCALER)/db/scaler16m.db","P=xxx:,S=scaler4,OUT=#C0 S0 @,DTYP=CAMAC scaler,FREQ=10000000") 
dbLoadRecords("$(SCALER)/db/scaler32.db", "P=xxx:,S=scaler5,OUT=@asyn($(PORT)),DTYP=Asyn Scaler,FREQ=50000000") 
# VSCSetup(int nCards, char *baseAddress, unisgned intVectBase) 
VSCSetup(2, 0xB0000000, 200) 
```

>| nCards | the actual number of cards may be less than, but not greater than this | 
>| baseAddress | the base address of the first card of a series. This must agree with address jumpers on the actual card(s). Joerger VSC8 and VSC16 have base addresses in the A32 address space, on a 256-byte (0x100) boundary. (I.e., these cards require 256 bytes each, and must all be addressed contiguously as, e.g., 0xB0000000, 0xB0000100,...). | 
>| intVectBase | the interrupt vector that will be loaded into the first card of a series. Succeeding cards will be loaded with intVectBase+1, intVectBase+2, etc. Stay in the range \[64..255\]. (The interrupt *level*is read from the hardware.) |  

``` 
# scalerVS_Setup(int nCards, char *baseAddress, unsigned intVectBase, int intLevel) 
scalerVS_Setup(1, 0x2000, 205, 5)
```

>| nCards | the actual number of cards may be less than, but not greater than this | 
>| baseAddress | the base address of the first card of a series. This must agree with address jumpers on the actual card(s). Joerger VS scalers have base addresses in the A16 address space, on a 2048-byte (0x800) boundary. (I.e., these cards require 2048 bytes each, and must all be addressed contiguously as, e.g., 0x2000, 0x2800,...). | 
>| intVectBase | the interrupt vector that will be loaded into the first card of a series. Succeeding cards will be loaded with intVectBase+1, intVectBase+2, etc. Stay in the range \[64..255\]. | 
>| intLevel | the interrupt level this board should use. | 

```
drvSIS3801Config(Port, baseAddress, intVectBase, intLevel, 2048, 32)
drvSIS3801Config($(PORT), 0xA0000000, 220, 6, $(MAX_CHANS), $(MAX_SIGNALS))
```

>| Port | name to give to asyn port defined by drvSIS3801Config() | 
>| baseAddress | the base address of the first card of a series. This must agree with address jumpers on the actual card(s). SIS3801 scalers have base addresses in the A32 address space, on a 2048-byte (0x800) boundary. (I.e., these cards require 2048 bytes each, and must all be addressed contiguously as, e.g., 0x90000000, 0x90000800,...). | 
>| intVectBase | the interrupt vector that will be loaded into the first card of a series. Succeeding cards will be loaded with intVectBase+1, intVectBase+2, etc. Stay in the range \[64..255\]. | 
>| intLevel | the interrupt level this board should use. | 
>| channels | number of channels for each signal. | 
>| signals | number of signals (i.e., counter inputs) | 


| BACKUP/RESTORE (BURT) REQUEST FILES | |
|---|---|
| scalerSettings.req | sample request file to save settings of one scaler database. Edit this file, supplying names of the scaler records whose settings you want saved. (The sample file also saves the states of other records in the sample database, Jscaler.db, that control calculations done when the scaler finishes counting.) |
| yyScalerSettings.req | save settings of a specified scaler record. This file is `#include`'d (once for each scaler) by scalerSettings.req. |
| These files tell the backup/restore tool how to save scaler settings. To use them from the command line, type, for example 
    ```  
    burtrb -f scalerSettings.req -o myScalerSettings.snap
    ```  
    To restore the scaler settings saved by the above commands, type 
    ```  
    burtwb -f myScalerSettings.snap
    ``` 
    |

- - - - - -

Restrictions
------------

When AutoCount is enabled, with a very short counting time (TP1) and delay time (DLY1), the scaler can swamp the network with data.

- - - - - -

Suggestions and comments to:   
[Tim Mooney](mailto:mooney@aps.anl.gov) : (mooney@aps.anl.gov)
