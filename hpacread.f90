Program hpacread

Integer, dimension(1:2,1:2) :: varnum
Character(len=256) :: nestfile
Character(len=8), dimension(:,:), allocatable :: tempvarname3d
Character(len=8), dimension(:,:), allocatable :: tempvarname2d
Character(len=8) runname
Integer, dimension(1:3) :: arrsize
Real, dimension(1:2,1:3) :: lonlat
Integer, dimension(1:6) :: datearr
Real, dimension(:), allocatable :: slvl
Real, dimension(:,:,:), allocatable :: datain
Real dx,dy,outlon,rtmp
Integer i,outunit,itmp,x,y,z
Logical mode

outunit=1
Open(UNIT=outunit,File='temp.fmt',FORM='Unformatted')

! FFLAG
! CODENAME, STAGGER
! TIME
! INITIAL TIME OF CALCULATION (NOT USED IN SCIPUFF)
! NUMBER OF GRID POINTS, KEY POINTS, VARIABLES (5 3d, 7 2d)
! NOT USED
! NOT USED
! GRID AND TIMING INFO
! NAMES AND UNITS
  Read(outunit) runname
  Write(6,*) runname
  Read(outunit) runname,mode,nestfile
  Write(6,*) runname,mode,nestfile
  Read(outunit) datearr(3),datearr(2),datearr(1),datearr(4),datearr(5),datearr(6)
  Write(6,*) datearr(3),datearr(2),datearr(1),datearr(4),datearr(5),datearr(6)
  Read(outunit) datearr(3),datearr(2),datearr(1),datearr(4),datearr(5),datearr(6)
  Write(6,*) datearr(3),datearr(2),datearr(1),datearr(4),datearr(5),datearr(6)
  Read(outunit) arrsize(1),arrsize(2),arrsize(3),itmp,varnum(1,1),varnum(2,1)
  Write(6,*) arrsize(1),arrsize(2),arrsize(3),itmp,varnum(1,1),varnum(2,1)  
  Read(outunit) itmp,itmp,itmp,itmp,itmp,itmp
  Read(outunit) itmp,itmp,itmp
  
Allocate(tempvarname3d(1:varnum(1,1),1:2),tempvarname2d(1:varnum(2,1),1:2),slvl(1:arrsize(3)))
  
  
  Read(outunit) (slvl(i),i=1,arrsize(3)),dx,dy,rtmp,rtmp,lonlat(2,1),outlon,rtmp,rtmp,rtmp,rtmp,slvl(arrsize(3))
  Write(6,*) (slvl(i),i=1,arrsize(3)),dx,dy,rtmp,rtmp,lonlat(2,1),outlon,rtmp,rtmp,rtmp,rtmp,slvl(arrsize(3))
  Read(outunit) (tempvarname3d(i,1),i=1,varnum(1,1)),(tempvarname3d(i,2),i=1,varnum(1,1)),(tempvarname2d(i,1),i=1,varnum(2,1)),(tempvarname2d(i,2),i=1,varnum(2,1))
  Write(6,*) (tempvarname3d(i,1),i=1,varnum(1,1)),(tempvarname3d(i,2),i=1,varnum(1,1)),(tempvarname2d(i,1),i=1,varnum(2,1)),(tempvarname2d(i,2),i=1,varnum(2,1))  

  Allocate(datain(arrsize(1),arrsize(2),arrsize(3)))

  Do i=1,varnum(1,1)
    Read(outunit) (((datain(x,y,z),x=1,arrsize(1)),y=1,arrsize(2)),z=1,arrsize(3))
    Write(6,*) maxval(datain(:,:,1)),minval(datain(:,:,1))
  End Do

  Do i=1,varnum(2,1)
    Read(outunit) ((datain(x,y,1),x=1,arrsize(1)),y=1,arrsize(2))
    Write(6,*) maxval(datain(:,:,1)),minval(datain(:,:,1))
  End Do


  Deallocate(datain,tempvarname3d,tempvarname2d,slvl)
Close(outunit)

Stop
End