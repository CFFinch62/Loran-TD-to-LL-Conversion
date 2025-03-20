Unit Types;

   Interface
      Uses Flt;
      Type
         Station_Rec = Record
                          coding_delay,
                          emission_delay,
                          lat,
                          lon,
                          alt: Float;
                          use: Boolean;
                        End;
         Station_Rec_Array = Array[0..5] Of Station_Rec;
         Geodetic = (NAD27, WGS72, NAD83, WGS84);
         Array_2x2 = Array[1..2,1..2] Of Float;
         Real_Array_1x4 = Array[0..5] Of Float;
         Str30 = String[30];
         Length_Type = (foot, yard, meter, nm);
         User_Rec =  Record
                        ecef_x,
                        ecef_y,
                        ecef_z,
                        altitude,
                        lat,
                        lon,
                        lat1,
                        lon1,
                        range,
                        azimuth,
                        delta_x,
                        delta_y: Float;
                        filename: String;
                        td,
                        td2: Real_array_1x4;
                        gri,
                        file_year,
                        file_day,
                        hour,
                        minute,
                        first,
                        second,
                        decimals,
                        mode: Integer;
                        coord_sys: Geodetic;
                        secs: Float;
                        new_value: Boolean;
                        length: Length_Type;
                     End;
         User_File = File Of User_Rec;

   Implementation
   End.