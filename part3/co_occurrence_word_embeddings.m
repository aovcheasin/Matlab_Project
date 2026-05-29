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

% Build co-occurrence counts and forward counts (for next-word prediction)
forwardCounts = sparse(vocabSize, vocabSize);
for i = 1:length(tokens)
    center = vocabLookup(tokens{i});
    startIdx = max(1, i - windowSize);
    endIdx = min(length(tokens), i + windowSize);
    nextIdx = i + 1;
    if nextIdx <= length(tokens)
        nextWord = vocabLookup(tokens{nextIdx});
        forwardCounts(center, nextWord) = forwardCounts(center, nextWord) + 1;
    end
    for j = startIdx:endIdx
        if j ~= i
            context = vocabLookup(tokens{j});
            coMatrix(center, context) = coMatrix(center, context) + 1;
        end
    end
end

    % Apply PPMI (Positive Pointwise Mutual Information) weighting
    % Compute directly on sparse matrix to avoid large temporary arrays
    totalCount = sum(coMatrix(:));
    if totalCount == 0
        ppmiMatrix = sparse(vocabSize, vocabSize);
    else
        % Normalize rows and columns to get marginal probabilities
        rowSums = sum(coMatrix, 2);
        colSums = sum(coMatrix, 1);
        % Scale rows by total count to get P(context|word)
        S = bsxfun(@rdivide, coMatrix, max(rowSums, 1));
        % Scale columns by total count to get P(context)
        S = bsxfun(@rdivide, S, max(full(colSums), 1) / totalCount);
        % PPMI = max(0, log(P(word,context) / (P(word)*P(context))))
        %       = max(0, log(P(context|word) / P(context)))
        ppmiMatrix = max(0, log(S + eps));
    end

    % Apply SVD for low-dimensional embeddings
    k = min(50, vocabSize - 1);
    if k >= 1
        [U, S, ~] = svds(ppmiMatrix, k);
    else
        U = zeros(vocabSize, 1);
        S = 0;
    end

embeddings.vocab = vocab;
embeddings.matrix = U * S;
embeddings.ppmiMatrix = ppmiMatrix;
embeddings.forwardCounts = forwardCounts;
embeddings.vocabLookup = containers.Map(vocab, 1:vocabSize);

% Calculate forward probabilities for next-word prediction
forwardProbs = sparse(vocabSize, vocabSize);
for i = 1:vocabSize
    rowSum = sum(forwardCounts(i, :));
    if rowSum > 0
        forwardProbs(i, :) = forwardCounts(i, :) / rowSum;
    end
end
embeddings.forwardProbs = forwardProbs;
end