function nextWords = predict_vector_similar(contextWord, embeddings, k)
%PREDICT_VECTOR_SIMILAR Predict next words by vector similarity
%   nextWords = predict_vector_similar(contextWord, embeddings, k)
%   contextWord: string or index
%   embeddings: struct from co_occurrence_word_embeddings
%   k: number of top similar words to return

if nargin < 3
    k = 5;
end
nextWords = {};
% TODO: implement cosine-similarity ranking over embedding matrix

end
