CMP = ifort
XFLAGS = -O -static-libcxa -xW
INC = -I/home/tha051/lib 
LIBS = -L/home/tha051/lib -lnetcdf_ifort

OBJ = ll2hpac.o readswitch.o ncread.o writehpac.o misc.o

ll2hpac : $(OBJ)
	$(CMP) $(XFLAGS) $(OBJ) $(LIBS) -o ll2hpac

clean:
	rm -f *.o core


.SUFFIXES:.f90

.f90.o:
	$(CMP) -c $(XFLAGS) $(INC) $<
ncread.o: ncread.f90
	$(CMP) -c $(XFLAGS) $(INC) -recursive ncread.f90
