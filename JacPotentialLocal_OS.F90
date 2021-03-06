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
    
SUBROUTINE JacPotentialLocal(ncomp,nsurf,nsurf_sec,npot,jx,jy,jz)
USE crunchtype
USE concentration
USE solver
USE mineral

IMPLICIT NONE

!  External variables and arrays

INTEGER(I4B), INTENT(IN)                                                :: ncomp
INTEGER(I4B), INTENT(IN)                                                :: nsurf
INTEGER(I4B), INTENT(IN)                                                :: nsurf_sec
INTEGER(I4B), INTENT(IN)                                                :: npot
INTEGER(I4B), INTENT(IN)                                                :: jx
INTEGER(I4B), INTENT(IN)                                                :: jy
INTEGER(I4B), INTENT(IN)                                                :: jz

!  Internal variables and arrays

REAL(DP)                                                                :: delta_z
REAL(DP)                                                                :: surfconc
REAL(DP)                                                                :: mutemp
REAL(DP)                                                                :: sum

INTEGER(I4B)                                                            :: npt2
INTEGER(I4B)                                                            :: is
INTEGER(I4B)                                                            :: is2
INTEGER(I4B)                                                            :: ns
INTEGER(I4B)                                                            :: i

fjpotncomp_local = 0.0
fjpotnsurf_local = 0.0

DO ns = 1,nsurf_sec
  surfconc = spsurf10(ns+nsurf,jx,jy,jz)
  delta_z = zsurf(ns+nsurf) - zsurf(islink(ns))

  DO i = 1,ncomp
    IF (musurf(ns,i) /= 0.0) THEN
      mutemp = musurf(ns,i)
      DO npt2 = 1,npot
        is2 = ispot(npt2)
        IF (islink(ns) == is2) THEN
          fjpotncomp_local(npt2,i) = fjpotncomp_local(npt2,i) -         &
                    2.0*delta_z*mutemp*surfconc
        END IF
      END DO     
    END IF
  END DO

  DO is = 1,nsurf
    IF (musurf(ns,is+ncomp) /= 0.0) THEN
      mutemp = musurf(ns,is+ncomp)
      DO npt2 = 1,npot
        is2 = ispot(npt2)
        IF (is == is2 .AND. islink(ns) == is2) THEN
          fjpotnsurf_local(npt2,is) = fjpotnsurf_local(npt2,is) -       & 
                   2.0*delta_z*mutemp*surfconc
        END IF
      END DO
    END IF   
  END DO

END DO


RETURN
END SUBROUTINE JacPotentialLocal
