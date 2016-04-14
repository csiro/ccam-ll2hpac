Program ll2hpac

! Revision date: 19/05/06

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! This code is for converting CCAM nc output (on lat/lon grid) into
! MEDOC (HPAC) format.
!

Implicit None

include 'version.h'

Integer :: nopts
Character*256, dimension(:,:), allocatable :: options

! Start banner
write(6,*) "=============================================================================="
write(6,*) "CCAM: Starting ll2hpac"
write(6,*) "=============================================================================="

Write(6,*) 'll2hpac - Lat/Lon to MEDOC (HPAC) converter'
write(6,*) version
Write(6,*) 'Warning: this code has only been designed for SCIPUFF'

! Read switches
nopts=3
Allocate (options(nopts,3))
options(:,1) = (/ '-i', '-o', '-n' /)
options(:,2) = ''

Call readswitch(options,nopts)
Call defaults(options,nopts)

Call hpacconvert(options,nopts)

Deallocate(options)

! Complete
write(6,*) "CCAM: ll2hpac completed successfully"
call finishbanner

Stop
End

subroutine finishbanner

implicit none

! End banner
write(6,*) "=============================================================================="
write(6,*) "CCAM: Finished ll2hpac"
write(6,*) "=============================================================================="

return
end    
    
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! This subroutine displays the help message
!

Subroutine help()

Implicit None

Write(6,*)
Write(6,*) "Usage:"
Write(6,*) "  ll2hpac -i inputfile [-o outputfile] [-n nestfile]"
Write(6,*)
Write(6,*) "Options:"
Write(6,*) "  -i inputfile   Input filename"
Write(6,*) "  -o outputfile  Output filename (default = inputfile.fmt)"
Write(6,*) "  -n nestfile    MEDOC file to be nested in the current file"
Write(6,*) "                 (default = no nested file)"
Write(6,*)
call finishbanner
Stop

Return
End


!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! This subroutine determins the default values for the switches
!

Subroutine defaults(options,nopts)

Implicit None

Integer nopts
Character(len=*), dimension(nopts,2), intent(inout) :: options
Integer infile,outfile,nestfile
Integer locate

infile=locate('-i',options(:,1),nopts)
outfile=locate('-o',options(:,1),nopts)
nestfile=locate('-n',options(:,1),nopts)

If (options(infile,2).EQ.'') then
  Write(6,*) "ERROR: No input filename specified"
  call finishbanner
  Stop
End if

If (options(outfile,2).EQ.'') then
  ! Default output filename
    options(outfile,2)=trim(options(infile,2))//'.fmt'
End if

Return
End

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! This subroutine converts from the specified netCDF file into MEDOC
! (HPAC) output.
!

Subroutine hpacconvert(options,nopts)

use netcdf_m

Implicit None

Integer, intent(in) :: nopts
Character(len=*), dimension(nopts,2), intent(in) :: options
Character*80, dimension(:,:), allocatable :: varname3d,varname2d
Character*80 :: infile,outfile,utype,returnoption
Character*80 :: nctmunit,nctmdate,outname,inunit
Character*256 :: nestfile
Real, dimension(:,:,:,:), allocatable :: arrdata
Real, dimension(:,:,:), allocatable :: inlvl
Real, dimension(:), allocatable :: outlvl
Real, dimension(1:2,1:3) :: lonlat
Real mintime,maxtime,timestep,x
Integer, dimension(1:4,1:2) :: arrsize
Integer, dimension(1:4) :: ncsize
Integer, dimension(1:6) :: datearray,outdate
Integer, dimension(1:3) :: tlist
Integer, dimension(1:2,1:2) :: varnum
Integer outunit,ncstatus,ncid,it,ii,ot
Integer i,j,itmin
Logical mode

mode=.TRUE. ! T=Free, F=Binary HPAC format

! Define HPAC metadata
varnum(1,2)=7 ! max 3d
varnum(2,2)=8 ! max 2d
Allocate(varname3d(1:varnum(1,2),1:2),varname2d(1:varnum(2,2),1:2))
varname3d(1,1)="U"
varname3d(2,1)="V"
varname3d(3,1)="W"
varname3d(4,1)="TA"
varname3d(5,1)="H"
varname3d(6,1)="UUE"
varname3d(7,1)="VVE"
varname3d(1,2)="m/s"
varname3d(2,2)="m/s"
varname3d(3,2)="m/s"
varname3d(4,2)="K"
varname3d(5,2)="g/g"
varname3d(6,2)="(m/s)^2"
varname3d(7,2)="(m/s)^2"
varname2d(1,1)="TOPO"
varname2d(2,1)="ZI"
varname2d(3,1)="HFLX"
varname2d(4,1)="ZRUF"
varname2d(5,1)="ALBEDO"
varname2d(6,1)="BOWEN"
varname2d(7,1)="CANOPY"
varname2d(8,1)="ALPHA"
varname2d(1,2)="m"
varname2d(2,2)="m"
varname2d(3,2)="W/m^2"
varname2d(4,2)="m"
varname2d(5,2)="none"
varname2d(6,2)="none"
varname2d(7,2)="m"
varname2d(8,2)="none"
varnum(:,1)=varnum(:,2) ! actual 3d and 2d

