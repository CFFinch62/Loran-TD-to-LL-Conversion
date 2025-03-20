Unit Strings;
Interface
   Uses Dos, Crt, Flt, Types;
   Function StrInsert(instring: String; position: Integer;
                      insert: String): String;
   Function StrDelete(instring: String; start, number: Integer): String;
   Function StrPad(instring: String; padding: Integer): String;
   Function StrStrip(instring, search: String): String;
   Function StrLTrim(instring: String): String;
   Function StrRTrim(instring: String): String;
   Function StrReplace(instring, oldstring, newstring: String): String;
   Function StrCaps(instring: String): String;
   Procedure StrReadReal(instring: String;
                         start: Integer;
                         Var stop: Integer;
                         Var returnvalue: Float;
                         Var error: Boolean);

   Procedure StrReadLongInt(instring: String;
                            start: Integer;
                            Var stop: Integer;
                            Var returnvalue: LongInt;
                            Var error: Boolean);

   Procedure StrReadInteger(instring: String;
                            start: Integer;
                            Var stop, returnvalue: Integer;
                            Var error: Boolean);

   Procedure StrReadLon(instring: String;
                        start: Integer;
                        Var stop: Integer;
                        Var default: Float;
                        mode: Integer);
   Procedure StrReadLat(instring: String;
                        start: Integer;
                        Var stop: Integer;
                        Var default: Float;
                        mode: Integer);
   Procedure StrReadTime(instring: String;
                         start: Integer;
                         Var stop, hour, minute, second: Integer;
                         Var default: Float;
                         mode: Integer);
   Function Fract(inval: Float): Float;

   Function TimeString(Var timevar: Float;
                       Var hour, minute, second: Integer;
                       mode: Integer): String;

   Function LatString(degval: Float; mode: Integer): String;

   Function LonString(degval: Float; mode: Integer): String;

