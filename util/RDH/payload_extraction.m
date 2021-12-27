% payload_extraction receives a marked block. 
% Four IWT subbands are computed and least significant bits of marked
% coefficients are obtained to recover the payload. 
% This function returns the unmarked sub-bands and extracted payload. 

function [cA, cH, cV, cD, payload] = payload_extraction(marked_block)
    load('coor16.mat', 'coor') % Use the same coordinates as in embedding 
    aux = '';
    payload = '';
    liftscheme = liftwave('haar', 'int2int');
    marked_block = double(marked_block);
    [cA, cH, cV, cD] = lwt2(marked_block, liftscheme);
    [dim1_sb, dim2_sb] = size(cA);
    global ci_bits payload_length;
    for h = 1:ci_bits/3
        i = coor(1, h);
        j = coor(2, h);
        aux = strcat(aux, dec2bin(bitget(abs(cH(i, j, 1)), 1)));
        aux = strcat(aux, dec2bin(bitget(abs(cV(i, j, 1)), 1)));
        aux = strcat(aux, dec2bin(bitget(abs(cD(i, j, 1)), 1)));
    end
    
    payload_size = bin2dec(aux) + payload_length + ci_bits + 1;
    difference = payload_size - (dim1_sb*dim2_sb*3);    
    payload(1:payload_size - 1) = '0';
    
    payload(1:ci_bits) = aux(1:ci_bits);
    if difference < 0
        cont = 1;
        for h = 1:dim1_sb*dim2_sb
            i = coor(1, h);
            j = coor(2, h);
            if cont < payload_size
                b = bitget(abs(cH(i, j)), 1);
                payload(cont) = dec2bin(b);
                cH(i, j) = ((cH(i, j) - b)/2);
            else
                break
            end
            cont = cont + 1;
            if cont < payload_size
                b = bitget(abs(cV(i, j)), 1);
                payload(cont) = dec2bin(b);
                cV(i, j) = ((cV(i, j) - b)/2);
            else
                break
            end
            cont = cont + 1;
            if cont < payload_size
                b = bitget(abs(cD(i, j)), 1);
                payload(cont) = dec2bin(b);
                cD(i, j) = ((cD(i, j) - b)/2);
            else
                break
            end
            cont = cont + 1;
        end
    end 
end