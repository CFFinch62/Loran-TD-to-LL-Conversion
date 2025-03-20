Unit RB;
   Interface
      Uses Flt, Coord_Gb;
      Procedure LL_RB(lat1, lon1, lat2, lon2: Float;
                      Var distance, azimuth: Float);
      Procedure RB_LL(lat1, lon1: Float;
                      Var lat2, lon2: Float;
                      distance, azimuth: Float);
      Function Delta_Ok(lat1, lon1, lat2, lon2: Float): Boolean;
      Function Range_Ok(distance: Float): Boolean;
      Function RB_Suspect(lon, azimuth: Float): Boolean;

   Implementation

{If the indicated range and bearing crosses the international dateline, the
 new position is suspect (algorithm not corrected for date line crossing).
 Function returns true if position may be suspect}

      Function RB_Suspect(lon, azimuth: Float): Boolean;
         Var
            temp: Boolean;
         Begin
            temp:= False;
            If azimuth < 0.0 Then
               Repeat
                  azimuth:= azimuth + (2.0*PI);
               Until azimuth <= 0.0;
            If Abs(lon) > (PI - (5*PI/180.0)) Then  {check for proximity to}
               Begin                                 {dateline +- 5 deg}
                  If lon < 0.0 Then                    {if west lon}
                     If (azimuth > PI) And             {and azimuth between}
                        (azimuth < (2.0*PI)) Then       {180 and 360}
                        temp:= True;
                  If lon > 0.0 Then                    {If east lon}
                     If (azimuth > 0.0) And            {and azimuth between}
                        (azimuth < PI) Then            {0 and 180}
                        temp:= True;
               End;
         End;

{The following function checks to make sure the distance involved is within the
 allowable limits of algorithm}

      Function Range_Ok(distance: Float): Boolean;
         Begin
            If distance < 9000000.0 Then
               Range_Ok:= True
            Else
               Range_Ok:= False;
         End;

{The following function checks to see if the delta_lat or delta_lon is
 greater than 90 degrees.  If either are then the function returns
 a False}
      Function Delta_OK(lat1, lon1, lat2, lon2: Float):Boolean;
         Var
            delta_lat,
            delta_lon: Float;
            temp: Boolean;
         Const
            EPSILON = 1E-10;
         Begin
            delta_lat:= Abs(lat2-lat1);
            delta_lon:= Abs(lon2-lon1);
            If (delta_lon >= PI) Then
               Begin
                  If lon1 < 0.0 Then
                     lon1:= lon1 + 2*PI;
                  If lon2 < 0.0 Then
                     lon2:= lon2 + 2*PI;
                  delta_lon:= Abs(lon2-lon1);
               End;
            If (delta_lat >= (PI/2.0)) Or
               (delta_lon >= (PI/2.0)) Then
               temp:= False
            Else
               temp:= True;
            Delta_Ok:= temp;
         End;


{The following procedure corrects the azimuths returned by built in ARCTAN
 function for the correct quadrant.  I thought that a modified ATAN function
 to do the same thing may be able to function, but the answers returned are
 different.  So to use the code from the original program called INVERSE
 (the algorithm is contained in Procedure LL_RB) this method is used}
      Procedure Correct_For_Quadrant(lat1, lon1, lat2, lon2: Float;
                                     Var az: Float);
         Var
            delta_lat,
            delta_lon: Float;
         Begin
            delta_lat:= lat2-lat1;
            delta_lon:= lon2-lon1;
            If (Abs(delta_lon) >=PI) Then
               Begin
                  If lon1<0.0 Then
                     lon1:= lon1 + 2*PI;
                  If lon2<0.0 Then
                     lon2:= lon2 + 2*PI;
               End;

            delta_lon:= lon2-lon1;
            If delta_lat = 0.0 Then
               If delta_lon = 0.0 Then       {same position}
                  az:= 0.0
               Else If delta_lon < 0.0 Then   {due west}
                  az:= 3.0*PI/2
               Else                           {due east}
                  az:= PI/2.0
            Else If delta_lat > 0.0 Then
               If delta_lon = 0.0 Then        {due north}
                  az:= 0.0
               Else                           {1st or 4th quadrant no change}
                  az:= az
            Else If delta_lat < 0.0 Then
               If delta_lon = 0.0 Then        {due south}
                  az:= PI
               Else If delta_lon < 0.0 Then   {3rd quadrant}
                  az:= az + PI
               Else az:= az - PI;             {2nd quadrant}
         End;


