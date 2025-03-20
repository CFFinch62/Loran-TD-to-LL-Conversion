{ ******************************************************************
  *                                                                *
  *                  The AIS Programmer ToolKits                   *
  *                      Global Declarations                       *
  *                    Revision 1.0  08/31/88                      *
  *                                                                *
  *               Abaire Information Services, Inc.                *
  *                      2302 Ginter Street                        *
  *                   Richmond, Virginia  23228                    *
  *                         804 262-2966                           *
  *                     Compuserve  74017,46                       *
  *                                                                *
  *                     Copyright 1987, 1988                       *
  *              by Abaire Information Services, Inc.              *
  *                     All rights reserved                        *
  *                                                                *
  ******************************************************************
}
unit atglob;
interface
uses Dos,Crt;

type StringType = String;

procedure StdError( ErrNo, ErrParm : integer );
function GetDateStr( Style : integer ) : String;
function GetTimeStr( Style : integer ) : String;

implementation
function GetDateStr( Style : integer ) : String;
   var
     Month,Day  : string[10];
     Year       : string[4];
     Y,M,D,R    : word;

   function GetMonth( Mon : integer ) : String;
      begin
      case Mon of
         1  : GetMonth := 'January';
         2  : GetMonth := 'February';
         3  : GetMonth := 'March';
         4  : GetMonth := 'April';
         5  : GetMonth := 'May';
         6  : GetMonth := 'June';
         7  : GetMonth := 'July';
         8  : GetMonth := 'August';
         9  : GetMonth := 'September';
         10 : GetMonth := 'October';
         11 : GetMonth := 'November';
         12 : GetMonth := 'December';
         end;
      end;

   begin
   GetDate( Y, M, D ,R );
   Str(Y,Year);
   Str(M,Month);
   Str(D,Day);
   case Style of
      0 : begin
          if Length(Month) < 2 then Month := '0' + Month;
          if Length(Day) < 2 then Day := '0' + Day;
          Delete(Year,1,2);
          GetDateStr := Month + '/' + Day + '/' + Year;
          end;
      1 : begin
          if Length(Month) < 2 then Month := '0' + Month;
          if Length(Day) < 2 then Day := '0' + Day;
          GetDateStr := Month + '/' + Day + '/' + Year;
          end;
      2 : begin
          Month := GetMonth(M);
          GetDateStr := Month + ' ' + Day + ', ' + Year;
          end;
      3 : begin
          Month := GetMonth(M);
          GetDateStr := Day + ' ' + Month + ' ' + Year;
          end;
      end;
   end;

function GetTimeStr( Style : integer ) : String;
   var
     Hour,Min,Sec,HSec : string[2];
     H,M,S,Hs          : word;
     NStr              : string[4];
   begin
   GetTime( H, M, S, Hs );
   Str(H,Hour);
   Str(M,Min);
   Str(S,Sec);
   Str(Hs,HSec);
   case Style of
      0 : begin
          if Length(Hour) < 2 then Hour := '0' + Hour;
          if Length(Min)  < 2 then Min  := '0' + Min;
          GetTimeStr := Hour + ':' + Min;
          end;
      1 : begin
          if H > 12
             then begin
                  H := H - 12;
                  Str(H,Hour);
                  NStr := 'p.m.';
                  end
             else NStr := 'a.m.';
          if Length(Min) < 2 then Min := '0' + Min;
          GetTimeStr := Hour + ':' + Min + ' ' + NStr;
          end;
      2 : begin
          if Length(Hour) < 2 then Hour := '0' + Hour;
          if Length(Min)  < 2 then Min  := '0' + Min;
          if Length(Sec)  < 2 then Sec  := '0' + Sec;
          GetTimeStr := Hour + ':' + Min + ':' + Sec;
          end;
      3 : begin
          if Length(Hour) < 2 then Hour := '0' + Hour;
          if Length(Min)  < 2 then Min  := '0' + Min;
          if Length(Sec)  < 2 then Sec  := '0' + Sec;
          if Length(HSec) < 2 then HSec := '0' + HSec;
          GetTimeStr := Hour + ':' + Min + ':' + Sec + '.' + HSec;
          end;
      end;
   end;

procedure StdError( ErrNo, ErrParm : integer );
   begin
   Window(1,1,80,25); ClrScr;
   GotoXY(1,1);
   writeln('Err=',ErrNo,' Parm=',ErrParm,'. Program aborted.');
   halt;
   end;
end.
{ ****************************************************************** }
