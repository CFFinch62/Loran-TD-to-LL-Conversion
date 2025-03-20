Unit Coord1;
   Interface
      Uses DOS, Crt, Menus, AtScrn, Strings, Math, Flt, Types, Coord2, Coord_GB;

      Procedure Change_Coord(new_sys: Geodetic;
                             Var user: User_Rec);
      Procedure Precise_Lat_To_Meters(lat: Real;
                                      Var meters_deg_lat,
                                          meters_deg_lon: Float);
      Procedure Get_E_Array(lat, lon: Float; first, second: Integer);
      Procedure Get_Td_Distance(receiver_td,   {td's from the receiver}
                             waypoint_td:   {td's of the waypoint}
                                          Real_Array_1x4;
                             Var distance, azimuth: Float);

      Procedure Init_J_Matrix(lat, lon: Float);
      Procedure Get_Timing_Delays(first, second: Integer);
      Procedure Lat_Lon_To_Td(lat, lon: Float;
                           Var tdp: Real_Array_1x4);
      Function Secondary_Ok(secondary: Integer): Boolean;
      Function SortTD(td: Float): Integer;
      Function Get_Ref_Data(gri: Integer;
                            filename: String;
                            coord_sys: Geodetic): Boolean;
      Function Time_Distance(distance: Float): Float;
      Procedure Distance_Azimuth(lat1, lon1, lat2, lon2: Float;
                                 Var distance, azimuth: Float);
      Procedure Td_To_Lat_Lon(td1, td2: Float;
                              Var lat, lon: Float;
                              Var good_position: Boolean);
      Procedure InitWgs84;
      Procedure InitNAD27;
      Procedure InitWgs72;
      Procedure InitNad83;

   Implementation
{following procedure changes lat/lon from radians to degrees}

   Procedure LL_to_Deg(Var lat, lon: Float);
      Begin
         lat:= lat * 180.0 / PI;
         lon:= lon * 180.0 / PI;
      End;

{following procedure changes lat/lon from degrees to radians}

   Procedure LL_to_Rad(Var lat, lon: Float);
      Begin
         lat:= lat * PI / 180.0;
         lon:= lon * PI / 180.0;
      End;

{This procedure is called to convert all coordinates from from geodetic system to
 another.  The coordinates changed are those of the LORAN-C transmitters.
 The new coordinate system is passed as
 new_sys and the old coordinate system is contained within the user record as
 coord_sys}
      Procedure Change_Coord(new_sys: Geodetic;
                             Var user: User_Rec);
         Var
            i: Integer;
         Begin
            Case new_sys Of
               NAD27: Begin
                         InitNAD27;
                         Case user.coord_sys Of
                            NAD27: ;  {do nothing already here}
                            WGS72: Begin
                                      For i:= 0 to 4 Do
                                         If transmitter[i].use Then
                                            WGS72_To_Nad27(transmitter[i].lat,
                                                           transmitter[i].lon,
                                                           transmitter[i].alt);
                                   End;
                            WGS84: Begin
                                      For i:= 0 to 4 Do
                                         If transmitter[i].use Then
                                            WGS84_To_Nad27(transmitter[i].lat,
                                                           transmitter[i].lon,
                                                           transmitter[i].alt);
                                   End;

                            NAD83: Begin
                                      For i:= 0 to 4 Do
                                         If transmitter[i].use Then
                                            WGS84_To_Nad27(transmitter[i].lat,
                                                           transmitter[i].lon,
                                                           transmitter[i].alt);
                                   End;
                         End;   {inner Case statement}
                      End;  {Case NAD27 statement}
               WGS72: Begin
                         InitWGS72;
                         Case user.coord_sys Of
                            NAD27: Begin
                                      For i:= 0 to 4 Do
                                         If transmitter[i].use Then
                                            NAD27_To_WGS72(transmitter[i].lat,
                                                           transmitter[i].lon,
                                                           transmitter[i].alt);
                                   End;
                            WGS72: ;   {do nothing already here}
                            WGS84: Begin
                                      For i:= 0 to 4 Do
                                         If transmitter[i].use Then
                                            WGS84_To_WGS72(transmitter[i].lat,
                                                           transmitter[i].lon,
                                                           transmitter[i].alt);
                                   End;

                            NAD83: Begin
                                      For i:= 0 to 4 Do
                                         If transmitter[i].use Then
                                            WGS84_To_WGS72(transmitter[i].lat,
                                                           transmitter[i].lon,
                                                           transmitter[i].alt);
                                   End;
                         End;   {inner Case statement}
                      End;   {Case WGS72 statement}
               WGS84: Begin
                         InitWGS84;
                         Case user.coord_sys Of
                            NAD27: Begin
                                      For i:= 0 to 4 Do
                                         If transmitter[i].use Then
                                            NAD27_To_WGS84(transmitter[i].lat,
                                                           transmitter[i].lon,
                                                           transmitter[i].alt);
                                   End;
                            WGS72: Begin
                                      For i:= 0 to 4 Do
                                         If transmitter[i].use Then
                                            WGS72_To_WGS84(transmitter[i].lat,
                                                           transmitter[i].lon,
                                                           transmitter[i].alt);
                                   End;
                            WGS84: ; {do nothing already here}
                            NAD83: user.coord_sys:= new_sys;
                         End;   {inner Case statement}
                      End;   {Case WGS84 statement}
               Nad83: Begin
                         InitWgs84;
                         Case user.coord_sys Of
                            NAD27: Begin
                                      For i:= 0 to 4 Do
                                         If transmitter[i].use Then
                                            NAD27_To_WGS84(transmitter[i].lat,
                                                           transmitter[i].lon,
                                                           transmitter[i].alt);
                                   End;
                            WGS72: Begin
                                      For i:= 0 to 4 Do
                                         If transmitter[i].use Then
                                            WGS72_To_WGS84(transmitter[i].lat,
                                                           transmitter[i].lon,
                                                           transmitter[i].alt);
                                   End;
                            WGS84: user.coord_sys:= new_sys;
                            NAD83: {do nothiong already here}
                         End;   {inner Case statement}
                      End;   {Case NAD83 statement}
            End;   {Case  Statement}

            user.coord_sys:= new_sys;
{Now the dust has settled initial;ize the j matrix using new coordinate system}
            Init_J_Matrix(user.lat, user.lon);

         End;   {Change_Coord}

{This procedure takes a latitude (radians) as input and returns the
 meters per degreee of latitude and meters per degree of longitude. }
      Procedure Precise_Lat_To_Meters(lat: Real;
                                      Var meters_deg_lat,
                                          meters_deg_lon: Float);
         Begin
            meters_deg_lat:= 111132.09 - 566.05 * Cos(lat * 2.0)
                             + 1.2 * Cos(lat * 4.0)
                             - 0.002 * Cos(lat * 6.0);
            meters_deg_lon:= 111415.13 * Cos(lat)
                             - 94.55 * Cos(lat * 3.0)
                             + 0.12 * Cos(lat * 5.0);
         End;  {Precise_Lat_To_Meters}

{This procedure Get_E_Array is called to develop an 'E' matrix for a location
 which the latitude/longitude is known.
 The e matrix is developed to enable a program to obtain the distance
 to point from the boat's corrected TD position. Only two secondaries TD's
 are used in this distancing procedure and thus are the only ones used to
 develop the e matrix. The procedure is passed the secondaries which will be
 used to do the distancing. These are passed as parameters first & second. The
 procedure assumes that the transmitter record has been properly initialized
 by calling Get_Ref_Data. The latitude and longitude of the point to distance to
 is passed as coordinates in radians.}

      Procedure Get_E_Array(lat, lon: Float; first, second: Integer);
         Var
            p : Array[1..3] Of Float;
            q : Array[1..3] Of Float;
            b : Array[1..3] Of Float;
            d: Array_2x2;
            i,j: Integer;
            e, f,
            dummy: Float;


         Procedure Inverse(Var d: Array_2x2);
            Var
               temp: Array_2x2;
               a: Array[1..2,1..4] Of Float;
               i,j,k: Integer;
               dummy: Float;
            Begin
               For i:= 1 to 2 Do    {initialize 'a' matrix to all zero's}
                  For j:= 1 to 4 Do
                     a[i,j]:= 0.0;

               For i:= 1 to 2 Do    {set left half of 'a' matrix equal to d}
                  For j:= 1 to 2 Do
                     a[i,j]:= d[i,j];

               If a[1,1] = 0.0 Then    {exchange rows to allow normalizing}
                  For i:= 1 to 4 Do
                     Begin
                        dummy:= a[1,i];
                        a[1,i]:= a[2,i];
                        a[2,i]:= dummy;
                     End;

              a[1,3]:= 1;           {set identity matrix on right}
              a[2,4]:= 1;

               dummy:= a[1,1];
               For i:= 1 to 4 Do    {normalize first row of a matrix}
                  a[1,i]:= a[1,i] / dummy;
               a[1,1]:= 1;

               dummy:= a[2,1] / a[1,1];
               For i:= 1 to 4 Do    {set corner element of 2nd row to zero}
                  a[2,i]:= a[2,i] - (dummy * a[1,i]);
               a[2,1]:= 0;

               dummy:= a[2,2];
               For i:= 1 to 4 Do    {normalize 2nd row of a matrix on element 2,2}
                  a[2,i]:= a[2,i] / dummy;
               a[2,2]:= 1;

                               {set element 1,2 to zero, completes identity
                                matrix. Inverse matrix is found in right half
                                of a}
               dummy:= a[1,2] / a[2,2];
               For i:= 1 to 4 Do
                  a[1,i]:= a[1,i] - (a[2,i] * dummy);

               For j:= 1 to 2 Do
                  For i:= 3 to 4 Do
                     temp[j,i-2]:= a[j,i];

               d:= temp;
            End;


         Procedure Mult(Var e: Array_2x2;
                       scaler: Float);
            Var
               i,j: Integer;

            Begin
               For i:= 1 to 2 Do
                  For j:= 1 to 2 Do
                     e[i,j]:= e[i,j] * scaler;
            End;

         Begin               {Get_E_Array}
            p[1]:=  transmitter[0].lat;      {latitude of master}
            q[1]:=  transmitter[0].lon;      {longitude of master}
            p[2]:=  transmitter[first].lat;  {latitude of first secondary}
            q[2]:=  transmitter[first].lon;  {longitude of first secondary}
            p[3]:=  transmitter[second].lat; {latitude of second secondary}
            q[3]:=  transmitter[second].lon; {longitude of second secondary}
            For i:= 1 to 3 Do
               Begin
                  e:= Cos(p[i]) * Sin(q[i] - lon);
                  f:= Sin(p[i]) * Cos(lat);
                  f:= f - Sin(lat) * Cos(p[i]) * Cos(q[i] - lon);
                  b[i]:= Arctan(e/f);
                  If f< 0.0 Then
                     b[i]:= b[i] + PI;
                  If b[i] < 0.0 Then
                     b[i]:= b[i] + (2 * PI);
               End;
            d[1,1]:= Cos(b[2]) - Cos(b[1]);
            d[1,2]:= Sin(b[2]) - Sin(b[1]);
            d[2,1]:= Cos(b[3]) - Cos(b[1]);
            d[2,2]:= Sin(b[3]) - Sin(b[1]);

            e_array:= d;
            Inverse(e_array);
            Mult(e_array,-300.0);
         End;     {Get_E_Array}

{This procedure Get_Td_Distance is called to determine the distance between
 two points where only the TD's of one point is known.  Use of this procedure
 is useful to distance to a position (of which the geodetic coordinates are
 known as well as the TD's) from a location where only the TD's are known.
 Another alternative to use of this procedure is to convert the position's
 TD's to a Lat/Lon and call Distance_Azimuth.  This procedure assumes that
 an E array is initialized for the position whose Lat/Lon is known.
 This is done by a call to Get_E_Array. This procedure is passed the TD's
 of the position we need the distance to, as well as the TD's of the position
 we are calculating the distance from.  The procedure returns the distance in
 meters and azimuth in degrees.}
   Procedure Get_Td_Distance(receiver_td,   {td's from the receiver}
                             waypoint_td:   {td's of the waypoint}
                                          Real_Array_1x4;
                             Var distance, azimuth: Float);

      Type
         Array_2x1 = Array[1..2] Of Float;
      Var
        u, r: Array_2x1;
        i: Integer;
        x, y: Float;


      Procedure Mult(e: Array_2x2;    {brief function to multiply two matrices}
                    r: Array_2x1;
                    Var result: Array_2x1);
         Var
            i,j,k: Integer;
            temp: Array_2x1;
         Begin
           For i:= 1 to 2 Do
              temp[i]:= 0.0;

           For i:= 1 to 2 Do
              For j:= 1 to 1 Do
                 For k:= 1 to 2 Do
                    temp[i]:= temp[i] + e[i,k] * r[k];
           result:= temp;
        End;


      Begin       {Procedure Get_Td_Distance}
         r[1]:= receiver_td[2] - waypoint_td[2];
         r[2]:= receiver_td[3] - waypoint_td[3];
         Mult(e_array, r, u);
         x:= u[2]; {distance north}
         y:= u[1]; {distance east}

         distance:= Sqrt(Sqr(x) + Sqr(y));
         azimuth:= Atan(x,y,1);
      End;  {Get_TD_Distances}

{This procedure is called to initialize the j_matrix. The j matrix is
 required to obtain predicted TD's from a given latitude/longitude.
 This procedure assumes that the transmitter records have been properly
 initialized for the chain to be used by a call to the procedure Get_Ref_Data;
 This procedure also assumes the values of the semimajor and semiminor
 axis values have been initialized. This procedure calls Get_Time_Delay to
 initialize the timing matrix from the j matrix. Some default latitude
 longitude is passed to the procedure to initialize the elements of the
 matrix.  These coordinates are passed as values in radians.}
      Procedure Init_J_Matrix(lat, lon: Float);
      Var
         i,j: Integer;
         flattening: Float;
      Begin
         flattening:= (SEMI_MAJOR_AXIS - SEMI_MINOR_AXIS) /
                       SEMI_MAJOR_AXIS;
         m:= 1 + flattening + Sqr(flattening);
         f:= Sqr(flattening)/2;
         j_matrix[0,1]:=   transmitter[0].lat;  {latitude of master}
         j_matrix[0,2]:=   transmitter[0].lon;  {longitude of master}
         j_matrix[1,1]:=   transmitter[1].lat;  {latitude of victor}
         j_matrix[1,2]:=   transmitter[1].lon;  {longitude of victor}
         j_matrix[2,1]:=   transmitter[2].lat;  {latitude of whiskey}
         j_matrix[2,2]:=   transmitter[2].lon;  {longitude of whiskey}
         j_matrix[3,1]:=   transmitter[3].lat;  {latitude of xray}
         j_matrix[3,2]:=   transmitter[3].lon;  {longitude of xray}
         j_matrix[4,1]:=   transmitter[4].lat;  {latitude of yankee}
         j_matrix[4,2]:=   transmitter[4].lon;  {longitude of yankee}
         j_matrix[5,1]:=   transmitter[5].lat;  {latitude of zulu}
         j_matrix[5,2]:=   transmitter[5].lon;  {longitude of zulu}
         j_matrix[6,1]:=   lat;                 {default latitude of user}
         j_matrix[6,2]:=   lon;                 {default longitude of user}

         For i:= 0 to 6 Do
            For j:= 0 to 6 Do
               timing_matrix[i,j]:= 0.0;

         For i:= 1 to 26 Do
            pv[i]:= 0.0;

         For i:= 0 to 6 Do    {initialize timing matrix for user position}
            For j:= 0 To 6 Do
               If j>i Then
                  Get_Timing_Delays(i,j);
      End;    {Init_J_Matrix}

{Procedure Get_Timing_Delays is called to initialize the timing matrix for
 a given LORAN-C chain. This procedure is called from Init_J_Matrix
 as well as from Lat_Lon_To_Td.  This procedure assumes that the transmitter
 record has been properly initialized by a call to Get_Ref_Data and the
 coordinates for earth axis dimensions have been initialized by a
 call to InitXXXXX.}

   Procedure Get_Timing_Delays(first, second: Integer);

      Begin
        pv[3]:= arctan(sin(j_matrix[first,1]) * SEMI_MINOR_AXIS /
                        (cos(j_matrix[first,1]) * SEMI_MAJOR_AXIS));
         pv[4]:= sin(pv[3]);
         pv[5]:= cos(pv[3]);
         pv[6]:= j_matrix[first,2] - j_matrix[second,2];
         pv[3]:= arctan(sin(j_matrix[second,1]) * SEMI_MINOR_AXIS /
                       (cos(j_matrix[second,1]) * SEMI_MAJOR_AXIS));
         pv[7]:= sin(pv[3]);
         pv[8]:= cos(pv[3]);
         pv[9]:= Abs(pv[6]);
         If pv[9] - PI >= 0.0 Then
            pv[10]:= 2 * PI - pv[9]
         Else
            pv[10]:= pv[9];
         pv[11]:= sin(pv[10]);
         pv[12]:= cos(pv[10]);
         pv[13]:= pv[4] * pv[7] + pv[5] * pv[8] * pv[12];
         pv[14]:= Sqrt(Sqr(pv[11] * pv[8]) +
                  Sqr(pv[7] * pv[5] - pv[4] * pv[8] * pv[12]));
         pv[15]:= 1 - Sqr(pv[5] * pv[8] * pv[11] / pv[14]);
         pv[16]:= arctan(pv[14]/Sqrt(1- Sqr(pv[14])));
         pv[17]:= Sqr(pv[16]);
         pv[18]:= m * pv[16] + pv[4] * pv[7] *
                  ((m-1) * pv[14] - f * pv[17] / pv[14]);
         pv[19]:= pv[15] * ((1-m)/2 * (pv[16]+pv[14]*pv[13])+
                 f*pv[17]*pv[13]/pv[14]);
         pv[20]:= -Sqr(pv[4]*pv[7])*f*pv[13]*pv[14];
         pv[21]:= (Sqr(flattening)/16*(pv[13]*pv[14]+pv[16])-
                   f*pv[17]*pv[13]/pv[14]-
                   f/4*pv[14]*Sqr(pv[13])*pv[13])*Sqr(pv[15]);
         pv[22]:= pv[4]*pv[7]*pv[15]*f*(pv[17]/pv[14]+
                  pv[14]*Sqr(pv[13]));
         pv[23]:= (pv[18]+pv[19]+pv[20]+pv[21]+pv[22])*SEMI_MINOR_AXIS*
                   LIGHT_SPEED;
         pv[24]:= pv[23]/1609.344;
         pv[26]:= pv[23]/1000.0;
         If  ((pv[24] - 100) < 0.0) Then
            pv[25]:= 0.510483 / pv[24] - 0.011402 + 0.00176 * pv[24]
         Else
            pv[25]:= 24.0305/pv[24] - 0.40758 + 0.00346776 * pv[24];
         timing_matrix[first,second]:= pv[25]+pv[23]/LIGHT_SPEED;
         timing_matrix[second,first]:= pv[25]+pv[23]/LIGHT_SPEED;
      End;    {Get_Timing_Delays}


   {This procedure Lat_Lon_To_Td is called to convert a Latitude Longitude to
    a set of TD's for a given LORAN-C chain.  This procedure assumes that
    the transmitter record has been properly initialized by a call to
    Get_RefData. It is also assumed that the values needed are initialized by a
    call to InitXXXXX and the j matrix for the LORAN-C chain has been initialized
    by a call to Init_J_Matrix.  The procedure is passed the latitude
    longitude coordinates (in radians) of the position to be converted and it
    returns the TD's for each secondary within the chain being used.}

   Procedure Lat_Lon_To_Td(lat, lon: Float;
                           Var tdp: Real_Array_1x4);
      Var
         i: Integer;

      Begin

      {set up j_matrix with new waypoint lat lon}
         j_matrix[6,1]:= lat;
         j_matrix[6,2]:= lon;


      {using new lat lon set up timing matrix to
       get predicted td's of new point}

         For i:= 0 to 5 Do
            Get_Timing_Delays(i,6);

      {get the predicted td's for this waypoint}
         For i:= 1 to 5 Do
           Begin
              tdp[i]:=
                 transmitter[i].emission_delay
                 + timing_matrix[i,6]     {distance user to secondary}
                 - timing_matrix[6,0];    {distance user to master}
           End;
      End;  {Lat_Lon_To_Td}

      Function Secondary_Ok(secondary: Integer): Boolean;
         Begin
            Secondary_Ok:= transmitter[secondary].use;
         End;

      Function SortTD(td: Float): Integer;
         Var
            i,j: Integer;
         Begin
            j:= 0;
            For i:= 0 to 5 Do
               If transmitter[i].use Then
                  If td >= transmitter[i].coding_delay Then
                  j:= i;
            SortTd:= j;
         End;

   Procedure Display_Error(filename: String);
      Var
         inch: Char;
      Begin
         ClrScr;
         MenuWriteString(4,4,60,'Error encountered while reading reference file');
         MenuWriteString(53,4,10,filename);
         MenuWriteString(4,5,60,'File is required to run program. Correct before restarting program');
         MenuWriteString(4,6,60,'Press any key to return to system');
         CursorOff;
         inch:= Readkey;
         CursorBig;
         Halt;
      End;

   Function Get_Ref_Data(gri: Integer;
                         filename: String;
                         coord_sys: Geodetic): Boolean;
      Var
         ref_file: Text;
         temp_string,
         ref_string: String[255];
         i,dum,ior: Integer;
         found, erc: Boolean;
         inch: Char;
         in_sys: Geodetic;

      Begin
         Assign(ref_file,filename);
         {$I-}
{first test to see if reference file exists. If not halt program}
         Reset(ref_file);
         ior:= IoResult;
         {$I+}
         If ior <> 0 Then
            Display_Error(filename);

{Program made it to here, reference file must exist. Look for chain}
{first make a search string for the desired GRI. make string look like}
{spaceGRIspace This will weed out finding 9960 for 99 etc}

         ref_string:= '';
         Str(gri:4, ref_string);
         temp_string:= ' ';
         temp_string:= Concat(temp_string,ref_string);
         temp_string:= Concat(temp_string,' ');

{Now look for existance of chain information in file}
{read in lines of file until 1) Both a $ and temp_string are found in line or
                             2) End of file is reached
 Boolean variable found will be used to indicated the selected GRI is located}

         found:= False;
{$I-}
         While ((Not Eof(ref_file)) And (Not found)) Do
            Begin
{blank out input string and get new value}
               ref_string:= '';
               Readln(ref_file,ref_string);
{check for error while reading and prompt user to correct if needed}
               ior:= IoResult;
               If ior <> 0 Then
                  Display_Error(filename);
               If ((Pos('$',ref_string) > 0) And
                  (Pos(temp_string,ref_string) > 0)) Then
                  found:= True;
            End;
{$I+}

{By now the file has either been completely read and at EOF or the GRI has been
 found.  Check to see if the GRI was found and if so read in the transmitter
 information}
         If found Then
            Begin
{determine what coordinate system is the positions in}
               If Pos('WGS84',ref_string) > 0 Then
                  in_sys:= WGS84
               Else If Pos('WGS72',ref_string) >0 Then
                  in_sys:= WGS72
               Else
                  in_sys:= NAD27;

               For i:= 0 to 5 Do
                  Begin
                     ref_string:= '';
{$I-}
                     Readln(ref_file,ref_string);
                     ior:= IoResult;
                     If ior <> 0 Then
                        Display_Error(filename);
{$I+}
                     transmitter[i].lat:= 0.0;
                     transmitter[i].lon:= 0.0;
                     transmitter[i].coding_delay:= 0.0;
                     transmitter[i].emission_delay:= 0.0;
                     dum:= 1;
                     StrReadLat(ref_string,dum,dum,transmitter[i].lat,4);
                     StrReadLon(ref_string,dum,dum,transmitter[i].lon,4);
                     StrReadReal(ref_string,dum,dum,transmitter[i].emission_delay,erc);
                     If erc Then
                        Display_Error(filename);
                     StrReadReal(ref_string,dum,dum,transmitter[i].coding_delay,erc);
                     If erc Then
                        Display_Error(filename);

{Set existance flag for transmitter in chain}
                     If transmitter[i].lon <> 0.0 Then
                        transmitter[i].use:= True
                     Else
                        Begin
                           transmitter[i].use:= False;
                           transmitter[i].lat:= 40.0/i;
                           transmitter[i].lon:= -72.0/i;
                        End;

{latitude and longitude was read in as degrees (south/west negative).
 Convert to radians for use in computer}

                     LL_To_Rad(transmitter[i].lat, transmitter[i].lon);
{assign an arbitrary altitude to transmitter location}
                     transmitter[i].alt:= 0.0;

{Convert transmitter location to WGS84 to allow common base for conversion to
 user selected system}
                     Case in_sys Of
                         WGS84:; {Do nothing}
                         NAD83:;
                         NAD27: Nad27_To_Wgs84(transmitter[i].lat,
                                               transmitter[i].lon,
                                               transmitter[i].alt);
                         WGS72: Wgs72_To_Wgs84(transmitter[i].lat,
                                               transmitter[i].lon,
                                               transmitter[i].alt);
                     End;

{Now convert to user selected coordinate system}
                     Case coord_sys Of
                         WGS84:; {Do nothing}
                         NAD83:;
                         NAD27: Wgs84_To_Nad27(transmitter[i].lat,
                                               transmitter[i].lon,
                                               transmitter[i].alt);
                         WGS72: Wgs84_To_Wgs72(transmitter[i].lat,
                                               transmitter[i].lon,
                                               transmitter[i].alt);
                     End;



                  End;  {for i:= 0 to 5 Do}
{set master unusable as secondary}
               transmitter[0].use:= False;
               Close(ref_file);
            End;  {If found}
         Get_Ref_Data:= found;
      End;  {Function Get_Ref_Data}

{This function is passed a meter distance and it converts it to a usecond
 distance based on all seawater path radio signal propagation velocities.
 Procedure assumes InitXXX?? has been called to initialize TPU variable
 LIGHT_SPEED}
      Function Time_Distance(distance: Float): Float;
         Var
            t,
            a0,
            a1,
            a2,
            delta_t: Float;
         Begin
            t:= distance / LIGHT_SPEED;
            If t > 537.0 Then
               Begin
                  a0:= 129.04398;
                  a1:= - 0.40758;
                  a2:=  0.00064576438;
               End
            Else
               Begin
                  a0:= 2.7412979;
                  a1:= -0.011402;
                  a2:= 0.00032774624;
               End;

            delta_t:= a0 / t + a1 + a2 * t;

            Time_distance:= t + delta_t;
         End;  {Function Time_Distance}

{Procedure Distance_Azimuth is called to determine the distance and azimuth
 between two geodetic coordinates on surface of the earth.  The procedure
 is passed two geodetic coordinates in radians. It calculates the
 distance between the two positions in meters (subsequently converted to
 useconds by a call to Time_Distance) and the bearing of position two
 from position 1. This procedure assumes positions passed are in
 radians. Whether they are negative east or west makes no difference as long as
 both are in the same coordinate system.  It is also assumed that the
 procedure InitXXX?? has been called to initialize the TPU variable
 FLATTENING. This procedure calls Function Time_Distance to
 convert meter distance between to positions to usecond distance. This procedure
 is called from Procedure Td_To_Lat_Lon durnig the iterations of solution
 convergence}
      Procedure Distance_Azimuth(lat1, lon1, lat2, lon2: Float;
                                 Var distance, azimuth: Float);
         Var
            phi,
            cos_phi,
            sin_phi,
            cot_phi,
            sin_cos_phi,
            delta_lon,
            abs_delta_lon,
            bj,
            bk,
            tan_bj,
            tan_bk,
            g,
            h,
            c,
            r,
            m,
            term1,
            term2,
            term3,
            term4,
            term5,
            term6,
            term7,
            term8,
            term9,
            term10,
            term11,
            cot_azimuth,
            sq_flattening,
            sq_phi,
            f_f2: Float;

         Begin
            sq_flattening:= Sqr(FLATTENING);
            f_f2:= FLATTENING + sq_flattening;
            delta_lon:= lon1 - lon2;
            abs_delta_lon:= Abs(delta_lon);

            If abs_delta_lon >= PI Then
               abs_delta_lon:= (2 * PI - abs_delta_lon);

{latitudes are always going to be in the 1st-2nd or 3rd-4th quadrants
 depending on north or south lat respectively.  The
 flattening term is a positive number less than 1 so 1 - flattening is
 also a positive number less than 1.  Multiplying the Tan of any number
 by a positive number less than one does not change the quadrant of the
 result.  By Taking the inverse tangent of this result, the angle is
 still in quadrant 1 or 4.  Resolving the quadrant is not necessary as
 we only need to take the Sin or Cos of these angles and the Sin or Cos
 of a negative number > -90 is the same as the Sin or Cos of the
 appropriate angle in quadrant 4.}

            bj:= Arctan(Tan(lat1) * (1 - FLATTENING));

            bk:= Arctan(Tan(lat2) * (1 - FLATTENING));

            g:= Sin(bj) * Sin(bk);
            h:= Cos(bj) * Cos(bk);

            cos_phi:= g + h * Cos(abs_delta_lon);

            term1:= Sin(abs_delta_lon) * Cos(bk);
            term2:= (Sin(bk) * Cos(bj)) - (Sin(bj) * Cos(bk) * Cos(abs_delta_lon));

            sin_phi:= Sqrt(Sqr(term1) + Sqr(term2));
            sin_cos_phi:= sin_phi * cos_phi;

            phi:= Arccos(cos_phi);

            If cos_phi < 0.0 Then
               phi:= PI - phi;

            sq_phi:= Sqr(phi);
            cot_phi:= cos_phi / sin_phi;

            c:= h * Sin(abs_delta_lon) / sin_phi;

            m:= 1 - Sqr(c);

            term3:= (1 + f_f2) * phi;

            term4:= g * (f_f2 * sin_phi -
                         (sq_flattening / 2.0) * (sq_phi / sin_phi));

            term5:= m * ((f_f2 / 2.0 * (phi +  sin_cos_phi)) -
                         (sq_flattening * sq_phi * cot_phi / 2.0));

            term6:= Sqr(g) * (sq_flattening * sin_cos_phi / 2.0);

            term7:= Sqr(m) * (((sq_flattening / 16.0) * (phi + sin_cos_phi)) -
                              (sq_flattening / 2.0 * sq_phi * cot_phi) -
                              (sq_flattening / 8.0 * sin_cos_phi * Sqr(cos_phi)));

            term8:= g * m * ((sq_flattening / 2.0) *
                             (sq_phi / sin_phi + sin_cos_phi * cos_phi));

            term9:= f_f2 * phi;

            term10:= g * ((sq_flattening / 2.0 * sin_phi) +
                          (sq_flattening * sq_phi / sin_phi));

            term11:= m * ((sq_flattening * 1.25 * phi) -
                          (sq_flattening / 4.0 * sin_cos_phi) -
                          (sq_flattening * sq_phi * cot_phi));


            distance:= (term3 + term4 - term5 - term6 + term7 + term8) * SEMIMINOR_AXIS;

            distance:= Time_Distance(distance);

            r:= ((term9 - term10 - term11) * c) + abs_delta_lon;


            cot_azimuth:= (Sin(bk) * Cos(bj) - Cos(r) * Sin(bj) * Cos(bk)) /
                        (Sin(r) * Cos(bk));

            If Abs(cot_azimuth) < 0.000000005 Then
               cot_azimuth:= 0.00000005;

            azimuth:= Arctan(1/cot_azimuth);

            If delta_lon >= 0.0 Then
               If delta_lon >= PI Then
                  If cot_azimuth >= 0.0 Then
                     Begin
                        azimuth:= 2.0 * PI - azimuth;
                        azimuth:= azimuth + PI;
                        azimuth:= azimuth - 2.0 * PI;
                        If azimuth < 0.0 Then
                           azimuth:= azimuth + 2.0 * PI;
                     End
                  Else
                     Begin
                        azimuth:= PI + azimuth;
                        azimuth:= azimuth + PI;
                        azimuth:= azimuth - 2.0 * PI;
                        If azimuth < 0.0 Then
                           azimuth:= azimuth + 2.0 * PI;
                     End
               Else
                  If cot_azimuth >= 0.0 Then
                     Begin
                        azimuth:= azimuth + PI;
                        azimuth:= azimuth - 2.0 * PI;
                        If azimuth < 0.0 Then
                           azimuth:= azimuth + 2.0 * PI;
                     End
                  Else
                     Begin
                        azimuth:= azimuth + PI;
                        azimuth:= azimuth + PI;
                        azimuth:= azimuth - 2.0 * PI;
                        If azimuth < 0.0 Then
                           azimuth:= azimuth + 2.0 * PI;
                     End
            Else
               If delta_lon + PI > 0.0 Then
                  If cot_azimuth >= 0.0 Then
                     Begin
                        azimuth:= 2.0 * PI - azimuth;
                        azimuth:= azimuth + PI;
                        azimuth:= azimuth - 2.0 * PI;
                        If azimuth < 0.0 Then
                           azimuth:= azimuth + 2.0 * PI;
                     End
                  Else
                     Begin
                        azimuth:= PI - azimuth;
                        azimuth:= azimuth + PI;
                        azimuth:= azimuth - 2.0 * PI;
                        If azimuth < 0.0 Then
                           azimuth:= azimuth + 2.0 * PI;
                     End
               Else
                  If cot_azimuth >= 0.0 Then
                     Begin
                        azimuth:= azimuth + PI;
                        azimuth:= azimuth - 2.0 * PI;
                        If azimuth < 0.0 Then
                           azimuth:= azimuth + 2.0 * PI;
                     End
                  Else
                     Begin
                        azimuth:= azimuth + PI;
                        azimuth:= azimuth + PI;
                        azimuth:= azimuth - 2.0 * PI;
                        If azimuth < 0.0 Then
                           azimuth:= azimuth + 2.0 * PI;
                     End;

         End;   {Procedure Distance_Azimuth}

{Procedure Td_To_Lat_Lon is passed two TD's and a seed lat/lon for position
 initialization.  The seed lat/lon is assumed to be in radian coordinates.
 It is also assumed that the unit (TPU) global variable transmitter has been
 initialized for the LORAN-C chain  (GRI) in use and that the TPU variables
 SEMIMAJOR_AXIS, SEMIMINOR_AXIS, SQ_E, and LIGHT_SPEED have been initialized.
 (Procedure InitXXXXX initializes these values). The variable
 transmitter is an array of records.  Each record contains 5 elements. The
 declaration looks like:
             Type
                Transmitter_Rec = Record
                                     lat,  (radians)
                                     lon,  (radians west negative)
                                     alt,  (distance from geodal surface)
                                     coding_delay,  (useconds)
                                     emission_delay (useconds)
                                                    : Real;
                                  End;
                Transmitter_Rec_Array = Array[0..5] Of Transmitter_Rec;
             Var
                transmitter: Transmitter_Rec_Array;

 in the structure transmitter[0] = Master
                  transmitter[1] = Victor
                  transmitter[2] = Whiskey
                  transmitter[3] = Xray
                  transmitter[4] = Yankee
                  transmitter[5] = Zulu

 This procedure calls two other procedures. SortTd is passed the two
 TD's passed to this procedure and its function is to determine which
 secondary they are associated with.  Distance_Azimuth is called to
 determine the distance and azimuth between two positions. The distance
 is returned in useconds (based on speed of light) and the azimuth
 of position 2 from position 1.

 This is an interative procedure which makes closer and closer approximations
 of the position until the difference between two approximations is less than
 a predeclared epsilon (meters) or it stops when a predeclared number of
 iterations has occurred.  If the allowed iterations is used then it is
 assumed that the solution did not properly converge and the returned
 position is questionable at best.  The value of the returned parameter
 good_position is based on this determination}

      Procedure Td_To_Lat_Lon(td1, td2: Float;
                              Var lat, lon: Float;
                              Var good_position: Boolean);
         Var

            a,b,c,
            distance,
            azimuth: Real_Array_1x4;
            delta_lat,
            delta_lon,
            x, y,
            sq_sin_lat,
            temp1,
            temp2,
            t0lon,
            t1lon,
            t2lon:  Float;
            i,count:  Integer;
            first,
            second: Integer;
         Begin
            good_position:= True;
            count:= 0;

{determine which secondary the TD's are from}
            first:= SortTd(td1);
            second:= SortTd(td2);

{convert negative west longitude to Sodano negative east longitude}
            lon:= lon * NEG_ONE;
{convert transmitter radians (west negative) to radians (east  negative)}
            t0lon:= transmitter[0].lon * NEG_ONE;      {longitude master}
            t1lon:= transmitter[first].lon * NEG_ONE;  {longitude secondary 1}
            t2lon:= transmitter[second].lon * NEG_ONE; {longitude secondary 2}
{Repeat until solution converged or number of iterations reached}
            Repeat
{get distance and azimuth between seed position and master}
               Distance_Azimuth(lat, lon,
                                transmitter[0].lat, t0lon,
                                distance[0], azimuth[0]);

{get distance and azimthuth between seed position and secondary 1}
               Distance_Azimuth(lat, lon,
                                transmitter[first].lat,
                                t1lon,
                                distance[first],
                                azimuth[first]);

{get distance and azimuth between seed position and secondary 2}
               Distance_Azimuth(lat, lon,
                                transmitter[second].lat,
                                t2lon,
                                distance[second],
                                azimuth[second]);
{count iterations}
               count:= count + 1;
               a[first]:= Sin(azimuth[first]) - Sin(azimuth[0]);
               b[first]:= Cos(azimuth[first]) - Cos(azimuth[0]);
               c[first]:= (distance[first] - distance[0] -
                       td1 + transmitter[first].emission_delay) *
                      LIGHT_SPEED; {convert usecs distance to meters}

               a[second]:= Sin(azimuth[second]) - Sin(azimuth[0]);
               b[second]:= Cos(azimuth[second]) - Cos(azimuth[0]);
               c[second]:= (distance[second] - distance[0] -
                       td2 + transmitter[second].emission_delay) *
                      LIGHT_SPEED; {convert usecs distance to meters}

               x:= (c[second] * b[first] - c[first] * b[second]) /
                   (a[first] * b[second] - a[second] * b[first]);
               y:= (c[second] * a[first] - c[first] * a[second]) /
                   (b[first] * a[second] - b[second] * a[first]);

               sq_sin_lat:= Sqr(sin(lat));
               temp1:= 1.0 - sq_e * sq_sin_lat;
               temp1:= Sqrt(temp1);
               temp2:= Sqr(temp1) * temp1;


               delta_lat:= y * temp2 / (SEMIMAJOR_AXIS * (1-SQ_E));

               delta_lon:= x * TEMP1 * NEG_ONE /
                               (SEMIMAJOR_AXIS * Cos(lat));
               lat:= lat + delta_lat;
               lon:= lon + delta_lon;

{The following sequence was added by myself maybe not required}

               If Abs(lat) > (PI / 2.0) Then
                  Repeat
                     lat := lat / (PI / 2.0);
                  Until Abs(lat) < (PI / 2.0);


               If Abs(lon) > 2 * PI Then
                  Repeat
                     lon:= lon / (2 * PI);
                  Until Abs(lon) < 2 * PI;

               If lon > PI Then
                  lon:= lon - 2.0 * PI;
               If lon < (0.0 - PI) Then
                  lon:= lon + 2.0 * PI;


            Until ((Abs(x) < EPSILON) And (Abs(y) < EPSILON)) Or (count > 400);

            If count > 200 Then
               good_position:= False;

{convert Sodano negative east longitude to negative west longitude}
            lon:= lon * NEG_ONE;


         End;   {Procedure Td_To_Lat_Lon}

{Procedure InitWgs84 is called to initialize TPU variables to WGS84 values.
 These variables are used in Sodano's iterative algorithm for converting
 LORAN-C TD's to lat lon. These variable are visible only within the TPU
 and are therefore not passed as parameters in the procedure call. This
 procedure must be called before and TD to lat/lon conversions are attempted}
      Procedure InitWgs84;
         VAR
            I: INTEGER;
         Begin
            SEMIMAJOR_AXIS:= 6378136.99999;     {WGS84 numbers in meters}
            SEMIMINOR_AXIS:= 6356790.22236;
            FLATTENING:= 1 - SEMIMINOR_AXIS / SEMIMAJOR_AXIS;
            SQ_E:= 1 - Sqr(SEMIMINOR_AXIS) / Sqr(SEMIMAJOR_AXIS);
            DEGREES_TO_RADIANS:= PI / 180.0;
            RADIANS_TO_DEGREES:= 180.0 / PI;
{these values of semiminor and semimajor axis are used in determining
 TDp of a selected lat/lon and are set to units of useconds}
            SEMI_MINOR_AXIS:= SEMIMINOR_AXIS / LIGHT_SPEED;  {axis in micro seconds}
            SEMI_MAJOR_AXIS:= SEMIMAJOR_AXIS / LIGHT_SPEED;
         End;    {InitWgs84}

{Procedure InitNad83 is called to initialize TPU variables to WGS84 values.
 These variables are used in Sodano's iterative algorithm for converting
 LORAN-C TD's to lat lon. These variable are visible only within the TPU
 and are therefore not passed as parameters in the procedure call. This
 procedure must be called before and TD to lat/lon conversions are attempted}
{Nad83 and Wgs84 values are almost identical so Wgs84 values are used}
      Procedure InitNad83;
         VAR
            I: INTEGER;
         Begin
            SEMIMAJOR_AXIS:= 6378136.99999;     {WGS84 numbers in meters}
            SEMIMINOR_AXIS:= 6356790.22236;
            FLATTENING:= 1 - SEMIMINOR_AXIS / SEMIMAJOR_AXIS;
            SQ_E:= 1 - Sqr(SEMIMINOR_AXIS) / Sqr(SEMIMAJOR_AXIS);
            DEGREES_TO_RADIANS:= PI / 180.0;
            RADIANS_TO_DEGREES:= 180.0 / PI;
{these values of semiminor and semimajor axis are used in determining
 TDp of a selected lat/lon and are set to units of useconds}
            SEMI_MINOR_AXIS:= SEMIMINOR_AXIS / LIGHT_SPEED;  {axis in micro seconds}
            SEMI_MAJOR_AXIS:= SEMIMAJOR_AXIS / LIGHT_SPEED;
         End;    {InitNad83}

{Procedure InitNAD27 is called to initialize TPU variables to NAD27 values.
 These variables are used in Sodano's iterative algorithm for converting
 LORAN-C TD's to lat lon. These variable are visible only within the TPU
 and are therefore not passed as parameters in the procedure call. This
 procedure must be called before and TD to lat/lon conversions are attempted}
      Procedure InitNAD27;
         VAR
            I: INTEGER;
         Begin
            SEMIMAJOR_AXIS:= 6378206.4;     {NAD27 numbers in meters}
            SEMIMINOR_AXIS:= 6356583.8;
            FLATTENING:= 1 - SEMIMINOR_AXIS / SEMIMAJOR_AXIS;
            SQ_E:= 1 - Sqr(SEMIMINOR_AXIS) / Sqr(SEMIMAJOR_AXIS);
            DEGREES_TO_RADIANS:= PI / 180.0;
            RADIANS_TO_DEGREES:= 180.0 / PI;
{these values of semiminor and semimajor axis are used in determining
 TDp of a selected lat/lon and are set to units of useconds}
            SEMI_MINOR_AXIS:= SEMIMINOR_AXIS / LIGHT_SPEED;
            SEMI_MAJOR_AXIS:= SEMIMAJOR_AXIS / LIGHT_SPEED;
         End;    {InitNad27}

{Procedure InitWGS72 is called to initialize TPU variables to WGS72 values.
 These variables are used in Sodano's iterative algorithm for converting
 LORAN-C TD's to lat lon. These variable are visible only within the TPU
 and are therefore not passed as parameters in the procedure call. This
 procedure must be called before and TD to lat/lon conversions are attempted}
      Procedure InitWgs72;
         VAR
            I: INTEGER;
         Begin
            SEMIMAJOR_AXIS:= 6378135.0;     {WGS72 numbers}
            SEMIMINOR_AXIS:= 6356750.52;
            FLATTENING:= 1 - SEMIMINOR_AXIS / SEMIMAJOR_AXIS;
            SQ_E:= 1 - Sqr(SEMIMINOR_AXIS) / Sqr(SEMIMAJOR_AXIS);
            DEGREES_TO_RADIANS:= PI / 180.0;
            RADIANS_TO_DEGREES:= 180.0 / PI;
{these values of semiminor and semimajor axis are used in determining
 TDp of a selected lat/lon and are set to units of useconds}
            SEMI_MINOR_AXIS:= SEMIMINOR_AXIS / LIGHT_SPEED;
            SEMI_MAJOR_AXIS:= SEMIMAJOR_AXIS / LIGHT_SPEED;
         End;    {InitWgs72}

   End.