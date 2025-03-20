Unit Locates;
{$M 4000,0,655330}
   Interface
   Uses CRT, Menus, Math, Coord1, Coord2, Types, AtScrn, Flt, Coord_Gb, RB;

   Procedure Locate(Var user: User_Rec);
   Procedure Change_Chain(Var user: User_Rec); {have user change loran-c chain}
   Procedure Change_Distances(Var user: User_Rec); {have user select units for distance display}
   Procedure Change_LL(Var user: User_Rec); {have user select display mode of Lat/Lon}
   Procedure Change_Geo(Var user: User_Rec);

   Implementation



{following procedure allows user to change loran-c chain selected. procedure
 verifies chian is valid and reinits library unit records with calls to
 Get_Ref_Data and Init_J_Matrix}

   Procedure Change_Chain(Var user: User_Rec); {have user change loran-c chain}
      Var
         gri: Integer;
         ok: Boolean;
         inch: Char;
      Begin
         Repeat
            ClrScr;
            gri:= user.gri;
            MenuWriteString(2,2,60,'Input GRI of new LORAN-C chain or');
            MenuWriteString(2,3,60,'press enter to use current      LORAN-C chain');
            MenuWriteInteger(29,3,4,gri);
            MenuReadInteger(53,3,10,gri);
            ok:= Get_Ref_Data(gri, 'chain.inf', user.coord_sys);
            If Not ok Then
            Begin
               MenuWriteString(2,5,60,'LORAN-C chain      does not exist in file. Select new GRI');
               MenuWriteInteger(16,5,4,gri);
               MenuWriteString(2,6,60,'Press ''L'' to list available LORAN-C chains or');
               MenuWriteString(2,7,60,'Press any other key to re-enter new GRI');
               CursorOff;
               inch:= ReadKey;
               CursorBig;
               If (inch = 'l') Or (inch = 'L') Then
                  ShowGri;
            End;
         Until ok;
         user.gri:= gri;
         Init_J_Matrix(user.lat1, user.lon1);
         Lat_Lon_to_Td(user.lat1, user.lon1, user.td2);
         Init_J_Matrix(user.lat, user.lon);
         Lat_Lon_to_Td(user.lat, user.lon, user.td);
      End;

{following procedure allows user to select different units for displaying/inputing
 distances}

   Procedure Change_Distances(Var user: User_Rec); {have user select units for distance display}
      Var
         inch: Char;
         t_length: Length_Type;
         i: Integer;
      Begin
         ClrScr;
         MenuWriteString(2,2,60,'Select new units for display of distance');
         MenuWriteString(2,3,60,'Or press <enter> to accept current value indicated');
         MenuWriteString(2,6,60,'1 => Display distance in');
         MenuWriteString(2,7,60,'2 => Display distance in');
         MenuWriteString(2,8,60,'3 => Display distance in');
         MenuWriteString(2,9,60,'4 => Display distance in');
         For t_length:= foot To nm Do
            MenuWriteString(28,6+Ord(t_length),20,Units_String(t_length));
         MenuWriteString(43,6+Ord(user.length),4,'<===');

         CursorOff;
         Inch:= ReadKey;
         CursorBig;
         Case inch Of
			  '1': user.length:= foot;
           '2': user.length:= yard;
			  '3': user.length:= meter;
           '4': user.length:= nm;
           Else ;
         End;
      End;

{following procedure allows user to select different modes of displaying/inputting
 lat/lon coordinate}

   Procedure Change_LL(Var user: User_Rec); {have user select display mode of Lat/Lon}
      Var
         inch: Char;
         i: Integer;
      Begin
         ClrScr;
         MenuWriteString(2,2,60,'Select new display format for Lat/Lon coordinates');
         MenuWriteString(2,3,60,'Or press <enter> to accept current value indicated');
         MenuWriteString(2,6,60,'1 => Display Lat/Lon as');
         MenuWriteString(2,7,60,'2 => Display Lat/Lon as');
         MenuWriteString(2,8,60,'3 => Display Lat/Lon as');
         MenuWriteString(2,9,60,'4 => Display Lat/Lon as');
         For i:= 1 to 4 Do
            MenuWriteString(28,5+i,50,Format_String(i));
         MenuWriteString(47,5+user.mode,4,'<===');
         CursorOff;
         inch:= ReadKey;
         CursorBig;
         Case inch Of
            '1': user.mode:= 1;
            '2': user.mode:= 2;
            '3': user.mode:= 3;
            '4': user.mode:= 4;
            else;
         end;
      End;

