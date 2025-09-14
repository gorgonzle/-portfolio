*deck,usercr       USERDISTRIB  parallel                                pck/dc
      subroutine usercr (elem,intpt,mat,ncomp,kfirst,kfsteq,e,posn,d,
     x proptb,timval,timinc,tem,dtem,toffst,fluen,dfluen,epel,epcrp,
     x statev,usvr,delcr)
c
c *** primary function:   allow users to write their own creep laws.
c                           this logic is accessed with c6 = 100
c *** secondary function:    demonstrate the use of user-written creep laws
c
c *** Notice - This file contains ANSYS Confidential information ***
c
c
c         *** Copyright ANSYS.  All Rights Reserved.
c         *** ansys, inc.
c
c  input arguments:
c     variable (type,sze,intent)    description
c
c     elem     (int,sc,in)         - element number (label)
c     intpt    (int,sc,in)         - element integration point number
c     mat      (int,sc,in)         - material reference number
c     ncomp    (int,sc,in)         - no. of stress/strain components (1,4 or 6)
c                                    1 - xB
c                                    4 - x,y,z,xy
c                                    6 - x,y,z,xy,yz,xz
c     kfirst   (int,sc,in)         - 1 if first time through, 0 otherwise
c                                    (useful for initializing state variables
c                                    to a non-zero value)
c     kfsteq   (int,sc,in)         - 1 if first equilibrium iteration of a
c                                    substep, 0 otherwise
c
c
c     e        (dp,sc,in)          - elastic young'S MODULUS
c     posn     (dp,sc,in)          - poisson'S RATIO
c     d        (dp,ar(ncomp,ncomp),in)- elastic stress-strain matrix
c     proptb   (dp,ar(72),in)      - material properties input on tb commands
c                               (do not use proptb(13), as it is used elsewhere)
c ----------------------------------------------------------------------
c proptb() mapping for Wen–Tu + Damage USERCR
c ----------------------------------------------------------------------
c proptb(1) = B0        base creep coefficient (Norton constant)
c proptb(2) = n         stress exponent at secondary creep
c proptb(3) = USE_SI    flag: 1 = use sig_1 principal stress correction,
c                             0 = ignore (pure deviatoric)
c proptb(4) = USE_ARR   flag: 1 = use Arrhenius correction for B(T),
c                             0 = constant B0
c proptb(5) = Qact      activation energy Q (J/mol or eV, unit consistent)
c proptb(6) = Rgas      gas constant R (J/mol·K, or eV/K accordingly)
c proptb(7) = PFLAG     plane option if ncomp=4:
c                         0 = plane strain (sig_zz from D*ep_el),
c                         1 = plane stress (sig_zz=0)
c proptb(8) = Bclip     minimum B value (lower bound to avoid underflow)
c proptb(9) = eps_f     fracture strain constant e_f (for e_f* in damage law)
c ----------------------------------------------------------------------
c     timval   (dp,sc,in)          - current time value
c     timinc   (dp,sc,in)          - time increment over this substep
c     tem      (dp,sc,in)          - temperature at the end of this substep
c     dtem     (dp,sc,in)          - temperature increment over this substep
c     toffst   (dp,sc,in)          - temperature offset from absolute zero
c     fluen    (dp,sc,in)          - fluence at the end of this substep
c     dfluen   (dp,sc,in)          - fluence increment over this substep
c
c     epel     (dp,ar(ncomp),inout)- elastic strain
c     epcrp    (dp,ar(ncomp),inout)- creep strain from previous substep
c     statev   (dp,ar(ncomp*5+2),inout)- state variables from previous 
c                                    (converged) substep.  This variable is for
c                                    explicit creep only and refers to a 
c                                    different internal variable than that 
c                                    defined by TB,stat which is used by 
c                                    implicit creep (usercreep) and usermat.
c     usvr     (dp,ar(nuval,nintp),inout)- additional state variables from
c                                    previous equilibrium iteration (saved
c                                    if the nsvr command is used)
c
c
c  output arguments:
c     variable (type,sze,intent)    description
c
c     epel     (dp,ar(ncomp),inout)- elastic strain adjusted for creep increment
c     epcrp    (dp,ar(ncomp),inout)- updated creep strain
c     statev   (dp,ar(ncomp*5+2),inout)- updated state variables
c     usvr     (dp,ar(nuval,nintp),inout)- updated additional state variables
c     delcr    (dp,sc,out)         - equivalent creep strain increment (used
c                                    for creep ratio calculation)
c
c  fortran parameters (to be defined by the user):
c     variable (type)              description
c     nuval    (int)               - number of additional state variables per
c                                    integration point
c     nintp    (int)               - maximum number of integration points of
c                                    an element to be used with this routine
c                                    (14 is the maximum)
c         note:  nuval x nintp = nstv(on nsvr command); cannot exceed 840!
c
c  internal variables:
c     variable (type,sze)     description
c     con      (dp,sc)         - temporary variable
c     del      (dp,ar(6))      - creep strain increments
c     epet     (dp,sc)         - equivalent elastic strain (before creep)
c     ept      (dp,ar(6))      - total strain
c     eptot    (dp,sc)         - equivalent total strain, elastic + creep
c     sigen    (dp,sc)         - equivalent stress (before creep)
c     temabs   (dp,sc)         - temperature on the absolute scale
c
#include "impcom.inc"


       external erhandler