! Read switches
infile=returnoption('-i',options,nopts)
outfile=returnoption('-o',options,nopts)
nestfile=returnoption('-n',options,nopts)

! Open files
outunit=1
If (mode) Then
  Open(outunit,FILE=outfile)
Else
  Open(outunit,FILE=outfile,FORM='Unformatted')
End If
ncstatus=nf_open(infile,nf_nowrite,ncid)
If (ncstatus.NE.nf_noerr) Then
  Write(6,*) "ERROR: Error opening NetCDF file ",trim(infile)," (",ncstatus,")"
  call finishbanner
  Stop
End If

! Get nc dimensions, date, time, lat, lon, etc
Call getncdims(ncid,ncsize)
Call getnctime(ncid,nctmunit,nctmdate)
Call ncdateconvert(nctmdate,datearray)
Call getnclonlat(ncid,lonlat(1:2,1:2))
lonlat(1,3)=Real(ncsize(1))
lonlat(2,3)=Real(ncsize(2))
Call getncminmaxtime(ncid,mintime,maxtime,timestep)
tlist(1)=Int(mintime)
tlist(2)=Int(maxtime)
tlist(3)=Int(timestep)
! Read nc level data and convert to meters
Allocate(outlvl(1:ncsize(3)))
Call nccallvlheight(ncid,outlvl,ncsize(3),'meters')

! Display nc data
Write(6,'(A20,I4.4,"-",I2.2,"-",I2.2," ",I2.2,":",I2.2,":",I2.2)') " NetCDF file date : ",datearray(:)
Write(6,*) "lon [start,end,count] =",lonlat(1,:)
Write(6,*) "lat [start,end,count] =",lonlat(2,:)
Write(6,*) "Time [start,end,step] =",tlist(:)
Write(6,*) "Rescaled levels (m) =",outlvl

! Match MEDOC metadata to nc file contents
Call matchmeta(ncid,varname3d,varnum(1,1))
Write(6,*) "3d var found :",(trim(varname3d(i,1))," ",i=1,varnum(1,1))
Call matchmeta(ncid,varname2d,varnum(2,1))
Write(6,*) "2d var found :",(trim(varname2d(i,1))," ",i=1,varnum(2,1))

! Prepare arrays
arrsize(:,1)=1
arrsize(:,2)=ncsize
arrsize(4,2)=1
Allocate(arrdata(1:arrsize(1,2),1:arrsize(2,2),1:arrsize(3,2),1:arrsize(4,2)))
Allocate(inlvl(1:arrsize(1,2),1:arrsize(2,2),0:arrsize(3,2)))

! Loop over time steps (skip first time step)
itmin=1
if (tlist(1).EQ.0) then
  Write(6,*) "Skip initial time step T:",1,"/",ncsize(4)
  itmin=2
end if
Do it=itmin,ncsize(4)

  ! Convert date for MEDOC
  x=Real((it-1)*tlist(3)+tlist(1))
  Call calrescale("minutes",nctmunit,x)
  ot=Int(x)
  Call advdate(datearray,outdate,ot)
  
  Write(6,*) "T:",it,"/",ncsize(4),"   (",Int(x),")"
  Write(6,*) outdate

  ! Write MEDOC header
  Call medochead(outunit,varnum,varname3d,varname2d,ncsize(1:3),lonlat,outlvl,outdate,mode,nestfile)
  
  ! Define slab
  arrsize(:,2)=ncsize
  arrsize(4,2)=1
  ! Calculate time index
  arrsize(4,1)=it

  ! Get levels in meters
  Call ncgetlvlheight(ncid,it,inlvl,arrsize(1:4,2),'meters')
  
  Do ii=1,varnum(1,1)
    ! Get data from nc file
    Call getmeta(ncid,varname3d(ii,:),arrdata(:,:,:,1),arrsize)
    Call convertlvl(arrdata(:,:,:,1),inlvl,outlvl,arrsize(1:3,2))

    ! Write MEDOC (HPAC) data
    Call medocdata(outunit,arrdata(:,:,:,1),arrsize(1:3,2),mode)
  End Do

  arrsize(3,2)=1
  Do ii=1,varnum(2,1)
    ! Get data from nc file
    Call getmeta(ncid,varname2d(ii,:),arrdata(:,:,1,1),arrsize)
    Select case(varname2d(ii,1))
      Case ('BOWEN')
        ! Fix for negative Bowen ratio
        Write(6,*) "WARN: Changing all negative BOWEN ratios to zero."
        arrdata=max(arrdata,0.)
      Case ('ZRUF')
        ! Fix for small roughness
        Write(6,*) "WARN: Limiting small ZRUF values."
        arrdata=max(arrdata,1.E-4)
      Case Default
        ! Do nothing
    End select

    ! Write MEDOC (HPAC) data
    Call medocdata(outunit,arrdata(:,:,1,1),arrsize(1:3,2),mode)
  End Do

End Do

! Close files
Deallocate(arrdata,varname3d,varname2d,inlvl,outlvl)
Close(outunit)
ncstatus=nf_close(ncid)

Return
End

