function nextWords = prediction_words_trigram(history2, trigramModel, k)
%PREDICTION_WORDS_TRIGRAM Predict next words using a trigram model
%   nextWords = prediction_words_trigram(history2, trigramModel, k)
%   history2: two previous words (cell array of 2 strings)
%   trigramModel: model returned by train_trigram_model
%   k: number of top predictions to return

if nargin < 3
    k = 5;
end
nextWords = {};
% TODO: implement trigram-backed prediction with backoff to bigrams

end
