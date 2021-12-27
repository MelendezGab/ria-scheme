function [accuracy, original_tampered_blocks] = get_accuracy(marked, tampered, tampered_blocks)
    array_marked = get_blocks(marked,32,32);
    array_tampered = get_blocks(tampered,32,32);

    ground_truth = cellfun(@isequal, array_marked, array_tampered);

    original_tampered_blocks = find(ground_truth==0);

    predicted = ones(1,length(array_marked));
    predicted(tampered_blocks)=0;

    TP=0;
    FP=0;
    TN=0;
    FN=0;

    for i=1:length(array_tampered)
        if(ground_truth(i) == 1 && predicted(i) == 1)
            TP = TP + 1;
        elseif(ground_truth(i) == 0 && predicted(i) == 1)
            FP = FP + 1;
        elseif(ground_truth(i) == 0 && predicted(i) == 0)
            TN = TN + 1;
        else
            FN = FN + 1;
        end
    end

    accuracy = (TP + TN)/(TP + TN + FP + FN);
end