!
! THIS CODE CONVERTS ARRAYS INTO HPAC FORMAT
!

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! This subroutine creates the MEDOC 'message' header
!

Subroutine medochead(outunit,varnum,varname3d,varname2d,arrsize,lonlat,slvl,datearr,mode,nestfile)

Implicit None

Logical, intent(in) :: mode
Integer, intent(in) :: outunit
Integer, dimension(1:2,1:2) :: varnum
Character(len=*), dimension(1:varnum(1,2),1:2), intent(in) :: varname3d
Character(len=*), dimension(1:varnum(2,2),1:2), intent(in) :: varname2d
Character(len=256), intent(in) :: nestfile
Character(len=8), dimension(1:varnum(1,2),1:2) :: tempvarname3d
Character(len=8), dimension(1:varnum(2,2),1:2) :: tempvarname2d
Character(len=8) runname
Integer, dimension(1:3), intent(in) :: arrsize
Real, dimension(1:2,1:3), intent(in) :: lonlat
Integer, dimension(1:6), intent(in) :: datearr
Real, dimension(1:arrsize(3)), intent(in) :: slvl
Real dx,dy,outlon
Integer i

dy=(lonlat(2,2)-lonlat(2,1))/(lonlat(2,3)-1.)
dx=(lonlat(1,2)-lonlat(1,1))/(lonlat(1,3)-1.)

outlon=Mod(lonlat(1,1),360.)
If (outlon.GT.180.) outlon=outlon-360.
If (outlon.LT.-180.) outlon=outlon+360.


9001 FORMAT(6(A8,1X))
9002 FORMAT(6(I12,1X))
9003 FORMAT(6(F12.4,1X))
9004 FORMAT(A8,1X,A8,1X,A256)

! FFLAG
! CODENAME, STAGGER
! TIME
! INITIAL TIME OF CALCULATION (NOT USED IN SCIPUFF)
! NUMBER OF GRID POINTS, KEY POINTS, VARIABLES (5 3d, 7 2d)
! NOT USED
! NOT USED
! GRID AND TIMING INFO
! NAMES AND UNITS
runname='CCAM'
tempvarname3d=varname3d
tempvarname2d=varname2d
If (mode) Then
  Write(outunit,9001) 'FFFFFFFF'
  Write(outunit,9004) runname,'FALSE',nestfile
  Write(outunit,9002) datearr(3),datearr(2),datearr(1),datearr(4),datearr(5),datearr(6)
  Write(outunit,9002) datearr(3),datearr(2),datearr(1),datearr(4),datearr(5),datearr(6)
  Write(outunit,9002) arrsize(1),arrsize(2),arrsize(3),0,varnum(1,1),varnum(2,1)
  Write(outunit,9002) 0,0,0,0,0,0
  Write(outunit,9002) 0,0,0
  Write(outunit,9003) (slvl(i),i=1,arrsize(3)),dx,dy,-999999.,-999999.,lonlat(2,1),outlon,0.,0.,0.,0.,slvl(arrsize(3))
  Write(outunit,9001) (tempvarname3d(i,1),i=1,varnum(1,1)),(tempvarname3d(i,2),i=1,varnum(1,1)),(tempvarname2d(i,1),    &
      i=1,varnum(2,1)),(tempvarname2d(i,2),i=1,varnum(2,1))
Else
  Write(outunit) 'BBBBBBBB'
  Write(outunit) runname,.FALSE.,nestfile
  Write(outunit) datearr(3),datearr(2),datearr(1),datearr(4),datearr(5),datearr(6)
  Write(outunit) datearr(3),datearr(2),datearr(1),datearr(4),datearr(5),datearr(6)
  Write(outunit) arrsize(1),arrsize(2),arrsize(3),0,varnum(1,1),varnum(2,1)
  Write(outunit) 0,0,0,0,0,0
  Write(outunit) 0,0,0
  Write(outunit) (slvl(i),i=1,arrsize(3)),dx,dy,-999999.,-999999.,lonlat(2,1),outlon,0.,0.,0.,0.,slvl(arrsize(3))
  Write(outunit) (tempvarname3d(i,1),i=1,varnum(1,1)),(tempvarname3d(i,2),i=1,varnum(1,1)),(tempvarname2d(i,1),         &
      i=1,varnum(2,1)),(tempvarname2d(i,2),i=1,varnum(2,1))
End If



Return
End

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! This subroutine writes data to a MEDOC (HPAC) file
!

Subroutine medocdata(outunit,datain,arrsize,mode)

Implicit None

Logical, intent(in) :: mode
Integer, intent(in) :: outunit
Integer, dimension(1:3), intent(in) :: arrsize
Real, dimension(1:arrsize(1),1:arrsize(2),1:arrsize(3)), intent(in) :: datain
Real, dimension(1:arrsize(1),1:arrsize(2),1:arrsize(3)) :: dummy
Integer x,y,z

9003 FORMAT(6(F12.4,1X))

If (mode) Then
  dummy=min(max(datain,-1.E5),1.E5)
  Write(outunit,9003) (((dummy(x,y,z),x=1,arrsize(1)),y=1,arrsize(2)),z=1,arrsize(3))
Else
  Write(outunit) (((datain(x,y,z),x=1,arrsize(1)),y=1,arrsize(2)),z=1,arrsize(3))
End If

Return
End

