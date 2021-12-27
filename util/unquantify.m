function [r] = unquantify(rq)
% A quantified reference value is received and an estimated reference
% value is returned. 
    rq2 = abs(rq);
    gr = rq2^2/90 + rq2/3;
    gr_1 = (rq2 + 1)^2/90 + (rq2 + 1)/3;

    if rq >= 0 && rq <= 127
        r = 0.5*(gr + gr_1);
    else
        r = 0.5*(-gr-gr_1);
    end
end

