function ui_demo()
%UI_DEMO Interactive next-word prediction demo
%   Creates a GUI for predicting next words using trained models

% Check for saved models
if exist('models.mat', 'file')
    load('models.mat');
else
    [tokens, ~, ~] = text_processing('corpus.txt');
    bigramModel = train_bigram_model(tokens);
    embeddings = co_occurrence_word_embeddings(tokens, 2);
end

vocab = bigramModel.vocab;
vocabLookup = bigramModel.vocabLookup;

% Create main window
fig = uifigure('Name', 'Next Word Prediction Demo', 'Position', [100 100 700 500]);

% Title
uilabel(fig, 'Position', [20 460 660 30], ...
    'Text', 'MATLAB Next Word Prediction', 'FontWeight', 'bold', 'FontSize', 16);

% Instructions
uilabel(fig, 'Position', [20 430 660 22], ...
    'Text', 'Options: Enter a word, first letter, or click "Letter Match" for suggestions:', ...
    'FontColor', [0.3 0.3 0.3]);

% Input area
uilabel(fig, 'Position', [20 395 100 22], 'Text', 'Word/Letter:');
editInput = uieditfield(fig, 'text', 'Position', [130 395 150 25], ...
    'ValueChangedFcn', @(src,event)predictCallback());

% Predict button
uibutton(fig, 'push', 'Position', [300 395 100 25], ...
    'Text', 'Predict', 'ButtonPushedFcn', @(src,event)predictCallback());

% Letter match button
uibutton(fig, 'push', 'Position', [420 395 120 25], ...
    'Text', 'Letter Match', 'ButtonPushedFcn', @(src,event)letterMatchCallback());

% Clear button
uibutton(fig, 'push', 'Position', [550 395 80 25], ...
    'Text', 'Clear', 'ButtonPushedFcn', @(src,event)clearResults());

% Results area - Bigram
uilabel(fig, 'Position', [20 355 660 22], 'Text', 'Bigram predictions:', 'FontWeight', 'bold');
lblBigram = uilabel(fig, 'Position', [20 330 660 22], 'Text', '-');

% Results area - Vector
uilabel(fig, 'Position', [20 295 660 22], 'Text', 'Vector predictions:', 'FontWeight', 'bold');
lblVector = uilabel(fig, 'Position', [20 270 660 22], 'Text', '-');

% Letter suggestions area
uilabel(fig, 'Position', [20 235 660 22], 'Text', 'Words starting with letter:', 'FontWeight', 'bold');
lblLetterWords = uilabel(fig, 'Position', [20 210 660 22], 'Text', '-');

% Status
lblStatus = uilabel(fig, 'Position', [20 185 660 22], ...
    'Text', sprintf('Ready! Vocabulary: %d words', numel(vocab)));

% Axes for probability distribution chart
ax = uiaxes(fig, 'Position', [20 20 400 150]);
ax.XLabel.String = 'Words';
ax.YLabel.String = 'Probability';
ax.Title.String = 'Top Predictions';
ax.Visible = 'off';

% Probability text label
lblProb = uilabel(fig, 'Position', [440 40 240 140], ...
    'Text', 'Enter a word to see probabilities', ...
    'HorizontalAlignment', 'left', 'VerticalAlignment', 'top', ...
    'FontName', 'monospace', 'FontSize', 10);

    function predictCallback()
        word = editInput.Value;
        if isempty(word)
            uialert(fig, 'Please enter a word.', 'Empty Input');
            return;
        end
        
        word = lower(word);
        
        if isKey(vocabLookup, word)
            idx = vocabLookup(word);
            bigramPreds = prediction_words_bigram(word, bigramModel, 5);
            vecPreds = predict_vector_similar(word, embeddings, 5);
            
            lblBigram.Text = sprintf('Bigram predictions: %s', strjoin(bigramPreds, ', '));
            lblVector.Text = sprintf('Vector predictions: %s', strjoin(vecPreds, ', '));
            
            updateChart(ax, bigramModel.vocab, bigramModel.probs(idx, :), bigramPreds);
            updateProbText(lblProb, bigramModel.vocab, bigramModel.probs(idx, :), bigramPreds);
            lblLetterWords.Text = sprintf('Word "%s" found in vocabulary', word);
        else
            lblBigram.Text = sprintf('Bigram predictions: %s', strjoin(prediction_words_bigram(word, bigramModel, 5), ', '));
            lblVector.Text = sprintf('Vector predictions: %s', strjoin(predict_vector_similar(word, embeddings, 5), ', '));
            lblLetterWords.Text = 'Word not in vocabulary. Try letter match.';
        end
    end

    function letterMatchCallback()
        letter = editInput.Value;
        if isempty(letter)
            uialert(fig, 'Please enter a letter.', 'Empty Input');
            return;
        end
        
        letter = lower(letter(1));
        if ~isstrprop(letter, 'alpha')
            uialert(fig, 'Please enter a valid letter.', 'Invalid Input');
            return;
        end
        
        words = findWordsStartingWithLetter(letter);
        lblLetterWords.Text = sprintf('Words starting with "%s": %s', letter, strjoin(words, ', '));
        
        if ~isempty(words)
            firstWord = words{1};
            lblBigram.Text = sprintf('Top prediction: %s', firstWord);
            lblVector.Text = sprintf('Also: %s', strjoin(words(2:min(end,5)), ', '));
        end
    end

    function clearResults()
        editInput.Value = '';
        lblBigram.Text = '-';
        lblVector.Text = '-';
        lblLetterWords.Text = '-';
        ax.Visible = 'off';
        lblProb.Text = 'Enter a word to see probabilities';
    end

    function matches = findWordsStartingWithLetter(letter)
        matches = {};
        for i = 1:length(vocab)
            w = vocab{i};
            if startsWith(w, letter)
                matches{end+1} = w;
            end
        end
        if length(matches) > 20
            matches = matches(1:20);
        end
    end

    function updateChart(ax, vocab, probs, preds)
        ax.Visible = 'on';
        ax.Children = [];
        if ~isempty(preds)
            predProbs = [];
            validPreds = {};
            for i = 1:length(preds)
                if isKey(vocabLookup, preds{i})
                    idx = vocabLookup(preds{i});
                    predProbs(end+1) = probs(idx);
                    validPreds{end+1} = preds{i};
                end
            end
            if ~isempty(predProbs)
                bar(ax, 1:length(predProbs), predProbs);
                ax.XTick = 1:length(predProbs);
                ax.XTickLabel = validPreds;
                ax.XTickLabelRotation = 45;
            end
        end
    end

    function updateProbText(lbl, vocab, probs, preds)
        if isempty(preds)
            lbl.Text = 'No predictions available';
            return;
        end
        txt = sprintf('Probabilities:\n');
        for i = 1:length(preds)
            if isKey(vocabLookup, preds{i})
                idx = vocabLookup(preds{i});
                p = probs(idx);
                txt = sprintf('%s  %s: %.1f%%\n', txt, preds{i}, p*100);
            end
        end
        lbl.Text = txt;
    end
end