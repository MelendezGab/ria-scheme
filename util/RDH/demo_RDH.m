%   Gabriel Melendez Melendez
%   November, 2021
% 
%   This is a reversible data hiding algorithm reimplementation, based on:
%   Xuan, Guorong, et al. "Reversible data hiding using integer wavelet transform and companding technique." International Workshop on Digital Watermarking. Springer, Berlin, Heidelberg, 2004.
%   The scheme is adapted to work with image blocks of size 32 x 32. 

clear all
tic
global T_c payload_length ci_bits hp_bits image_path results_path;
set_RDH_variables();

image_name = 'Lena';
Ic = double(imread(strcat(image_path, image_name, '.tiff')));
liftscheme = liftwave('haar', 'int2int');

block_dim1 = 32;
block_dim2 = 32;
[im_dim1,im_dim2]=size(Ic);
row_blocks = im_dim1/block_dim1;
col_blocks = im_dim2/block_dim2;

array_blocks = get_blocks(Ic, block_dim1, block_dim2);
blocks_number = length(array_blocks);

reference_values = 'something';          % In the RIA scheme this information is fullfilled with reference values and block index respectivelly
block_ind = 1;
block_MACs = arrayfun(@(x,y) get_MAC(cell2mat(x), reference_values, num2str(block_ind),'key'), array_blocks, 'UniformOutput', false);

no_emb = {};

hist_payload_lengths = zeros(blocks_number, 1);
hist_ctrl_inf_length = zeros(blocks_number, 1);

marked_blocks = cell(1, blocks_number);
compressed_blocks = cell(1, blocks_number);
recovered_blocks = cell(1, blocks_number);

for num_block = 1:blocks_number
    disp(char(strcat('----------------- Embedding block', {' '}, num2str(num_block), ' -----------------')));
    block = cell2mat(array_blocks(num_block));
    payload = num2str(round(rand(1, payload_length)));
    payload = payload(~isspace(payload));    
    payload = strcat(cell2mat(block_MACs(num_block)), payload);
    % Block preprocessing stage
    [recovery_sequence, modified_block]= block_preprocessing(block);
    % Apply wavelet transform    
    [cA, cH, cV, cD] = lwt2(modified_block, liftscheme);
    % High-frequency sub-bands compression 
    [cH, errorCH] = compression(cH, T_c);
    [cV, errorCV] = compression(cV, T_c);
    [cD, errorCD] = compression(cD, T_c);
    % Final payload including control information    
    payload = strcat(recovery_sequence, payload);
    payload = strcat(payload, errorCH, errorCV, errorCD);
    payload = strcat(dec2bin(length(recovery_sequence) + length(errorCH) + length(errorCV) + length(errorCD), ci_bits), payload);    
    hist_payload_lengths(num_block) = length(payload);
    hist_ctrl_inf_length(num_block) =  length(payload) - payload_length;
    compressed_coef_block = ilwt2(cA, cH, cV, cD, liftscheme);
    compressed_blocks(1,num_block) = {compressed_coef_block};
    % Payload embedding
    marked_block = payload_embedding(cA, cH, cV, cD, payload);
    marked_blocks(1, num_block) = {marked_block};
end

marked_image = uint8(cell2mat(reshape(marked_blocks, [row_blocks, col_blocks])));
%imwrite(im_marked,char(strcat(results_path, image_name, {' '}, 'Tc = ',num2str(T_c), '.tiff')));
%marked_im = imread(char(strcat(results_path, image_name, {' '}, 'Tc = ',num2str(T_c), '.tiff')));

cont_mal = 0;
array_blocks_marked = get_blocks(marked_image, block_dim1, block_dim2);
no_rev = {};

