% Global variables definition

function [] = set_RDH_variables()
    global T_c payload_length ci_bits hp_bits image_path results_path;

    T_c = 15;                           % Compression threshold T_c
    payload_length = 410;               % Number of bits to be embedded by block 
    ci_bits = 9;                        % Number of bits required to store the length of control information. Set a multiple of 3. 
    hp_bits = 10;                       % Number of bits required to store the recovery sequence length. 

    image_path = 'C:\Users\Gabriel\Documents\GitHub\JESTECH\img\';  % Cover image path
    results_path = 'C:\Users\Gabriel\Desktop\RWS results\';         % Path for saving some evaluated images
end

