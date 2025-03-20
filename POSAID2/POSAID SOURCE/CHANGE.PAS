Unit Change;
   Interface
   Uses Crt, Dos, Menus, Coord1, Coord2, Coord_Gb, Math, AtScrn, Locates, Flt, Strings, Types;

      Type
         User_File = File Of User_Rec;

   Procedure SetDefaults(Var user: User_Rec);
   Procedure HelpChange;
   Procedure ChangeDefaults(Var user: User_Rec);

   Implementation

   Procedure SetDefaults(Var user: User_Rec);
      Var
         ior: Integer;
         ref_file: User_File;
         filename: Str30;
         ok: Boolean;
         lat, lon, alt: Float;
      Begin
         filename:= 'Posaid.def';
         Assign(ref_file,filename);
         {$I-}
         Reset(ref_file);
         ior:= IoResult;
         {$I+}
         If ior <> 0 Then   {can't find default file out there}
            Begin
               user.lat:= 41.0 * PI / 180.0;  {appx. lat/lon/alt of rdc in radians}
               user.lon:= -72.0 * PI / 180.0;
               user.lat1:= user.lat;
               user.lon1:= user.lon;
               user.range:= 0.0;
               user.azimuth:= 0.0;     {angles are set in radians}
               user.altitude:= 15.0;
               user.mode:= 4;                 {X dd mm ss.sss}
               user.decimals:= 4;             {decimal places to display real numbers}
               user.coord_sys:= WGS84;        {WGS84 coordinate system}
               user.length:= meter;           {display lengths in meters}
               user.gri:= 9960;               {use NEUS chain}
               user.filename:= filename;      {POSAID.DEF on default drive}
               user.first:= 3;                {use Xray}
               user.second:= 4;               {Use Yankee}
            End
         Else
            Begin
               Read(ref_file, user);
               Close(ref_file);
            End;
         If user.filename <> filename Then  {check to see if we have the correct file}
            Begin
               filename:= user.filename;
               Assign(ref_file,filename);
               {$I-}
               Reset(ref_file);
               ior:= IoResult;
               {$I+}
               If ior = 0 Then   {read the desired default file}
                  Begin
                     Read(ref_file,user);
                     Close(ref_file);
                  End;
            End;
         Case user.coord_sys Of
            NAD83: InitNad83;  {NAD83 is same as WGS84}
            WGS84: InitWGS84;
            WGS72: InitWGS72;
            NAD27: InitNAD27;
         End;

{Initialize ecef coordinates, they don't have to be correct just a value}
         lat:= user.lat;
         lon:= user.lon;
         alt:= user.altitude;
         Wgs84_To_Ecef84(lat, lon, alt,
                         user.ecef_x, user.ecef_y, user.ecef_z);

         ok:= Get_Ref_Data(user.gri,'chain.inf', user.coord_sys);
         Init_J_Matrix(user.lat, user.lon);
      End;   {SetDefaults}

   Procedure HelpChange;
      Var
         inch: Char;
      Begin
         ClrScr;
         MenuWriteString(2,1,60,'       Change Defaults       HELP SCREEN');
         MenuWriteString(2,4,60,'Press 1 to Input a new seed position for LORAN-C positions');
         MenuWriteString(2,5,60,'           Position should be within +/- 1 degree in Lat and Lon');
         MenuWriteString(2,6,60,'Press 2 to Change the display format of Latitude and Longitude coordinates');
         MenuWriteString(2,7,60,'Press 3 to Change the geodetic coordinate system of Lat/Lon positions');
         MenuWriteString(2,8,60,'Press 4 to Change the units used to display distance');
         MenuWriteString(2,9,60,'Press 5 to Change the number of decimal places for distance/bearing values');
         MenuWriteString(2,10,60,'Press 6 to Select a new LORAN-C chain');
         MenuWriteString(2,11,60,'Press 7 to Select a new file of default parameters');
         MenuWriteString(2,12,60,'Press 8 to Save the currently selected default parameters to selected file');
         MenuWriteString(2,13,60,'Press L to List the LORAN-C chains available on disk');
         MenuWriteString(2,14,60,'Press H to Display this HELP screen');
         MenuWriteString(2,15,60,'Press R to return to MAIN MENU');
         MenuWriteString(2,17,60,'Press any key to continue program');
         CursorOff;
         inch:= ReadKey;
         CursorBig;
      End;


   Procedure ChangeDefaults(Var user: User_Rec);
      Var
         inch: Char;
         t_user: User_Rec;
         f: User_File;
         ref_file: Text;
         temp: String;
         temp1,temp2,i,j, ior: Integer;
         ok, file_ok: Boolean;
         lat, lon, alt: Float;
         t_geo: Geodetic;
         t_length: Length_Type;
      Begin
         file_ok:= True;
         {$I-}
         Assign(ref_file, user.filename);
         Reset(ref_file);
         ior:= Ioresult;
         {$I+}
         If ior = 0 Then
            Close(ref_file)
         Else
            file_ok:= False;
         Repeat
            ClrScr;
            MenuWriteString(2,1,60,'          Change Defaults MENU');
            MenuWriteString(2,3,60,'Select value(s) to modify');
            MenuWriteString(2,5,60,'1 - Work area position   Latitude   =>');
            MenuWriteString(2,6,60,'                         Longitude  =>');
            MenuWriteString(2,7,60,'2 - Latitude/Longitude display mode =>');
            MenuWriteString(2,8,60,'3 - Coordinate system for Lat/Lon   =>');
            MenuWriteString(2,9,60,'4 - Units for displaying distance   =>');
            MenuWriteString(2,10,60,'5 - Decimal places displayed        =>');
            MenuWriteString(2,11,60,'6 - LORAN-C chain used              =>');
            MenuWriteString(2,12,60,'7 - Name of defaults file           =>');
            MenuWriteString(2,13,60,'8 - Save current defaults');
            MenuWriteString(2,14,60,'L - List GRI of chains on disk');
            MenuWriteString(2,15,60,'H - Help');
            MenuWriteString(2,17,60,'R - Return to MAIN MENU');
            If Not file_ok Then
   MenuWriteString(2,18,60,'Selected defaults file does not exist.  Save file before returning');
            LL_To_Deg(user.lat, user.lon);
            MenuWriteLat(42,5,20,user.lat,user.mode);
            MenuWriteLon(42,6,20,user.lon,user.mode);
            LL_To_Rad(user.lat, user.lon);
            MenuWriteString(42,7,16,Format_String(user.mode));
            MenuWriteString(42,8,5,Geodetic_String(user.coord_sys));
            MenuWriteString(42,9,14,Units_String(user.length));
            MenuWriteInteger(42,10,4,user.decimals);
            MenuWriteInteger(42,11,4,user.gri);
            MenuWriteString(42,12,20,user.filename);
            CursorOff;
            inch:= ReadKey;
            CursorBig;
            Case inch Of
               '1': Begin   {select seed lat/lon}
                       LL_To_Deg(user.lat, user.lon);
                       MenuReadLat(42,5,20,user.lat, 4); {use mode 4 to be free form}
                       MenuWriteLat(42,5,20,user.lat,user.mode);
                       MenuReadLon(42,6,20,user.lon, 4); {use mode 4 to be free form}
                       MenuWriteLon(42,6,20,user.lon, user.mode);
                       LL_To_Rad(user.lat, user.lon);
                    End;
               '2': Change_LL(user);  {change display mode of Lat/Lon}
               '3': Change_Geo(User); {change geodetic coordinate system}
               '4': Change_Distances(user); {change units for distance display}
               '5': MenuReadInteger(42,10,4,user.decimals);  {select number of decimal places for real numbers}
               '6': Change_Chain(User);   {select new gri}
               '7': Begin   {select new reference file}
                       temp:= user.filename;
                       MenuReadString(42,12,10,temp);
                       Assign(f,temp);
                       {$I-}
                       Reset(f);
                       ior:= IoResult;
                       {$I+}
                       If ior = 0 Then   {read the desired default file}
                          Begin
                             Read(f,t_user);
                             Close(f);
                             user.filename:= temp;
                             Change_Coord(t_user.coord_sys, user);
                             user:= t_user;
                             Init_J_Matrix(user.lat, user.lon);
                             file_ok:= True;
                          End
                       Else
                          Begin
                             MenuWriteString(2,19,60,'Selected reference file not found');
                             MenuWriteString(2,20,60,'Press any key to continue');
                             user.filename:= temp;
                             CursorOff;
                             inch:= Readkey;
                             CursorBig;
                             file_ok:= False;
                          End;
                    End;  {Case 7:}
               '8': Begin  {save current defaults to reference files}
                       {$I-}
                       Assign(f,'posaid.def');
                       Rewrite(f);
                       ior:= Ioresult;
                       {$I+}
                       If ior <> 0 Then
                          Begin
                             MenuWriteString(2,19,60,'Having problems with disk access. File not saved');
                             MenuWriteString(2,20,60,'Press any key to continue');
                             inch:= ReadKey;
                          End;
                       If ior = 0 Then
                          Begin
                             Write(f,user);
                             Close(f);
                             {$I-}
                             Assign(f,user.filename);
                             Rewrite(f);
                             Ior:= Ioresult;
                             {$I+}
                             If ior = 0 Then
                                Begin
                                   Write(f,user);
                                   Close(f);
                                   file_ok:= True;
                                End;
                          End;
                       If ior <> 0 Then
                          Begin
                             MenuWriteString(2,19,60,'Having problems with disk access. File not saved');
                             MenuWriteString(2,20,60,'Press any key to continue');
                             inch:= ReadKey;
                          End;
                    End;  {Case 8:}
               'l','L': ShowGri;
               'r','R': inch:= #0;
               'h','H': HelpChange;
               Else;
            End;   {Case statement}

         Until (inch = #0) And (file_ok);
      End;     {ChangeDefaults}

End.