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

In addition to fields common to all record types (see [Fields Common to All Record Types](https://docs.epics-controls.org/projects/base/en/latest/dbCommonRecord.html)) the scaler record has the fields described below.

In the **Access** column: **R** = read only, **R/W** = read and write,
**R/W\*** = read and write where writing triggers record processing when
SCAN is "Passive", **r** = read only, not posted.

### Control/status fields

| Field | Access | Type | Choices | Description |
| - | - | - | - | - |
| CNT | R/W* | RECCHOICE | 0: Done, 1: Count | Set to "Count" to start counting. When a preset is reached, counting stops, this field resets to "Done", and the forward link fires. Setting to "Done" while counting is in progress stops counting and reports accumulated counts. |
| CONT | R/W* | RECCHOICE | 0: OneShot, 1: AutoCount | Set to "AutoCount" to enable background counting. See also DLY1, RAT1, and TP1. |
| G1...G64 | R/W | RECCHOICE | 0: N, 1: Y | Gate control for each channel. Determines whether the channel is a simple scaler (N) or preset scaler (Y). Setting Gn to Y ensures PRn is nonzero (defaults to 1000). Setting PRn to a positive value automatically sets Gn to Y. Device support forces Gn to N on hardware that does not support presets. |
| PR1...PR64 | R/W | ULONG | | Preset values. If Gn = Y, counting stops when Sn reaches PRn. If Gn = N, PRn is ignored. Setting PRn to a positive value automatically sets Gn to Y. |
| TP | R/W | DOUBLE | | Time preset in seconds. Acts as a proxy for PR1: changing TP sets PR1 = TP * FREQ. |
| TP1 | R/W | DOUBLE | | AutoCount time preset. Specifies the background-counting period in seconds. |
| DLY | R/W | FLOAT | | Delay in seconds after CNT is set to "Count" before counting actually begins. |
| DLY1 | R/W | FLOAT | | AutoCount delay in seconds between successive background-counting periods. |
| RATE | R/W | FLOAT | | Display update rate in Hz (0-60) during normal counting. If zero, counts are displayed only after counting stops. |
| RAT1 | R/W | FLOAT | | Display update rate in Hz (0-60) during background counting. If zero, counts are displayed only after background counting stops. |

### Data fields

| Field | Access | Type | Choices | Description |
| - | - | - | - | - |
| FREQ | R/W | DOUBLE | | Clock frequency in Hz for the signal counted by scaler channel 1. Used to convert between time values (T, TP) and channel 1 values (S1, PR1). The user must ensure this field is correct. |
| S1...S64 | R | ULONG | | Accumulated counts for each channel. Posted at RATE Hz while counting and once after counting stops. |
| T | R | DOUBLE | | Elapsed time in seconds. Computed as S1 / FREQ whenever S1 changes. |

### Link fields

| Field | Access | Type | Choices | Description |
| - | - | - | - | - |
| COUT | R/W | OUTLINK | | Output link. CNT field value is written to this PV when a count sequence starts or finishes. Delayed by the DLY field. |
| COUTP | R/W | OUTLINK | | Prompt output link. Same as COUT but not delayed by DLY -- fires immediately when CNT changes. |
| OUT | R | OUTLINK | | Output specification. Specifies the hardware to be controlled. |

### Miscellaneous fields

| Field | Access | Type | Choices | Description |
| - | - | - | - | - |
| NM1...NM64 | R/W | STRING | | User-assigned names for individual scaler channels. |
| PREC | R/W | SHORT | | Display precision. Number of digits to the right of the decimal point. |
| EGU | R/W | STRING | | Engineering units string sent to Channel Access clients. |
| VERS | R | FLOAT | | Code version number of the scaler record support. |
| NCH | R | SHORT | | Number of channels supported by the hardware, as reported by device support. |

### Private fields

| Field | Access | Type | Choices | Description |
| - | - | - | - | - |
| D1...D64 | R/W | RECCHOICE | 0: Up, 1: Dn | Count direction. The direction in which the hardware actually counts for channel n. These fields are for internal use and may become read-only in the future. |
| PCNT | R/W | RECCHOICE | 0: Done, 1: Count | Previous value of the CNT field. |
| SS | r | SHORT | | Scaler hardware state. |
| US | r | SHORT | | User request state. |
| VAL | R/W | DOUBLE | | Result. Set to the value of T and posted when counting is done, after all other fields have been posted. |
| RPVT | r | void * | | Private pointer used internally by the record. |

## Restrictions

When AutoCount is enabled with a very short counting time (TP1) and
delay time (DLY1), the scaler can swamp the network with data.
