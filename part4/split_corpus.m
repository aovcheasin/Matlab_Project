function [trainSet, testSet] = split_corpus(tokens, testRatio)
%SPLIT_CORPUS Split tokenized corpus into train and test sets
%   [trainSet, testSet] = split_corpus(tokens, testRatio)
%   tokens: cell array of sentences (each a cell array of tokens)
%   testRatio: fraction for test set (default 0.2)

if nargin < 2
    testRatio = 0.2;
end
n = numel(tokens);
idx = randperm(n);
cut = max(1, round((1-testRatio)*n));
trainSet = tokens(idx(1:cut));
testSet = tokens(idx(cut+1:end));

end
