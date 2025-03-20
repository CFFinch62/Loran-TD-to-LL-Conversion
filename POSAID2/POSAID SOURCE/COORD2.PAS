Unit Coord2;
   Interface
      Uses DOS, Crt, Menus, AtScrn, Strings, Math, Flt, Types;

      Procedure Ecef84_To_Ecef72(Var x,y,z: Float);
      Procedure Ecef84_To_Nad27(x,y,z: Float;
                                Var lat, lon, alt: Float);
      Procedure Ecef84_To_Wgs72(x,y,z: Float;
                                 Var lat, lon, alt: Float);
      Procedure Ecef84_To_Wgs84(x,y,z: Float;
                                Var lat, lon, alt: Float);

      Procedure Ecef72_to_Ecef84(Var x,y,z: Float);
      Procedure Ecef72_To_Nad27(x,y,z: Float;
                                Var lat, lon, alt: Float);
      Procedure Ecef72_To_Wgs72(x,y,z: Float;
                                Var lat, lon, alt: Float);
      Procedure Ecef72_To_Wgs84(x,y,z: Float;
                                Var lat, lon, alt: Float);

      Procedure Nad27_To_Ecef84(lat, lon, alt: Float;
                                Var x, y, z: Float);
      Procedure Nad27_To_Ecef72(lat, lon, alt: Float;
                                Var x, y, z: Float);
      Procedure Nad27_To_Wgs84(Var lat, lon, alt: Float);
      Procedure Nad27_To_Wgs72(Var lat, lon, alt: Float);

      Procedure Wgs84_to_Ecef84(lat, lon, alt: Float;
                                Var x, y, z: Float);
      Procedure Wgs84_To_Ecef72(lat, lon, alt: Float;
                                Var x, y, z: Float);
      Procedure Wgs84_To_Wgs72(Var lat, lon, alt: Float);
      Procedure Wgs84_To_Nad27(Var lat, lon, alt: Float);

      Procedure Wgs72_to_Ecef84(lat, lon, alt: Float;
                                Var x, y, z: Float);
      Procedure Wgs72_To_Ecef72(lat, lon, alt: Float;
                                Var x, y, z: Float);
      Procedure Wgs72_To_Wgs84(Var lat, lon, alt: Float);
      Procedure Wgs72_To_Nad27(Var lat, lon, alt: Float);


      Procedure Ecef_To_Xy(Var mx, my: Float;
                           ex, ey, nx, ny, nz, rx, ry, rz, x, y, z: Float);
      Procedure Calculate_Coeficients(Var ex, ey, nx, ny, nz: Float;
                                      rx, ry, rz: Float);
   Implementation

      PROCEDURE  Ecef72_to_Ecef84( Var x,y,z  : Float );

         Var
            ref_change : Float;

         Begin  { Ecef72_to_Ecef84 }
            ref_change := (0.554/3600) * (PI/180); {ECEF72 TO 84 ROTATION FACTOR}
            x := x - Sin(ref_change) * y;  { this adjusts ECEF 72 TO ECEF 84 }
            y := y + Sin(ref_change) * x;  { the accurate formula is : }
            z := z + 4.5;                  { x84 = (x72 - tan(.554")(y)) * cos(.554") }
                                           { This appoximate formula is accurate to }
                                           { .0001 meters }
         End;   { Ecef72_to_Ecef84 }

      PROCEDURE  Ecef84_to_Ecef72( Var x,y,z  : Float );

         Var
            ref_change : Float;

         Begin  { Ecef84_to_Ecef72 }
           ref_change := (0.554/3600) * (PI/180); {ECEF84 TO 72 ROTATION FACTOR}
            x := x + sin(ref_change) * y;  { this adjusts ECEF 84 TO ECEF 72 }
            y := y - sin(ref_change) * x;  { the accurate formula is : }
            z := z - 4.5;                  { x72 = (x84 + tan(.554")(y)) * cos(.554")
                                             The formula used is accurate to
                                             .0001 meters }
         End;   { Ecef84_to_Ecef72 }

{values of lat and lon are passed as radians with north lat = + and west lon = +}
      PROCEDURE   Ecef84_to_Nad27( x,y,z  : Float;
                                   Var lat,lon,alt  : Float );
         Var
            a,
            ae2,
            e2,
            f,
            one_e2,
            r,
            rad_to_deg,
            t1,
            t2,
            w,
            x2,
            y2,
            z2  : Float;
            sign : Integer;

         Begin  { ECEF84_TO_NAD27 }
            rad_to_deg:= 180.0 / PI;
            a := 6378206.4 ;          { semi_major axis (Earth) NAD-27 }
            f := (1 / 298.26) + 0.000037295850;  { F ADJUSTMENT FOR NAD 27 }
            e2 := (F * 2.0) - SQR(F);
            one_e2 := 1.0 - e2;
            ae2 := a * e2;
            Ecef84_to_Ecef72(x,y,z);
            x  := x + 22.0;  { DATUM SHIFT FOR WGS 72 ECEF TO NAD 27 ECEF }
            y  := y - 157.0;
            z  := z - 176.0;
            x2 := x * x;
            y2 := y * y;
            z2 := z * z;
            w := Sqrt( x2 + y2 );
            r := Sqrt( x2 + y2 + z2 );
            If y > 0 Then
               sign := 1
            Else
               sign := -1;
            lon :=  abs (arctan(y / x)  * rad_to_deg) ;
            If x < 0 Then
               lon := 180 - lon;
            lon := sign * lon;
            lat := z / ( one_e2 * w ) ;
            t1 := 1 + ( one_e2 * lat * lat ) ;
            t2 := Sqrt( t1 ) ;
            t1 := t1 * t2 ;
            lat := lat + (t1/(w*t1-ae2)) * ((ae2*lat)/t2 -w*lat+z);
            lat :=  Arctan( lat );
            lon:= lon / rad_to_deg;
            alt := r - a / Sqrt(1 + e2 * z2/(one_e2 * ( x2 + y2 + z2 )));
         End;   { ECEF84_TO_NAD27 }

{values of lat and lon are passed as radians with north lat = + and west lon = +}
      PROCEDURE  Ecef84_to_Wgs72( x,y,z  : Float;
                                  VAR lat,lon,alt  : Float );

         Var
            rad_to_deg,
            e2,
            one_e2,
            ae2,
            a,
            w,
            delta_r,
            r,
            t1,
            t2,
            x2,
            y2,
            z2  : Float;
            sign : Integer;

         Begin  { Ecef84_to_wgs72 }
            delta_r := 1.39;
            rad_to_deg := 180.0 / PI;
            a := 6378135.0 ;          { semi_major axis (Earth) WGS-72 }
            e2 := 6.69431780E-03 ;    { eccentricity squared (Earth)WGS 72 }
            one_e2 := 1.0 - e2;
            ae2 := A * e2;
            Ecef84_To_Ecef72(x,y,z);  { from included file }
            x2 := x * x;
            y2 := y * y;
            z2 := z * z;
            w := Sqrt( x2 + y2 );
            r := Sqrt( x2 + y2 + z2 ) - delta_r;
            If y < 0 Then
               sign := -1
            Else
               sign := 1;
            lon :=  Abs(Arctan(y / x)  * rad_to_deg) ;
            If x < 0 Then
               lon := 180 - lon;
            lon := sign * lon;
            lat := z / ( one_e2 * w ) ;
            t1 := 1 + ( one_e2 * lat * lat ) ;
            t2 := Sqrt( t1 ) ;
            t1 := t1 * t2 ;
            lat := lat + (t1/(w*t1-ae2)) * ((ae2*lat)/t2 -w*lat+z);
            lat := Arctan( lat );
            lon:=  lon / rad_to_deg;
            alt := r - a / Sqrt(1 + e2 * z2/(one_e2 * ( x2 + y2 + z2 )));
         End;   { Ecef84_to_wgs72 }

{values of lat and lon are passed as radians with north lat = + and west lon = +}
      PROCEDURE  Ecef84_To_Wgs84( x,y,z  : Float;
                                  VAR lat,lon,alt  : Float );

         Var
            rad_to_deg,
            e2,
            one_e2,
            ae2,
            f,
            a,
            w,
            r,
            t1,
            t2,
            x2,
            y2,
            z2  : Float;
            sign : Integer;

         Begin  { Ecef84_to_wgs84 }
            rad_to_deg := 180.0 / PI;
            a := 6378137.0 ;          { semi_major axis (Earth) WGS-72 }
            f := 1/298.257223563;
            e2 := (f * 2.0) - SQR(f);    { eccentricity squared (Earth)WGS 72 }
            one_e2 := 1.0 - e2;
            ae2 := A * e2;
            If x = 0 Then x:= 0.00000001;
            x2 := x * x;
            y2 := y * y;
            z2 := z * z;
            w := Sqrt( x2 + y2 );
            r := Sqrt( x2 + y2 + z2 );
            If y < 0 Then
               sign := -1
            Else
               sign := 1;
            lon :=  Abs(Arctan(y / x)  * rad_to_deg) ;
            If x < 0 Then
               lon := 180 - lon;
            lon := sign * lon;
            lat := z / ( one_e2 * w ) ;
            t1 := 1 + ( one_e2 * lat * lat ) ;
            t2 := Sqrt( t1 ) ;
            t1 := t1 * t2 ;
            lat := lat + (t1/(w*t1-ae2)) * ((ae2*lat)/t2 -w*lat+z);
            lat := Arctan( lat );
            lon := lon / rad_to_deg;
            alt := r - a / Sqrt(1 + e2 * z2/(one_e2 * ( x2 + y2 + z2 )));
         End;   { Ecef84_to_wgs84 }

{values of lat and lon are passed as radians with north lat = + and west lon = +}
      PROCEDURE   Ecef72_To_Nad27( x,y,z  : Float;
                                   Var lat,lon,alt  : Float );
         Var
            a,
            ae2,
            e2,
            f,
            one_e2,
            r,
            rad_to_deg,
            t1,
            t2,
            w,
            x2,
            y2,
            z2  : Float;
            sign : Integer;

         Begin  { ECEF_TO_NAD27 }
            rad_to_deg:= 180.0 / PI;
            a := 6378206.4 ;          { semi_major axis (Earth) NAD-27 }
            f := (1 / 298.26) + 0.000037295850;  { F ADJUSTMENT FOR NAD 27 }
            e2 := (f * 2.0) - SQR(F);
            one_e2 := 1.0 - e2;
            ae2 := a * e2;
            x  := x + 22.0;  { DATUM SHIFT FOR WGS 72 ECEF TO NAD 27 ECEF }
            y  := y - 157.0;
            z  := z - 176.0;
            x2 := x * x;
            y2 := y * y;
            z2 := z * z;
            w := Sqrt( x2 + y2 );
            r := Sqrt( x2 + y2 + z2 );
            If y > 0 Then
               sign := 1
            Else
               sign := -1;
            lon :=  abs (arctan(y / x)  * rad_to_deg) ;
            If x < 0 Then
               lon := 180 - lon;
            lon := sign * lon;
            lat := z / ( one_e2 * w ) ;
            t1 := 1 + ( one_e2 * lat * lat ) ;
            t2 := Sqrt( t1 ) ;
            t1 := t1 * t2 ;
            lat := lat + (t1/(w*t1-ae2)) * ((ae2*lat)/t2 -w*lat+z);
            lat :=  arctan( lat );
            lon := lon / rad_to_deg;
            alt := r - a / Sqrt(1 + e2 * z2/(one_e2 * ( x2 + y2 + z2 )));
         End;   { ECEF72_TO_NAD27 }

{values of lat and lon are passed as radians with north lat = + and west lon = +}
      PROCEDURE  Ecef72_to_Wgs72( x,y,z  : Float;
                                  VAR lat,lon,alt  : Float );

         Var
            rad_to_deg,
            e2,
            one_e2,
            ae2,
            a,
            w,
            r,
            t1,
            t2,
            x2,
            y2,
            z2  : Float;
            sign : Integer;

         Begin  { Ecef72_to_Wgs72 }
            rad_to_deg := 180.0 / PI;
            a := 6378135.0 ;          { semi_major axis (Earth) WGS-72 }
            e2 := 6.69431780E-03 ;    { eccentricity squared (Earth)WGS 72 }
            one_e2 := 1.0 - e2;
            ae2 := A * e2;
            If x = 0 Then x:= 0.00000001;
            x2 := x * x;
            y2 := y * y;
            z2 := z * z;
            w := Sqrt( x2 + y2 );
            r := Sqrt( x2 + y2 + z2 );
            If y < 0 Then
               sign := -1
            Else
               sign := 1;
            lon :=  Abs(Arctan(y / x)  * rad_to_deg) ;
            If x < 0 Then
               lon := 180 - lon;
            lon := sign * lon;
            lat := z / ( one_e2 * w ) ;
            t1 := 1 + ( one_e2 * lat * lat ) ;
            t2 := Sqrt( t1 ) ;
            t1 := t1 * t2 ;
            lat := lat + (t1/(w*t1-ae2)) * ((ae2*lat)/t2 -w*lat+z);
            lat := Arctan( lat );
            lon := lon / rad_to_deg;
            alt := r - a / Sqrt(1 + e2 * z2/(one_e2 * ( x2 + y2 + z2 )));
         End;   { Ecef72_to_Wgs72 }

{values of lat and lon are passed as radians with north lat = + and west lon = +}
      Procedure Ecef72_To_Wgs84(x,y,z: Float;
                                Var lat, lon, alt: Float);
         Begin
            Ecef72_To_Ecef84(x,y,z);
            Ecef84_To_Wgs84(x,y,z,lat,lon,alt);
         End;

{values of lat and lon are passed as radians with north lat = + and west lon = +}
      PROCEDURE Nad27_To_Ecef84( lat,lon,alt  : Float ;
                                 Var x,y,z     : Float ) ;
         Var
            deg_to_rad,
            e2,
            f,
            one_e2,
            r,
            a:          Float ;

         Begin  { Nad27_to_ecef84 }
            deg_to_rad := PI / 180.0;
            a := 6378206.4 ;          { semi_major axis (Earth) NAD-27 }
            f := (1 / 298.26) + 0.000037295850;  { F ADJUSTMENT FOR NAD 27 }
            e2 := (f * 2.0) - SQR(F);
            one_e2 := 1.0 - e2;
            r := a / Sqrt( 1 - e2 * Sqr( Sin( lat ) ) ) ;
            x := ( r + alt ) * Cos( lat ) * Cos( lon );
            y := ( r + alt ) * Cos( lat ) * Sin( lon );
            z := ( one_e2 * r + alt ) * Sin( lat );
            x  := x - 22.0;  { DATUM SHIFT FOR NAD 27 ECEF TO WGS72 ECEF }
            y  := y + 157.0;
            z  := z + 176.0;
            Ecef72_To_Ecef84(x,y,z);
         End;   { Nad27_to_Ecef84 }

{values of lat and lon are passed as radians with north lat = + and west lon = +}
      PROCEDURE Nad27_to_Ecef72( lat,lon,alt  : Float ;
                                 Var x,y,z     : Float ) ;
         Var
            deg_to_rad,
            e2,
            f,
            one_e2,
            r,
            a:          Float ;

         Begin  { Nad27_to_Ecef72 }
            deg_to_rad := PI / 180.0;
            a := 6378206.4 ;          { semi_major axis (Earth) NAD-27 }
            f := (1 / 298.26) + 0.000037295850;  { F ADJUSTMENT FOR NAD 27 }
            e2 := (f * 2.0) - Sqr(f);
            one_e2 := 1.0 - e2;
            r := a / Sqrt( 1 - e2 * Sqr( Sin( lat ) ) ) ;
            x := ( r + alt ) * Cos( lat ) * Cos( lon );
            y := ( r + alt ) * Cos( lat ) * Sin( lon );
            z := ( one_e2 * r + alt ) * Sin( lat );
            x  := x - 22.0;  { DATUM SHIFT FOR NAD 27 ECEF TO WGS72 ECEF }
            y  := y + 157.0;
            z  := z + 176.0;
         End;   { Nad27_to_Ecef72 }

{values of lat and lon are passed as radians with north lat = + and west lon = +}
      Procedure Nad27_To_Wgs72(Var lat, lon, alt: Float);
         Var
            x, y, z: Float;
         Begin
            Nad27_To_Ecef72(lat, lon, alt, x, y, z);
            Ecef72_To_Wgs72(x, y, z, lat, lon, alt);
         End;

{values of lat and lon are passed as radians with north lat = + and west lon = +}
      Procedure Nad27_To_Wgs84(Var lat, lon, alt: Float);
         Var
            x, y, z: Float;
         Begin
            Nad27_To_Ecef84(lat, lon, alt, x, y, z);
            Ecef84_To_Wgs84(x, y, z, lat, lon, alt);
         End;

{values of lat and lon are passed as radians with north lat = + and west lon = +}
      PROCEDURE Wgs84_To_Ecef84 ( lat,lon,alt  : Float ;
                                  Var x,y,z     : Float ) ;

         Var
            deg_to_rad,
            e2,
            f,
            one_e2,
            ae2,
            r,
            a : Float ;

         Begin  { Wgs84_To_Ecef84 }
            deg_to_rad := PI / 180.0;
            a := 6378137.0 ;          { semi_major axis (Earth) WGS-84 }
            f := 1/298.257223563;
            e2 := (f * 2.0) - SQR(f);    { eccentricity squared (Earth)WGS 84 }
            one_e2 := 1.0 - e2;
            ae2 := a * e2;
            r := a / Sqrt( 1 - e2 * Sqr( Sin( lat ) ) ) ;
            x := ( r + alt ) * Cos( lat ) * Cos( lon );
            y := ( r + alt ) * Cos( lat ) * Sin( lon );
            z := ( one_e2 * r + alt ) * Sin( lat );
         End;   { Wgs84_to Ecef84 }

{values of lat and lon are passed as radians with north lat = + and west lon = +}
      Procedure Wgs84_To_Ecef72(lat, lon, alt: Float;
                                Var x, y, z: Float);
         Begin
            Wgs84_To_Ecef84(lat, lon, alt, x, y, z);
            Ecef84_To_Ecef72(x, y, z);
         End;

{values of lat and lon are passed as radians with north lat = + and west lon = +}
      Procedure Wgs84_To_Wgs72(Var lat, lon, alt: Float);
         Var
            x, y, z: Float;
         Begin
            Wgs84_To_Ecef72(lat, lon, alt, x, y, z);
            Ecef72_To_Wgs72(x, y, z, lat, lon, alt);
         End;

{values of lat and lon are passed as radians with north lat = + and west lon = +}
      Procedure Wgs84_To_Nad27(Var lat, lon, alt: Float);
         Var
            x, y, z: Float;
         Begin
            Wgs84_To_Ecef84(lat, lon, alt, x, y, z);
            Ecef84_To_Nad27(x, y, z, lat, lon, alt);
         End;


{values of lat and lon are passed as radians with north lat = + and west lon = +}
      PROCEDURE Wgs72_to_ecef84 ( lat,lon,alt  : Float ;
                                  Var x,y,z    : Float ) ;

         Var
            deg_to_rad,
            e2,
            f,
            one_e2,
            ae2,
            delta_r,
            r,
            a : Float ;

      Begin  { Wgs72_To_Ecef84 }
         delta_r := 1.39;
         deg_to_rad := PI / 180.0;
         a := 6378135.0 ;          { semi_major axis (Earth) WGS-72 }
         e2 := 6.69431780E-03 ;    { eccentricity squared (Earth)WGS 72 }
         one_e2 := 1.0 - e2;
         ae2 := a * e2;
         r := a / Sqrt( 1 - e2 * Sqr( Sin( lat ) ) ) + delta_r;
         x := ( r + alt ) * Cos( lat ) * Cos( lon );
         y := ( r + alt ) * Cos( lat ) * Sin( lon );
         z := ( one_e2 * r + alt ) * Sin( lat );
         Ecef72_To_Ecef84(x,y,z);  { from included file }
      End;   { Wgs72_To_Ecef84 }

{values of lat and lon are passed as radians with north lat = + and west lon = +}
      PROCEDURE Wgs72_To_Ecef72 ( lat,lon,alt  : Float ;
                                  Var x,y,z     : Float ) ;

         Var
            deg_to_rad,
            e2,
            f,
            one_e2,
            ae2,
            r,
            a : Float ;

         Begin  { Wgs72_to_Ecef72 }
            deg_to_rad := PI / 180.0;
            a := 6378135.0 ;          { semi_major axis (Earth) WGS-72 }
            e2 := 6.69431780E-03 ;    { eccentricity squared (Earth)WGS 72 }
            one_e2 := 1.0 - e2;
            ae2 := a * e2;
            r := a / sqrt( 1 - e2 * sqr( Sin( lat ) ) ) ;
            x := ( r + alt ) * Cos( lat ) * Cos( lon );
            y := ( r + alt ) * Cos( lat ) * Sin( lon );
            z := ( one_e2 * r + alt ) * Sin( lat );
         End;   { Wgs72_to Ecef72 }

{values of lat and lon are passed as radians with north lat = + and west lon = +}
      Procedure Wgs72_To_Wgs84(Var lat, lon, alt: Float);
         Var
            x, y, z: Float;
         Begin
            Wgs72_To_Ecef72(lat, lon, alt, x, y, z);
            Ecef72_To_Wgs84(x, y, z, lat, lon, alt);
         End;

{values of lat and lon are passed as radians with north lat = + and west lon = +}
      Procedure Wgs72_To_Nad27(Var lat, lon, alt: Float);
         Var
            x, y, z: Float;
         Begin
            Wgs72_To_Ecef72(lat, lon, alt, x, y, z);
            Ecef72_To_Nad27(x, y, z, lat, lon, alt);
         End;

      Procedure Ecef_To_Xy(Var mx, my: Float;
                           ex, ey, nx, ny, nz, rx, ry, rz, x, y, z: Float);
         Begin
            mx:= (ex * (x - rx) + ey * (y - ry));
            my:= (nx * (x - rx) + ny * (y - ry) + nz * (z - rz));
         End;

      Procedure Calculate_Coeficients(Var ex, ey, nx, ny, nz: Float;
                                      rx, ry, rz: Float);
         Var
            r, w,
            rx2, ry2, rz2: Float;
         Begin
            rx2:= Sqr(rx);
            ry2:= Sqr(ry);
            rz2:= Sqr(rz);
            w:= Sqrt(rx2 + ry2);
            r:= Sqrt(rx2 + ry2 + rz2);
            ex:= (-1 * ry) / w;
            ey:= rx / w;
            nx:= (-1 * rz * rx) / (r * w);
            ny:= (-1 * rz * ry) / (r * w);
            nz:= w / r;
         End;
   End.