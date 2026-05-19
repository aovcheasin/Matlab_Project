function bigramModel = train_bigram_model(corpus)
%TRAIN_BIGRAM_MODEL Train a bigram model from a tokenized corpus
%   bigramModel = train_bigram_model(corpus)
%   corpus: cell array of tokenized sentences (cells of tokens)
%   bigramModel: struct with fields `counts` and `probs`

bigramModel = struct('counts',[], 'probs',[]);
% TODO: implement frequency counts and probability estimates

end
