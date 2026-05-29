% Main script for MATLAB Next Word Prediction Project
% Loads models and shows interactive demo

clear; clc; close all;

% Add paths to all parts
addpath('part1');
addpath('part2');
addpath('part3');
addpath('part4');
addpath('part5');

fprintf('===============================================\n');
fprintf('   MATLAB Next Word Prediction Project\n');
fprintf('===============================================\n\n');

% Load and process corpus
fprintf('Loading corpus...\n');
[tokens, ~, ~] = text_processing('corpus.txt');
fprintf('Loaded %d tokens\n', length(tokens));

% Train models
fprintf('Training models (this may take a minute)...\n');
bigramModel = train_bigram_model(tokens);
embeddings = co_occurrence_word_embeddings(tokens, 2);
fprintf('Models ready! Vocabulary size: %d words\n', length(bigramModel.vocab));

% Save models for UI demo
save('models.mat', 'bigramModel', 'embeddings');

% Demo predictions
fprintf('\n=== Sample Predictions ===\n');
sampleWords = {'she', 'he', 'the', 'was', 'is', 'big'};
for i = 1:length(sampleWords)
    word = sampleWords{i};
    bigramPreds = prediction_words_bigram(word, bigramModel, 3);
    vecPreds = predict_vector_similar(word, embeddings, 3);
    fprintf('  "%s" -> Bigram: [%s]  |  Vector: [%s]\n', ...
        word, strjoin(bigramPreds, ', '), strjoin(vecPreds, ', '));
end

fprintf('\n=== Launching UI Demo ===\n');
ui_demo();
