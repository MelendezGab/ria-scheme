% block_posprocessing receives a pre-processed block and recovers original 
% grayscale values using the received recovery sequence. 

function [block] = block_posprocessing(recovery_sequence, preproc_block)
    global hp_bits;
    block_dims = size(preproc_block);
    aux = preproc_block;
    
    if strcmp(recovery_sequence(1), '0')
        block = preproc_block;
    else    
        recovery_sequence(1) = [];
        recovery_sequence(1:hp_bits) = [];
        aux(aux == 1) = 0;
        aux(aux == 254) = 255;

        cont = 0;
        for i = 1:block_dims(1)
            for j = 1:block_dims(2)
                if aux(i, j) == 2 || aux(i, j) == 253
                    cont = cont + 1;
                    if recovery_sequence(cont) == '1'
                        if aux(i, j) == 2
                            aux(i, j) = 1;
                        else
                            aux(i, j) = 254;
                        end
                    end
                end
            end
        end
        block = aux;
    end
end