Procedure LPos(Var user: User_Rec);

   Type
      Str11 = String[11];
      Str255 = String[255];
      Array_2x2 = Array[0..4,0..4] Of Float;

      Real_Array_2x2 = Array[1..2,1..2] Of Float;
      Str250 = String[250];
      Real_Array_1x2 = Array[1..2] Of Float;
      Loran_Rec = Record
                     cr,
                     lf,
                     sync,
                     decode,
                     first: Boolean;     {used by sync procedure}
                     next_pos: Integer;
                     loran_data: String[255];
                     td: Real_Array_1x4;
                  End;

      Loran_Rec_Ptr =^Loran_Rec;

      Positions = Array[0..5] Of Real_Array_1x2;
      File_Rec = Record
                    file_name: String[20];
                    file_var: Text;
                    file_open: Boolean;
                 End;


      Asf_Rec = Record
                   lat,
                   lon,
                   distance: Float;
                   e_array: Real_Array_2x2;
                   td: Real_Array_1x4;
                   asf: Real_Array_1x4;
                End;

      Asf_Rec_Ary = Array[0..125] Of Asf_Rec;
      Work_Area_Table = Record
                           way_point: Asf_Rec_Ary;
                           num_way_points: Integer;
                        End;

   Var
      ASF_FACTOR: Integer;

      loran_ptr: Loran_Rec_Ptr;
      loran: File_Rec;

      wpt: Work_Area_Table;

      td,
      distance,
      asf,
      azimuth: Real_Array_1x4;
      sq_e: Float;

      i, j, k: Integer;
      inch: Char;
      success: Boolean;
      in_string: Str250;
      temp1,
      temp2,
      lat,
      lon: Float;
      good_position: Boolean;

