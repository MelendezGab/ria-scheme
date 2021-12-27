function [recovered_blocks, reference_values, tampered_blocks] = extraction_process(marked_image, T_c)
    liftscheme = liftwave('haar','int2int');
    global MAC_size reference_values_no ci_bits;

    block_dim1 = 32;
    block_dim2 = 32;

    array_blocks_marked = get_blocks(marked_image,block_dim1,block_dim2);
    tampered_blocks = [];
    recovered_blocks = cell(1,length(array_blocks_marked));
    reference_values = [];

    for num_block=1:length(array_blocks_marked)
        %disp(strcat('----------------- Block ',num2str(num_block),' -----------------'));
        marked_block = cell2mat(array_blocks_marked(num_block));
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
        % Inverse process from here
        try
        [cAr, cHr, cVr, cDr, recovered_payload]=payload_extraction(marked_block);

        % Delete control information bits from recovered payload
        recovered_payload = recovered_payload(ci_bits+1:length(recovered_payload));

        % Recovery sequence for block posprocessing stage 
        if recovered_payload(1)=='0'
            rec_recovery_sequence = '0';
            rs_length = 1;        
        else
            rs_length = bin2dec(recovered_payload(2:hp_bits+1));
            rec_recovery_sequence = recovered_payload(1:rs_length+1);
        end
        % Recovered watermark -> Authentication bits + reference values
        recovered_payload = recovered_payload(rs_length+1:length(recovered_payload));
        MAC_rec = recovered_payload(1:MAC_size);
        bin_ref_val = recovered_payload(MAC_size+1:MAC_size+(reference_values_no*8));

        rec_error = recovered_payload((reference_values_no*8)+MAC_size+1:length(recovered_payload));
        [cH_coefrec, errorCVrec] = expansion(cHr, T_c, rec_error);
        [cV_coefrec, errorCDrec] = expansion(cVr, T_c, errorCVrec);
        [cD_coefrec] = expansion(cDr,T_c,errorCDrec);

        modified_block = ilwt2(cAr, cH_coefrec, cV_coefrec, cD_coefrec, liftscheme);
        recovered_block = block_posprocessing(rec_recovery_sequence, modified_block);
        recovered_blocks(1,num_block) = {recovered_block};

        MAC_new =  get_MAC(recovered_block, bin_ref_val, num2str(num_block), 'key');
        if(strcmp(MAC_new, MAC_rec) == 0)
            error('Authentication codes do not match.');
        end

        bin_ref_val = cellstr(reshape(bin_ref_val, 8, [])');
        reference_values = [reference_values bin2dec(bin_ref_val)'];

        catch e
            tampered_blocks = [tampered_blocks, num_block];
            no_rec(1:reference_values_no) = nan;
            reference_values = [reference_values no_rec];

            warning(char(strcat('Tampered block detected: ', {' '}, num2str(num_block))));
            recovered_blocks(1, num_block) = {zeros(32, 32)};
        end
    end
end