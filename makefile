CMP = ifort
XFLAGS = -O -fpp
INC = -I $(NETCDF_ROOT)/include
LIBS = -L $(NETCDF_ROOT)/lib -lnetcdf -lnetcdff

OBJ = ll2hpac.o readswitch.o ncread.o writehpac.o misc.o \
      netcdf_m.o

ll2hpac : $(OBJ)
	$(CMP) $(XFLAGS) $(OBJ) $(LIBS) -o ll2hpac

clean:
	rm -f *.o core


.SUFFIXES:.f90

.f90.o:
	$(CMP) -c $(XFLAGS) $(INC) $<

ll2hpac.o : netcdf_m.o
ncread.o : netcdf_m.o
