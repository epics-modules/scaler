# Makefile
TOP = ../..

include $(TOP)/configure/CONFIG
#----------------------------------------
#  ADD MACRO DEFINITIONS AFTER THIS LINE

# Install everything
DB += $(patsubst ../%, %, $(wildcard ../*.template))
DB += $(patsubst ../%, %, $(wildcard ../*.db))
DB += $(patsubst ../%, %, $(wildcard ../*.vdb))

DB += $(patsubst ../%, %, $(wildcard ../*.req))

include $(TOP)/configure/RULES
#----------------------------------------
#  ADD RULES AFTER THIS LINE
