ifneq ($(CUSTOM),yes)
FC = ifort
XFLAGS = -O -assume byterecl -fp-model precise -traceback
LIBS = -L $(NETCDF_ROOT)/lib -lnetcdf
ifneq ($(NCCLIB),yes)
LIBS += -lnetcdff
endif
INC = -I $(NETCDF_ROOT)/include
PPFLAG90 = -fpp
PPFLAG77 = -fpp
DEBUGFLAG = -check all -debug all -traceback -fpe0
endif

ifeq ($(GFORTRAN),yes)
FC = gfortran
XFLAGS = -O2 -mtune=native -march=native -I $(NETCDF_ROOT)/include
PPFLAG90 = -x f95-cpp-input
PPFLAG77 = -x f77-cpp-input
DEBUGFLAG = -g -Wall -Wextra -fbounds-check -fbacktrace
endif

ifeq ($(CRAY),yes)
FC = ftn
XFLAGS = -h noomp
PPFLAG90 = -eZ
PPFLAG77 = -eZ
DEBUGFLAG =
endif

# Testing - I/O and fpmodel
ifeq ($(TEST),yes)
XFLAGS += $(DEBUGFLAG)
endif

ifeq ($(NCCLIB),yes)
XFLAGS += -Dncclib
endif

OBJ = ll2hpac.o readswitch.o ncread.o writehpac.o misc.o \
      netcdf_m.o

ll2hpac : $(OBJ)
	$(FC) $(XFLAGS) $(OBJ) $(LIBS) -o ll2hpac

clean:
	rm -f *.o core *.mod


.SUFFIXES:.f90

version.h: FORCE
	rm -f brokenver tmpver
	echo "      character(len=*), parameter :: version ='LL2HPAC r'" > brokenver
	echo "      character(len=*), parameter :: version ='LL2HPAC r`svnversion .`'" > tmpver
	grep exported tmpver || grep Unversioned tmpver || cmp tmpver brokenver || cmp tmpver version.h || mv tmpver version.h
FORCE:

.f90.o:
	$(FC) -c $(XFLAGS) $(INC) $(PPFLAG90) $<
.f.o:
	$(FC) -c $(XFLAGS) $(INC) $(PPFLAG77) $<

ll2hpac.o : netcdf_m.o version.h
ncread.o : netcdf_m.o