{following procedure allows user to select different geodetic coordinate systems
 for the input/display of lat/lon.  Procedure calls Change_Coord which in turn calls
 and Init_J_Matrix  and InitXXX?? to reinitialize Coord.tpu variables used in program
 to match user selected coordinate system}

   Procedure Change_Geo(Var user: User_Rec);
      Var
         inch: Char;
         t_geo: Geodetic;
      Begin
         ClrScr;
         MenuWriteString(2,2,60,'Select new geodetic coordinate system');
         MenuWriteString(2,3,60,'Or press <enter> to accept current value indicated');
         MenuWriteString(2,6,60,'1 => Use coordinate system ');
         MenuWriteString(2,7,60,'2 => Use coordinate system ');
         MenuWriteString(2,8,60,'3 => Use coordinate system ');
         MenuWriteString(2,9,60,'4 => Use coordinate system ');
         For t_geo:= NAD27 to WGS84 Do
            MenuWriteString(30,6+Ord(t_geo),6,Geodetic_String(t_geo));
         MenuWriteString(38,6+Ord(user.coord_sys),4,'<==');

         CursorOff;
         inch:= ReadKey;
         CursorBig;
         Case inch Of
            '1': Change_Coord(NAD27, user);
            '2': Change_Coord(WGS72, user);
            '3': Change_Coord(NAD83, user);
            '4': Change_Coord(WGS84, user);
            Else;
         End;
         Init_J_Matrix(user.lat, user.lon);
      End;

{following procedure prompts user what to do when asked to input positions in lat/lon}

   Procedure HelpLL(user: User_Rec);
      Var
         inch: Char;
      Begin
         ClrScr;
         MenuWriteString(2,1,60,'   Range/Bearing using Lat/Lon positions     HELP SCREEN');
         MenuWriteString(2,4,60,'Press 1 to input one known position using Lat/Lon');
			MenuWriteString(2,5,60,'        coordinates and a range and bearing to an unknown second position.');
         MenuWriteString(2,6,60,'        Program will calculate Lat/Lon coordinates of second position');
         MenuWriteString(2,8,60,'Press 2 to input two known positions using Lat/Lon');
         MenuWriteString(2,9,20,'        coordinates. Program will calculate the range and bearing');
			MenuWriteString(3,10,20,'       from position 1 to position 2');
         MenuWriteString(2,12,20,'Press 3 to Change the geodetic coordinate system of Lat/Lon positions');
         MenuWriteString(2,13,20,'Press 4 to Change the display format of Latitude and Longitude coordinates');
         MenuWriteString(2,14,20,'Press 5 to Change units used to display distance');
         MenuWriteString(2,15,60,'Press H to Display this HELP screen');
         MenuWriteString(2,16,60,'Press R to Return to the Range/Bearing  MENU');
         MenuWriteString(2,18,60,'Press any key to continue with program');
         CursorOff;
         inch:= ReadKey;
         CursorBig;
      End;   {HelpLL}