c
c  user-defined fortran parameters
c     --- size of usvr data
      integer nuval,nintp
      parameter (nuval=1,nintp=1)
c
c  external subroutines and functions
      external egen
      double precision egen
      external vapb,vapb1,vamb1,vmult
c
c  integer variables
      integer elem,intpt,mat,ncomp,kfirst,kfsteq
c
c  double precision variables
      double precision
     x e,posn,d(ncomp,ncomp),proptb(72),timval,timinc,tem,dtem,toffst,
     x fluen,dfluen,epel(ncomp),epcrp(ncomp),statev(ncomp*5+2),
     x usvr(nuval,nintp),delcr,
     x temabs,con,del(6),epet,sigen,eptot,ept(6)
      
c ---- ADDED/CORRECTED declarations for Wen–Tu + Damage ----
      integer i,j,a,b,pflag
      logical useSI,useARR
      double precision Bbase,nn,Qact,Rgas,Bclip,eps_f
      double precision Bc,Tkel,u_old,rpar,bfac,ratio,bracket,scale
      double precision dot_eq,d_eq,fac_n,epsf_star,domega,sI,sm,seq
      double precision sigv(6),sig(3,3),S(3,3),edot(3,3)
      double precision ten2dot
      external vec_to_tensor, deviator, max_principal
      external distribute_prandtl_reuss, b0_poly
c
c   **** the current version of the ansys program does not accumulate
c        the affects of creep work.  if this is desired, it is recommened
c        to:
c              1.  compute the desired creep work in this routine.
c                  this can be accumulated over the element.  this can
c                  be done by:  if (intpt .eq. 1) usvr(1,1) = 0.0  at
c                  the first of this routine.  then, later, accumulate
c                  over all integration points as:
c                  usvr(1,1) = usvr(1,1) + xxxxx
c                  note that this is really only a creep work density,
c                  and, if the total creep work is desired, will need
c                  to be multiplied by the volume as indicated in the
c                  next steps.
c                  actually, it is a bit more complex than this.  we want
c                  this accumulation to be done only for converged
c                  equilibrium iterations.  the concept that may be used is:
c                     if (kfstps .eq. 1) work = 0.0
c                     if (kfsteq .eq. 1) workold = work
c                     work = workold + delta(work)
c                  thus, at the converged equilibrium iteration,
c                  work will be correct.
c              2.  in userou, move the data from usvr(1,1) to udbdat(1).
c                  userou is called only after all integration points
c                  are processed.
c              3.  in post1, access udbdat(1) at the end of the nmisc record
c                  (miscellaneous nonsummable record).
c              4.  multiply by the element volume and accumulate.
c        this procedure presumes that the creep work density does not
c        change rapidly in a region of irregular elements.
c
c   this routine demonstrates the computation of creep strains using a
c   primary creep equation equivalent to c6=0. see section 3.3 of the ansys
c   theoretical manual for more detailed documentation.
c   in a large strain analysis, all strains are the hencky (i.e. log) strains.
c   all quantities are rotation-neutralized and are in the rotated element
c   coordinate system (not global).
c
c                     ***** initializations *****
c
c --- initial checks
c     --- author should remove the warning below when making any changes
      if (intpt.eq.1 .and. kfirst.eq.1)
