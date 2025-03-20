Unit Coord_Gb;
   Interface
      Uses Flt, Types, Crt, AtScrn;

      Const
         LIGHT_SPEED = 299.7924580/1.000338;          {meters / usec)
                                             {corrected for index of refraction}
         EPSILON = 0.000000025;              {how close is close (meters)}
         NEG_ONE = -1;                       {sodano uses east lon as negative}

      Var
         semimajor_axis,
         semiminor_axis: Float;
         ASF_FACTOR: Integer;
         sq_e,
         flattening,
         degrees_to_radians,
         radians_to_degrees: Float;
         transmitter: Station_Rec_Array;
         j_matrix,
         timing_matrix: Array[0..6,0..6] Of Float;
         e_array: Array_2x2;
         m, f,
         semi_minor_axis,
         semi_major_axis    {meter values converted to usecond distances}
                        : Float;
         pv: Array[1..26] Of Float;

      Procedure ShowGri;
      Procedure CursorBig;
      Procedure CursorOff;
      Function Secondary_String(tx:Integer): String;
      Function Format_String(mode: Integer): String;
      Function Geodetic_String(geo: Geodetic): String;
      Function Units_String(units: Length_Type): String;
      Procedure User_to_Meters(Var range: Float; user: User_Rec);
      Procedure Meters_to_User(Var range: Float; user: User_Rec);
      Procedure LL_to_Deg(Var lat, lon: Float);
      Procedure LL_to_Rad(Var lat, lon: Float);

      Implementation

         Function Secondary_String(tx: Integer): String;
            Begin
               Case tx Of
                  0: Secondary_String:= 'MASTER';
                  1: Secondary_String:= 'VICTOR';
                  2: Secondary_String:= 'WHISKEY';
                  3: Secondary_String:= 'XRAY';
                  4: Secondary_String:= 'YANKEE';
                  5: Secondary_String:= 'ZULU';
                  Else Secondary_String:= '??????';
               End;
            End;

         Function Format_String(mode: Integer): String;
            Begin
               Case mode Of
                  1: Format_String:= '+/-ddd.dddddd';
                  2: Format_String:= 'ddd.dddddd';
                  3: Format_String:= 'ddd mm.mmmm';
                  4: Format_String:= 'ddd mm ss.sss';
                  Else Format_string:= '??????';
               End;
            End;

         Function Geodetic_String(geo: Geodetic): String;
            Begin
               Case geo Of
                  NAD27: Geodetic_String:= 'NAD27';
                  NAD83: Geodetic_String:= 'NAD83';
                  WGS72: Geodetic_String:= 'WGS72';
                  WGS84: Geodetic_String:= 'WGS84';
                  Else   Geodetic_String:= '?????';
               End;
            End;

         Function Units_String(units: Length_Type): String;
            Begin
               Case units Of
                  foot: Units_String:= 'feet';
                  yard: Units_String:= 'yards';
                  meter: Units_String:= 'meters';
                  nm:   Units_string:= 'nautical miles';
                  Else   Units_String:= '??????';
               End;
            End;

{following procedure is to convert distances into meters from whatever units
 user has selected}

         Procedure User_to_Meters(Var range: Float; user: User_Rec);
            Begin
               Case user.length Of
                  meter: range:= range;
                  foot:  range:= range * 0.3048;
                  yard:  range:= range * 0.9144;
                  nm:    range:= range * 1852.0;
               End;
            End;

{following procedure is to convert distances from meters into whatever units
 user has selected}

         Procedure Meters_to_User(Var range: Float; user: User_Rec);
            Begin
               Case user.length Of
                  meter: range:= range;
                  foot:  range:= range / 0.3048;
                  yard:  range:= range / 0.9144;
                  nm:    range:= range / 1852.0;
               End;
            End;

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

   Procedure ShowGri;
         Var
         instr,
         temp: String;
         inch: Char;
         f: Text;
         ior,i,j: Integer;
      Begin
         Clrscr;
         {$I-}   {turn off io error checking}
         Assign(f,'chain.inf');
         Reset(f);
         ior:= Ioresult;
         {$I+}
         If ior <> 0 Then
            Begin
               Writeln;
               Writeln('  Cannot show available LORAN-C chains. Missing file');
               Writeln('  Chain.inf');
            End
         Else
            Begin
               ClrScr;
               Writeln('  GRI        CHAIN DESCRIPTION');
{               Writeln(' ____     ___________________________');
}               While Not Eof(f) Do
                  Begin
                     Readln(f,instr);
                     If Pos('$',instr) > 0 Then
                        Begin
                           temp:= '';
                           j:= Pos('WGS',instr);
                           temp:= Copy(instr, 2, j-2);
                           Writeln(temp);
                        End;
                  End;
               Close(f);
            End;
{         Writeln;
}         Writeln('Press any key to return to program');
         CursorOff;
         inch:= Readkey;
         CursorBig;
      End;   {ShowGri}

      Procedure CursorOff;
         Begin
            NoBlinkVideo;
            SetCursorSize(13,0);
         End;

      Procedure CursorBig;
         Begin
            NoBlinkVideo;
            SetCursorSize(0,13);
         End;

End.