{following procedure is called to prompt user how to respond to screen for
 inputting positions in TD coordinates}

   Procedure HelpTD(user: User_Rec);
      Var
         inch: Char;
      Begin
         ClrScr;
         MenuWriteString(2,1,60,'    Range/Bearing using TD positions      HELP SCREEN');
         MenuWriteString(2,4,60,'Press 1 to input one known position using LORAN-C');
			MenuWriteString(2,5,60,'        coordinates and a range and bearing to an unknown second position.');
         MenuWriteString(2,6,60,'        Program will calculate LORAN-C coordinates of second position');
         MenuWriteString(2,8,60,'Press 2 to input two known positions using LORAN-C');
         MenuWriteString(2,9,20,'        coordinates. Program will calculate the range and bearing');
			MenuWriteString(3,10,20,'       from position 1 to position 2');
         MenuWriteString(2,12,20,'Press 3 to Select a new LORAN-C chain');
         MenuWriteString(2,13,20,'Press 4 to Change units used to display distance');
         MenuWriteString(2,15,60,'Press H to Display this HELP screen');
         MenuWriteString(2,16,60,'Press R to Return to the Range/Bearing  MENU');
         MenuWriteString(2,18,60,'Press any key to continue with program');
         CursorOff;
         inch:= ReadKey;
         CursorBig;
      End;  {HelpTD}




