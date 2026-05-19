function results = compare_all_models(trainSet, testSet)
%COMPARE_ALL_MODELS Train and compare models on provided sets
%   results = compare_all_models(trainSet, testSet)

% Train bigram model
bigramModel = train_bigram_model(trainSet);

% Train embeddings
embeddings = co_occurrence_word_embeddings(trainSet, 2);

% Evaluate bigram model
predictions = {};
targets = {};

for i = 2:length(testSet)
    history = testSet{i-1};
    target = testSet{i};
    preds = prediction_words_bigram(history, bigramModel, 10);
    predictions{i-1} = preds;
    targets{i-1} = target;
end

bigramAcc = evaluate_accuracy(predictions, targets);

% Evaluate vector model
predictions = cell(length(testSet) - 1, 1);
for i = 2:length(testSet)
    history = testSet{i-1};
    preds = predict_vector_similar(history, embeddings, 10);
    predictions{i-1} = preds;
end

vectorAcc = evaluate_accuracy(predictions, targets);

% Measure perplexity
ppl = measure_perplexity(bigramModel, testSet);

results.accuracy.bigram = bigramAcc;
results.accuracy.vector = vectorAcc;
results.perplexity = ppl;
results.bigramModel = bigramModel;
results.embeddings = embeddings;
end