Implementation
   Procedure StrReadTime(instring: String;
                         start: Integer;
                         Var stop, hour, minute, second: Integer;
                         Var default: Float;
                         mode: Integer);
      Var
         locreal: Array[1..3] Of Float;
         i,j,
         dum,
         tlength: Integer;
         errcode: Array[1..3] Of Integer;
         temp: String;
         tempreal,
         secs: Float;
         error,
         correct: Boolean;
      Begin
         temp:= instring;
         tlength:= Length(temp);

         If default > 0.0 Then
            Begin
               hour:= Trunc(default);
               locreal[1]:= (default - hour) * 60.0;
               minute:= Trunc(locreal[1]);
               locreal[1]:= (locreal[1] - minute) * 60.0;
               second:= Trunc(locreal[1]);
               secs:= locreal[1];
            End
         Else
            Begin
               default:= hour + (minute / 60.0) + (second / 3600.0);
               secs:= second;
            End;

         For i:= 1 to 3 Do
            Begin
               locreal[i]:= -999.0;
               errcode[i]:= 0;
            End;

         dum:= start;
         i:= 1;
         error:= False;
         Case mode Of
            1:   Begin           {expect only hh.hhhh}
                    While (Not error) And (dum <= tlength) And (i <= 1) Do
                       Begin
                          StrReadReal(temp,dum,dum,locreal[i],error);
                          If error Then
                             For j:= i to 3 Do
                                Begin
                                   errcode[j]:= 1;
                                   locreal[j]:= -999.0;
                                End;
                          i:= i + 1;
                       End;
                 End;

            2:   Begin           {expect only hh mm.mmm}
                    While (Not error) And (dum <= tlength) And (i <= 2) Do
                       Begin
                          StrReadReal(temp,dum,dum,locreal[i],error);
                          If error Then
                             For j:= i to 3 Do
                                Begin
                                   errcode[j]:= 1;
                                   locreal[j]:= -999.0;
                                End;
                          i:= i + 1;
                       End;
                 End;

            3:   Begin           {expect only hh mm ss}
                    While (Not error) And (dum <= tlength) And (i <= 3) Do
                       Begin
                          StrReadReal(temp,dum,dum,locreal[i],error);
                          If error Then
                             For j:= i to 3 Do
                                Begin
                                   errcode[j]:= 1;
                                   locreal[j]:= -999.0;
                                End;
                          i:= i + 1;
                       End;
                 End;

            4:   Begin           {expect only hh mm ss.sss}
                    While (Not error) And (dum <= tlength) And (i <= 3) Do
                       Begin
                          StrReadReal(temp,dum,dum,locreal[i],error);
                          If error Then
                             For j:= i to 3 Do
                                Begin
                                   errcode[j]:= 1;
                                   locreal[j]:= -999.0;
                                End;
                          i:= i + 1;
                       End;
                 End;
         End;     {Case statement}
         stop:= dum;

         For i:= 1 to 3 Do
            If locreal[i] < 0 Then
               For j:= i to 3 Do
                  Begin
                     locreal[j]:= -999.0;
                     errcode[i]:= 1;
                  End;

         If locreal[1] > 24 Then
            errcode[1]:= 1;

         If (locreal[2] > 59.99) Or
            ((locreal[2] > 0.0) And (locreal[1] = 24.0)) Then
            errcode[2]:= 1;

         If (locreal[3] > 59.99) Or
            ((locreal[3] > 0.0) And (locreal[1] = 24.0)) Then
            errcode[3]:= 1;


         tempreal:= 0.0;
         i:= 0;

         If errcode[1] = 0 Then
            Begin
               correct:= True;
               For i:= 1 to 3 Do
                  Case i Of
                     1: tempreal:= locreal[1];
                     2: If errcode[2] = 0 Then
                           tempreal:= tempreal + locreal[2] / 60.0;
                     3: If errcode[3] = 0 Then
                           tempreal:= tempreal + locreal[3] / 3600.0;
                  End;
            End
         Else
            correct:= False;

         If correct Then
            default:= tempreal;

         Hour:= Trunc(default);
         locreal[2]:= Fract(default) * 60.0;
         locreal[3]:= Fract(locreal[2]) * 60.0;
         minute:= Trunc(locreal[2]);
         second:= Trunc(locreal[3]);
      End;   {MenuReadTime}



   Procedure StrReadLon(instring: String;
                        start: Integer;
                        Var stop: Integer;
                        Var default: Float;
                        mode: Integer);
      Var
         dir,
         done: Boolean;
         locreal: Array[1..3] Of Float;
         erc: Boolean;
         errcode: Array[1..3] Of Integer;
         i,
         dum,
         tlength: Integer;
         temp: String;
      Begin
         If default < 0.0 Then
            While default <= -360.0 Do
               default:= default + 360.0
         Else
            While default >= 360.0 Do
               default:= default - 360.0;
         temp:= '';
         temp:= instring;
         tlength:= Length(instring);
         dum:= start;

{Assign default of east longitude}
         dir:= True;

{determine hemisphere of input}
         While (dum < tlength) And (Not (temp[dum] In ['+','e','E','-','w','W'])) Do
            dum:= dum + 1;
         If temp[dum] In ['-','w','W'] Then
            dir:= False;

{set pointer to beginning of actual number}
         dum:= start;
         While (dum <= tlength) And (Not (temp[dum] In ['0'..'9'])) Do
            dum:= dum + 1;

{set error catcher to failed}
         For i:= 1 to 3 Do
            errcode[i]:= 1;

