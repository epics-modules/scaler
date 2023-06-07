---
layout: default
title: Release Notes
nav_order: 3
---


# Scaler Release Notes

##  Release 4.1 (Jun. 7, 2023)

* Buffer out-of-bounds access fixed in drvScaler974.cpp 
* Inconsistent definition of Debug() macro fixed
* Documentation moved to github pages

##  Release 4.0 (Aug. 21, 2019)

* The scaler record type, device support and associated databases and display files were extracted from the synApps std module into this new stand-alone module, which depends only on Asyn (release 4-32 or later) and EPICS Base.

----

The items below are the scaler-related excerpts from the Release Notes of the synApps std module from before this module was created.

##  Release 3-5 (Jul. 10, 2018)

* When counting is finished, post scaler values with DBE_VALUE|DBE_LOG, after updating the time stamp.
* New iocsh top-level directory, contains scripts with the correct shell commands to add an individual device support to an IOC. For use with the `iocshLoad` command from EPICS base 3.15, further information can be found [here](https://github.com/epics-modules/xxx/wiki/IOC-Shell-Scripts).

##  Release 3-3 (Nov. 10, 2014)

* scalerRecord.c: use "epicsUInt32" instead of "unsigned long" for Sn and PRn fields
* devScalerAsyn.c: Changed pointers from unsigned long to epicsUInt32; changes to avoid compiler warnings
* translated .adl files for caQtDM and CSS-BOY
* drvScalerSoft.c: modified to zero scaler-count PVs when scaler is started.
* Added scalerSoftCtrl database and settings file; added softScaler.cmd example of loading soft scaler into ioc.

##  Release 3-0 (Sept 15, 2011)

* The scaler record no longer makes two calls to disarm the hardware (dset->arm(0)) when the scaler completes counting normally. (Previously, the code supporting user abort of a count was also executed after normal completion.)
* drvScalerSoft.c: The callback for done must pass the value 1, not 0
* scaler16m.db: Added COPT=="Always" to $(P)$(S)_calc1 (transform record)
* Added .opi display files for CSS-BOY

##  Release 2-8 (Mar. 30, 2010)

* drvScaler974 - new file for Ortec 974 scaler
* devScalerAsyn.c - ignore callback when DONE==0, register callbacks on address 0.

## Release 2-6 (Sept 10, 2008)

* The scaler record has a new field, COUTP, which is like the COUT field, but is not delayed by a nonzero setting of the DLY field.
* If the scaler-record DLY field was less that 1, it was not honored. (Thanks to Xuesong Jiao for the fix.)

## Release 2-5-5 (April, 2007)

* Added scaler16m.db database, and corresponding MEDM displays. These differ from scaler16.db and its display files only in the implementation of end calculations. The new support provides end calcs for all 16 signals.
* Added field COUTP, an output link, to the scaler record. This is similar to the COUT link, which sends the value of the CNT field to its target whenever CNT changes. COUTP differs from COUT in that it doesn't wait for the delay specified in the DLY field, but sends promptly after CNT changes.
* Minor change to devScalerAsyn to support change in API for asyn callbacks.

## Release 2-5-4 (Dec. 6, 2006)

* Changes to scaler record:
  * PRn and Sn fields are now DBF_ULONG rather than DBF_LONG.
  * No longer hardcode VME_IO device type in the record logic.
  * Removed .CARD record field.
  * Changed interface to device support so that all functions pass precord rather than card, and init_record passes pointer to device callback structure.
  * Move callback structures from dpvt to rpvt so record does not access dpvt.

* Added asyn device support for scaler record. This is currently used by the SIS3820 device support in mcaApp/SISSrc, but all scaler device support will eventually be changed to use asyn.

* Changed stdApp/Db/scaler*.db so that $(OUT) is a macro parameter, rather than assuming VME_IO link type.
* Deleted CARD field from stdApp/op/adl/scaler*.adl.

## Release 2-5-2

* scaler record: v3.18: Don't post CNT field unless record-support changed its value. Modified debug macro.

## Release 2-4

* minor scaler-record changes to accommodate Joerger VS series. Existing support for other scaler devices should not require any modifications.

## Release 2-3

* scaler record - device support that used "struct callback" defined in devScaler.h must now replace that with "CALLBACK", and must include epics/base/include/callback.h

Suggestions and Comments to:
[Tim Mooney ](mailto:mooney@aps.anl.gov): (mooney@aps.anl.gov)

