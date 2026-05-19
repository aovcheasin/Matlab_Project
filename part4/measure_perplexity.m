function ppl = measure_perplexity(model, testSet)
%MEASURE_PERPLEXITY Compute perplexity of a probabilistic language model
%   ppl = measure_perplexity(model, testSet)
%   model: bigram model with probs and vocabLookup fields
%   testSet: cell array of words

logProb = 0;
N = 0;

for i = 2:length(testSet)
    w1 = testSet{i-1};
    w2 = testSet{i};
    
    if isKey(model.vocabLookup, w1) && isKey(model.vocabLookup, w2)
        idx1 = model.vocabLookup(w1);
        idx2 = model.vocabLookup(w2);
        prob = model.probs(idx1, idx2);
        if prob > 0
            logProb = logProb + log(prob);
        else
            logProb = logProb + log(1 / model.vocabSize);  % Backoff
        end
        N = N + 1;
    end
end

if N > 0
    ppl = exp(-logProb / N);
else
    ppl = inf;
end
end