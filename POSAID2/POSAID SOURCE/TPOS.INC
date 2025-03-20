Procedure Tpos(Var user: User_Rec);

   Var
      inch: Char;
      fileok: Boolean;
      i,j: Integer;
      dummy1,
      dummy2,
      dummy3,
      degrees_to_radians: Float;
      temp: Array[0..5] Of String;


{following procedure gets input from user. lat lon is passed both ways as
 radians}

   Procedure Get_LL_Input(Var user: User_Rec);
      Var
         inch: Char;
      Begin
         ClrScr;
         LL_to_Deg(user.lat, user.lon);   {convert to degrees}
         Repeat
            MenuWriteString(4,4,60,'Latitude      [                 ] ');
            MenuWriteString(4,5,60,'Longitude     [                 ] ');
            MenuWriteLat(19,4,14,user.lat,user.mode);
            MenuWriteLon(19,5,14,user.lon,user.mode);
            MenuWriteLat(40,4,15,user.lat,user.mode);
            MenuWriteLon(40,5,15,user.lon,user.mode);
            MenuReadLat(40,4,24,user.lat, 4); {use mode 4 only}
            MenuWriteLat(40,4,24,user.lat,user.mode);
            MenuReadLon(40,5,24,user.lon, 4); {use mode 4 only}
            MenuWriteLon(40,5,24,user.lon,user.mode);
            MenuWriteString(4,10,60,'Are both entries correct?  Y/[N] ');
            CursorOff;
            inch:= Readkey;
            CursorBig;
            If inch = 'y' Then
               inch:= 'Y';
            MenuWriteString(4,10,60,'                                 ');
         Until inch = 'Y';
         LL_to_Rad(user.lat, user.lon);    {CONVERT BACK TO RADIANS}
         Init_J_Matrix(user.lat, user.lon);
         Lat_Lon_to_Td(user.lat, user.lon, user.td);
      End;

   Procedure Help;
      Var
         inch: Char;
      Begin
         ClrScr;
         MenuWriteString(2,1,60,'    Lat/Lon to TD         HELP SCREEN');
         MenuWriteString(2,4,60,'Press I to Input a new Lat/Lon position to convert to TD''s');
         MenuWriteString(2,5,60,'Press G to Change the geodetic coordinate system of Lat/Lon positions');
         MenuWriteString(2,6,60,'Press D to Change the display format of Latitude and Longitude coordinates');
         MenuWriteString(2,7,60,'Press C to Select a new LORAN-C chain');
         MenuWriteString(2,8,60,'Press H to Display this HELP screen');
         MenuWriteString(2,9,60,'Press R to Return to the MAIN MENU');
         MenuWriteString(2,11,60,'Press and key to continue with program');
         CursorOff;
         inch:= ReadKey;
         CursorBig;
      End;



   Begin     {TPos}
      degrees_to_radians:= PI / 180.0;
      temp[1]:= 'Victor';
      temp[2]:= 'Whiskey';
      temp[3]:= 'Xray';
      temp[4]:= 'Yankee';
      temp[5]:= 'Zulu';
      ClrScr;
      inch:= #0;

      Repeat
         ClrScr;
         CursorOff;
         MenuWriteString(2,1,60,'             Changing Lat/Lon to TD''s Display');
         MenuWriteString(2,3,70,'(I)nput position (G)eodetic system (D)isplay format');
         MenuWriteString(2,4,70,'(C)hange chain information  (H)elp  (R)eturn to MAIN MENU');
         MenuWriteString(10,6,60,'TD''s in      LORAN-C chain based on given position');
         MenuWriteInteger(18,6,4,user.gri);

{lat lon in radians, ok to do conversion}
         Lat_Lon_To_Td(user.lat, user.lon, user.td);

         j:= 8;
         For i:= 1 to 5 Do
            If Secondary_Ok(i) Then
               Begin
                  MenuWriteString(j,8,60,temp[i]);
                  MenuWriteReal(j-2,10,9,user.decimals,user.td[i]);
                  j:= j + 14;
               End;

{convert radians lat lon to degrees lat lon for display purposes and calling
 coordinate conversion procedures which require degrees}
         LL_to_Deg(user.lat, user.lon);
         MenuWriteString(25,13,50,Geodetic_String(user.coord_sys));
         MenuWriteString(31,13,20,'Position');
         MenuWriteLat(12,15,14,user.lat,user.mode);
         MenuWriteLon(36,15,14,user.lon,user.mode);

{return coordinates to wgs84 and turn into radians}
         LL_to_Rad(user.lat, user.lon);
         CursorOff;
         inch:= Readkey;
         CursorBig;
         Case inch Of
            'i','I': Get_LL_Input(user);
            'g','G': Change_Geo(user);
            'd','D': Change_LL(user);
            'c','C': Change_Chain(user);
            'h','H': Help;
            'r','R': inch:= #0;
            Else;
         End;
      Until inch = #0;
      CursorBig;
   End;
