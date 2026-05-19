function embeddings = co_occurrence_word_embeddings(tokens, windowSize)
%CO_OCCURRENCE_WORD_EMBEDDINGS Build simple co-occurrence embeddings
%   embeddings = co_occurrence_word_embeddings(tokens, windowSize)
%   tokens: cell array of tokenized sentences
%   windowSize: integer context window

if nargin < 2
    windowSize = 2;
end
embeddings = struct('vocab',[], 'matrix',[]);
% TODO: compute co-occurrence counts and optionally apply weighting/SVD

end
