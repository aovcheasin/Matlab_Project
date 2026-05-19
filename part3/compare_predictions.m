function report = compare_predictions(testSet, models)
%COMPARE_PREDICTIONS Compare outputs of n-gram and vector models
%   report = compare_predictions(testSet, models)
%   testSet: cell array of tokenized sentences (each sentence is a cell array)
%   models: struct with fields bigramModel, trigramModel, embeddings

correctBigram = 0;
correctTrigram = 0;
correctVector = 0;
total = 0;

for i = 1:length(testSet)
    sentence = testSet{i};
    if length(sentence) < 2
        continue;
    end
    
    % Test bigram model
    if isfield(models, 'bigramModel')
        if length(sentence) >= 2
            history = sentence{end-1};
            actual = sentence{end};
            preds = prediction_words_bigram(history, models.bigramModel, 10);
            if ismember(actual, preds)
                correctBigram = correctBigram + 1;
            end
        end
    end
    
    % Test trigram model
    if isfield(models, 'trigramModel') && length(sentence) >= 3
        history = {sentence{end-2}, sentence{end-1}};
        actual = sentence{end};
        preds = prediction_words_trigram(history, models.trigramModel, 10);
        if ismember(actual, preds)
            correctTrigram = correctTrigram + 1;
        end
    end
    
    % Test vector model
    if isfield(models, 'embeddings') && length(sentence) >= 2
        context = sentence{end-1};
        actual = sentence{end};
        preds = predict_vector_similar(context, models.embeddings, 10);
        if ~isempty(preds) && ismember(actual, preds)
            correctVector = correctVector + 1;
        end
    end
    
    total = total + 1;
end

report.accuracy.bigram = correctBigram / max(total, 1);
report.accuracy.trigram = correctTrigram / max(total, 1);
report.accuracy.vector = correctVector / max(total, 1);
report.total = total;
end