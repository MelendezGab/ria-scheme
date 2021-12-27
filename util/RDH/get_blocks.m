% get_blocks receives an image and divides it into nonoverlapping blocks of
% size [size_n, size_m].
% This function returns an array of image blocks

function [blocks_array] = get_blocks(image, size_n, size_m)
    image_dims = size(image);
    a = 1:size_n:image_dims(1);
    b = 1:size_m:image_dims(2);
    [i, j] = ndgrid(a, b);
    blocks = arrayfun(@(x, y) image(x:x+size_n-1, y:y+size_m-1), i, j, 'un', 0);
    blocks_array = reshape(blocks, 1, (image_dims(1)/size_n * image_dims(2)/size_m));
end

