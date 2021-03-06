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


SUBROUTINE satcalc(ncomp,nrct,jx,jy,jz)
USE crunchtype
USE params
USE concentration
USE mineral
USE medium
USE temperature


IMPLICIT NONE

INTEGER(I4B), INTENT(IN)                                        :: ncomp
INTEGER(I4B), INTENT(IN)                                        :: nrct
INTEGER(I4B), INTENT(IN)                                        :: jx
INTEGER(I4B), INTENT(IN)                                        :: jy
INTEGER(I4B), INTENT(IN)                                        :: jz

!  Internal variables and arrays

REAL(DP)                                                        :: tk
REAL(DP)                                                        :: tkinv
REAL(DP)                                                        :: reft
REAL(DP)                                                        :: sum
REAL(DP)                                                        :: sumiap 

INTEGER(I4B)                                                    :: k
INTEGER(I4B)                                                    :: np
INTEGER(I4B)                                                    :: i
INTEGER(I4B)                                                    :: id
INTEGER(I4B)                                                    :: kd
INTEGER(I4B)                                                    :: isotope

tk = t(jx,jy,jz) + 273.15D0
tkinv = 1.0/tk
reft = 1.0/298.15

DO k = 1,nrct
  DO np = 1,nreactmin(k)

    IF (ikh2o /= 0) THEN

      sumiap = 0.0D0
      DO i = 1,ncomp
        IF (ulab(i) == 'H2O') THEN
          sumiap = sumiap + decay_correct(i,k)*mumin(np,k,i)*(gam(i,jx,jy,jz))
        ELSE
          sumiap = sumiap + decay_correct(i,k)*mumin(np,k,i)*(sp(i,jx,jy,jz)+gam(i,jx,jy,jz))
        END IF
      END DO

    ELSE

      sumiap = 0.0D0
      DO i = 1,ncomp
        sumiap = sumiap + decay_correct(i,k)*mumin(np,k,i)*(sp(i,jx,jy,jz)+gam(i,jx,jy,jz))
      END DO

    END IF

    silog(np,k) = (sumiap - keqmin(np,k,jx,jy,jz))/clg
  END DO
END DO

RETURN
END SUBROUTINE satcalc
!********************************************************