{This procedure was taken from a program FORWARD written by Steve FRAKES
 of the National Geodetic Survey. (301) 443-8520.  The original program was
 written in FORTRAN77 and run under MSDOS using the IBM professional FORTRAN
 compiler. It was converted to PASCAL by Cordell VIEHWEG of the U.S. Coast Guard
 (212) 668-6210, in conjunction with a coordinate conversion program POSAID.
 All variables from the original code were left intact to simplify code comparison.
 One change from the original code is the use of the function DATAN2.  This function
 in FORTRAN accepts 2 parameters, where the Arctan function of PASCAL accepts
 only 1. I have a function ATAN which accepts 2 parameters (x,y) which returns
 angle as an azimuth from north (proper quadrant).  This does not work properly
 in given algorithm.  Two other values (flattening and semimajor_axis) are taken
 an included Library unit (COORD1) and are the flattening term and semimajor_axis
 of the spheroid model of the earth in use.  The mentioned library unit initializes
 these terms for one of three models, NAD27, WGS72 and WGS84.  The algorithm
 also provides a value BAZ which is the back azimuth, and is not used in this
 implementation.  The parameters passed are the coordinates of the known
 position (in radians) where east/north are positive, and an azimuth (radians) and distance
 (meters or same units as the term semimajor_axis).  The procedure returns the
 lat/lon coordinates of the unknown position in radians (east/north as positive).}
      Procedure RB_LL(lat1, lon1: Float;
                      Var lat2, lon2: Float;
                      distance, azimuth: Float);
         Var
            r, tu, sf, cf, baz,
            cu, su, sa, c2a, x,
            c, d, y, sy, cy, cz, e: Float;
         Begin
            r:= 1.0 - flattening;
            tu:= r * Sin(lat1)/Cos(lat1);
            sf:= Sin(azimuth);
            cf:= Cos(azimuth);
            baz:= 0.0;
            If cf <> 0.0 Then
               baz:= Arctan(tu/cf) * 2.0;
            cu:= 1.0 / Sqrt(tu*tu + 1.0);
            su:= tu*cu;
            sa:= cu*sf;
            c2a:= -sa*sa + 1.0;
            x:= Sqrt((1.0/r/r - 1.0) * c2a + 1.0) + 1.0;
            x:= (x-2.0)/x;
            c:= 1.0 - x;
            c:= (x*x/4.0 + 1.0)/c;
            d:= (0.375*x*x - 1.0) * x;
            tu:= distance/r/semimajor_axis/c;
            y:= tu;
            Repeat
               sy:= Sin(y);
               cy:= Cos(y);
               cz:= Cos(baz+y);
               e:= cz*cz*2 -1.0;
               c:= y;
               x:= e*cy;
               y:= e + e - 1.0;
               y:= (((sy*sy*4.0 -3.0)*y*cz*d/6.0 +x)*d/4.0 -cz)*sy*d +tu;
            Until (Abs(y-c) < 5.0e-14);
            baz:= cu*cy*cf - su*sy;
            c:= r*Sqrt(sa*sa + baz*baz);
            d:= su*cy + cu*sy*cf;
            lat2:= Arctan(d/c);
            c:= cu*cy - su*sy*cf;
            x:= Arctan(sy*sf/c);
            c:= ((-3.0*c2a + 4.0)*flattening+4.0)*c2a*flattening/16.0;
            d:= ((e*cy*c + cz)*sy*c + y)*sa;
            lon2:= lon1 + x - (1.0 -c)*d*flattening;
            If lon2 >= (2.0*PI) Then
               lon2:= lon2 - (2.0*PI);
            If lon2 < 0.0 Then
               lon2:= lon2 + (2.0*PI);
            If lon2 > PI Then
               lon2:= lon2-(2.0*PI);
            baz:= Arctan(sa/baz) + PI;
            If baz >= (2.0*PI) Then
               baz:= baz - (2.0*PI);
            If baz < 0.0 Then
               baz:= baz + (2.0*PI);
         End;

