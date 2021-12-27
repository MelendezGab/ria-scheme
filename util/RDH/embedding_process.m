function [marked_image] = embedding_process(array_blocks, received_payload, T_c, original_image)

    % Read image and set requiered values: T, liftscheme  
    liftscheme = liftwave('haar','int2int');
    global ci_bits;

    block_dims = size(cell2mat(array_blocks(1)));
    im_dims = size(original_image);
    row_blocks = im_dims(1)/block_dims(1);
    col_blocks = im_dims(2)/block_dims(2);

    %array_blocks = get_blocks(imagen, block_dim1, block_dim2);
    blocks_number = length(array_blocks);
    block_index = 1:blocks_number;
    block_MACs = arrayfun(@(x, y, z) get_MAC(cell2mat(x), cell2mat(y), num2str(z), 'key'), array_blocks, received_payload, block_index, 'UniformOutput', false);

    marked_blocks = cell(1, blocks_number);

    for num_block = 1:blocks_number
        %disp(strcat('----------------- Block ',num2str(num_block),' -----------------'));
        block = cell2mat(array_blocks(num_block));
        payload = cell2mat(received_payload(num_block));
        payload = strcat(cell2mat(block_MACs(num_block)), payload);
        % Histogram pre-processing to avoid overflow/underflow
        [recovery_sequence, modified_block] = block_preprocessing(block);
        % Apply integer wavelet transform
        modified_block = double(modified_block);
        [cA, cH, cV, cD]=lwt2(modified_block, liftscheme);
        % High-frequency subbands compression
        [cH, errorCH] = compression(cH, T_c);
        [cV, errorCV] = compression(cV, T_c);
        [cD, errorCD] = compression(cD, T_c);
        % Prepare payload + control information    
        payload = strcat(recovery_sequence, payload);
        payload = strcat(payload, errorCH, errorCV, errorCD);
        payload = strcat(dec2bin(length(recovery_sequence) + length(errorCH) + length(errorCV) + length(errorCD), ci_bits), payload);
        % Embedd payload
        marked_block = payload_embedding(cA, cH, cV, cD, payload);
        marked_blocks(1, num_block) = {marked_block};     
    end

    marked_image = uint8(cell2mat(reshape(marked_blocks, [row_blocks, col_blocks])));
end
