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

SUBROUTINE gases_init_co2(ncomp,ngas,tempc,pg,vrInOut)
USE crunchtype
USE params
USE concentration
USE temperature
USE runtime, ONLY: Duan,Duan2006

IMPLICIT NONE

!  External variables

INTEGER(I4B), INTENT(IN)                                   :: ncomp
INTEGER(I4B), INTENT(IN)                                   :: ngas
REAL(DP), INTENT(IN)                                       :: tempc
REAL(DP), INTENT(IN)                                       :: pg
REAL(DP), INTENT(INOUT)                                       :: vrInOut

!  Internal variables

REAL(DP)                                                   :: tempk
REAL(DP)                                                   :: denmol
REAL(DP)                                                   :: sum

INTEGER(I4B)                                               :: i
INTEGER(I4B)                                               :: kk

REAL(DP)                                                   :: ln_fco2
REAL(DP)                                                   :: ln_fco2_Check
REAL(DP)                                                   :: GasCheck

tempk = tempc + 273.15
!!denmol = DLOG(1.D05/(8.314d0*tempk))           ! P/RT = n/V, with pressure converted from bars to Pascals

DO kk = 1,ngas
  IF (ikh2o /= 0) THEN

    sum = 0.0
    DO i = 1,ncomp
      IF (ulab(i) == 'H2O') THEN
        sum = sum + mugas(kk,i)*(gamtmp(i))
      ELSE
        sum = sum + mugas(kk,i)*(sptmp(i) + gamtmp(i))
      END IF
    END DO

  ELSE

    sum = 0.0
    DO i = 1,ncomp
      sum = sum + mugas(kk,i)*(sptmp(i) + gamtmp(i))
    END DO

  END IF
  
  ln_fco2 = 0.0d0  ! fugacity coefficient for CO2(g)
  if (namg(kk) == 'CO2(g)') then
    IF (Duan) THEN
      call fugacity_co2(pg,tempk,ln_fco2,vrInOut)
    ELSE IF (Duan2006) THEN
      call fugacity_co24(pg,tempk,ln_fco2,vrInOut)
!!!      call fugacity_co2(pg,tempk,ln_fco2_Check,vrInOut)
      continue
    END IF

  end if
  
  spgastmp(kk) = keqgas_tmp(kk) + sum - ln_fco2 
  spgastmp10(kk) = DEXP(spgastmp(kk))       !  partial pressure of gases

END DO

RETURN
END SUBROUTINE gases_init_co2
!  **************************************************************
