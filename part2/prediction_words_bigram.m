function nextWords = prediction_words_bigram(history, bigramModel, k)
%PREDICTION_WORDS_BIGRAM Predict next words using a bigram model
%   nextWords = prediction_words_bigram(history, bigramModel, k)
%   history: previous word (string)
%   bigramModel: model returned by train_bigram_model
%   k: number of top predictions to return

if nargin < 3
    k = 5;
end
nextWords = {};
% TODO: implement lookup of most probable continuations

end
