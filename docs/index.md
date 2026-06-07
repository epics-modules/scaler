---
layout: default
title: Scaler
nav_order: 1
---

# Scaler Module
{: .no_toc}

## Table of contents
{: .no_toc .text-delta }

- TOC
{:toc}

## Overview

The scaler module provides the EPICS scaler record and associated device
support for controlling banks of hardware counter/timer channels. It
supports up to 64 32-bit counters controlled by a common start/stop
mechanism, with optional preset-counter operation.

The module includes:

- The **scaler record** -- a custom EPICS record type for counter/timer
  hardware with preset counting, automatic background counting, and
  configurable display update rates.
- **Asyn device support** -- a generic device support layer using the
  [asyn](https://github.com/epics-modules/asyn) driver framework, allowing
  any asyn-based scaler driver to work with the scaler record.
- **Soft scaler driver** -- a software-only scaler driver for testing and
  simulation without hardware.
- **Ortec 974 driver** -- device support for the Ortec 974 counter/timer.

## Supported Hardware

Device support exists for the following hardware, either built into this
module or provided by external driver modules:

| Hardware | Driver | Interface |
| - | - | - |
| Any asyn-based scaler | devScalerAsyn | asyn (INST_IO) |
| Software simulation | drvScalerSoft | asyn |
| Ortec 974 | drvScaler974 | asyn |
| Joerger VSC 8/16 | devScaler (external) | VME_IO |
| Joerger VS64 | devScaler_VS (external) | VME_IO |
| SIS3801 | drvSIS3801 (in mca module) | asyn |
| SIS3820 | drvSIS3820 (in mca module) | asyn |

## Dependencies

The scaler library requires:

- [asyn](https://github.com/epics-modules/asyn) -- for the asyn device
  support interface used by all current scaler drivers.

The scaler database files (`scaler.db`, `scaler16.db`, etc.) use record
types from the [calc](https://github.com/epics-modules/calc) module
(`transform`, `calcout`). The calc module is a runtime dependency for
these databases but is not required to build the scaler library.

## Databases and Display Files

The module provides several database variants for different channel counts:

| Database | Description |
| - | - |
| `scaler.db` | 16-channel scaler with user calculations |
| `scaler16.db` | 16-channel scaler |
| `scaler16m.db` | 16-channel scaler (modified end calculations) |
| `scaler32.db` | 32-channel scaler |
| `scalerSoftCtrl.db` | Control database for the soft scaler driver |

Display files are provided in MEDM (`.adl`), CSS-BOY (`.opi`),
caQtDM (`.ui`), and Phoebus (`.bob`) formats.

## Quick Start

A soft scaler can be loaded using the provided iocsh script:

```
iocshLoad "$(SCALER)/iocsh/softScaler.iocsh", "PREFIX=xxx:,INSTANCE=scaler1"
```

For hardware scalers, load the appropriate database with the device type
and output link matching your hardware:

```
dbLoadRecords("$(SCALER)/db/scaler16m.db", "P=xxx:,S=scaler1,OUT=@asyn(scalerPort),DTYP=Asyn Scaler,FREQ=50000000")
```
