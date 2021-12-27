function authenticated_image = create_authenticated_image(array_blocks, tampered_blocks, im_dim1, im_dim2, block_dim1, block_dim2)
    rep_mat = zeros(block_dim1, block_dim2);
    rep_mat(:) = 255;
    array_blocks(tampered_blocks) = mat2cell(uint8(rep_mat), block_dim1, block_dim2);
    array_blocks = reshape(array_blocks, im_dim1/block_dim1, im_dim2/block_dim2);

    authenticated_image = uint8(cell2mat(array_blocks));
end