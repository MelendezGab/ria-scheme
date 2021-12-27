function [] = set_global_variables()
%   Define global variables   

    global T_d T_c image_path results_path MAC_size reference_values_no ci_bits payload_length hp_bits;  
    
    image_path      = 'C:\Users\Gabriel\Documents\GitHub\ria-scheme\img\';
    results_path    = 'C:\Users\Gabriel\Documents\GitHub\ria-scheme\results\';

    MAC_size = 10;
    reference_values_no = 50;
    
    payload_length = (reference_values_no*8) + MAC_size;    % 410 watermark-bits
    
        
    T_c = 15;       % A different Tc value could be better for different images 
    T_d  = 20;      % Threshold Td modifies sparse signal representations in the watermark creation phase
    
    % For reversible data hiding method
    ci_bits = 9;    % Number of bits used to store the control information length per block 
    hp_bits = 10;   % Number of bits used to store the recovery sequence length per block 
end
