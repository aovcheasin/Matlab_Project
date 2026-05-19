function bigramModel = train_bigram_model(tokens)
%TRAIN_BIGRAM_MODEL Train a bigram model from tokenized corpus
%   bigramModel = train_bigram_model(tokens)
%   tokens: cell array of words (from preprocessing)
%   bigramModel: struct with fields counts and probs

% Get vocabulary and its reverse mapping
[vocab, ~, tokenIdx] = unique(tokens, 'stable');
vocabSize = length(vocab);

% Initialize counts matrix
bigramModel.counts = zeros(vocabSize);
bigramModel.vocab = vocab;
bigramModel.vocabLookup = containers.Map(vocab, 1:vocabSize);

% Count bigrams
for i = 1:(length(tokenIdx)-1)
    w1 = tokenIdx(i);
    w2 = tokenIdx(i+1);
    bigramModel.counts(w1, w2) = bigramModel.counts(w1, w2) + 1;
end

% Calculate transition probabilities with Laplace smoothing
bigramModel.probs = zeros(vocabSize);
for w1 = 1:vocabSize
    rowSum = sum(bigramModel.counts(w1, :));
    if rowSum > 0
        bigramModel.probs(w1, :) = (bigramModel.counts(w1, :) + 1) / (rowSum + vocabSize);
    else
        bigramModel.probs(w1, :) = 1 / vocabSize;
    end
end

% Calculate unigram probabilities for backoff
unigramCounts = accumarray(tokenIdx, 1);
bigramModel.unigramProbs = unigramCounts / sum(unigramCounts);
bigramModel.vocabSize = vocabSize;
end