{following procedure is called to input first or second position using lat/lon
 coordinates. Procedure is passed lat/lon in radians, the line number it is
 supposed to read input from and a string indicating first or second position'}

   Procedure InLL(Var lat, lon: Float; line: Integer; instr: String; user: User_Rec);
      Var
         inch: Char;
      Begin
         inch:= #0;
         Repeat
            LL_to_Deg(lat, lon);  {change to degrees for display}
            Gotoxy(4,line+3);
            Write('                                                               ');
            Gotoxy(2,line);
            Write('Input coordinates of ',instr,' position  LATITUDE                         ');
            Gotoxy(2,line+1);
            Write('                                      LONGITUDE                        ');
            MenuReadLat(55,line,24,lat,4); {use only mode 4}
            MenuWriteLat(55,line,24,lat,user.mode);
            MenuReadLon(55,line+1,24,lon,4); {use mode 4 only}
            MenuWriteLon(55,line+1,24,lon,user.mode);
            MenuWriteString(2,line+2,60,'Is this position correct? (Y/N) ');
            CursorOff;
            inch:= ReadKey;
            CursorBig;
            MenuWriteString(2,line+2,60,'                                ');
            LL_to_Rad(lat, lon);  {Change back to radians}
         Until (inch = 'y') Or (inch = 'Y');
         Gotoxy(2,line+2);
         Write('                                       ');
      End;   {InLL}


{following procedure is called to input a position in TD coordinates. It is
 passed the default values of the TDs being read, the line number the TDs
 are to read from as well as a string indicating whether this is the first
 or second position. procedure checks to make sure TDs are valid and both
 TDs are not from same secondary}

   Procedure InTD(Var td1, td2: Float; line: Integer; instr: String;
                  user: User_Rec);
      Var
         i, first, second: Integer;
         ok: Boolean;
         inch: Char;
      Begin
         Repeat
            ok:= True;
            Gotoxy(2,line);
            Write('Input LORAN-C coordinates of ',instr,' position                                ');
            MenuReadReal(50,line,10,user.decimals,td1);
            Gotoxy(4,line+3);
            Write('                                                               ');
            first:= SortTd(td1);
            MenuWriteString(65,line,7,Secondary_String(first));

            MenuReadReal(50,line+1,10,user.decimals,td2);
            second:= SortTd(td2);
            MenuWriteString(65,line+1,7,Secondary_String(second));

            If second = first then
               Begin
                  ok:= False;
                  Gotoxy(4,line+3);
                  Write('Both TD''s can not be from same secondary. Reenter both TD''s');
               End
            Else
               Begin
                  Gotoxy(4,line+3);
                  Write('                                                             ');
                  Gotoxy(4,line+3);
                  Write('Is this entry correct (Y/N) ');
                  CursorOff;
                  inch:= ReadKey;
                  CursorBig;
                  If (inch = 'y') Or (inch = 'Y') Then
                    ok:= True
                  Else
                     ok:= False;
               End;

         Until ok;
         Gotoxy(4,line+3);
         Write('                                                             ');
      End;   {InTD}

{following procedure is a generic procedure for input of range or bearing.
 User prompt of what is being requested is passed as instr procedure gives back
 bearing in radians and range in meters}

   Procedure InRB(Var default: Float; line: Integer; instr: String; user: User_Rec);
      Var
         az: Boolean;
         inch: Char;
      Begin
         Repeat
            az:= True;
            Gotoxy(2,line);
            Write('Input ',instr,' from position 1 to position 2                               ');
            Gotoxy(63,line);
            If instr = 'range' Then
               Begin
                  Meters_to_User(default, user);
                  az:= False;
                  Write(Units_String(user.length));
               End
            Else
               Begin
                  az:= True;
                  Write('degrees');
                  default:= default * 180.0 / PI;  {change to degrees}
               End;
            MenuReadReal(50,line,10,user.decimals,default);
            If az Then
               default:= default * DEGREES_TO_RADIANS  {change to radians}
            Else
               User_to_Meters(default, user);  {change to meters}
            MenuWriteString(2,line+2,60,'Is above information correct? (Y/N) ');
            CursorOff;
            inch:= Readkey;
            CursorBig;
         Until (inch = 'y') Or (inch = 'Y');
         MenuWriteString(2,line+2,60,'                                       ');
      End;   {InRB}

{following procedure is called to output to screen the range and bearing
 calculated by TwoTD and TwoLL.  Range is passed as meters and bearing is
 passed as radians}

   Procedure OutRB(user: User_Rec);
      Begin
         user.azimuth:= user.azimuth * 180.0 / PI;  {convert to degrees}
         Meters_to_User(user.range, user);          {convert to user units}

         MenuWriteString(2,13,60,'Range and bearing of position 2 from position 1 is:');
         Gotoxy(2,14);
         Write(user.range:12:user.decimals,'  ');
         Write(Units_String(user.length));
         Write('   bearing ',user.azimuth:12:user.decimals,'  degrees');
         {no need to change back to radians or units because user not passed in as a VAR}
      End;

{following procedure is called from InTD or Inll to prompt user that the
 coordinates input are close tio dateline and the unknown position may
 be on the other dised of the dateline.  Algorithms do not account
 properly for dateline crossing}
   Procedure Out_Suspect(line: Integer);
      Begin
         MenuWriteString(2,line,60,'The two positions may be on opposite sides of the International ');
         MenuWriteString(2,line+1,60,'Date line.  Results are suspect in this case');
      End;

{following procedure is called from InTD to prompt user to input two lat/lon
 coordinates and procedure calculates range and bearing from position1
 to position 2}

   Procedure Out_Large_Delta(line: Integer);
      Begin
         MenuWriteString(2,line,60,'The two positions are separated by more than 90 degrees in either ');
         MenuWriteString(2,line+1,60,'Latitude or Longitude.  This program does work with position ');
         MenuWriteString(2,line+2,60,'differences of this magnitude. ');
      End;



{following procedure is called from procedure locate when user wants to input
 one position coordinates in TDs and a range/bearing to second position. This
 procedure calls for the input and outputs TD coordinates of second position.
 Procedure converts input Tds to lat/lon and does calculations in lat/lon. Converts
 answer lat lon back into TD coordinates for user}

    Procedure OneTD(Var user: User_Rec); {input one set of TD's and a range bearing}
       Var
          good: Boolean;
          i: Integer;
          lat, lon, alt: Float;
          temp: String;
          td: Real_Array_1x4;
          inch: Char;
       Begin
          ClrScr;
          Repeat
             td:= user.td;
             good:= True;
             MenuWriteString(2,2,60,'Approximate location of work area            Latitude');
             MenuWriteString(2,3,60,'                                             Longitude');
             MenuWriteString(2,3,40,'(Input position in       coordinates)');
             MenuWriteString(21,3,5,Geodetic_String(user.coord_sys));
             Repeat
                lat:= user.lat;
                lon:= user.lon;
                alt:= user.altitude;
                LL_to_Deg(lat, lon);  {convert to degrees}
                MenuReadLat(58,2,22,lat,4); {use only mode 4}
                MenuWriteLat(58,2,22,lat,user.mode);
                MenuReadLon(58,3,22,lon,4); {use only mode 4}
                MenuWriteLon(58,3,22,lon,user.mode);
                MenuWriteString(2,5,60,'Is above position correct?  Y/N');
                CursorOff;
                inch:= ReadKey;
                CursorBig;
                MenuWriteString(2,5,60,'                               ');
             Until (inch = 'y') Or (inch = 'Y');
             MenuWriteString(2,5,60,' ');
             LL_to_Rad(lat, lon);    {change to radians}
             Init_J_Matrix(lat, lon);
             Lat_Lon_to_Td(lat, lon, user.td);
             MenuWriteString(2,5,60,'Input coordinates of positions using       LORAN-C chain');
             Gotoxy(39,5);
             Write(user.gri:4);

             MenuWriteString(2,6,60,'                                                    TD       Secondary     ');
             InTD(td[user.first], td[user.second], 7, 'first ', user);
             MenuWriteString(2,11,60,'         VERIFYING WORK AREA POSITION');
             Td_to_Lat_Lon(td[user.first], td[user.second], lat,
                           lon, good);
             If Not good Then
                MenuWriteString(2,11,60,'Work area position does not approximate position of TD''s. Renter')
             Else
                MenuWriteString(2,11,60,' ');
          Until good;

          user.lat:= lat;
          user.lon:= lon;
          user.altitude:= alt;
          Init_J_Matrix(user.lat, user.lon);
          Lat_Lon_to_Td(user.lat, user.lon, user.td);

          InRB(user.range, 10, 'range',user);
          InRB(user.azimuth,11, 'bearing',user);

          If Range_Ok(user.range) Then
             Begin
                If RB_Suspect(user.lon, user.azimuth) Then
                   Out_Suspect(13);
                RB_LL(user.lat, user.lon, user.lat1, user.lon1,
                      user.range, user.azimuth);
                Lat_Lon_to_TD(user.lat1, user.lon1, user.td2);

                Gotoxy(2,16);
                Write(user.gri:4,' LORAN-C chain coordinates for second position are: ');
                Gotoxy(6,18);
                For i:= 1 to 5 Do
                   If Secondary_Ok(i) Then
                      Begin
                         Case i Of
                            1: temp:= 'Victor         ';
                            2: temp:= 'Whiskey        ';
                            3: temp:= 'Xray           ';
                            4: temp:= 'Yankee         ';
                            5: temp:= 'Zulu              ';
                         End;
                         Write(temp);
                      End;
                   Gotoxy(2,19);
                   For i:= 1 to 5 Do
                      If Secondary_Ok(i) Then
                         Write(user.td2[i]:12:user.decimals,'   ');
             End
          Else
             Out_Large_Delta(14);
       End;    {OneTD}

{following procedure prompts user to input two positions in LORAn-C coordinates.
 procedure returns range and bearing of second from first}

   Procedure TwoTD(Var user: User_Rec);
      Var
         good: Boolean;
         i: Integer;
         lat, lon, alt: Float;
         td: Real_Array_1x4;
         inch: Char;
      Begin
         ClrScr;
         Repeat
            MenuWriteString(2,2,60,'Approximate location of work area            Latitude');
            MenuWriteString(2,3,60,'                                             Longitude');
            MenuWriteString(2,3,40,' (Input position in       coordinates)');
            MenuWriteString(22,3,5,Geodetic_String(user.coord_sys));
            td:= user.td;
            good:= True;
            Repeat
               lat:= user.lat;
               lon:= user.lon;
               alt:= user.altitude;
               LL_to_Deg(lat, lon);  {convert to degrees}
               MenuReadLat(58,2,24,lat,4); {use only mode 4}
               MenuWriteLat(58,2,24,lat,user.mode);
               MenuReadLon(58,3,24,lon,4); {use only mode 4}
               MenuWriteLon(58,3,24,lon,user.mode);
               MenuWriteString(2,5,60,'Is above position correct?  (Y/N)');
               CursorOff;
               inch:= ReadKey;
               CursorBig;
               MenuWriteString(2,5,60,'                                    ');
            Until (inch = 'y') Or (inch = 'Y');
            MenuWriteString(2,5,60,' ');
            LL_to_Rad(lat, lon);    {change to radians}
            Init_J_Matrix(lat, lon);
            Lat_Lon_to_Td(lat, lon, td);
            MenuWriteString(2,5,60,'Input coordinates of positions using       LORAN-C chain');
            Gotoxy(39,5);
            Write(user.gri:4);
                   MenuWriteString(2,6,60,'                                                    TD       Secondary     ');
            InTD(td[user.first], td[user.second], 7, 'first ', user);
            MenuWriteString(2,10,60,'         VERIFYING WORK AREA POSITION');
            Td_to_Lat_Lon(td[user.first], td[user.second], lat,
                          lon, good);
            If Not good Then
               MenuWriteString(2,10,60,'Work area position does not approximate position of TD''s. Renter')
            Else
               MenuWriteString(2,10,60,' ');
         Until good;
         user.lat:= lat;
         user.lon:= lon;
         user.altitude:= alt;
         Init_J_Matrix(user.lat, user.lon);
         Lat_Lon_to_Td(user.lat, user.lon, user.td);
         td:= user.td;
         Repeat
            InTD(td[user.first], td[user.second], 10, 'second', user);
            user.lat1:= user.lat;
            user.lon1:= user.lon;
            MenuWriteString(2,13,60,'         VERIFYING');
            Td_to_Lat_Lon(td[user.first], td[user.second], user.lat1,
                          user.lon1, good);
            If Not good Then
               MenuWriteString(2,13,60,'Position 2 outside range of program ability. Renter')
            Else
               MenuWriteString(2,13,60,' ');
         Until good;
         Init_J_Matrix(user.lat1, user.lon1);
         Lat_Lon_to_Td(user.lat1, user.lon1, user.td2);
         If Delta_Ok(user.lat, user.lon, user.lat1, user.lon1) Then
            Begin
               LL_RB(user.lat, user.lon, user.lat1, user.lon1, user.range, user.azimuth);
               OutRB(user);
            End
         Else
            Out_Large_Delta(14);
      End;   {TwoTD}

   Procedure ActTDMenu(Var user: User_Rec; Var inch: Char);
      Var
         inc: Char;
      Begin
         CursorOff;
         inch:= ReadKey;
         CursorBig;
         Case inch Of
            '1': OneTD(user);
            '2': TwoTD(user);
            '3': Change_Chain(user);
            '4': Change_Distances(user);
            'h','H': HelpTD(user);
            'r','R': inch:= #0;
            Else;
         End;
         If (inch = '1') Or (inch = '2') Then
            Begin
               MenuWriteString(2,21,60,'Press any key to continue with program');
               CursorOff;
               inc:= ReadKey;
               CursorBig;
            End;
      End;  {ActTDMenu}


   Procedure DisplayTDMenu;
      Begin
         ClrScr;
			MenuWriteString(2,1,60,'      Menu to input TD positions for Range and Bearing');
         MenuWriteString(2,4,60,'Select desired function');
			MenuWriteString(2,6,60,'1 => Input 1 position and a range/bearing. Calculate second position');
         MenuWriteString(2,7,60,'2 => Input 2 positions and calculate range/bearing between them');
         MenuWriteString(2,8,60,'3 => Change GRI of LORAN-C chain');
         MenuWriteString(2,9,60,'4 => Change units for display of distances');
         MenuWriteString(2,11,60,'H => Help');
         MenuWriteString(2,12,60,'R => Return to Range and Bearing Menu');
      End;  {DisplayTDMenu}

   Procedure Input_Td(Var user:User_Rec); {have user input positions as TD's}
      Var
         inch: Char;
         lat, lon, alt: Float;

      Begin  {Input_TD}
         Repeat
            DisplayTDMenu;
            ActTDMenu(user, inch);
         Until inch = #0;
      End;   {Input _TD}

   Procedure TwoLL(Var user: User_Rec);
      Begin
         ClrScr;
         Gotoxy(2,3);
         Write('Input positions using       Latitude/Longitude coordinates');
         MenuWriteString(24,3,5,Geodetic_String(user.coord_sys));
         InLL(user.lat, user.lon, 7, 'first ',user);
         InLL(user.lat1, user.lon1, 10, 'second',user);
         If Delta_Ok(user.lat, user.lon, user.lat1, user.lon1) Then
            Begin
               LL_RB(user.lat,user.lon,user.lat1,user.lon1,user.range,user.azimuth);
               OutRB(user);
            End
         Else
            Out_Large_Delta(14);
         Init_J_Matrix(user.lat1, user.lon1);
         Lat_Lon_to_Td(user.lat1, user.lon1, user.td2);
         Init_J_Matrix(user.lat, user.lon);
         Lat_Lon_to_Td(user.lat, user.lon, user.td);
      End;   {TwoLL}

{following procedure prompts user to input one lat/lon coordinate with a range and
 bearing to second position. Procedure calculates lat/lon coordinates of second
 position}

   Procedure OneLL(Var user: User_Rec);
      Begin
         ClrScr;
         Gotoxy(2,3);
         Write('Input positions using       Latitude/Longitude coordinates');
         MenuWriteString(24,3,5,Geodetic_String(user.coord_sys));
         InLL(user.lat, user.lon, 7, 'first ',user);
         InRB(user.range, 10, 'range', user);
         InRB(user.azimuth, 11, 'bearing', user);
         RB_LL(user.lat, user.lon, user.lat1, user.lon1, user.range, user.azimuth);
         If Range_Ok(user.range) Then
            Begin
               If RB_Suspect(user.lon, user.azimuth) Then
                  Out_Suspect(13);
               MenuWriteString(2,16,60,'Lat/Lon coordinates for second position are                        LATITUDE');
               MenuWriteString(2,17,60,'                                                                   LONGITUDE');
               LL_to_Deg(user.lat1, user.lon1);
               MenuWriteLat(47,16,20,user.lat1,user.mode);
               MenuWriteLon(47,17,20,user.lon1,user.mode);
               LL_to_Rad(user.lat1, user.lon1);
            End   {If Range_Ok}
         Else
            Out_Large_Delta(14);
         Init_J_Matrix(user.lat1, user.lon1);
         Lat_Lon_to_Td(user.lat1, user.lon1, user.td2);
         Init_J_Matrix(user.lat, user.lon);
         Lat_Lon_to_Td(user.lat, user.lon, user.td);

      End;   {OneLL}


   Procedure ActLLMenu(Var user: User_Rec; Var inch: Char);
      Var
         inc: Char;
      Begin
         CursorOff;
         inch:= ReadKey;
         CursorBig;
         ClrScr;
         Case inch Of
            '1': OneLL(user);            {one position and range/bearing}
            '2': TwoLL(user);            {Input two positions}
            '3': Change_Geo(user);       {change geodetic coordinate systems}
            '4': Change_Distances(user); {change units for distances}
            '5': Change_LL(user);        {change loran-c chain}
            'r','R': inch:= #0;          {return to main locate menu}
            'h','H': HelpLL(user);


            Else;
         End;  {Case statement}

         If (inch = '1') Or (inch = '2') Then
            Begin
               MenuWriteString(2,18,60,'Positions shown are       coordinates');
               MenuWriteString(22,18,5,Geodetic_String(user.coord_sys));
               MenuWriteString(2,19,60,'Distances shown are in ');
               MenuWriteString(25,19,14,Units_String(user.length));
               MenuWriteString(2,21,60,'Press any key to continue');
               CursorOff;
               inc:= ReadKey;
               CursorBig;
            End;

      End;  {ActLLMenu}


      Procedure DisplayLLMenu;
         Begin
            ClrScr;
				MenuWriteString(2,1,60,'      Menu to input Lat/Lon positions for Range and Bearing');
            MenuWriteString(2,4,60,'Select desired function');
				MenuWriteString(2,6,60,'1 => Input 1 position and a range/bearing. Calculate second position');
            MenuWriteString(2,7,60,'2 => Input 2 positions and calculate range/bearing between them');
            MenuWriteString(2,8,60,'3 => Change Geodetic coordinate system of Lat/Lon input/display');
            MenuWriteString(2,9,60,'4 => Change units for display of distances');
            MenuWriteString(2,10,60,'5 => Change input/display format of Lat/Lon coordinates');
            MenuWriteString(2,12,60,'H => Help');
            MenuWriteString(2,13,60,'R => Return to Range and Bearing Menu');
         End;  {DisplayLLMenu}

   Procedure Input_LL(Var user: User_Rec); {have user input positions as lat/lon}
      Var
         inch: Char;
      Begin  {Input_LL}
         Repeat
            DisplayLLMenu;
            ActLLMenu(user, inch);
         Until inch = #0;
      End;   {InputLL}

   Procedure HelpLocate;
      Var
         inch: Char;
      Begin
         ClrScr;
         MenuWriteString(2,1,60,'   Range and Bearing    MAIN HELP SCREEN');
			MenuWriteString(2,4,60,'Press 1 to do range/bearing calculations using TD''s as positions');
			MenuWriteString(2,5,60,'Press 2 to do range bearing calculations using Lat/Lon as positions');
         MenuWriteString(2,6,60,'Press 3 to Select a new LORAN-C chain');
         MenuWriteString(2,7,60,'Press 4 to List the LORAN-C chains available on disk');
         MenuWriteString(2,8,60,'Press 5 to Change units used to display distance');
         MenuWriteString(2,9,60,'Press 6 to Change the display format of Latitude and Longitude coordinates');
         MenuWriteString(2,10,60,'Press H to Display this HELP screen');
         MenuWriteString(2,11,60,'Press R to return to the MAIN MENU');
         MenuWriteString(2,13,60,'Press any key to continue with program');
         CursorOff;
         inch:= ReadKey;
         CursorBig;
      End;


   Procedure Locate(Var user: User_Rec);
      Var
         inch: Char;
      Begin
         Repeat
            ClrScr;
            MenuWriteString(2,1,60,'            Determine Range and Bearing Menu');
            MenuWriteString(2,3,60,'Select desired function');
            MenuWriteString(2,5,60,'1 - Input/Display positions as TD''s');
            MenuWriteString(2,6,60,'2 - Input/Display positions as Lat/Lon');
            MenuWriteString(2,7,60,'3 - Change LORAN-C chain from ');
            MenuWriteInteger(32,7,4,user.gri);
            MenuWriteString(2,8,60,'4 - List GRI of chains available on disk');
            MenuWriteString(2,9,60,'5 - Display distances in other than ');
            MenuWriteString(38,9,14,Units_String(user.length));
            MenuWriteString(2,10,60,'6 - Display Lat/Lon as other than ');
            MenuWriteString(38,10,20,Format_String(user.mode));
            MenuWriteString(2,12,60,'H - Help');
            MenuWriteString(2,13,60,'R - Return to MAIN MENU');
            CursorOff;
            inch:= ReadKey;
            CursorBig;
            Case inch of
               '1': Input_Td(user); {have user input positions as TD's}
               '2': Input_LL(user); {have user input positions as lat/lon}
               '3': Change_Chain(user); {have user change loran-c chain}
               '4': ShowGri;
               '5': Change_Distances(user); {have user select units for distance display}
               '6': Change_LL(user); {have user select display mode of Lat/Lon}
               'h','H': HelpLocate;
               'r','R': inch:= 'R';
            End;
         Until inch = 'R';
      End;   {Locate}
   End.  {Unit Locates}