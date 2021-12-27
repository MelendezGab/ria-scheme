% payload_embedding receives four IWT sub-bands and the payload. 
% cH, cV and cD sub-bands have been previously compressed according to 
% threshold T_c.
% This function returns a marked block.

function [marked_block] = payload_embedding(cA, cH, cV, cD, payload)
    [dim1_sb, dim2_sb] = size(cA);
    load('coor16.mat', 'coor'); % Sequence of coordinates to embed bits. 
    payload_size = length(payload)+1;
    liftscheme = liftwave('haar','int2int');
    cont = 1;
    for h = 1:dim1_sb*dim2_sb
        i = coor(1, h);
        j = coor(2, h);
        if cont < payload_size
            cH(i, j) = (cH(i, j)*2) + bin2dec(payload(cont));
            cont = cont +1;
        else
            break
        end
        if cont < payload_size
            cV(i, j) = (cV(i, j)*2) + bin2dec(payload(cont));
            cont = cont + 1;
        else
            break
        end
        if cont < payload_size
            cD(i, j) = (cD(i, j)*2) + bin2dec(payload(cont));
            cont = cont + 1;
        else
            break
        end 
    end            
    marked_block = ilwt2(cA, cH, cV, cD, liftscheme);
end