c
     x call erhandler('usercr',5000,2,
     x  'Ansys, Inc.-supplied version of coding for USERCR has been 
     x  used.'
     x  ,0.0d0,' ')
c

c     ---- author should remove the following line.  it is only there
c     ---- for the analyzer.
      con = d(1,1)+dfluen+dtem+fluen+statev(1)+usvr(1,1)+
     x             dble(elem+kfsteq+mat)
c     --- check that author-defined usvr size is within bounds
c
      if (nuval*nintp.gt.840)
     Xcall erhandler('usercr',5010,4,
     x 'Maximum storage allowed by USVR has been exceeded.'
     x ,0.0d0,' ')
c

c     --- inititialize creep strain increment in case no creep
      delcr = 0.0d0
c     --- no creep if time is not moving
      if (timinc .le. 0.0d0 .and. timval .le. 0.0d0) go to 999
c     --- no creep if temperature is not defined
      temabs = tem + toffst
      if (temabs .le. 0.0d0)  then
c
         call erhandler('usercr',5020,3,
     x    'Temperature= %G must be greater than zero for creep.'
     x    ,temabs,' ')
c

         go to 999
      endif
c
c          ***** define the equivalent strain and stress *****
c
c --- define the equivalent strain using the function egen
      epet = egen (ncomp,epel(1),posn)
c     --- no creep if the strain is zero
      if (epet .eq. 0.0d0) go to 999
c     --- define the stress
      sigen = e*epet
c
c
c           ***** define the creep strain rate *****
c
c       ***** normal beginning of user changes
c       ***** beginning of sample creep law - same as c6 = 0
c
c --- skip if c1 is zero
      if (proptb(1) .eq. 0.0d0) go to 999
c
c --- define the equivalent total strain
      call vapb (epel(1),epcrp(1),ept(1),ncomp)
      eptot = egen (ncomp,ept(1),posn)
c
c --- define the creep strain rate
c ====================== USERCR: Wen–Tu Full + Damage  ======================
      Bbase  = proptb(1)
      nn     = proptb(2)
      useSI  = (proptb(3) .gt. 0.5d0)
      useARR = (proptb(4) .gt. 0.5d0)
      Qact   = proptb(5)
      Rgas   = proptb(6)
      pflag  = int(proptb(7))
      Bclip  = max(proptb(8), 1.0d-60)
      eps_f  = max(proptb(9), 1.0d-30)

c --- elastic Cauchy stress from Hencky elastic strain: sigv = D * epel
      do i=1,ncomp
         sigv(i)=0.d0
         do j=1,ncomp
            sigv(i)=sigv(i)+d(i,j)*epel(j)
         enddo
      enddo

c --- Voigt -> 3x3 tensor  (ncomp=6: 3D, ncomp=4: 2D with plane flag)
      call vec_to_tensor(sigv, ncomp, pflag, sig)

c --- Deviator, mean stress, von Mises
      call deviator(sig, S, sm, seq)
      if (seq .le. 1.0d-20) goto 999

c --- Max principal stress (optional)
      if (useSI) then
         call max_principal(sig, sI)
      else
         sI = 0.d0
      endif

c --- Temperature dependence: B(T)
      Bc = Bbase
      if (useARR) then
         Tkel = tem + toffst
         if (Tkel .le. 1.d-12) Tkel = 1.d-12
         if (Rgas .gt. 1.d-30) then
            Bc = Bbase * exp(-Qact/(Rgas*Tkel))
         else
            Bc = Bbase * exp(-Qact/Tkel)
         endif
      endif


c --- Path variable u := ∫ ep_eq^c dt  (statev(1) 사용)
      u_old = max(statev(1), 0.d0)

