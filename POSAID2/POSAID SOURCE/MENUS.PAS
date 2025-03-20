Unit Menus;
Interface
   Uses Dos, Crt, Strings, Flt, Types;
   Procedure MenuReadInteger(x,y,field: Integer; Var default: Integer);
   Procedure MenuReadReal(x,y,field1,field2: Integer; Var default: Float);
   Procedure MenuReadBoolean(x,y,field: Integer; Var default: Boolean);
   Procedure MenuReadString(x,y,field: Integer; Var default: String);
   Procedure MenuReadLat(x,y,field: Integer; Var default: Float; mode: Integer);
   Procedure MenuReadLon(x,y,field: Integer; Var default: Float; mode: Integer);
   Procedure MenuReadTime(x,y,field: Integer;
                          Var hour, minute, second: Integer;
                          Var default: Float;
                          mode: Integer);
   Procedure MenuWriteInteger(x,y,field,intval: LongInt);
   Procedure MenuWriteReal(x,y,field1,field2: Integer; realval: Float);
   Procedure MenuWriteString(x,y,field:Integer; strval: String);
   Procedure MenuWriteBoolean(x,y,field: Integer; booval: Boolean);
   Procedure MenuWriteLat(x,y,field: Integer; degval: Float; mode: Integer);
   Procedure MenuWriteLon(x,y,field: Integer; degval: Float; mode: Integer);
   Procedure MenuWriteTime(x,y,field: Integer; timval: Float; mode: Integer);


