function [rq] = quantify(r, gu, index_gu)
% A reference value r is received and quantified according to gu function 
    if r >= -(gu(1))
        rq = 127;
    elseif (r<gu(1))
        rq = -128;
    else
        rq = index_gu(find(gu <= r, 1, 'last'));
    end
end


