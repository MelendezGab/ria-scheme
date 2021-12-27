% get_MAC returns a message authentication code using SHA-256 hash function
% block             -> matrix of grayscale values
% refernece_values  -> string of binary reference values
% block_index       -> block's position index 
% key               -> user predifined key 

function MAC = get_MAC(block, reference_values, block_index, key)
    persistent md
    if isempty(md)
        md = java.security.MessageDigest.getInstance('SHA-256');
    end
    global MAC_size;
    block_dims = size(block);
    binario = dec2bin(block, 8); % Pixels to binary representation
    block_bin = reshape(binario', [1 block_dims(1)*block_dims(2)*8]);
    block_bin = strcat(block_bin, reference_values, block_index, key);
    MAC = typecast(md.digest(uint8(block_bin)), 'uint8'); % Get hash value 
    bin = dec2bin(MAC, 8);
    MAC =  reshape(bin', [1 256]);
    MAC = MAC(1:MAC_size); %Return first MAC_size bits
end