Unit Math;
   Interface
   Uses Dos, Crt, Flt;
      Function Arccos(temp: Float): Float;
      Function Tan(value: Float): Float;
      Function Atan(x,y: Float;
                    mode: Integer): Float;

   Implementation
{Function Atan  is called to give an angle from a 0,0 origin to a given x,y
 coordinate on an x,y axis.  This function accounts for quadrants and returns
 the angle in degrees if mode is a 1 or radians if any other value}
        Function Atan(x,y: Float;
                     mode: Integer): Float;
         Var
            temp: Float;
         Begin

   {first check for cases of x or y equal to zero}
            If y = 0.0 Then
               If x >= 0.0 Then
                  temp:= PI/2
               Else
                  temp:= 3*PI/2;

            If x = 0.0 Then
               If y > 0.0 Then
                 temp:= 0.0
               Else
                  temp:= PI;

  {Check for values in first and 2nd quadrant (x  > 0.0)}

            If (x <> 0.0) AND (y <> 0.0) Then
               If x > 0.0 Then

                  If y > 0.0 Then

  {value in first quadrant}
                     temp:= Arctan(Abs(x/y))

                  Else

  {value in 2nd quadrant}
                     temp:= Arctan(Abs(y/x)) + PI/2

  {otherwise values must be in 3rd or 4th quadrants}

               Else   {If x > 0.0}
                  If y < 0.0 Then

   {value in 3rd quadrant}
                     temp:= Arctan(Abs(x/y)) + PI
                  Else

   {value in 4th quadrant}
                     temp:= Arctan(Abs(y/x)) + 3*PI/2;

            If mode = 1 Then
               temp:= temp * 180.0/PI;

            Atan:= temp;
         End;    {Function Atan}

      Function Tan(value: Float): Float;
         Begin
            Tan:= Sin(value) / Cos(value);
         End;

      Function Arccos(temp: Float): Float;
         Begin
            If (temp < 1) And (temp > -1) Then
               temp:= Arctan(Sqrt(1-Sqr(temp))/temp)
            Else
               If temp = 1.0 Then
                  temp:= 0.0
               Else
                  If temp = -1.0 Then
                     temp:= PI;
            Arccos:= temp;
        End;
   End.