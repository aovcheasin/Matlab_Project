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
    [~, sortedIdx] = sort(probs, 'descend');
    nextWords = bigramModel.vocab(sortedIdx(1:min(k, end)));
else
    % Unknown word - use unigram backoff
    [~, sortedIdx] = sort(bigramModel.unigramProbs, 'descend');
    nextWords = bigramModel.vocab(sortedIdx(1:min(k, end)));
end
end