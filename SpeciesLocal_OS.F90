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


SUBROUTINE SpeciesLocal(ncomp,nspec,jx,jy,jz)
USE crunchtype
USE params
USE concentration

IMPLICIT NONE
!fp! auto_par_loops=0;

!  External variables and arrays

INTEGER(I4B), INTENT(IN)                                    :: ncomp
INTEGER(I4B), INTENT(IN)                                    :: nspec
INTEGER(I4B), INTENT(IN)                                    :: jx
INTEGER(I4B), INTENT(IN)                                    :: jy
INTEGER(I4B), INTENT(IN)                                    :: jz

!  Internal variables and arrays

INTEGER(I4B)                                                :: ksp
INTEGER(I4B)                                                :: i
INTEGER(I4B)                                                :: nk

REAL(DP)                                                    :: sum

DO ksp = 1,nspec

  IF (ikh2o /= 0) THEN

    sum = 0.0D0
    DO i = 1,ncomp
      IF (ulab(i) == 'H2O') THEN
        sum = sum + muaq(ksp,i)*(gam(i,jx,jy,jz))
      ELSE
        sum = sum + muaq(ksp,i)*(sp(i,jx,jy,jz) + gam(i,jx,jy,jz))
      END IF
    END DO

  ELSE

    sum = 0.0D0
    DO i = 1,ncomp
      sum = sum + muaq(ksp,i)*(sp(i,jx,jy,jz) + gam(i,jx,jy,jz))
    END DO

  END IF


  nk = ncomp + ksp
  sp(nk,jx,jy,jz) = keqaq(ksp,jx,jy,jz) - gam(nk,jx,jy,jz) + sum
  sp10(nk,jx,jy,jz) = EXP(sp(nk,jx,jy,jz))
END DO

RETURN
END SUBROUTINE SpeciesLocal
!  **************************************************************