{This procedure was taken from a program INVERSE written by Steve FRAKES
 of the National Geodetic Survey. (301) 443-8520.  The program was written
 in FORTRAN77 and run under MSDOS using the IBM professional FORTRAN compiler.
 It was converted to PASCAL by Cordell VIEHWEG (212) 668-6210
 of the US Coast Guard to work
 in conjunction with a coordinate conversion program POSAID.  All variables
 from original code were left intact to simplify code comparison.  One change
 was made from original code in that the DATAN2 function from FORTRAN accepted
 2 parameters as input (x coordinate value and a y coordinate value).  PASCAL
 does not have a standard 1:1 replacement for this function.  The ARCTAN function
 of PASCAL is a one parameter function.  I have developed a two parameter function
 for PASCAL called ATAN which accepts x and y coordinate values and returns
 an Arc Tangent value (0..360) in the correct quadrant.  This does not work
 properly with this algorithm for unknown reasons.  It may be that the FORTRAN
 DATAN2 function did not return values 0..360 in proper quadrant. The value is
 critical in several assignment statements.  If I were more familiar with FORTRAN
 perhaps I could resolve the problem.  Using the existing ARCTAN function of
 PASCAL leaves resolving the quadrant to the programmer to provide a valid
 azimuth value.  This is accomplished by a call to the included procedure
 Correct_For_Quadrant.  Two additional variables which this procedure uses
 are flattening and semimajor_axis.  Flattening is a measure of the earth's
 lack of being a perfect sphere (squished).  The semiminor_axis is the
 shortest diameter of this squished sphere and the semimajor axis is the
 largest diameter of this squished sphere.  The program POSAID allows the user
 to use several geoidal models of the earth's sphere, and these two reguired
 were assigned in the Used library unit Coord_GB.  (see unit for details).
 to have this unit, the programmer must declare these variables within this
 procedure and assign values to them commensurate with the system in use.
 The flattening term is calculated as 1-(semiminor_axis/semimajor_axis).
 The values of the lat and lon terms (as well as azimuth) are passed as radians.
 The value of distance is returned in the same units as used for
 semimajor_axis. In this instance it is meters}

      Procedure LL_RB(lat1, lon1, lat2, lon2: Float;
                      Var distance, azimuth: Float);
         Var
            r, tu1, tu2, cu1, su1, cu2, s, baz,
            faz, x, sx, cx, sy, cy, y, sa, c2a,
            cz, e, c, d, delta_lon: Float;
         Begin
{This first section was added by C. VIEHWEG to account for shortest path of
 positions more than 180 degrees difference in longitude and which cross
 international date line as shortest path.  The remaining procedure uses
 delta longitude, the rationale is that at a given latitude, the longitudes
 are relative as long as the relative difference is constant.  If a crossing
 of the date line is detected as being the shortest route, numbering of the
 longitudes is changed as a function of 2*PI.  Deltas are then taken as usual.
 Entire function falls apart if user attempts to derive distances which are
 greater than 90 degrees apart}
            delta_lon:= lon2-lon1;
            If (Abs(delta_lon) >= PI) Then
               Begin
                  If lon1<0.0 Then
                     lon1:= lon1 + 2*PI;
                  If lon2<0.0 Then
                     lon2:= lon2 + 2*PI;
               End;

            r:= 1.0 - flattening;
            tu1:= r * Sin(lat1) / Cos(lat1);
            tu2:= r * Sin(lat2) / Cos(lat2);
            cu1:= 1.0 / Sqrt(tu1*tu1 + 1.0);
            su1:= cu1 * tu1;
            cu2:= 1.0 / Sqrt(tu2*tu2 + 1.0);
            s:= cu1 * cu2;
            baz:= s * tu2;
            faz:= baz * tu1;
            x:= lon2 - lon1;
            Repeat             {next section iterates for convergence}
               sx:= Sin(x);
               cx:= Cos(x);
               tu1:= cu2 * sx;
               tu2:= baz - su1 * cu2 * cx;
               sy:= Sqrt(tu1*tu1 + tu2*tu2);
               cy:= s * cx + faz;
               y:= Arctan(sy/cy);
               sa:= s * sx/sy;
               c2a:= sa * sa + 1.0;
               cz:= faz + faz;
               If c2a > 0.0 Then
                  cz:= -cz/c2a + cy;
               e:= cz * cz * 2.0 -1.0;
               c:= ((-3.0*c2a+4.0)*flattening+4.0)*c2a*flattening/16.0;
               d:= x;
               x:= ((e*cy*c+cz)*sy*c+y)*sa;
               x:= (1.0-c) * x * flattening +lon2-lon1;
            Until (Abs(d-x) < 5E-15);  {some small epsilon}

            faz:= Arctan(tu1/tu2);

            If faz >= 2*PI Then
               Repeat
                  faz:= faz - (2*PI);
               Until faz < 2*PI;

            If faz < 0.0 Then
               Repeat
                  faz:= faz + (2*PI);
               Until faz >= 0.0;

            baz:= Arctan((cu1*sx) / (baz*cx - su1*cu2)) + PI;

            If baz >= 2*PI Then
               Repeat
                  baz:= baz - (2*PI);
               Until baz < 2*PI;

            If baz < 0.0 Then
               Repeat
                  baz:= baz + (2*PI);
               Until baz >= 0.0;

            x:= Sqrt((1.0/r/r -1.0) * c2a +1.0) + 1.0;
            x:= (x-2.0)/x;
            c:= 1.0 - x;
            c:= (x * x/4.0 +1.0) / c;
            d:= (0.375 * x * x - 1.0) * x;
            x:= e * cy;
            s:= 1.0 - e - e;
            s:= ((((sy*sy*4.0 - 3.0)*s*cz*d/6.0 -x)*d/4.0 +cz)*sy*d + y) *
                    c*semimajor_axis*r;
            distance:= s;
            azimuth:= faz;
            Correct_For_Quadrant(lat1, lon1, lat2, lon2, azimuth);
         End;
      End.



