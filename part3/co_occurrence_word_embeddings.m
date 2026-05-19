function embeddings = co_occurrence_word_embeddings(tokens, windowSize)
%CO_OCCURRENCE_WORD_EMBEDDINGS Build simple co-occurrence embeddings
%   embeddings = co_occurrence_word_embeddings(tokens, windowSize)
%   tokens: cell array of words
%   windowSize: integer context window
%   Returns struct with vocab and embedding matrix

if nargin < 2
    windowSize = 2;
end

% Get vocabulary
vocab = unique(tokens, 'stable');
vocabSize = length(vocab);
vocabLookup = containers.Map(vocab, 1:vocabSize);

% Initialize co-occurrence matrix
coMatrix = sparse(vocabSize, vocabSize);

% Build co-occurrence counts
for i = 1:length(tokens)
    center = vocabLookup(tokens{i});
    startIdx = max(1, i - windowSize);
    endIdx = min(length(tokens), i + windowSize);
    
    for j = startIdx:endIdx
        if j ~= i
            context = vocabLookup(tokens{j});
            coMatrix(center, context) = coMatrix(center, context) + 1;
        end
    end
end

% Apply PPMI (Positive Pointwise Mutual Information) weighting
% P(w,c) = coMatrix / sum(coMatrix)
% P(w) = sum(coMatrix(w,:)) / sum(coMatrix)
% P(c) = sum(coMatrix(:,c)) / sum(coMatrix)
% PPMI = max(0, log(P(w,c) / (P(w) * P(c))))

totalCount = sum(coMatrix(:));
rowSums = sum(coMatrix, 2);
colSums = sum(coMatrix, 1);

ppmiMatrix = sparse(vocabSize, vocabSize);
for i = 1:vocabSize
    for j = 1:vocabSize
        if coMatrix(i, j) > 0
            pwc = coMatrix(i, j) / totalCount;
            pw = rowSums(i) / totalCount;
            pc = colSums(j) / totalCount;
            ppmiMatrix(i, j) = max(0, log(pwc / (pw * pc)));
        end
    end
end

% Apply SVD for low-dimensional embeddings
[~, ~, V] = svds(ppmiMatrix, 50);

embeddings.vocab = vocab;
embeddings.matrix = V;
embeddings.ppmiMatrix = ppmiMatrix;
end