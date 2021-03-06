!! CrunchTope 
!! Copyright (c) 2016, Carl Steefel
!! Copyright (c) 2016, The Regents of the University of California, 
!! through Lawrence Berkeley National Laboratory (subject to 
!! receipt of any required approvals from the U.S. Dept. of Energy).  
!! All rights reserved.

!! Redistribution and use in source and binary forms, with or without
!! modification, are permitted provided that the following conditions are
!! met: 

!! (1) Redistributions of source code must retain the above copyright
!! notice, this list of conditions and the following disclaimer.

!! (2) Redistributions in binary form must reproduce the above copyright
!! notice, this list of conditions and the following disclaimer in the
!! documentation and/or other materials provided with the distribution.

!! (3) Neither the name of the University of California, Lawrence
!! Berkeley National Laboratory, U.S. Dept. of Energy nor the names of    
!! its contributors may be used to endorse or promote products derived
!! from this software without specific prior written permission.

!! THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
!! "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
!! LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
!! A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
!! OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
!! SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
!! LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
!! DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
!! THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
!! (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
!! OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE 


SUBROUTINE read_pump(nout,nx,ny,nz,nchem,npump)
USE crunchtype
USE CrunchFunctions
USE params
USE concentration
USE transport
USE flow
USE strings

IMPLICIT NONE

!  External variables and arrays

INTEGER(I4B), INTENT(IN)                                    :: nout
INTEGER(I4B), INTENT(IN)                                    :: nx
INTEGER(I4B), INTENT(IN)                                    :: ny
INTEGER(I4B), INTENT(IN)                                    :: nz
INTEGER(I4B), INTENT(IN)                                    :: nchem
INTEGER(I4B), INTENT(OUT)                                   :: npump

!  Internal variables and arrays

INTEGER(I4B)                                                :: id
INTEGER(I4B)                                                :: iff
INTEGER(I4B)                                                :: ids
INTEGER(I4B)                                                :: ls
INTEGER(I4B)                                                :: lzs
INTEGER(I4B)                                                :: nxyz
INTEGER(I4B)                                                :: nlen1
INTEGER(I4B)                                                :: nco
INTEGER(I4B)                                                :: intbnd_tmp
INTEGER(I4B)                                                :: jxxtemp
INTEGER(I4B)                                                :: jyytemp
INTEGER(I4B)                                                :: jzztemp

REAL(DP)                                                    :: qtemp

nxyz = nx*ny*nz

REWIND nout

npump = 0
10 READ(nout,'(a)',END=500) zone
nlen1 = LEN(zone)
CALL majuscules(zone,nlen1)
id = 1
iff = mls
CALL sschaine(zone,id,iff,ssch,ids,ls)
IF(ls /= 0) THEN
  lzs=ls
  CALL convan(ssch,lzs,res)
  IF (ssch == 'pump') THEN
    id = ids + ls
    CALL sschaine(zone,id,iff,ssch,ids,ls)
    IF(ls /= 0) THEN
      lzs=ls
      CALL convan(ssch,lzs,res)
      IF (res == 'n') THEN
        qtemp = DNUM(ssch)
      ELSE                !  An ascii string--so bag it.
        WRITE(*,*)
        WRITE(*,*) ' Cant interpret string following "pump"'
        WRITE(*,*) ' Looking for numerical value'
        WRITE(*,*)
        READ(*,*)
        STOP
      END IF
      
!  Now, look for geochemical condition following pumping rate (only used if rate is positive)
      
      id = ids + ls
      CALL sschaine(zone,id,iff,ssch,ids,ls)
      IF(ls /= 0) THEN
        lzs=ls
        CALL convan(ssch,lzs,res)
        
!  Check to see that heterogeneity label matches one of the labels
!  for geochemical conditions (condlabel)
        
        DO nco = 1,nchem
          IF (ssch == condlabel(nco)) THEN
            GO TO 50
          END IF
        END DO
        WRITE(*,*)
        WRITE(*,*) ' Geochemical condition for pumping well not found'
        WRITE(*,*) ' Label = ',ssch
        WRITE(*,*)
        READ(*,*)
        STOP
        50         npump = npump+ 1
        intbnd_tmp = nco
      ELSE         !  Blank string
        WRITE(*,*)
        WRITE(*,*) ' No geochemical condition for pumping well provided'
        WRITE(*,*)
        READ(*,*)
        STOP
      END IF
      
! Now look for pumping well
      
      id = ids + ls
      CALL sschaine(zone,id,iff,ssch,ids,ls)
      IF(ls /= 0) THEN
        lzs=ls
        CALL convan(ssch,lzs,res)
        IF (res == 'n') THEN
          jxxtemp = JNUM(ssch)
        ELSE                !  An ascii string--so bag it.
          WRITE(*,*)
          WRITE(*,*) ' A grid location should follow pumping well specification'
          WRITE(*,*)
          READ(*,*)
          STOP
        END IF
      ELSE                  ! Zero length trailing string
        WRITE(*,*)
        WRITE(*,*) ' No grid location given for pumping zone'
        WRITE(*,*) ' Pumping zone ',npump
        WRITE(*,*)
        READ(*,*)
        STOP
      END IF
      
      IF (jxxtemp > nx) THEN
        WRITE(*,*)
        WRITE(*,*) ' You have specified a pumping zone at JX > NX'
        WRITE(*,*) ' Pumping zone number ',npump
        READ(*,*)
        STOP
      END IF
      IF (jxxtemp < 1) THEN
        WRITE(*,*)
        WRITE(*,*) ' You have specified a pumping zone at JX < 1'
        WRITE(*,*) ' Pumping zone number ',npump
        READ(*,*)
        STOP
      END IF
      
      WRITE(*,*)
      WRITE(*,*) ' Pumping zone number ',npump
      WRITE(*,*) ' Jxx location = ', jxxtemp
      
!!      IF (ny > 1) THEN
        id = ids + ls
        CALL sschaine(zone,id,iff,ssch,ids,ls)
        IF(ls /= 0) THEN
          lzs=ls
          CALL convan(ssch,lzs,res)
          IF (res == 'n') THEN
            jyytemp = JNUM(ssch)
          ELSE                !  An ascii string--so bag it.
            WRITE(*,*)
            WRITE(*,*) ' No Y location for pumping zone'
            WRITE(*,*) ' Pumping zone ',npump
            WRITE(*,*)
            READ(*,*)
            STOP
          END IF
        ELSE                  ! Zero length trailing string
          WRITE(*,*)
          WRITE(*,*) ' No Y location for pumping zone'
          WRITE(*,*) ' Pumping zone ',npump
          WRITE(*,*)
          READ(*,*)
          STOP
        END IF
        
        IF (jyytemp > ny) THEN
          WRITE(*,*)
          WRITE(*,*) ' You have specified a pumping zone at JY > NY'
          WRITE(*,*) ' Pumping zone number ',npump
          READ(*,*)
          STOP
        END IF
        IF (jyytemp < 1) THEN
          WRITE(*,*)
          WRITE(*,*) ' You have specified a pumping zone at JY < 1'
          WRITE(*,*) ' Pumping zone number ',npump
          READ(*,*)
          STOP
        END IF
        
        WRITE(*,*)
        WRITE(*,*) ' Pumping zone number ',npump
        WRITE(*,*) ' Jyy location = ', jyytemp
        
!!      ELSE
!!        jyytemp = 1
!!      END IF


        id = ids + ls
        CALL sschaine(zone,id,iff,ssch,ids,ls)
        IF(ls /= 0) THEN
          lzs=ls
          CALL convan(ssch,lzs,res)
          IF (res == 'n') THEN
            jzztemp = JNUM(ssch)
          ELSE                !  An ascii string--so bag it.
            WRITE(*,*)
            WRITE(*,*) ' No Z location for pumping zone'
            WRITE(*,*) ' Pumping zone ',npump
            WRITE(*,*)
            READ(*,*)
            STOP
          END IF
        ELSE                  ! Zero length trailing string
          WRITE(*,*)
          WRITE(*,*) ' No Z location for pumping zone'
          WRITE(*,*) ' Pumping zone ',npump
          WRITE(*,*)
          READ(*,*)
          STOP
        END IF
        
        IF (jzztemp > nz) THEN
          WRITE(*,*)
          WRITE(*,*) ' You have specified a pumping zone at JZ > NZ'
          WRITE(*,*) ' Pumping zone number ',npump
          READ(*,*)
          STOP
        END IF
        IF (jzztemp < 1) THEN
          WRITE(*,*)
          WRITE(*,*) ' You have specified a pumping zone at JZ < 1'
          WRITE(*,*) ' Pumping zone number ',npump
          READ(*,*)
          STOP
        END IF
        
        WRITE(*,*)
        WRITE(*,*) ' Pumping zone number ',npump
        WRITE(*,*) ' Jzz location = ', jzztemp

      qg(jxxtemp,jyytemp,jzztemp) = qtemp
      intbnd(jxxtemp,jyytemp,jzztemp) = intbnd_tmp
      
    ELSE
      WRITE(*,*)
      WRITE(*,*) ' No pumping rate given'
      WRITE(*,*) ' Pumping zone ignored'
      WRITE(*,*)
      GO TO 10
    END IF
  ELSE
    GO TO 10
  END IF
ELSE
  GO TO 10
END IF

GO TO 10

500 RETURN
END SUBROUTINE read_pump
