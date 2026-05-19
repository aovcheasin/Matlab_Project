function trigramModel = train_trigram_model(tokens)
%TRAIN_TRIGRAM_MODEL Train a trigram model from tokenized corpus
%   trigramModel = train_trigram_model(tokens)
%   tokens: cell array of words
%   trigramModel: struct with trigram counts, probs, and backoff to bigrams

% Get vocabulary
[vocab, ~, tokenIdx] = unique(tokens, 'stable');
vocabSize = length(vocab);

% Create vocab lookup
vocabLookup = containers.Map(vocab, 1:vocabSize);

% Use containers.Map for trigram counts since dynamic field names don't work
trigramCounts = containers.Map('KeyType', 'char', 'ValueType', 'any');

% Count trigrams
for i = 1:(length(tokenIdx)-2)
    w1 = tokenIdx(i);
    w2 = tokenIdx(i+1);
    w3 = tokenIdx(i+2);
    key = sprintf('%d_%d', w1, w2);
    if isKey(trigramCounts, key)
        vec = trigramCounts(key);
        vec(w3) = vec(w3) + 1;
        trigramCounts(key) = vec;
    else
        vec = sparse(vocabSize, 1);
        vec(w3) = 1;
        trigramCounts(key) = vec;
    end
end

% Train bigram model as fallback
bigramModel = train_bigram_model(tokens);

% Store trigram data
trigramModel.trigramCounts = trigramCounts;
trigramModel.bigramModel = bigramModel;
trigramModel.vocab = vocab;
trigramModel.vocabLookup = vocabLookup;
trigramModel.vocabSize = vocabSize;
end