Implementation

   Procedure ClearField(x,y,field: Integer);
      Var
         i: Integer;
      Begin
         If x > 80 Then x:= 80;
         If y > 24 Then y:= 24;
         Gotoxy(x,y);
         For i:= 1 to field Do
            Write(' ');
         Gotoxy(x,y);
     End;

   Procedure MenuWriteBoolean(x,y,field: Integer; booval: Boolean);
      Var
         i: Integer;
      Begin
         ClearField(x,y,field);
         Write(booval);
         Gotoxy(x,y);
      End;

   Procedure MenuWriteInteger(x,y,field, intval: LongInt);
      Var
         i: Integer;
      Begin
         ClearField(x,y,field);
         Write(intval:field);
         Gotoxy(x,y);
      End;

   Procedure MenuWriteReal(x,y,field1,field2: Integer;
                           realval: Float);
      Var
         i: Integer;
      Begin
         ClearField(x,y,field1);
         Write(realval:field1:field2);
         Gotoxy(x,y);
      End;

   Procedure MenuWriteString(x,y,field: Integer;
                             strval: String);
      Var
         i: Integer;
      Begin
          If (x > 80) Or (y > 25) Then
             Begin
                Writeln;
                Writeln('error in last menu write string ');
                Writeln(strval);
                Writeln(' write to position ',x:5,'  ',y:5);
                Readln;
             End;
          ClearField(x,y,field);
          Gotoxy(x,y);
          Write(strval);
          Gotoxy(x,y);
       End;

   Function GetChar(Var fnctn: Boolean): Char;
      Var
         inch: Char;
      Begin
         fnctn:= False;
         inch:= ReadKey;
         If inch = #0 Then
            Begin
               inch:= Readkey;
               fnctn:= True;
            End;
         GetChar:= inch;
      End;

   Function GetInteger(Var intval: LongInt): Boolean;
      Var
         inch: Char;
         temp: String[20];
         fnctn: Boolean;
         errcode,
         tlength: Integer;
         locint: LongInt;
         x,y: Byte;
      Begin
         temp:= '';
         intval:= 0;
         Repeat
            inch:= GetChar(fnctn);
            If Not fnctn Then
               Begin
                  If inch = #8 Then
                     Begin
                        tlength:=Length(temp);
                        If tlength > 0 Then
                           Begin
                              temp:= Copy(temp,1,tlength - 1);
                              x:= WhereX - 1;
                              y:= Wherey;
                              ClearField(x,y,1);
                           End;
                     End;
                  If (inch = '-') Or (inch = '+') Then
                     If Length(temp) = 0 Then
                        Begin
                           temp:= Concat(temp, inch);
                           Write(inch);
                        End;
                  If inch in ['0'..'9'] Then
                     Begin
                        temp:= Concat(temp, inch);
                        Write(inch);
                     End;
               End;
         Until inch = #13;
         Val(temp, intval, errcode);
         If errcode = 0 Then
            GetInteger:= True
         Else
            GetInteger:= False;
      End;

   Procedure MenuReadInteger(x,y,field: Integer;
                             Var default: Integer);
      Var
         i: Integer;
         ok: Boolean;
         locint: LongInt;
         temp: String;
         erc: Boolean;
      Begin
         Str(default:field,temp);
         MenuReadString(x,y,field,temp);
         StrReadInteger(temp,1,i,default,erc);
         MenuWriteInteger(x,y,field,default);
      End;

   Function GetReal(Var realval: Float): Boolean;
      Var
         inch: Char;
         temp: String[20];
         fnctn,
         decimal: Boolean;
         errcode,
         tlength: Integer;
         locreal: Float;
         x,y: Byte;
      Begin
         temp:= '';
         decimal:= False;
         realval:= 0;
         Repeat
            inch:= GetChar(fnctn);
            If Not fnctn Then
               Begin
                  If inch = #8 Then  {take care of backspaces}
                     Begin
                        tlength:=Length(temp);
                        If tlength > 0 Then
                           Begin
                              temp:= Copy(temp,1,tlength - 1);
                              x:= WhereX - 1;
                              y:= Wherey;
                              ClearField(x,y,1);
                              If Pos('.',temp) = 0 Then
                                 decimal:= False
                              Else
                                 decimal:= True;
                           End;
                     End;
                  If (inch = '-') Or (inch = '+') Then   {accept - sign in first position only}
                     If Length(temp) = 0 Then
                        Begin
                           temp:= Concat(temp, inch);
                           Write(inch);
                        End;
                  If inch = '.' Then   {check for decimal point}
                     If Not decimal Then
                        Begin
                           decimal:= True;
                           temp:= Concat(temp, inch);
                           Write(inch);
                        End;
                  If inch in ['0'..'9'] Then    {accept only integers}
                     Begin
                        temp:= Concat(temp, inch);
                        Write(inch);
                     End;
               End;
         Until inch = #13;              {stop at carriage return}
         Val(temp, locreal, errcode);
         If errcode = 0 Then
            Begin
               GetReal:= True;
               realval:= locreal;
            End
         Else
            GetReal:= False;
      End;

   Procedure MenuReadReal(x,y,field1,field2: Integer;
                          Var default: Float);
      Var
         dum: Integer;
         ok: Boolean;
         locreal: Float;
         temp: String;
         erc: Boolean;
      Begin
         Str(default:field1:field2, temp);
         MenuReadString(x,y,field1,temp);
         StrReadReal(temp,1,dum,default,erc);
         MenuWriteReal(x,y,field1,field2,default);
      End;

   Function GetBoolean(Var booval: Boolean): Boolean;
      Var
         temp: String[20];
         tlength: Integer;
         inch: Char;
         x,y: Byte;
         fnctn:Boolean;
      Begin
         temp:= '';
         Repeat
            inch:= GetChar(fnctn);
            If Not fnctn Then
               Begin
                  tlength:= Length(temp);
                  If inch = #8 Then
                     If tlength > 0 Then
                        Begin
                           x:= Wherex - 1;
                           y:= Wherey;
                           ClearField(x,y,1);
                           temp:= Copy(temp,1,tlength-1);
                        End;

                  If inch in ['f','a','l','s','e','F','A','L','S','E'] Then
                     Begin
                        Case tlength Of
                           0: If (inch = 'f') Or (inch = 'F') Then
                                 Begin
                                    temp:= Concat(temp, inch);
                                    Write(inch);
                                 End;
                           1: If ((inch = 'a') Or (inch = 'A')) And
                                 ((temp[1] = 'f') Or (temp[1] = 'F')) Then
                                 Begin
                                    temp:= Concat(temp, inch);
                                    Write(inch);
                                 End;
                           2: If ((inch = 'l') Or (inch = 'L')) And
                                 ((temp[1] = 'f') Or (temp[1] = 'F')) Then
                                 Begin
                                    temp:= Concat(temp, inch);
                                    Write(inch);
                                 End;
                           3: If ((inch = 's') Or (inch = 'S')) And
                                 ((temp[1] = 'f') Or (temp[1] = 'F')) Then
                                 Begin
                                    temp:= Concat(temp, inch);
                                    Write(inch);
                           End;
                           4: If ((inch = 'e') Or (inch = 'E')) And
                                 ((temp[1] = 'f') Or (temp[1] = 'F')) Then
                                 Begin
                                    temp:= Concat(temp, inch);
                                    Write(inch);
                                    inch:= #13;
                                 End;
                        End;   {Case tlength of}
                     End;    {If inch in false}

                  If (inch in ['t','r','u','e','T','R','U','E']) Then
                     Begin
                        Case tlength Of
                           0: If (inch = 't') Or (inch = 'T') Then
                                 Begin
                                    temp:= Concat(temp, inch);
                                    Write(inch);
                                 End;
                           1: If ((inch = 'r') Or (inch = 'R')) And
                                 ((temp[1] = 't') Or (temp[1] = 'T')) Then
                                 Begin
                                    temp:= Concat(temp, inch);
                                    Write(inch);
                                 End;
                           2: If ((inch = 'u') Or (inch = 'U')) And
                                 ((temp[1] = 't') Or (temp[1] = 'T')) Then
                                 Begin
                                    temp:= Concat(temp, inch);
                                    Write(inch);
                           End;
                           3: If ((inch = 'e') Or (inch = 'E')) And
                                 ((temp[1] = 't') Or (temp[1] = 'T')) Then
                                 Begin
                                    temp:= Concat(temp, inch);
                                    Write(inch);
                                    inch:= #13;
                                 End;
                        End;   {Case tlength of}
                     End;   {If inch in true}

                  If (inch in ['y','e','s','Y','E','S']) Then
                     Begin
                        Case tlength Of
                           0: If (inch = 'y') Or (inch = 'Y') Then
                                 Begin
                                    temp:= Concat(temp, inch);
                                    Write(inch);
                                 End;
                           1: If ((inch = 'e') Or (inch = 'E')) And
                                 ((temp[1] = 'y') Or (temp[1] = 'Y')) Then
                                 Begin
                                    temp:= Concat(temp, inch);
                                    Write(inch);
                                 End;
                           2: If ((inch = 's') Or (inch = 'S')) And
                                 ((temp[1] = 'y') Or (temp[1] = 'Y')) Then
                                 Begin
                                    temp:= Concat(temp, inch);
                                    Write(inch);
                                    inch:= #13;
                                 End;
                        End;   {Case tlength of}
                     End;   {If inch in yes}

                  If (inch in ['n','o','N','O']) Then
                     Begin
                        Case tlength Of
                           0: If (inch = 'n') Or (inch = 'N') Then
                                 Begin
                                    temp:= Concat(temp, inch);
                                    Write(inch);
                                 End;
                           1: If ((inch = 'o') Or (inch = 'O')) And
                                 ((temp[1] = 'n') Or (temp[1] = 'N')) Then
                                 Begin
                                    temp:= Concat(temp, inch);
                                    Write(inch);
                                    inch:= #13;
                                 End;
                        End;   {Case tlength of}
                     End;   {If inch in no}
               End;   {If Not fnctn Then}
         Until inch = #13;
         If Length(temp) > 0 Then
            Begin
               If (temp[1] = 't') Or (temp[1] = 'T') Or
                  (temp[1] = 'y') Or (temp[1] = 'Y') Then
                  booval:= True
               Else
                  booval:= False;
               GetBoolean:= True;
            End
         Else
            GetBoolean:= False;
      End;

   Procedure MenuReadBoolean(x,y,field: Integer;
                             Var default: Boolean);
      Var
         ok,
         locboo: Boolean;
         i: Integer;
      Begin
         TextBackground(7);
         TextColor(0);
         MenuWriteString(x,y,field,' ');
         TextBackground(0);
         TextColor(15);
         Repeat
         Until KeyPressed;
         ClearField(x,y,field);
         ok:= GetBoolean(locboo);
         If ok Then
            default:= locboo;
         MenuWriteBoolean(x,y,field,default);
      End;

   Procedure MenuReadString(x,y,field: Integer;
                            Var default: String);
      Var
         locstr: String[40];
         i: Integer;
      Begin
         TextBackground(7);
         TextColor(0);
         ClearField(x,y,field);
         TextBackground(0);
         TextColor(15);
         Repeat
         Until KeyPressed;
         ClearField(x,y,field);
         Readln(locstr);
         If Length(locstr) > 0 Then
           default:= locstr;
        MenuWriteString(x,y,field,default);
     End;

   Procedure MenuReadTime(x,y,field: Integer;
                          Var hour, minute, second: Integer;
                          Var default: Float;
                          mode: Integer);
      Var
         temp: String;
         dum: Integer;
      Begin
         temp:= TimeString(default,hour, minute, second, mode);
         MenuReadString(x,y,field,temp);
         StrReadTime(temp,1,dum,hour,minute,second,default,4);
         MenuWriteTime(x,y,field,default,mode);
      End;

   Procedure MenuReadLon(x,y,field: Integer;
                         Var default: Float;
                         mode: Integer);
      Var
         dum: Integer;
         temp: String;
      Begin
         temp:= LonString(default,mode);
         MenuReadString(x,y,field,temp);
         StrReadLon(temp,1,dum,default,mode);
      End;   {MenuReadLon}

   Procedure MenuReadLat(x,y,field: Integer;
                         Var default: Float;
                         mode: Integer);
      Var
         dum: Integer;
         temp: String;
      Begin
         temp:= LatString(default,mode);
         MenuReadString(x,y,field,temp);
         StrReadLat(temp,1,dum,default,mode);
      End;   {MenuReadLat}

   Procedure MenuWriteLat(x,y,field: Integer;
                          degval: Float;
                          mode: Integer);
      Var
         temp: String;
      Begin
         temp:= LatString(degval, mode);
         MenuWriteString(x,y,field,temp);
      End;

   Procedure MenuWriteLon(x,y,field: Integer;
                          degval: Float;
                          mode: Integer);
      Var
         temp: String;
      Begin
         temp:= LonString(degval, mode);
         MenuWriteString(x,y,field,temp);
      End;

   Procedure MenuWriteTime(x,y,field: Integer; timval: Float; mode: Integer);
      Var
         hour,
         minute,
         second: Integer;
         temp: String;
      Begin
         temp:= TimeString(timval, hour, minute, second, mode);
         MenuWriteString(x,y,field,temp);
      End;

   End.