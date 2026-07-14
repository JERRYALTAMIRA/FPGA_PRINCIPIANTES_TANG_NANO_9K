// Paleta generada automaticamente
    case (pixel_val)
        3'd0: begin // RGB: (0, 255, 0)
            logo_viewport_mask = 0;
            red = 0; green = 0; blue = 0;
        end
        3'd1: begin // RGB: (238, 255, 255)
            logo_viewport_mask = 1;
            red = 5'd29; green = 6'd63; blue = 5'd31;
        end
        3'd2: begin // RGB: (190, 167, 152)
            logo_viewport_mask = 1;
            red = 5'd23; green = 6'd41; blue = 5'd19;
        end
        3'd3: begin // RGB: (221, 119, 51)
            logo_viewport_mask = 1;
            red = 5'd27; green = 6'd29; blue = 5'd6;
        end
        3'd4: begin // RGB: (48, 82, 116)
            logo_viewport_mask = 1;
            red = 5'd6; green = 6'd20; blue = 5'd14;
        end
        3'd5: begin // RGB: (162, 30, 5)
            logo_viewport_mask = 1;
            red = 5'd20; green = 6'd7; blue = 5'd0;
        end
        3'd6: begin // RGB: (39, 4, 17)
            logo_viewport_mask = 1;
            red = 5'd4; green = 6'd1; blue = 5'd2;
        end
        3'd7: begin // RGB: (0, 34, 68)
            logo_viewport_mask = 1;
            red = 5'd0; green = 6'd8; blue = 5'd8;
        end
    endcase
