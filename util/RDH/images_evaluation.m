% iages_evaluation  
% Original, marked and recovered images are received to be evaluated using
% PSNR and SSIM metrics. A pixel-wise comparisson is provided to show
% difference images.
% White grayscale values represent pixel differences. 

function images_evaluation(original_image, compressed_image, marked_image, recovered_image, payload, image_name, T_c)
    global results_path;
    figure
    set(gcf, 'name', char(strcat('Images evaluation -', {' '}, image_name, {' '}, 'image.')), 'Position', [20 20 800 750]); 
    subplot(2, 2, 1);
    imshow(original_image);
    title('Original image');
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    subplot(2, 2, 2);
    imshow(uint8(compressed_image));
    text(0.3,-0.1, strcat('PSNR = ', num2str(psnr(original_image, compressed_image))), 'Units', 'normalized')
    title(char(strcat('Compressed coefficients Tc = ', {' '}, num2str(T_c))));
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    subplot(2, 2, 3);
    imshow(uint8(marked_image));
    text(0.3,-0.1, char(strcat('PSNR = ', {' '}, num2str(psnr(original_image, marked_image)))), 'Units', 'normalized')
    title('Marked image');
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    subplot(2, 2, 4);
    imshow(uint8(recovered_image));
    text(0.3,-0.1, char(strcat('PSNR =', {' '},num2str(psnr(original_image, recovered_image)))), 'Units', 'normalized')
    title('Recovered image');
%    saveas(gcf,char(strcat(results_path, image_name,{' '}, 'Tc=',num2str(T_c), {' '}, '- PSNR results.png')));

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    figure
    im_dims = size(original_image);
    set(gcf, 'name', char(strcat('Pixel-wise comparison -', {' '}, image_name, ' image.')), 'Position', [0 100 1500 500]);     
    bin_image = original_image;
    for i=1:im_dims(1)
        for j=1:im_dims(2)
            if original_image(i,j,1) ~= compressed_image(i,j,1)
                bin_image(i,j,:) = 255;
            else
                bin_image(i,j,:) = 0;
            end
        end
    end
    subplot(1,3,1);
    imshow(uint8(bin_image))
    title('Original vs Compressed coefficients');
    bin_image=original_image;
    for i=1:im_dims(1)
        for j=1:im_dims(2)
            if original_image(i,j,1) ~= marked_image(i,j,1)
                bin_image(i,j,:) = 255;
            else
                bin_image(i,j,:) = 0;
            end
        end
    end
    subplot(1,3,2);
    imshow(uint8(bin_image)) 
    title('Original vs Marked image');
    th = text(1,-100,char(strcat('Embedding ---> ',{' '},num2str(mean(payload)/(32*32)),{' '},'BPP',{' +-'}, num2str(std(payload)/(32*32)))));
    
    bin_image=original_image;
    for i=1:im_dims(1)
        for j=1:im_dims(2)
            if original_image(i,j,1) ~= recovered_image(i,j,1)
                bin_image(i,j,:) = 255;
            else
                bin_image(i,j,:) = 0;
            end
        end
    end
    subplot(1,3,3);
    imshow(uint8(bin_image))
    title('Original vs Recovered');
   % saveas(gcf,char(strcat(results_path, image_name, {' '}, 'Tc=', num2str(T_c), {' '}, '- Difference results.png')));


    
end