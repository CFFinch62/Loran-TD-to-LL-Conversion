   Procedure DisplayGeoMenu(menu: Integer;
                            user: User_Rec);
      Begin
         ClrScr;
         Case menu Of
            1: Begin   {Display of choices,  Main menu}
                  MenuWriteString(2,1,35,'       Geodetic Coordinate System Transformation Menu');
                  MenuWriteString(2,4,35,'1 => NAD27 to WGS72    ');
                  MenuWriteString(2,5,35,'2 => NAD27 to NAD83    ');
                  MenuWriteString(2,6,35,'3 => NAD27 to WGS84    ');
                  MenuWriteString(2,7,35,'4 => WGS72 to NAD27    ');
                  MenuWriteString(2,8,35,'5 => WGS72 to NAD83    ');
                  MenuWriteString(2,9,35,'6 => WGS72 to WGS84    ');
                  MenuWriteString(2,10,35,'7 => NAD83 to NAD27    ');
                  MenuWriteString(2,11,35,'8 => NAD83 to WGS72    ');
                  MenuWriteString(2,12,35,'9 => NAD83 to WGS84    ');
                  MenuWriteString(2,13,35,'A => WGS84 to NAD27    ');
                  MenuWriteString(2,14,35,'B => WGS84 to WGS72    ');
                  MenuWriteString(2,15,35,'C => WGS84 to NAD83    ');
                  MenuWriteString(2,17,35,'H => Help');
                  MenuWriteString(2,18,35,'R => Return to MAIN MENU     ');
                  MenuWriteString(30,8,1,'Select desired transformation');
               End;
            2: Begin   {NAD27 to WGS72}
                   MenuWriteString(2,2,35,'NAD27 LATITUDE      = ');
                   MenuWriteString(2,3,35,'NAD27 LONGITUDE     = ');
                   MenuWriteString(2,4,35,'NAD27 ALTITUDE      = ');
                   MenuWriteString(2,6,35,'WGS72 LATITUDE      = ');
                   MenuWriteString(2,7,35,'WGS72 LONGITUDE     = ');
                   MenuWriteString(2,8,35,'WGS72 ALTITUDE      = ');
                End;
            3: Begin   {NAD27 to NAD83}
                   MenuWriteString(2,2,35,'NAD27 LATITUDE      = ');
                   MenuWriteString(2,3,35,'NAD27 LONGITUDE     = ');
                   MenuWriteString(2,4,35,'NAD27 ALTITUDE      = ');
                   MenuWriteString(2,6,35,'NAD83 LATITUDE      = ');
                   MenuWriteString(2,7,35,'NAD83 LONGITUDE     = ');
                   MenuWriteString(2,8,35,'NAD83 ALTITUDE      = ');
                End;

            4: Begin   {NAD27 to WGS84}
                   MenuWriteString(2,2,35,'NAD27 LATITUDE      = ');
                   MenuWriteString(2,3,35,'NAD27 LONGITUDE     = ');
                   MenuWriteString(2,4,35,'NAD27 ALTITUDE      = ');
                   MenuWriteString(2,6,35,'WGS84 LATITUDE      = ');
                   MenuWriteString(2,7,35,'WGS84 LONGITUDE     = ');
                   MenuWriteString(2,8,35,'WGS84 ALTITUDE      = ');
                End;

            5: Begin   {WGS72 to Nad 27}
                   MenuWriteString(2,2,35,'WGS72 LATITUDE      = ');
                   MenuWriteString(2,3,35,'WGS72 LONGITUDE     = ');
                   MenuWriteString(2,4,35,'WGS72 ALTITUDE      = ');
                   MenuWriteString(2,6,35,'NAD27 LATITUDE      = ');
                   MenuWriteString(2,7,35,'NAD27 LONGITUDE     = ');
                   MenuWriteString(2,8,35,'NAD27 ALTITUDE      = ');
                End;
            6: Begin   {WGS72 to NAD83}
                   MenuWriteString(2,2,35,'WGS72 LATITUDE      = ');
                   MenuWriteString(2,3,35,'WGS72 LONGITUDE     = ');
                   MenuWriteString(2,4,35,'WGS72 ALTITUDE      = ');
                   MenuWriteString(2,6,35,'NAD83 LATITUDE      = ');
                   MenuWriteString(2,7,35,'NAD83 LONGITUDE     = ');
                   MenuWriteString(2,8,35,'NAD83 ALTITUDE      = ');
                End;
            7: Begin   {WGS72 to WGS84}
                   MenuWriteString(2,2,35,'WGS72 LATITUDE      = ');
                   MenuWriteString(2,3,35,'WGS72 LONGITUDE     = ');
                   MenuWriteString(2,4,35,'WGS72 ALTITUDE      = ');
                   MenuWriteString(2,6,35,'WGS84 LATITUDE      = ');
                   MenuWriteString(2,7,35,'WGS84 LONGITUDE     = ');
                   MenuWriteString(2,8,35,'WGS84 ALTITUDE      = ');
                End;
            8: Begin   {NAD83 to NAD27}
                   MenuWriteString(2,2,35,'NAD83 LATITUDE      = ');
                   MenuWriteString(2,3,35,'NAD83 LONGITUDE     = ');
                   MenuWriteString(2,4,35,'NAD83 ALTITUDE      = ');
                   MenuWriteString(2,6,35,'NAD27 LATITUDE      = ');
                   MenuWriteString(2,7,35,'NAD27 LONGITUDE     = ');
                   MenuWriteString(2,8,35,'NAD27 ALTITUDE      = ');
                End;
            9: Begin   {NAD83 to WGS72}
                   MenuWriteString(2,2,35,'NAD83 LATITUDE      = ');
                   MenuWriteString(2,3,35,'NAD83 LONGITUDE     = ');
                   MenuWriteString(2,4,35,'NAD83 ALTITUDE      = ');
                   MenuWriteString(2,6,35,'WGS72 LATITUDE      = ');
                   MenuWriteString(2,7,35,'WGS72 LONGITUDE     = ');
                   MenuWriteString(2,8,35,'WGS72 ALTITUDE      = ');
                End;
            10: Begin   {NAD83 to WGS84}
                   MenuWriteString(2,2,35,'NAD83 LATITUDE      = ');
                   MenuWriteString(2,3,35,'NAD83 LONGITUDE     = ');
                   MenuWriteString(2,4,35,'NAD83 ALTITUDE      = ');
                   MenuWriteString(2,6,35,'WGS84 LATITUDE      = ');
                   MenuWriteString(2,7,35,'WGS84 LONGITUDE     = ');
                   MenuWriteString(2,8,35,'WGS84 ALTITUDE      = ');
                End;
            11: Begin   {WGS84 to NAD27}
                   MenuWriteString(2,2,35,'WGS84 LATITUDE      = ');
                   MenuWriteString(2,3,35,'WGS84 LONGITUDE     = ');
                   MenuWriteString(2,4,35,'WGS84 ALTITUDE      = ');
                   MenuWriteString(2,6,35,'NAD27 LATITUDE      = ');
                   MenuWriteString(2,7,35,'NAD27 LONGITUDE     = ');
                   MenuWriteString(2,8,35,'NAD27 ALTITUDE      = ');
                End;
            12: Begin   {WGS84 to WGS72}
                   MenuWriteString(2,2,35,'WGS84 LATITUDE      = ');
                   MenuWriteString(2,3,35,'WGS84 LONGITUDE     = ');
                   MenuWriteString(2,4,35,'WGS84 ALTITUDE      = ');
                   MenuWriteString(2,6,35,'WGS72 LATITUDE      = ');
                   MenuWriteString(2,7,35,'WGS72 LONGITUDE     = ');
                   MenuWriteString(2,8,35,'WGS72 ALTITUDE      = ');
                End;
            13: Begin   {WGS84 to NAD83}
                   MenuWriteString(2,2,35,'WGS84 LATITUDE      = ');
                   MenuWriteString(2,3,35,'WGS84 LONGITUDE     = ');
                   MenuWriteString(2,4,35,'WGS84 ALTITUDE      = ');
                   MenuWriteString(2,6,35,'NAD83 LATITUDE      = ');
                   MenuWriteString(2,7,35,'NAD83 LONGITUDE     = ');
                   MenuWriteString(2,8,35,'NAD83 ALTITUDE      = ');
                End;
         End;    {Case menu Of}
      End;     {DisplayGeoMenu}

   Procedure HelpGeo;
      Var
         inch: Char;
      Begin
         ClrScr;
         Writeln('     Geodetic Transformation    HELP SCREEN');
         Writeln;
         Writeln;
         Writeln('    The list contains 4 different coordinate systems from which positions can');
         Writeln('  be transformed from/to.');
         Writeln('    These 4 coordinate systems use the familiar Latitude and Longitude');
         Writeln('  positions.  They are based on mathmatical models of the earth as a spheroid.');
         Writeln('  NAD27 is based on the Clark spheroid where WGS72, WGS84 and NAD83 are based');
         Writeln('  on models accepted in 1972 and 1984.  The altitude term in these coordinate');
         Writeln('  systems refer to the height above (+) or below (-) the surface of this');
         Writeln('  spheroid.  The surface of the spheroid may not coincide with the actual');
         Writeln('  surface of the earth, and therefore should not be accepted as ''height above');
         Writeln('  ground''.');
         Writeln;
         Writeln;
         Writeln('Press any key to continue program');
         CursorOff;
         inch:= ReadKey;
         CursorBig;
      End;   {HelpGeo}

   Procedure Do_First_Half(Var user: User_Rec);
      Begin
         LL_To_Deg(user.lat, user.lon);
         MenuWriteLat(30,2,35,user.lat,user.mode);
         MenuWriteLon(30,3,35,user.lon,user.mode);
         Meters_To_User(user.altitude,user);
         MenuWriteReal(30,4,user.decimals+6,user.decimals,user.altitude);
         MenuWriteString(45,4,20,Units_String(user.length));
         MenuReadLat(30,2,35,user.lat,4);
         MenuWriteLat(30,2,35,user.lat,user.mode);
         MenuReadLon(30,3,35,user.lon,4);
         MenuWriteLon(30,3,35,user.lon,user.mode);
         LL_To_Rad(user.lat, user.lon);
         MenuReadReal(30,4,user.decimals+6,user.decimals,user.altitude);
         MenuWriteString(45,4,20,Units_String(user.length));
         User_To_Meters(user.altitude,user);
      End;   {Do_First_Half}

   Procedure Do_Second_Half(user: User_Rec;
                             Var menu: Integer);
      Var
         inch: Char;
      Begin
         LL_To_Deg(user.lat, user.lon);
         MenuWriteLat(30,6,35,user.lat,user.mode);
         MenuWriteLon(30,7,35,user.lon,user.mode);
         Meters_To_User(user.altitude,user);
         MenuWriteReal(30,8,user.decimals+6,user.decimals,user.altitude);
         MenuWriteString(45,8,20,Units_String(user.length));
         MenuWriteString(2,10,35,'Press any key to continue ');
         CursorOff;
         inch:= ReadKey;
         CursorBig;
         menu:= 1;
      End;  {Do_Second_Half}

   Procedure ActOnGeoMenu(Var menu: Integer;
                       Var user: User_Rec);
      Var
         inch: Char;
         temp: Float;
      Begin
         With user Do
         Case Menu Of
            1: Begin   {Main menu}
                  Gotoxy(1,1);
                  CursorOff;
                  inch:= ReadKey;
                  CursorBig;
                  Case inch Of
                     '1':  menu:= 2;  {NAD27 to WGS72}
                     '2':  menu:= 3;  {NAD27 to NAD83}
                     '3':  menu:= 4;  {NAD27 to WGS84}
                     '4':  menu:= 5;  {WGS72 to NAD27}
                     '5':  menu:= 6;  {WGS72 to NAD83}
                     '6':  menu:= 7;  {WGS72 to WGS84}
                     '7':  menu:= 8;  {NAD83 to NAD27}
                     '8':  menu:= 9;  {NAD83 to WGS72}
                     '9':  menu:= 10;  {NAD83 to WGS84}
                     'a','A': menu:= 11; {WGS84 to NAD27}
                     'b','B': menu:= 12; {WGS84 to WGS72}
                     'c','C': menu:= 13; {WGS84 to NAD83}
                     'h','H': HelpGeo;
                     'r','R': menu:= 0;
                     Else menu:= 1;
                  End;   {Case inch of}
               End;   {Case menu of 1}

           2:  Begin   {NAD27 to WGS72}
                  Do_First_Half(user);
                  NAD27_To_WGS72(lat, lon, altitude);
                  Do_Second_Half(user,menu);
               End;
            3,4:  Begin   {NAD27 to NAD83 or NAD27 to WGS84}
                     Do_First_Half(user);
                     NAD27_To_WGS84(lat, lon, altitude);
                     Do_Second_Half(user,menu);
                  End;
           5:  Begin       {WGS72 to NAD27}
                  Do_First_Half(user);
                  WGS72_To_NAD27(lat, lon, altitude);
                  Do_Second_Half(user,menu);
               End;

            6,7:  Begin   {WGS72 to NAD83 or WGS72 to WGS84}
                     Do_First_Half(user);
                     WGS72_To_WGS84(lat, lon, altitude);
                     Do_Second_Half(user,menu);
                  End;
           11,8:  Begin   {WGS84 to NAD27 or NAD83 to NAD27}
                  Do_First_Half(user);
                  WGS84_To_NAD27(lat, lon, altitude);
                  Do_Second_Half(user,menu);
               End;
           12,9:  Begin  {WGS84 to WGS72 or NAD83 to WGS72}
                  Do_First_Half(user);
                  WGS84_To_WGS72(lat, lon, altitude);
                  Do_Second_Half(user,menu);
               End;
           13,10:  Begin  {WGS84 to NAD83 or NAD83 to WGS84}
                  Do_First_Half(user);
                  Do_Second_Half(user,menu);
               End;
         End;      {Case menu Of}
      End;   {ActOnGeoMenu}

   Procedure Geo(user: User_Rec);

      Begin
         menu:= 1;
         Repeat
            DisplayGeoMenu(menu, user);
            ActOnGeoMenu(menu, user);
         Until menu = 0;
         ClrScr;
      End;  {Procedure Geo}


