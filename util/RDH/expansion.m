% A compressed IWT sub-band is received and expanded according to threshold 
% T_c. The compression error sequence is required to recover original 
% coefficients.
% This function returns an expanded sub-band and the remaining errors. 

function [expanded_sub_band, remaining_error] = expansion(sub_band, T_c, error)    
    expanded_sub_band = sub_band;
    [dim1_sb, dim2_sb] = size(sub_band);
    for i = 1:dim1_sb
        for j = 1:dim2_sb
            if abs(expanded_sub_band(i, j)) >= T_c                          
                x=expanded_sub_band(i, j);
                expanded_sub_band(i, j) = sign(x)*((2*abs(x)) - T_c);
                expanded_sub_band(i, j) = expanded_sub_band(i, j) + sign(x)*bin2dec(error(1));
                error(1)=[];
            end   
        end
    end
    remaining_error = error;
end
