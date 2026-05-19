function nextWords = predict_vector_similar(contextWord, embeddings, k)
%PREDICT_VECTOR_SIMILAR Predict next words by vector similarity
%   nextWords = predict_vector_similar(contextWord, embeddings, k)
%   contextWord: string or index
%   embeddings: struct from co_occurrence_word_embeddings
%   k: number of top similar words to return

if nargin < 3
    k = 5;
end

vocabLookup = containers.Map(embeddings.vocab, 1:length(embeddings.vocab));

% Get context vector
if ischar(contextWord) || isstring(contextWord)
    if ~isKey(vocabLookup, contextWord)
        nextWords = {};
        return;
    end
    idx = vocabLookup(contextWord);
else
    idx = contextWord;
end

% Compute cosine similarity with all words
contextVec = embeddings.matrix(idx, :)';
normContext = norm(contextVec);
if normContext == 0
    nextWords = embeddings.vocab(1:min(k, end));
    return;
end

similarities = zeros(length(embeddings.vocab), 1);
for i = 1:length(embeddings.vocab)
    wordVec = embeddings.matrix(i, :)';
    normWord = norm(wordVec);
    if normWord > 0
        similarities(i) = (contextVec' * wordVec) / (normContext * normWord);
    end
end

% Get top k similar words (excluding the context word itself)
[~, sortedIdx] = sort(similarities, 'descend');
sortedIdx = sortedIdx(sortedIdx ~= idx);  % Remove context word
nextWords = embeddings.vocab(sortedIdx(1:min(k, end)));
end