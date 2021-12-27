% Reversible image authentication scheme with blind content reconstruction 
% based on compressed sensing
%
% https://doi.org/10.1016/j.jestch.2021.101080
%
% G. Melendez-Melendez, melendez@inaoep.mx
% National Institute of Astrophisics, Optics and Electronics (INAOE)
% December, 2021

clear all
path(path, './util');         
path(path, './util/OMP');            % Include OMP toolbox, available on: https://www.mathworks.com/matlabcentral/fileexchange/32402-cosamp-and-omp-for-sparse-recovery
path(path, './util/RDH');            % Include the reversible data hiding method
global T_d T_c image_path results_path reference_values_no;
image_name = 'Lena';
set_global_variables();

Ic = imread(strcat(image_path, image_name, '.tiff'));  
%Ic = rgb2gray(Ic);
Ic = Ic(:, :, 1);
[Ic_dim1, Ic_dim2] = size(Ic);
block_dim1 = 32;    
block_dim2 = 32;
blocks_group_size = 16;
n = block_dim1*block_dim2*blocks_group_size;
pixels_number = block_dim1*block_dim2;
m = reference_values_no*blocks_group_size;


% Divide image into nonoverlapping blocks of size block_dim1 x block_dim2
blocks_array = get_blocks(Ic, block_dim1, block_dim2);

blocks_number = numel(blocks_array);

p_blocks = randperm(blocks_number);         % Permitation for scramble blocks
[px_blocks, ind_blocks] = sort(p_blocks);  
p_cg = randperm(n);                         % Permutation for Cgs 
[px_cg, ind_cg] = sort(p_cg);  
                                            % DCT2 coefficients are obtained for every block
blocks_dct = arrayfun(@(x) dct2(double(cell2mat(x))-128), blocks_array, 'uniformoutput', false); 

