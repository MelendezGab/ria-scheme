% block_preprocessing receives an image block, which is modified to avoid
% overflow/underflow issues. 
% A pre-processed block is returned together with control information
% required to recover original values. 

function [bdata, preproc_block] = block_preprocessing(block)
    global hp_bits;
    aux = block;
    block_dims = size(block);
    
    aux(aux < 2) = aux(aux < 2) + 1;        % Increment grayscale values 0 and 1 
    aux(aux > 253) = aux(aux > 253) - 1;    % Decrement grayscale values 255 and 254 
    
    cont = 0;
    recovery_sequence = '';
    % Create the recovery sequence Rs
    for i = 1:block_dims(1)
        for j = 1:block_dims(2)
            if aux(i, j) == 2 || aux(i, j) == 253
                cont = cont + 1;
                if aux(i, j) == block(i, j)
                    recovery_sequence = strcat(recovery_sequence,'0');
                else 
                    recovery_sequence = strcat(recovery_sequence,'1');
                end
            end
        end
    end
    
    if cont == 0
        bdata = '0';
        preproc_block = block;
    else        
        bdata = strcat('1', dec2bin(length(recovery_sequence), hp_bits), recovery_sequence);
        preproc_block = aux;
    end
end