for num_block = 1:length(array_blocks_marked)    
    disp(char(strcat('----------------- Extraction block', {' '}, num2str(num_block), ' -----------------')));
    marked_block = cell2mat(array_blocks_marked(num_block));
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
    % Inverse process from here
    try
    [cAr, cHr, cVr, cDr, recovered_payload] = payload_extraction(marked_block);    
    % Delete the bits containig control information length
    recovered_payload(1:ci_bits) = [];

    % Get the recovery sequence from recovered payload
    if recovered_payload(1) == '0'
        rec_recovery_sequence = '0';
        rec_rs_length = 1;
        recovered_payload = recovered_payload(2:length(recovered_payload));
    else
        rec_rs_length = bin2dec(recovered_payload(2:hp_bits + 1)) + hp_bits + 1;
        rec_recovery_sequence = recovered_payload(1:rec_rs_length);
        recovered_payload = recovered_payload(rec_rs_length + 1:length(recovered_payload));
    end
    
    recovered_message = recovered_payload(1:payload_length); 

    recovered_error = recovered_payload(payload_length+1:length(recovered_payload));
    % High-frequency coefficients expansion
    [cH_coefrec, errorCVrec] = expansion(cHr, T_c, recovered_error);
    [cV_coefrec, errorCDrec] = expansion(cVr, T_c, errorCVrec);
    [cD_coefrec, errorfinal] = expansion(cDr, T_c, errorCDrec);

    unmarked_block = ilwt2(cAr, cH_coefrec, cV_coefrec, cD_coefrec,liftscheme);
    recovered_block = block_posprocessing(rec_recovery_sequence, unmarked_block);
    recovered_blocks(1, num_block) = {recovered_block};
    
    catch 
        cont_mal = cont_mal+1;
        no_emb = [no_emb, num2str(num_block)];
        warning(strcat('Block was not recovered. ',num2str(num_block)));
        recovered_blocks(1,num_block) = {zeros(32,32)};
    end
    if ssim(double(cell2mat(recovered_blocks(num_block))),double(cell2mat(array_blocks(num_block)))) < 1
        no_rev = [no_rev, num2str(num_block)];
    end

end

recovered_image = uint8(cell2mat(reshape(recovered_blocks, [row_blocks, col_blocks])));
if cont_mal == 0
    disp('Original image was recovered.');
else
    disp(char(strcat(num2str(cont_mal), {' '}, 'blocks were not recovered.')));
end


compressed_image = uint8(cell2mat(reshape(compressed_blocks,[row_blocks,col_blocks])));
marked_image = uint8(cell2mat(reshape(marked_blocks,[row_blocks,col_blocks])));

images_evaluation(uint8(Ic), compressed_image, marked_image, recovered_image, hist_payload_lengths, image_name, T_c);
%imwrite(im_compressed,char(strcat('C:\Users\Gabriel\Desktop\Resultados Bloques\Compressed images\',image_name,{' '}, 'T=',num2str(T),'.tif')));
%imwrite(im_marked,char(strcat('C:\Users\Gabriel\Desktop\Resultados Bloques\Marked images\',image_name,{' '}, 'T=',num2str(T),'.tif')));
%imwrite(im_recovered,char(strcat('C:\Users\Gabriel\Desktop\Resultados Bloques\Recovered images\',image_name,{' '}, 'T=',num2str(T),'.tif')));

figure
set(gcf,'name','Marked blocks comparison','Position',get(0,'Screensize')); 
bar(hist_payload_lengths)
line_y(1:blocks_number) = block_dim1*block_dim2*0.75;
line_x(1:blocks_number)=1:blocks_number;
line(line_x,line_y,'color','red')
title(strcat(image_name,' image - total payload size by block with ',{' '},'Tc = ',{' '},num2str(T_c)))
%saveas(gcf,char(strcat('C:\Users\Gabriel\Desktop\Resultados Bloques\',image_name,{' '},'T=',num2str(T),{' '},'- Payload by block.png')));

stats(1) = min(hist_payload_lengths);
stats(2) = max(hist_payload_lengths);
stats(3) = mean(hist_payload_lengths);
stats(4) = std(hist_payload_lengths);
stats(5) = mean(hist_ctrl_inf_length);
stats(6) = std(hist_ctrl_inf_length);
stats(7) = psnr(uint8(Ic),marked_image);
stats(8) = ssim(uint8(Ic),marked_image);

stats'
toc