CMP = ifort
XFLAGS = -O -fpp
INC = -I $(NETCDF_ROOT)/include
LIBS = -L $(NETCDF_ROOT)/lib -lnetcdf -lnetcdff

OBJ = ll2hpac.o readswitch.o ncread.o writehpac.o misc.o \
      netcdf_m.o

ll2hpac : $(OBJ)
	$(CMP) $(XFLAGS) $(OBJ) $(LIBS) -o ll2hpac

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
	$(CMP) -c $(XFLAGS) $(INC) $<

ll2hpac.o : netcdf_m.o version.h
ncread.o : netcdf_m.o
