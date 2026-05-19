function nextWords = prediction_words_bigram(history, bigramModel, k)
%PREDICTION_WORDS_BIGRAM Predict next words using a bigram model
%   nextWords = prediction_words_bigram(history, bigramModel, k)
%   history: previous word (string) or empty string for unigram backoff
%   bigramModel: model returned by train_bigram_model
%   k: number of top predictions to return

if nargin < 3
    k = 5;
end

if isKey(bigramModel.vocabLookup, history)
    idx = bigramModel.vocabLookup(history);
    probs = bigramModel.probs(idx, :);
    % Avoid backoff if we have good bigram matches
    validIdx = probs > (1 / bigramModel.vocabSize);
    if sum(validIdx) > 0
        [~, sortedIdx] = sort(probs(validIdx), 'descend');
        topIdx = find(validIdx);
        topIdx = topIdx(sortedIdx(1:min(k, length(topIdx))));
        nextWords = bigramModel.vocab(topIdx);
    else
        % Backoff to unigram probabilities
        [~, sortedIdx] = sort(bigramModel.unigramProbs, 'descend');
        nextWords = bigramModel.vocab(sortedIdx(1:min(k, end)));
    end
else
    % Unknown word - use unigram backoff
    [~, sortedIdx] = sort(bigramModel.unigramProbs, 'descend');
    nextWords = bigramModel.vocab(sortedIdx(1:min(k, end)));
end
end