{Initialize local variable}
         For i:= 1 to 3 Do
            locreal[i]:= 0.0;

         i:= 1;
         done:= False;
         Case mode of
          1,2:  Begin        {Expect only dd.ddd (read only one number)}
                   While (i <= 1) And (dum <= tlength) And (Not done) Do
                      Begin
                         StrReadReal(temp,dum,dum,locreal[i], done);
                         If done Then
                            errcode[i]:= 1
                         Else
                            errcode[i]:= 0;
                         locreal[i]:= Abs(locreal[i]);
                         i:= i + 1;
                      End;
                End;

            3:  Begin        {Expect only dd mm.mm (read two numbers)}
                   While (i <= 2) And (dum <= tlength) And (Not done) Do
                      Begin
                         StrReadReal(temp,dum,dum,locreal[i], done);
                         If done Then
                            errcode[i]:= 1
                         Else
                            errcode[i]:= 0;
                         locreal[i]:= Abs(locreal[i]);
                         i:= i + 1;
                      End;
                End;

            4:  Begin        {Expect only hh mm ss (read three numbers)}
                   While (i <= 3) And (dum <= tlength) And (Not done) Do
                      Begin
                         StrReadReal(temp,dum,dum,locreal[i], erc);
                         If erc Then
                            errcode[i]:= 1
                         Else
                            errcode[i]:= 0;
                         locreal[i]:= Abs(locreal[i]);
                         i:= i + 1;
                      End;
                End;
            End;      {Case statement}

         stop:= dum;  {set tail pointer to last place read in string}

         If (errcode[1] = 0) And (locreal[1] <= 360.0) Then
            Begin
               If (errcode[2] = 0) And (locreal[2] < 60.0) Then
                  locreal[1]:= locreal[1] + locreal[2] / 60.0;
               If (errcode[3] = 0) And (locreal[3] < 60.0) Then
                  locreal[1]:= locreal[1] + locreal[3] / 3600.0;
            End
         Else
            locreal[1]:= default;

         While locreal[1] >= 360.0 Do
            locreal[1]:= locreal[1] - 360.0;

         If dir Then
           default:= locreal[1]
         Else
           default:= -locreal[1];
      End;   {StringReadLon}


   Procedure StrReadLat(instring: String;
                           start: Integer;
                        Var stop: Integer;
                     Var default: Float;
                            mode: Integer);
      Var
         dir,
         done: Boolean;
         locreal: Array[1..3] Of Float;
         erc: Boolean;
         errcode: Array[1..3] Of Integer;
         i,
         dum,
         tlength: Integer;
         temp: String;
      Begin
         If default < 0.0 Then
            While default <= -360.0 Do
               default:= default + 360.0
         Else
            While default >= 360.0 Do
               default:= default - 360.0;
         temp:= '';
         temp:= instring;
         tlength:= Length(temp);
         dum:= start;

{assign default value of North Latitude}
         dir:= True;

{determine the semishphere of coordinate}
         While (dum < tlength) And (Not(temp[dum] In ['s','n','S','N','+','-'])) Do
            dum:= dum + 1;
{Assign direction south if north or + not found}
         If temp[dum] In ['-','s','S'] Then
            dir:= False
         Else
            dir:= True;

{Advance counter to beginning of actual number}
         dum:= start;
         While (dum <= tlength) And (Not (temp[dum] In ['0'..'9'])) Do
            dum:= dum + 1;

{Initialize boolean to reflect no errors and not done}
         done:= False;

{Initialize error detectors for error detect. Changed for no error later if needed}
         For i:= 1 to 3 Do
            errcode[i]:= 1;

{Initialize local temporay variable}
         For i:= 1 to 3 Do
            locreal[i]:= 0.0;