{following procedure takes in two TDs from user selected LORAN-C chain. procedure
 checks to make sure TDs are not the same}
   Procedure KeyboardInput(Var user: User_Rec;
                           Var ptr: Loran_Rec_Ptr);
      Var
         first, second: Integer;
         ok: Boolean;
         inch: Char;
         td1, td2: Float;
         temp: String;
      Begin
         ClrScr;
         Gotoxy(2,3);
         Write('Input TD coordinates of position from the ',user.gri:4,' LORAN-C chain');
         MenuWriteString(1,4,70,'                                    TD coordinate          Secondary');
         Repeat
            td1:= loran_ptr^.td[user.first];
            td2:= loran_ptr^.td[user.second];
            ok:= True;
            MenuWriteString(1,5,70,'                   First TD                                                  ');
            MenuReadReal(40,5,12,user.decimals,td1);
            Gotoxy(1,10);
            Write('                                                                      ');
            first:= SortTd(td1);
            MenuWriteString(61,5,7,Secondary_String(first));

            MenuWriteString(1,6,70,'                  Second TD                                                  ');
            MenuReadReal(40,6,12,user.decimals,td2);
            second:= SortTd(td2);
            MenuWriteString(61,6,7,Secondary_String(second));

            ok:= (Secondary_Ok(first) And Secondary_Ok(second));

            If Not ok Then
               MenuWriteString(4,9,60,'You have input an invalid TD');


            If second = first then
               Begin
                  ok:= False;
                  MenuWriteString(4,10,60,'Both TD''s can not be from same secondary. Reenter both TD''s');
               End;

            If ok Then
               Begin
                  Gotoxy(4,9);
                  Write('                                                             ');
                  Gotoxy(4,10);
                  Write('Is this position correct? (Y/N)                                                        ');
                  CursorOff;
                  inch:= ReadKey;
                  CursorBig;
                  If (inch = 'y') Or (inch = 'Y') Then
                    ok:= True
                  Else
                     ok:= False;
               End;
         Until ok;
         Gotoxy(4,10);
         Write('                                                             ');
         user.first:= first;
         user.second:= second;
         loran_ptr^.td[first]:= td1;
         loran_ptr^.td[second]:= td2;
         user.td[first]:= td1;
         user.td[second]:= td2;
         ClrScr;
      End;   {KeyBoardInput}


   Procedure Help_Change;
      Var
         inch: Char;
      Begin
         ClrScr;
         MenuWriteString(2,1,60,'   TD to Lat/Lon  Change parameters HELP SCREEN');
         MenuWriteString(2,4,60,'Press 1 to Select a new LORAN-C chain');
         MenuWriteString(2,5,60,'Press 2 to List the LORAN-C chains available on disk');
         MenuWriteString(2,6,60,'Press 3 to Input a new seed position for LORAN-C positions');
         MenuWriteString(2,7,60,'Press 4 to Change the display format of Latitude and Longitude coordinates');
         MenuWriteString(2,8,60,'Press 5 to Change the geodetic coordinate system of Lat/Lon positions');
         MenuWriteString(2,9,60,'Press H to Display this HELP screen');
         MenuWriteString(2,10,60,'Press C to Use current values and continue with program');
         MenuWriteString(2,13,60,'Press and key to continue with program');
         CursorOff;
         inch:= ReadKey;
         CursorBig;
      End;



   Procedure Init_File_Info(Var loran: File_Rec;
                            Var success: Boolean;
                            Var user: User_Rec);
      Var
         done,
         change_gri,
         erc: Boolean;
         i,
         dum,
         index: Integer;
         inch: Char;
         ref_file: Text;
         ref_string: String;
         temp_string: String[5];
      Begin
         inch:= 'g';
         change_gri:= False;
         LL_to_Deg(user.lat, user.lon);
         Repeat
            ClrScr;
            MenuWriteString(8,2,60,'Select desired function');
            MenuWriteString(2,4,60,'1 => Select LORAN-C Chain GRI');
            MenuWriteInteger(60,4,4,user.gri);
            MenuWriteString(2,5,60,'2 => List LORAN-C Chains on disk');
            MenuWriteString(2,6,60,'3 => Input new seed position');
            MenuWriteString(60,6,17,LatString(user.lat,user.mode));
            MenuWriteString(60,7,17,LonString(user.lon,user.mode));
            MenuWriteString(2,8,60,'4 => Change display format of Lat/Lon');
            MenuWriteString(60,8,17,Format_String(user.mode));
            MenuWriteString(2,9,60,'5 => Change coordinate system for Lat/Lon positions');
            MenuWriteString(60,9,10,Geodetic_String(user.coord_sys));
            MenuWriteString(2,10,60,'H => Help');
            MenuWriteString(2,12,30,'C => Continue with current values');

            CursorOff;
            inch:= ReadKey;
            CursorBig;
            Case inch Of
               '1': Change_Chain(user);
               '2': ShowGri;
               '3': Begin   {Select new seed latitude}
                           MenuReadLat(60,6,18,user.lat, 4); {use mode 4 only}
                           MenuWriteLat(60,6,18,user.lat, user.mode);
                           MenuReadLon(60,7,18,user.lon, 4); {use mode 4 only}
                           MenuWriteLon(60,7,18,user.lon,user.mode);
                        End;

               '4': Change_LL(user);   {change display mode of lat/lon}
               '5': Change_Geo(user);  {change geodetic coordinate system}
               'h','H': Help_Change;
               'c','C': inch:= 'C';

               Else;
            End;   {Case inch Of}


         Until (inch = 'C');
         LL_to_Rad(user.lat, user.lon);
         Init_J_Matrix(user.lat, user.lon);
         ClrScr;
      End;   {Init_File_Info}

   Procedure Help_Main;
      Var
         inch: Char;
      Begin
         ClrScr;
         MenuWriteString(2,1,60,'      TD to Lat/Lon   HELP SCREEN');
         MenuWriteString(2,4,60,'Press C to Change general information such as LORAN-C chain, ');
         MenuWriteString(2,5,60,'           display format, seed position, geodetic system');
         MenuWriteString(2,6,60,'Press I to Input a new set of TD''s to calculate position from');
         MenuWriteString(2,7,60,'Press G to Change the geodetic coordinate system of Lat/Lon positions');
         MenuWriteString(2,8,60,'Press H to Display this HELP screen');
         MenuWriteString(2,9,60,'Press R to Return to MAIN MENU');
         MenuWriteString(2,11,60,'Press any key to continue with program');
         CursorOff;
         inch:= ReadKey;
         CursorBig;
      End;

   Procedure Help_Verify;
      Var
         inch: Char;
      Begin
         ClrScr;
         MenuWriteString(2,1,60,'  TD to Lat/Lon Input Verification  HELP SCREEN');
         MenuWriteString(2,4,60,'Press 1 to select a new LORAN-C chain');
         MenuWriteString(2,5,60,'Press 2 to Change the geodetic coordinate system of Lat/Lon positions');
         MenuWriteString(2,6,60,'Press 3 to Input a new seed position for LORAN-C positions');
         MenuWriteString(2,7,60,'Press 4 to Input LORAN-C TD''s of unknown position');
         MenuWriteString(2,8,60,'Press 5 to List the LORAN-C chains available on disk');
         MenuWriteString(2,9,60,'Press H to Display this HELP screen');
         MenuWriteString(2,10,60,'Press C to Continue with program when all values are satisfactory');
         MenuWriteString(2,13,60,'Press any key to continue with program');
         CursorOff;
         inch:= ReadKey;
         CursorBig;
      End;

   Procedure Verify_Defaults(Var user: User_Rec;
                             loran_ptr: Loran_Rec_Ptr);
      Var i: Integer;
         lat, lon, alt: Real;
         inch: Char;
         ok: Boolean;
         first,
         second: Float;
         one,
         two: Integer;
         temp1,
         temp2: String;
      Begin
         inch:= #0;
         Repeat
            ClrScr;
            ok:= True;
            MenuWriteString(2,2,60,'TD to LAT/Lon Input Verification MENU');
            MenuWriteString(2,4,60,'Select value(s) to modify');
            MenuWriteString(2,6,60,'1 => LORAN-C Chain');
            MenuWriteString(2,7,60,'2 => Coordinate system of positions');
            MenuWriteString(2,8,60,'3 => Seed Position  (+/- 1 deg from work area)');
            MenuWriteString(2,10,60,'4 => LORAN-C TD''s of unknown position');
            MenuWriteString(2,12,60,'5 => List LORAN-C chains contained on disk');
            MenuWriteString(2,13,60,'H => Help');
            MenuWriteString(2,16,60,'C => Continue with current values');
            MenuWriteInteger(55,6,4,user.gri);
            MenuWriteString(55,7,10,Geodetic_String(user.coord_sys));
            LL_To_Deg(user.lat, user.lon);
            MenuWriteLat(54,8,20,user.lat, user.mode);
            MenuWriteLon(54,9,20,user.lon, user.mode);
            LL_To_Rad(user.lat, user.lon);

            If Not(transmitter[user.first].use) Or
               Not(transmitter[user.second].use) Then
               ok:= False;

            If Not ok Then
               MenuWriteString(2,18,60,'An invalid TD has been entered. Correct input is required.');

            MenuWriteReal(50,10,15,user.decimals,loran_ptr^.td[user.first]);
            MenuWriteReal(50,11,15,user.decimals,loran_ptr^.td[user.second]);
            MenuWriteString(69,10,8,Secondary_String(user.first));
            MenuWriteString(69,11,8,Secondary_String(user.second));
            CursorOff;
            inch:= ReadKey;
            Case inch Of
               '1': Change_Chain(user);
               '2': Change_Geo(user);
               '3': Begin   {Change seed position}
                       ClrScr;
                       MenuWriteString(2,4,60,'Enter new coordinates or press enter to accept coordinates shown');
                       MenuWriteString(2,6,60,'Latitude  ==>');
                       MenuWriteString(2,7,60,'Longitude ==>');
                       LL_To_Deg(user.lat, user.lon);
                       MenuWriteLat(17,6,60,user.lat,user.mode);
                       MenuWriteLon(17,7,60,user.lon,user.mode);
                       MenuReadLat(50,6,20,user.lat,4);
                       MenuWriteLat(50,6,20,user.lat,user.mode);
                       MenuReadLon(50,7,20,user.lon,4);
                       MenuWriteLon(50,7,20,user.lon,user.mode);
                       LL_To_Rad(user.lat, user.lon);
                       Init_J_Matrix(user.lat, user.lon);
                    End;
               '4': Begin    {Input LORAN-C TD's of unknown position}
                       ClrScr;
                       first:= loran_ptr^.td[user.first];
                       second:= loran_ptr^.td[user.second];
                       MenuWriteString(2,4,60,'Enter new TD''s or press enter to accept values shown');
                       MenuWriteString(2,6,70,Secondary_String(user.first));
                       MenuWriteString(2,7,70,Secondary_String(user.second));
                       MenuWriteReal(16,6,15,user.decimals,first);
                       MenuWriteReal(16,7,15,user.decimals,second);
                       MenuReadReal(40,6,15,user.decimals,first);
                       one:= SortTD(first);
                       MenuWriteString(65,6,12,Secondary_String(one));

                       MenuReadReal(40,7,15,user.decimals,second);
                       two:= SortTD(second);
                       MenuWriteString(65,7,12,Secondary_String(two));

                       ok:= Secondary_Ok(one) And Secondary_Ok(two);

                       If Not ok Then
                          MenuWriteString(2,11,60,'An invalid TD for this chain has been entered.');

                       If one = two Then
                          Begin
                             MenuWriteString(2,10,60,'The TD''s input are from the same secondary');
                             ok:= False;
                          End;

                       If ok Then
                          Begin
                             user.first:= one;
                             user.second:= two;
                             loran_ptr^.td[one]:= first;
                             loran_ptr^.td[two]:= second;
                          End
                       Else
                          Begin
                             MenuWriteString(2,13,60,'Press any key to continue');
                             CursorOff;
                             inch:= ReadKey;
                          End;
                    End;
               '5': ShowGri;
               'C','c': inch:= #0; {Do nothing let program continue}
               'h','H': Help_Verify;
               Else;  {Do nothing but repeat above display and prompts}
            End;   {Case inch of}

         Until (inch = #0) And ok;
      End;   {Verify_Defaults}


   Procedure Display_Top;
      Begin
         MenuWriteString(2,1,60,'             Changing TD''s to Lat/Lon Display');
         MenuWriteString(2,3,78,'(C)hange station parameters  (I)put TD''s  (G)eodetic system change');
         MenuWriteString(2,4,78,'(H)elp  (R)eturn to MAIN MENU');
      End;


   Begin    {LPos}
      New(loran_ptr);
      CursorOff;

      loran_ptr^.td:= user.td;

      user.new_value:= TRUE;
      success:= True;

      ClrScr;
      inch:= #0;
      Verify_Defaults(user, loran_ptr);
      Display_Top;
      Repeat
         If KeyPressed Then
            Begin
               inch:= ReadKey;
               Case inch Of
                 'r','R': inch:= 'R';
                 'c','C': Begin
                             Init_File_Info(loran, success, user);
                             For i:= 1 to 4 Do
                                loran_ptr^.td[i]:= user.td[i];
                             user.new_value:= True;
                          End;
                 'i','I': Begin
                             KeyboardInput(user, loran_ptr);
                             user.new_value:= True;
                          End;
                 'h','H': Begin
                             Help_Main;
                             user.new_value:= True;
                          End;
                 'g','G': Begin
                             Change_Geo(user);
                             user.new_value:= True;
                          End;
                 Else     user.new_value:= False;
               End;
            End;



         If user.new_value Then
            Begin
               ClrScr;
               MenuWriteString(18,12,60,'Calculations underway.   Please standby.....');
               good_position:= True;
               For i:= 1 to 5 Do
                  td[i]:= loran_ptr^.td[i];
               Td_To_Lat_Lon(td[user.first],
                             td[user.second],user.lat,user.lon,good_position);
               MenuWriteString(18,12,60,'                                            ');
               Display_Top;
               For i:= 1 to 5 Do
                  td[i]:= loran_ptr^.td[i];
               Gotoxy(4,6);
               Write('Position is derived using these TD''s from the ',user.gri:4,' chain ');
               j:= 7;
               For i:= 1 to 5 Do
                  If Secondary_Ok(i) Then
                     Begin
                        MenuWriteString(j,8,14,Secondary_String(i));
                        j:= j + 14;
                     End;
               If user.second < user.first Then
                  Begin
                     j:= user.first;
                     user.first:= user.second;
                     user.second:= j;
                  End;
               Gotoxy(4,9);
               For i:= 1 to 5 Do
                  If Secondary_Ok(i) Then
                     If (i = user.first) Or (i = user.second) Then
                        Write(loran_ptr^.td[i]:10:user.decimals,'    ')
                     Else
                        Write('              ');
               MenuWriteString(17,13,40,Geodetic_String(user.coord_sys));
               MenuWriteString(23,13,40,'position');

               If Not good_position Then
                  MenuWriteString(4,17,30,'Solution is questionable. Use new seed position!')
               Else
                  MenuWriteString(4,17,60,'                                                ');

               MenuWriteString(4,14,40,'     LAT                     LON');
               LL_To_Deg(user.lat, user.lon);
               MenuwriteLat(4,15,15,user.lat,user.mode);
               MenuWriteLon(27,15,15,user.lon,user.mode);
               LL_To_Rad(user.lat, user.lon);
               user.new_value:= False;
               CursorOff;
            End;

      Until inch = 'R';

      CursorBig;
   End;  {LPos}