function acc = evaluate_accuracy(predictions, targets)
%EVALUATE_ACCURACY Compute top-k accuracy for predictions
%   acc = evaluate_accuracy(predictions, targets)
%   predictions: cell array of predicted word lists per test case
%   targets: cell array of true next words

correct = 0;
for i = 1:length(targets)
    if i <= length(predictions)
        preds = predictions{i};
        if ~isempty(preds) && ismember(targets{i}, preds)
            correct = correct + 1;
        end
    end
end

acc = correct / max(length(targets), 1);
end