{Start counter at one}
         i:= 1;

         Case mode of
          1,2:  Begin        {Expect only hh.hhh  (read one value)}
                   While (i <= 1) And (dum <= tlength) And (Not done) Do
                      Begin
                         StrReadReal(temp,dum,dum,locreal[i], done);
                         If done Then
                            errcode[i]:= 1
                         Else
                            errcode[i]:= 0;
                         locreal[i]:= Abs(locreal[i]);
                         i:= i + 1;
                      End;
                End;

            3:  Begin        {Expect only hh mm  (read two values)}
                   While (i <= 2) And (dum <= tlength) And (Not done) Do
                      Begin
                         StrReadReal(temp,dum,dum,locreal[i], done);
                         If done Then
                            errcode[i]:= 1
                         Else
                            errcode[i]:= 0;
                         locreal[i]:= Abs(locreal[i]);
                         i:= i + 1;
                      End;
                End;

            4:  Begin        {Expect only hh mm ss  (read three values)}
                   While (i <= 3) And (dum <= tlength) And (Not done) Do
                      Begin
                         StrReadReal(temp,dum,dum,locreal[i], done);
                         If done Then
                            errcode[i]:= 1
                         Else
                            errcode[i]:= 0;
                         locreal[i]:= Abs(locreal[i]);
                         i:= i + 1;
                      End;
                End;
            End;      {Case statement}
          stop:= dum;


         If (errcode[1] = 0) And (locreal[1] <= 360.0) Then
            Begin
               If (errcode[2] = 0) And (locreal[2] < 60.0) Then
                  locreal[1]:= locreal[1] + locreal[2] / 60.0;
               If (errcode[3] = 0) And (locreal[3] < 60.0) Then
                  locreal[1]:= locreal[1] + locreal[3] / 3600.0;
            End
         Else
            locreal[1]:= default;

         While locreal[1] >= 360.0 Do
           locreal[1]:= locreal[1] - 360.0;

         If dir Then
           default:= locreal[1]
         Else
           default:= -locreal[1];
      End;   {StringReadLat}

   Function StrPad(instring: String; padding: Integer): String;
      Var
         i: Integer;
         temp: String;
      Begin
         temp:= '';
         temp:= instring;
         For i:= 1 to padding Do
            temp:= Concat(temp,' ');
         StrPad:= temp;
      End;

   Function StrInsert(instring: String; position: Integer;
                      insert: String): String;
      Var
         i,
         len1,
         len2: Integer;
         temp: String;
      Begin
         temp:= '';
         position:= position - 1;
         len1:= Length(instring);
         If len1 <= position Then
            For i:= 1 to len1 Do
               temp:= Concat(temp,instring[i])
         Else
            For i:= 1 to position Do
               temp:= Concat(temp,instring[i]);

         len2:= position - (len1);
         temp:= StrPad(temp,len2);
         {
         For i:= len1+1 to position Do
            temp:= Concat(temp,' ');
         }
         temp:= Concat(temp,insert);
         position:= position + 1;
         For i:= position To len1 Do
            temp:= Concat(temp,instring[i]);
         StrInsert:= temp;
      End;


   Function StrDelete(instring: String; start, number: Integer): String;
      Var
         len1,
         len2,
         i: Integer;
         temp: String;
      Begin
         temp:= '';
         len1:= Length(instring);
         len2:= start + number;
         If len1 <= start Then
            For i:= 1 to len1 Do
               temp:= Concat(temp,instring[i])
         Else
            For i:= 1 to start-1 Do
               temp:= Concat(temp,instring[i]);

         For i:= len2 to len1 Do
            temp:= Concat(temp, instring[i]);
         StrDelete:= temp;
      End;

   Function LatString(degval: Float; mode: Integer): String;
      Var
         h, m, s: Float;
         temp1, temp2: String;
         dir: Boolean;
      Begin
         If degval > 0.0 Then
            dir:= True
         Else
            dir:= False;
         degval:= Abs(degval);
         temp1:= '';
         temp2:= '';
         h:= degval;
         m:= (degval - Trunc(h)) * 60.0;
         s:= (((degval - Trunc(h)) * 60.0) - Trunc(m)) * 60.0;
         Case mode Of
            1: Begin                           {+/-dd.dddddd}
                  Str(h:10:6, temp2);
                  If dir Then
                     temp1:= '+'
                  Else
                     temp1:= '-';
                  temp1:= Concat(temp1, temp2);
                  temp1:= Concat(temp1,' ');
               End;

            2: Begin                           {dd.dddddd X}
                  Str(h:10:6, temp2);
                  temp1:= Concat(temp1, temp2);
                  If dir Then
                     temp1:= Concat(temp1,' N ')
                  Else
                     temp1:= Concat(temp1,' S');
                  temp1:= Concat(temp1, ' ');
               End;

            3: Begin                           {X dd mm.mmmm}
                  h:= Trunc(h);
                  m:= (Round(m * 10000.0) / 10000.0);
                  If m >= 60.0 Then
                     Begin
                        m:= m - 60.0;
                        h:= h + 1;
                     End;
                  Str(Trunc(h):3,temp2);
                  temp1:= Concat(temp1, temp2);
                  temp1:= Concat(temp1,' ');
                  Str(m:6:4, temp2);
                  If m < 10.0 Then
                     temp1:= Concat(temp1,'0');
                  temp1:= Concat(temp1, temp2);
                  temp1:= Concat(temp1, #39);
                  If dir Then
                     temp1:= Concat(temp1,' N')
                  Else
                     temp1:= Concat(temp1,' S');
               End;
            4: Begin                           {X dd mm ss.sss}
                  h:= Trunc(h);
                  m:= Trunc(m);
                  s:= (Round(s * 1000.0) / 1000.0);
                  If s >= 60.0 Then
                     Begin
                        s:= s - 60.0;
                        m:= m + 1.0;
                        If m >= 60.0 Then
                           Begin
                              m:= m - 60.0;
                              h:= h + 1.0;
                           End;
                     End;

                  Str(Trunc(h):3, temp2);
                  temp1:= Concat(temp1, temp2);
                  temp1:= Concat(temp1,' ');
                  Str(Trunc(m):1, temp2);
                  If m < 10.0 Then
                     temp1:= Concat(temp1,'0');
                  temp1:= Concat(temp1, temp2);
                  temp1:= Concat(temp1,#39);
                  s:= Round(s*1000.0) / 1000.0;
                  Str(s:5:3, temp2);
                  If s < 10.0 Then
                     temp1:= Concat(temp1,'0');
                  temp1:= Concat(temp1, temp2);
                  temp1:= Concat(temp1, #34);
                  If dir Then
                     temp1:= Concat(temp1,' N')
                  Else
                     temp1:= Concat(temp1,' S');
               End;
         End;
         LatString:= temp1;
      End;   {Function LatString}

   Function LonString(degval: Float; mode: Integer): String;
      Var
         h, m, s: Float;
         temp1, temp2: String;
         dir: Boolean;
      Begin
         If degval > 0.0 Then
            dir:= True
         Else
            dir:= False;
         degval:= Abs(degval);
         temp1:= '';
         temp2:= '';
         h:= degval;
         m:= (degval - Trunc(h)) * 60.0;
         s:= (((degval - Trunc(h)) * 60.0) - Trunc(m)) * 60.0;
         Case mode Of
            1: Begin                           {ddd.dddddd}
                  Str(h:10:6, temp2);
                  If dir Then
                     temp1:= '+'
                  Else
                     temp1:= '-';
                  temp1:= Concat(temp1, temp2);
                  temp1:= Concat(temp1, ' ');
               End;

            2: Begin                           {X ddd.dddddd}
                  Str(h:10:6, temp2);
                  temp1:= Concat(temp1, temp2);
                  If dir Then
                     temp1:= Concat(temp1,' E')
                  Else
                     temp1:= Concat(temp1,' W');
                  temp1:= Concat(temp1, ' ');
               End;

            3: Begin                           {X ddd mm.mmmm}
                  h:= Trunc(h);
                  m:= (Round(m * 10000.0) / 10000.0);
                  If m >= 60.0 Then
                     Begin
                        m:= m - 60.0;
                        h:= h + 1.0;
                     End;
                  Str(Trunc(h):3,temp2);
                  temp1:= Concat(temp1, temp2);
                  temp1:= Concat(temp1, ' ');
                  Str(m:6:4, temp2);
                  If m < 10.0 Then
                     temp1:= Concat(temp1,'0');
                  temp1:= Concat(temp1, temp2);
                  temp1:= Concat(temp1, #39);
                  If dir Then
                     temp1:= Concat(temp1,' E')
                  Else
                     temp1:= Concat(temp1,' W');
               End;
            4: Begin                           {X ddd mm ss.sss}
                  h:= Trunc(h);
                  m:= Trunc(m);
                  s:= (Round(s * 1000.0) / 1000.0);
                  If s >= 60.0 Then
                     Begin
                        s:= s - 60.0;
                        m:= m + 1;
                        If m >= 60.0 Then
                           Begin
                              m:= m - 60.0;
                              h:= h + 1.0;
                           End;
                     End;

                  Str(Trunc(h):3, temp2);
                  temp1:= Concat(temp1, temp2);
                  temp1:= Concat(temp1, ' ');
                  Str(Trunc(m):1, temp2);
                  If m < 10.0 Then
                     temp1:= Concat(temp1,'0');
                  temp1:= Concat(temp1, temp2);
                  temp1:= Concat(temp1, #39);
                  temp2:= '';
                  Str(s:5:3, temp2);
                  If s < 10.0 Then
                     temp1:= Concat(temp1,'0');
                  temp1:= Concat(temp1, temp2);
                  temp1:= Concat(temp1, #34);
                  If dir Then
                     temp1:= Concat(temp1,' E')
                  Else
                     temp1:= Concat(temp1,' W');
               End;
         End;
         LonString:= temp1;
      End;   {Function LonString}

   Function StrCaps(instring: String): String;
      Var
         i,j: Integer;
      Begin
         j:= Length(instring);
         For i:= 1 to j Do
            If (Ord(instring[i]) > 96) And (Ord(instring[i]) < 123) Then
               instring[i]:= Chr(Ord(instring[i]) - 32);
         StrCaps:= instring;
      End;   {Function StrCaps}

   Function StrStrip(instring, search: String): String;
      Var
         i,j: Integer;
      Begin
         j:= Length(search);
         i:= Pos(search, instring);
         While i <> 0 Do
            Begin
               Delete(instring, i, j);
               i:= Pos(search, instring);
            End;
         StrStrip:= instring;
      End;   {Function StrStrip}

   Function StrLTrim(instring: String): String;
      Var
         i,j: Integer;
      Begin
         i:= 1;
         j:= Length(instring);
         While (i <= j) And (instring[i] = ' ') Do
            i:= i + 1;
         StrLTrim:= Copy(instring, i, (j - i + 1));
      End;   {Function StrLTrim}

   Function StrRTrim(instring: String): String;
      Var
         i,j: Integer;
      Begin
         j:= Length(instring);
         i:= j;
         While (i >= 1) And (instring[i] = ' ') Do
            i:= i - 1;
         StrRTrim:= Copy(instring,1,i);
      End;   {Function StrRTrim}

   Function StrReplace(instring, oldstring, newstring: String): String;
      Var
         i,j,k: Integer;
         temp,
         temp1: String;
      Begin
         temp:= '';
         temp1:= instring;
         j:= Length(oldstring);
         k:= Length(newstring);
         i:= Pos(oldstring, instring);
         While i <> 0 Do
            Begin
               temp:= Concat(temp, Copy(instring,1,i-1));
               temp:= Concat(temp, newstring);
               temp1:= temp;
               Delete(instring, 1,(i+j-1));
               i:= Pos(oldstring, instring);
            End;
         If temp1 <> instring Then
            temp1:= Concat(temp1, instring);
         StrReplace:= temp1;
      End;   {Function StrReplace}


   Function TimeString(Var timevar: Float;
                       Var hour, minute, second: Integer;
                       mode: Integer): String;
      Var
         locreal: Float;
         locint1,
         locint2: LongInt;
         h, m, s: Integer;
         temp,
         temp1: String;
         secs: Float;
      Begin
         If timevar >= 0.0 Then
            Begin
               While timevar >= 24.0 Do
                  timevar:= Timevar - 24.0;
               hour:= Trunc(timevar);
               minute:= Trunc((timevar - hour) * 60.0);
               second:= Trunc((((timevar - hour) * 60.0) - minute) * 60.0);
               secs:= (((timevar - hour) * 60.0) - minute) * 60.0;
            End
         Else
            timevar:= second /3600  +
                      minute / 60.0 +
                      hour;
         temp:= '';
         If (mode < 1) Or (mode > 4) Then
            mode:= 3;     {default to mode 3}
         Case mode Of
            1: Str(timevar:7:4, temp);                  {hh.hhhh}
            2: Begin                                    {hh:mm.mm}
                  locreal:= minute + (secs / 60.0);
                  locreal:= Round(locreal * 100.0) / 100.0;
                  If locreal >= 60.0 Then
                     Begin
                        locreal:= locreal - 60.0;
                        hour:= hour + 1;
                     End;
                  temp:= '';
                  temp1:= '';
                  Str(hour:2, temp1);
                  temp:= Concat(temp, temp1);
                  temp:= Concat(temp, ':');
                  temp1:= '';
                  If locreal < 10.0 Then
                     temp:= Concat(temp, '0');
                  Str(locreal:4:2,temp1);
                  temp:= Concat(temp, temp1);
               End;
            3: Begin                                    {hh:mm:ss}
                  temp:= '';
                  temp1:= '';
                  Str(hour:2, temp);
                  temp:= Concat(temp, ':');

                  If minute < 10 Then
                     temp:= Concat(temp, '0');
                  temp1:= '';
                  Str(minute:1, temp1);
                  temp:= Concat(temp, temp1);
                  temp:= Concat(temp, ':');

                  If second < 10 Then
                     temp:= Concat(temp, '0');
                  temp1:= '';
                  Str(second:1, temp1);
                  temp:= Concat(temp, temp1);
               End;
            4: Begin                                    {hh:mm:ss.ss}
                  secs:= Round(secs * 100.0) / 100.0;
                  If secs >= 60.0 Then
                     Begin
                        secs:= secs - 60.0;
                        minute:= minute + 1;
                        If minute >= 60 Then
                          Begin
                             minute:= minute - 60;
                             hour:= hour + 1;
                          End;
                     End;
                  temp:= '';
                  temp1:= '';
                  Str(hour:2,temp);
                  temp:= Concat(temp, ':');

                  If minute < 10 Then
                     temp:= Concat(temp, '0');
                  Str(minute:1, temp1);
                  temp:= Concat(temp, temp1);
                  temp:= Concat(temp, ':');

                  If secs < 10.0 Then
                     temp:= Concat(temp, '0');
                  temp1:= '';
                  Str(secs:4:2, temp1);
                  temp:= Concat(temp, temp1);
               End;
         End;    {Case mode Of}
         TimeString:= temp;
      End;



   Procedure StrReadReal(instring: String;
                         start: Integer;
                         Var stop: Integer;
                         Var returnvalue: Float;
                         Var error: Boolean);
      Var
         tlength,
         errcode: Integer;
         temp: String;
         done,
         decimal: Boolean;
         locreal: Float;
      Begin
         tlength:= Length(instring);
         temp:= '';
         While (Not(instring[start] In ['0'..'9','.'])) And
               (start <= tlength) Do
            start:= start + 1;

         If (start <= tlength) Then
            Begin
               If instring[start-1] In ['-','+'] Then  {Check for sign}
                  temp:= Concat(temp, instring[start - 1])
               Else
                  temp:= Concat(temp, '+');  {default to positive}

               If instring[start] = '.' Then  {Check for decimal in 1st position}
                  temp:= Concat(temp,'0');  {put 0 in as integer portion of real}
            End;

         stop:= start;
         If start <= tlength Then
            Begin
               done:= False;
               decimal:= False;
               While Not done Do
                  Begin

{Check for scientific notation and finish parse}
                     If instring[stop] In ['e','E','d','D'] Then
                        Begin
{need an integer to preceed an exponent character}
                           If instring[stop-1] In ['0'..'9'] Then
                              Begin
{add an E to the temp string and increment stop}
                                 temp:= Concat(temp, 'E');
                                 stop:= stop + 1;
{check to see if we have emptied the input string}
                                 If stop <= tlength Then
                                    Begin
{at least one more character is there check it for sign}
                                       If instring[stop] In ['+','-'] Then
                                          Begin
                                             temp:= Concat(temp, instring[stop]);
                                             stop:= stop + 1;
                                          End
{the last character was not a sign assume a positive sign}
                                       Else
                                          temp:= Concat(temp, '+');
{check to see if there is still data left}
                                       If stop <= tlength Then
                                          Begin
{see if remaining data is numeral. we need at least one after exponent
 check for existence of first numeral}
                                             If instring[stop] In ['0'..'9'] Then
                                                Begin
                                                   temp:= Concat(temp, instring[stop]);
                                                   stop:= stop + 1;
                                                End
{If not a numeral assume an exponent of zero and terminate}
                                             Else
                                                Begin
                                                   temp:= Concat(temp, '00');
                                                   done:= True;
                                                End;
{check for existence of 2nd numeral after exponent}
                                             If stop <= tlength Then
                                                If instring[stop] In ['0'..'9'] Then
                                                   Begin
                                                      temp:= Concat(temp, instring[stop]);
                                                      stop:= stop + 1;
                                                      done:= True;
                                                   End
{2nd numeral did not exist. Can't assume 0, terminate}
                                                Else
                                                   done:= True;


                                          End  {If stop <= tlength}
{no data left after placing sign. assume exponent of 0 and terminate}
                                       Else
                                          Begin
                                             temp:= Concat(temp, '00');
                                             done:= True;
                                          End;
                                    End   {If stop <= tlength}
{no characters exist after the exponent character. Assume 0's and terminate}
                                 Else
                                    Begin
                                       temp:= Concat(temp, '+00');
                                       done:= True;
                                    End;
                              End

{Without an integer before an exponent character do not continue.
 Assume character is not an exponent}
                            Else   {If instring[stop-1] In ['0'..'9']}
                              done:= True;
                        End   {If instring[stop] In ['e'..'d']}



                     Else
                     If decimal Then
                        If instring[stop] In ['0'..'9'] Then
                           temp:= Concat(temp, instring[stop])
                        Else       {If in ['0'..'9']}
                           done:= True

                     Else If instring[stop] In ['0'..'9','.'] Then
                        Begin
                           temp:= Concat(temp, instring[stop]);
                           If instring[stop] = '.' Then
                              decimal:= True;
                        End
                     Else
                        done:= True;

                     If Not done Then
                        stop:= stop + 1;

                     If stop > tlength Then
                        done:= True;

                  End;   {While Not done Do}

{check to make sure there is something there to read}
               If Length(temp) > 0 Then
                  Begin
                     Val(temp,locreal,errcode);
                     If errcode = 0 Then
                        returnvalue:= locreal
                     Else
                        returnvalue:= 0.0;
                  End
{If no data in temp then set return values to defaults}
               Else
                  Begin
                     errcode:= 1;
                     returnvalue:= 0.0;
                  End;
            End   {If start <= tlength Then}

         Else  {If start > tlength Then  no value to return}
            Begin
               returnvalue:= 0.0;
               errcode:= 1;
            End;

         If errcode = 0 Then   {test errcode for correct return of boolean}
            error:= False
         Else
            error:= True;
      End;   {Procedure StrReadReal}

   Procedure StrReadLongInt(instring: String;
                            start: Integer;
                            Var stop: Integer;
                            Var returnvalue: LongInt;
                            Var error: Boolean);
      Var
         errcode,
         tlength: Integer;
         temp: String;
         done,
         signed: Boolean;
         locint: LongInt;
      Begin
         tlength:= Length(instring);
         temp:= '';
         While (Not(instring[start] In ['0'..'9'])) And
               (start <= tlength) Do
            start:= start + 1;
         If (start <> 1) And (start <= tlength) Then
            If instring[start-1] In ['-','+'] Then
               temp:= Concat(temp, instring[start - 1]);
         stop:= start;
         If start <= tlength Then
            Begin
               signed:= False;
               done:= False;
               While Not done Do
                  Begin
                     If instring[stop] In ['0'..'9'] Then
                        temp:= Concat(temp, instring[stop])
                     Else
                        done:= True;
                     If Not done Then
                        stop:= stop + 1;

                     If stop > tlength Then
                        done:= True;
                  End;

               If Length(temp) > 0 Then
               Val(temp,locint,errcode);
               If errcode = 0 Then
                  returnvalue:= locint
               Else
                  returnvalue:= 0;
            End
         Else
            Begin
               returnvalue:= 0;
               errcode:= 1;
            End;
         If errcode = 0 Then
            error:= False
         Else
            error:= True;
      End;   {Procedure StrReadLongInt}

   Procedure StrReadInteger(instring: String;
                            start: Integer;
                            Var stop: Integer;
                            Var returnvalue: Integer;
                            Var error: Boolean);
      Var
         errcode,
         tlength: Integer;
         temp: String;
         done,
         signed: Boolean;
         locint: Integer;
      Begin
         tlength:= Length(instring);
         temp:= '';
         While (Not(instring[start] In ['0'..'9'])) And
               (start <= tlength) Do
            start:= start + 1;
         If (start <> 1) And (start <= tlength) Then
            If instring[start-1] In ['-','+'] Then
               temp:= Concat(temp, instring[start - 1]);
         stop:= start;
         If start <= tlength Then
            Begin
               signed:= False;
               done:= False;
               While Not done Do
                  Begin
                     If instring[stop] In ['0'..'9'] Then
                        temp:= Concat(temp, instring[stop])
                     Else
                        done:= True;
                     If Not done Then
                        stop:= stop + 1;

                     If stop > tlength Then
                        done:= True;
                  End;

               If Length(temp) > 0 Then
               Val(temp,locint,errcode);
               If errcode = 0 Then
                  returnvalue:= locint
               Else
                  returnvalue:= 0;
            End
         Else
            Begin
               returnvalue:= 0;
               errcode:= 1;
            End;
         If errcode = 0 Then
            error:= False
         Else
            error:= True;
      End;   {Procedure StrReadInteger}

   Function Fract(inval: Float): Float;
      Var
         temp: Float;
      Begin
         Fract:= inval - Trunc(inval);
      End;


   End.