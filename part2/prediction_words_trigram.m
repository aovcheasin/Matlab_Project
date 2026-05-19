function nextWords = prediction_words_trigram(history2, trigramModel, k)
%PREDICTION_WORDS_TRIGRAM Predict next words using a trigram model
%   nextWords = prediction_words_trigram(history2, trigramModel, k)
%   history2: two previous words (cell array of 2 strings)
%   trigramModel: model returned by train_trigram_model
%   k: number of top predictions to return

if nargin < 3
    k = 5;
end

% Check if we have valid history
if length(history2) < 2 || isempty(history2{1}) || isempty(history2{2})
    % Not enough history, use bigram model with empty context
    nextWords = prediction_words_bigram('', trigramModel.bigramModel, k);
    return;
end

% Check if both words are in vocabulary
w1 = history2{1};
w2 = history2{2};

if ~isKey(trigramModel.vocabLookup, w1) || ~isKey(trigramModel.vocabLookup, w2)
    % Unknown words, backoff to bigram
    nextWords = prediction_words_bigram(w2, trigramModel.bigramModel, k);
    return;
end

% Get vocabulary indices
idx1 = trigramModel.vocabLookup(w1);
idx2 = trigramModel.vocabLookup(w2);

% Look up trigram probabilities
key = sprintf('%d_%d', idx1, idx2);
if isKey(trigramModel.trigramCounts, key)
    trigramProbs = full(trigramModel.trigramCounts(key));
    if sum(trigramProbs) > 0
        % Normalize and get top predictions
        trigramProbs = trigramProbs / sum(trigramProbs);
        [~, sortedIdx] = sort(trigramProbs, 'descend');
        validIdx = sortedIdx(trigramProbs(sortedIdx) > 0);
        if ~isempty(validIdx)
            nextWords = trigramModel.vocab(validIdx(1:min(k, end)));
            return;
        end
    end
end

% Backoff to bigram with second word as context
nextWords = prediction_words_bigram(w2, trigramModel.bigramModel, k);
end