blocks_dct(:) = blocks_dct(p_blocks);       % Scramble all blocks 
Phi = randn(m, n);                          % Create the measurement matrix
%Phi = Phi ./ repmat( sqrt(sum(Phi.^2)), [m 1] );
for i=1:(blocks_number/blocks_group_size)
    % Create a subset with 16 blocks
    blocks_set = blocks_dct(blocks_group_size*(i - 1) + 1:blocks_group_size*i);
    % Reshape blocks into a one-dimentional array
    Cg = arrayfun(@(x) reshape(cell2mat(x)', 1, block_dim1*block_dim2), blocks_set, 'uniformoutput', false);
    Cg = cell2mat(Cg);
    Cg(abs(Cg) <= T_d ) = 0;                  % Set DCT coefficients to 0 according to T_d
    Cg(:) = Cg(p_cg);                         % Cgs permutation
    % Compressed sensing 
    y = Phi*Cg';                            % Obtain a measurement vector 
    % Append measurements
    measurements{i} = y';         
end
% All measurements are reference values 
reference_values = cell2mat(measurements)/100;
p_rv = randperm(numel(reference_values));  
[px_rv, ind_rv] = sort(p_rv);
reference_values(:) = reference_values(p_rv); % Reference values permutation

% Quantify reference values
u = 0:128;
gu = u.^2/90 + u/3;
gu = [-fliplr(gu(2:129)), gu]; 
indices_gu = [(-128:127),127]; 

reference_values_q = arrayfun(@(x) quantify(x, gu, indices_gu), reference_values);
reference_values_q = reference_values_q + 128;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Watermark Embedding 
binary_quantified_values = cell2mat(arrayfun(@(x) dec2bin(x, 8), reference_values_q, 'UniformOutput', 0));
% Create subsets of reference values
bin_cell = mat2cell(binary_quantified_values, 1, zeros(1, blocks_number) + (reference_values_no*8));

marked_image = embedding_process(blocks_array, bin_cell, T_c, Ic);
Iw_PSNR = psnr(Ic, marked_image);
Iw_SSIM = ssim(Ic, marked_image);

imwrite(marked_image, char(strcat(results_path, '01 Marked', {' '}, 'T_c=', num2str(T_c), {' '}, num2str(Iw_PSNR), {' '}, num2str(Iw_SSIM), '.tiff')));
imwrite(marked_image, char(strcat(results_path, '02 Tampered', {' '}, 'T_c=', num2str(T_c), '.tiff')));

% Add a breaking point here to apply tampering attacks in the tampered image.  

% Extraction & tampering detection  
tampered_image = imread(char(strcat(results_path, '02 Tampered', {' '}, 'T_c=', num2str(T_c), '.tiff')));
tampered_image = tampered_image(:,:,1);
It_PSNR = psnr(Ic, tampered_image);
It_SSIM = ssim(Ic, tampered_image);

[rec_blocks, rec_reference_values_q, tampered_blocks] = extraction_process(tampered_image, T_c);
Tamp_Acc = get_accuracy(marked_image, tampered_image, tampered_blocks);

%%%%%%%%%%%%%%%%%% Image recovery from reference values %%%%%%%%%%%%%%%%%%%

rec_reference_values = arrayfun(@(x) unquantify(x), rec_reference_values_q - 128);
rec_reference_values = rec_reference_values*100;

rec_reference_values(:) = rec_reference_values(ind_rv);      %Inverse reference values permutation

blocks_dct = arrayfun(@(x) dct2(double(cell2mat(x)) - 128), rec_blocks, 'uniformoutput', false); 
blocks_dct(tampered_blocks) = mat2cell(nan(block_dim1, block_dim2), block_dim1, block_dim2);
blocks_dct(:) = blocks_dct(p_blocks);       % Blocks permutation 

Cg_all = arrayfun(@(x) reshape(cell2mat(x)', 1, block_dim1*block_dim2), blocks_dct, 'uniformoutput', false);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i = 1:(blocks_number/blocks_group_size)
    
    Cg = cell2mat(Cg_all(blocks_group_size*(i - 1) + 1:blocks_group_size*i));
    Cresp = Cg;
    Cresp(:) = Cresp(p_cg);
    
    Cg(abs(Cg) <= T_d )=0;              % Cgs   
    Cg(:) = Cg(p_cg);
    sum_nan = sum(isnan(Cg));
    
    if sum_nan > 0
        disp(strcat('Set ', {' '}, num2str(i), ' contains tampered values.'));
        r = rec_reference_values(m*(i - 1) + 1:m*i);
        Me = Phi;
        
        tampered_r = find(isnan(r));
        tampered_c = find(isnan(Cg));
        
        r(tampered_r) = [];
        Me(tampered_r,:) = [];
        
        MeT = Me(:,tampered_c);
        MeI = Me;
        MeI(:,tampered_c) = [];

        CgT = Cg(tampered_c);
        CgI = Cg;
        CgI(tampered_c)=[];
        
        rT = r'-(MeI*CgI');
        CgTrOMP = OMP(MeT, rT, round(size(MeT,1)*0.25));          
        
        Cresp(tampered_c) = CgTrOMP;   
%         disp(strcat('Intact dct coefficients   : ', num2str(length(CgI))));    
%         disp(strcat('Tampered dct coefficients : ', num2str(length(tampered_c))));    
%         disp(strcat('Recovered reference values: ', num2str(length(r))));
%         disp(strcat('Missing reference values  : ', num2str(length(tampered_r))));
%         disp(strcat('MeT size                  : ', num2str(size(MeT))));
%         disp(strcat('MeI size                  : ', num2str(size(MeI))));   
%         disp(strcat('Recovered reference values: ', num2str(length(CgTrOMP))));    
    end
    
    Cresp(:) =  Cresp(ind_cg);     % Apply inverse coefficients permutation
    Cg_recOMP{i} = Cresp;
end

authenticated_image = create_authenticated_image(blocks_array, tampered_blocks, Ic_dim1, Ic_dim2, block_dim1, block_dim2);
imwrite(authenticated_image, char(strcat(results_path, '03 Authenticated image', {' '}, '.tiff')));

rec_imageOMP = get_recovered_image(Cg_recOMP, pixels_number, blocks_number, ind_blocks, Ic_dim1, Ic_dim2, block_dim1, block_dim2);
Ir_PSNR = psnr(Ic, rec_imageOMP);
Ir_SSIM = ssim(Ic, rec_imageOMP);
imwrite(rec_imageOMP, char(strcat(results_path, '04 Recovered image OMP T_d', {' '}, num2str(T_d), {' '}, num2str(Ir_PSNR), {' '}, num2str(Ir_SSIM), '.tiff')));

results = table(Iw_PSNR, Iw_SSIM, It_PSNR, It_SSIM, Tamp_Acc, Ir_PSNR, Ir_SSIM);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tampered_blocks
results

