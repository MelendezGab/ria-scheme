function [rec_image] = get_recovered_image(Cg_rec, pixels_number, blocks_number, ind_blocks, Ic_dim1, Ic_dim2, block_dim1, block_dim2)
    recovered_coeffients = cell2mat(Cg_rec);
    for i=1:(blocks_number)
        coef_set{i} = recovered_coeffients(pixels_number*(i-1)+1:pixels_number*i);
    end

    coef_set(:) = coef_set(ind_blocks);      % Inverse blocks permutation

    for i=1:numel(coef_set)
    pixels_set{i} = (idct2(reshape(cell2mat(coef_set(i)),block_dim1,block_dim2))+128)';
    end

    rec_image = uint8(cell2mat(reshape(pixels_set, Ic_dim1/block_dim1, Ic_dim2/block_dim2)));
end

