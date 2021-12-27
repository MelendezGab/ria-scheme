% An IWT sub-band is received and compressed according to threshold T_c.
% This function returns a compressed IWT sub-band and compressioen errors,
% which must be embedded along with the payload.

function [compressed_sub_band, comp_error] = compression(sub_band, T_c)
    dims_sb = size(sub_band);    
    comp_error = '';
    for i = 1:dims_sb(1)
        for j = 1:dims_sb(2)
            x = sub_band(i,j);
            if abs(x) < T_c
                sub_band(i, j) = x;
            else
                sub_band(i,j) = sign(x) * (floor((abs(x) - T_c)/2) + T_c);
                error = (sign(sub_band(i, j))*(2*abs(sub_band(i, j)) - T_c)) - x;                      
                comp_error = strcat(comp_error, num2str(abs(error))); 
            end    
        end
    end
    
    compressed_sub_band = sub_band;
end

