function [oneHot, vocab] = one_hot_encoding(tokens)
%ONE_HOT_ENCODING Create one-hot encodings for a token list
%   [oneHot, vocab] = one_hot_encoding(tokens)
%   tokens: cell array of strings
%   oneHot: sparse matrix where each column is a word vector
%   vocab: cell array of vocabulary words

vocab = unique(tokens, 'stable');
vocabSize = length(vocab);
vocabLookup = containers.Map(vocab, 1:vocabSize);
numTokens = length(tokens);

% Create sparse one-hot matrix
oneHot = sparse(vocabSize, numTokens);
for i = 1:numTokens
    idx = vocabLookup(tokens{i});
    oneHot(idx, i) = 1;
end
end