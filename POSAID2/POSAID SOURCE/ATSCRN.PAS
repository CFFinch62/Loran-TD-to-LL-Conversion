{ ******************************************************************
  *                                                                *
  *                    The AIS Screen ToolKit                      *
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
unit atscrn;
interface
uses Dos,Crt,atglob;

const
   NormTextColor : integer =   11;
   NormBGrdColor : integer =    0;
   InvTextColor  : integer =    0;
   InvBGrdColor  : integer =    7;
   StdMonoBase   = $B000;
   StdColorBase  = $B800;

var
   ScreenMode,
   ScreenWidth,
   ScreenPage       : integer;

procedure Beep( Frequency, Duration : integer );
procedure GetVideoMode;
procedure GetCursorSize( var Top,Bottom : integer );
procedure SetCursorSize( Top, Bottom : integer );
procedure HideCursor;
procedure ResetCursor;
procedure InverseVideo;
procedure NormalVideo;
procedure BlinkVideo;
procedure NoBlinkVideo;
function Blinkon : boolean;
procedure Pause( S : String );
procedure Show( S : String; Duration : integer );
function Response( S : String ) : boolean;
procedure ScreenInit;

implementation
const
   StdScreenInit : boolean = false;
   StdMaxCol     : integer =   80;
   StdMaxRow     : integer =   25;

var
   StdBlinkOn       : boolean;
   StdTextColor,
   StdBGrdColor     : integer;
   StdCursorTop,
   StdCursorBot     : integer;

procedure Beep( Frequency, Duration : integer );
   begin
   Sound(Frequency);
   if Duration < 0 then Duration := 0;
   Delay(Duration);
   NoSound;
   end;

procedure GetVideoMode;
   var StdRegs : Registers;
   begin
   with StdRegs do
      begin
      AX := $0F00;
      Intr($10,StdRegs);
      ScreenMode  := Lo(AX);
      ScreenWidth := Hi(AX);
      ScreenPage  := Hi(BX);
      end;
   StdMaxCol := ScreenWidth;
   end;

procedure GetCursorSize( var Top,Bottom : integer );
   var StdRegs : Registers;
   begin
   with StdRegs do
      begin
      AX := $0300;
      Intr($10,StdRegs);
      Top    := Hi(CX);
      Bottom := Lo(CX);
      end;
   end;

procedure SetCursorSize( Top, Bottom : integer );
   var StdRegs : Registers;
   begin
   with StdRegs do
      begin
      AX := $0100;
      CX := (Top shl 8) + Bottom;
      Intr($10,StdRegs);
      end;
   end;

procedure HideCursor;
   begin
   SetCursorSize(14,0);
   end;

procedure ResetCursor;
   var StdRegs : Registers;
   begin
   if not StdScreenInit then StdError(3,0);
   with StdRegs do
      begin
      AX := $0100;
      CX := (StdCursorTop shl 8) + StdCursorBot;
      Intr($10,StdRegs);
      end;
   end;

procedure InverseVideo;
   begin
   StdTextColor := InvTextColor;
   StdBGrdColor := InvBGrdColor;
   if StdBlinkOn
      then TextColor(StdTextColor+Blink)
      else TextColor(StdTextColor);
   TextBackGround(StdBGrdColor);
   end;

procedure NormalVideo;
   begin
   StdTextColor := NormTextColor;
   StdBGrdColor := NormBGrdColor;
   if StdBlinkOn
      then TextColor(StdTextColor+Blink)
      else TextColor(StdTextColor);
   TextBackGround(StdBGrdColor);
   end;

procedure BlinkVideo;
   begin
   if not StdScreenInit then StdError(3,0);
   TextColor(StdTextColor+Blink);
   TextBackGround(StdBGrdColor);
   StdBlinkOn := true;
   end;

procedure NoBlinkVideo;
   begin
   if not StdScreenInit then StdError(3,0);
   TextColor(StdTextColor);
   TextBackGround(StdBGrdColor);
   StdBlinkOn := false;
   end;

function BlinkOn : boolean;
   begin
   if StdBlinkOn
      then BlinkOn := true
      else BlinkOn := false;
   end;

procedure StdSetMsg( var B : String; C,R : integer );
   var Ch       : char;
   begin
   while KeyPressed do Ch := ReadKey;
   GotoXY(C,R); write(B);
   FillChar(B[1],Length(B),' ');
   B[0] := chr(Length(B));
   end;

procedure Pause( S : String );
   var Ch       : char;
       Col, Row : integer;
   begin
   Col := WhereX; Row := WhereY;
   StdSetMsg(S,Col,Row);
   repeat until KeyPressed;
   while KeyPressed do Ch := ReadKey;
   GotoXY(Col,Row); write(S);
   end;

procedure Show( S : String; Duration : integer);
   var Col, Row : integer;
   begin
   Col := WhereX; Row := WhereY;
   StdSetMsg(S,Col,Row);
   if Duration < 0 then Duration := 0;
   Delay(Duration);
   GotoXY(Col,Row); write(S);
   end;

function Response( S : String ) : boolean;
   var Ch       : char;
       Col, Row : integer;
   begin
   Col := WhereX; Row := WhereY;
   StdSetMsg(S,Col,Row);
   repeat
      repeat until KeyPressed;
      Ch := ReadKey;
   until Ch in ['Y','y','N','n','1','0'];
   if Ch in ['Y','y','1']
      then Response := true
      else Response := false;
   while KeyPressed do Ch := ReadKey;
   GotoXY(Col,Row); write(S);
   end;

procedure ScreenInit;
   begin
   end;

begin
StdScreenInit := true;
StdBlinkOn    := false;
GetVideoMode;
NormalVideo;
GetCursorSize(StdCursorTop,StdCursorBot);
end.
{ ******************************************************************** }