c --- r(u) per Wen–Tu
      if (nn .le. 0.d0) then
         rpar = 0.d0
      else
         rpar = (2.d0*(nn+1.d0)/3.141592653589793d0)
     &          * sqrt(1.d0 + 3.d0/nn) * (u_old**1.5d0)
      endif


c --- b0(n,r)
      call b0_poly(nn, rpar, bfac)

c --- Bracket term with principal stress
      if (useSI) then
         ratio   = sI/seq
         bracket = 1.d0 + bfac*ratio*ratio
      else
         bracket = 1.d0
      endif
      if (bracket .lt. 0.d0) bracket = 0.d0

c --- Wen–Tu creep rate tensor: edot = (3/2) * B(T) * seq^(n-1) * bracket^((n+1)/2) * S
      scale = 1.5d0 * Bc * seq**(nn-1.d0) * bracket**((nn+1.d0)/2.d0)
      if (scale .lt. 0.d0)   scale = 0.d0
      if (scale .gt. 1.d12)  scale = 1.d12

      do a=1,3
        do b=1,3
          edot(a,b) = scale * S(a,b)
        enddo
      enddo

c --- Equivalent creep rate & increment
      dot_eq = sqrt( (2.d0/3.d0) * ten2dot(edot, edot) )
      if (dot_eq .lt. 0.d0) dot_eq = 0.d0
      d_eq = dot_eq * timinc
      if (d_eq .gt. 1.d0) d_eq = 1.d0   ! 안전 상한(초기 튜닝용)

      delcr = delcr + d_eq

c --- Component-wise increment (PR mapping)
      call distribute_prandtl_reuss(epel, posn, d_eq, del, ncomp)

c --- Update creep / elastic strains
      call vapb1 (epcrp(1),del(1),ncomp)
      call vamb1 (epel(1),del(1),ncomp)

c --- Accumulators: u, eps_c,eq
      statev(1) = u_old + d_eq
      statev(2) = max(statev(2),0.d0) + d_eq

c --- Damage w update (eq.12) with eps_f* (eq.5)
      fac_n = (nn - 0.5d0)/(nn + 0.5d0)
      epsf_star = eps_f * exp( (2.d0/3.d0)*fac_n )
     &           * exp( -2.d0*fac_n * sm/seq )
      if (epsf_star .lt. 1.d-30) epsf_star = 1.d-30
      domega = (dot_eq/epsf_star) * timinc
      if (domega .lt. 0.d0) domega = 0.d0
      statev(3) = max(statev(3),0.d0) + domega
      if (statev(3) .gt. 1.d0) statev(3) = 1.d0

c ======================================================================

  999  continue
      return
      end





c --- Functions----------------------------------------------

      subroutine vec_to_tensor(sv, ncomp, pflag, T)
      double precision sv(*), T(3,3)
      integer ncomp, pflag, i, j
      do i=1,3
        do j=1,3
          T(i,j)=0.d0
        enddo
      enddo
      if (ncomp .eq. 6) then
         T(1,1)=sv(1); T(2,2)=sv(2); T(3,3)=sv(3)
         T(1,2)=sv(4); T(2,1)=sv(4)
         T(2,3)=sv(5); T(3,2)=sv(5)
         T(1,3)=sv(6); T(3,1)=sv(6)
      else
