function [oneHot, vocab] = one_hot_encoding(tokens)
%ONE_HOT_ENCODING Create one-hot encodings for a token list
%   [oneHot, vocab] = one_hot_encoding(tokens)
%   tokens: cell array of strings or cell array of token lists
%   oneHot: sparse matrix of one-hot vectors
%   vocab: cell array of vocabulary words

vocab = unique([tokens{:}]);
% Placeholder: return empty oneHot
oneHot = sparse([]);
% TODO: implement mapping from tokens to one-hot matrix

end
