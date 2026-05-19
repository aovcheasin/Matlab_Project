function [trainSet, testSet] = split_corpus(tokens, testRatio)
%SPLIT_CORPUS Split tokenized corpus into train and test sets
%   [trainSet, testSet] = split_corpus(tokens, testRatio)
%   tokens: cell array of words
%   testRatio: fraction for test set (default 0.2)

if nargin < 2
    testRatio = 0.2;
end

% Convert flat tokens to sentences (simple approach: split by periods)
% For simplicity, we'll use the last N tokens as test set
n = length(tokens);
cut = floor((1 - testRatio) * n);

trainSet = tokens(1:cut);
testSet = tokens(cut+1:end);
end