c ncomp=4: plane option (0: strain, 1: stress)
         T(1,1)=sv(1); T(2,2)=sv(2)
         if (pflag .eq. 0) then
            T(3,3)=sv(3)    ! plane strain: sig_zz from D*epel
         else
            T(3,3)=0.d0     ! plane stress : sig_zz = 0
         endif
         T(1,2)=sv(4); T(2,1)=sv(4)
      endif
      return
      end

      subroutine deviator(T, S, sm, seq)
      double precision T(3,3), S(3,3), sm, seq, J2
      sm = (T(1,1)+T(2,2)+T(3,3))/3.d0
      S(1,1)=T(1,1)-sm; S(2,2)=T(2,2)-sm; S(3,3)=T(3,3)-sm
      S(1,2)=T(1,2); S(2,1)=T(2,1)
      S(1,3)=T(1,3); S(3,1)=T(3,1)
      S(2,3)=T(2,3); S(3,2)=T(3,2)
      J2 = 0.5d0*( S(1,1)*S(1,1) + S(2,2)*S(2,2)
     &            + S(3,3)*S(3,3)
     &            + 2.d0*( S(1,2)*S(1,2) + S(1,3)*S(1,3)
     &            + S(2,3)*S(2,3) ) )
      if (J2 .lt. 0.d0) J2=0.d0
      seq = sqrt(3.d0*J2)
      return
      end

      subroutine max_principal(T, smax)
      double precision T(3,3), smax
      double precision I1,I2,I3,q,r,phi,pi,cphi
      double precision a11,a22,a33,a12,a13,a23
      a11=T(1,1); a22=T(2,2); a33=T(3,3)
      a12=T(1,2); a13=T(1,3); a23=T(2,3)
      I1 = a11+a22+a33
      I2 = a11*a22 + a22*a33 + a33*a11 - (a12*a12 + a13*a13 + a23*a23)
      I3 = a11*(a22*a33 - a23*a23) - a12*(a12*a33 - a13*a23)
     &   + a13*(a12*a23 - a13*a22)
      q = (3.d0*I2 - I1*I1)/9.d0
      r = (9.d0*I1*I2 - 27.d0*I3 - 2.d0*I1*I1*I1)/54.d0
      pi = 3.141592653589793d0
      if (q .ge. 0.d0) then
         smax = I1/3.d0
         return
      endif
      cphi = r / sqrt(-q*q*q)
      if (cphi .gt. 1.d0)  cphi = 1.d0
      if (cphi .lt. -1.d0) cphi = -1.d0
      phi = acos(cphi)
      smax = 2.d0*sqrt(-q)*cos(phi/3.d0) + I1/3.d0
      return
      end

      double precision function ten2dot(A,B)
      double precision A(3,3), B(3,3)
      ten2dot = A(1,1)*B(1,1)+A(2,2)*B(2,2)+A(3,3)*B(3,3)
     &        +2.d0*(A(1,2)*B(1,2)+A(1,3)*B(1,3)+A(2,3)*B(2,3))
      return
      end

      subroutine distribute_prandtl_reuss(epel, posn, delcr, del, ncomp)
      double precision epel(*), posn, delcr, del(6), epet, con
      integer ncomp
      double precision egen
      external egen
      del(1)=0.d0; del(2)=0.d0; del(3)=0.d0
      del(4)=0.d0; del(5)=0.d0; del(6)=0.d0
      epet = egen(ncomp, epel(1), posn)
      if (epet .le. 1.d-30) return
      if (ncomp .eq. 1) then
         del(1) = delcr * epel(1) / epet
      else
         con = delcr/epet
         con = con/(2.d0*(1.d0+posn))
         del(4) = 3.d0*con*epel(4)
         if (ncomp .eq. 6) then
            del(5) = 3.d0*con*epel(5)
            del(6) = 3.d0*con*epel(6)
         endif
         del(1) = con*(2.d0*epel(1) - epel(2) - epel(3))
         del(2) = con*(2.d0*epel(2) - epel(3) - epel(1))
         del(3) = con*(2.d0*epel(3) - epel(1) - epel(2))
      endif
      return
      end

      subroutine b0_poly(nexp, r, b0)
c b0(r,n) = 2*r/(n+1) + ((2n+3)/n)*r^2/(n+1)^2
c         + ((n+3)/(9n))*r^3/(n+1)^3 + ((n+3)/(108n))*r^4/(n+1)^4
      double precision nexp, r, b0
      double precision n, invnp1, invn, r2, r3, r4
      n = max(nexp, 1.0d-12)
      invnp1 = 1.0d0/(n + 1.0d0)
      invn   = 1.0d0/n
      r2 = r*r
      r3 = r2*r
      r4 = r2*r2
      b0 = 2.0d0*r*invnp1
     &   + ( (2.0d0*n + 3.0d0) * invn ) * r2 * (invnp1*invnp1)
     &   + ( (n + 3.0d0) / (9.0d0*n) )   * r3 * (invnp1**3)
     &   + ( (n + 3.0d0) / (108.0d0*n) ) * r4 * (invnp1**4)
      return
      end

