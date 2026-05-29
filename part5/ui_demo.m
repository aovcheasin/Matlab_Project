function ui_demo()
%UI_DEMO Interactive next-word prediction demo — Modern Light Theme

    % Load models
    if exist('models.mat', 'file')
        data = load('models.mat');
        bigramModel = data.bigramModel;
        embeddings = data.embeddings;
    else
        [tokens, ~, ~] = text_processing('corpus.txt');
        bigramModel = train_bigram_model(tokens);
        embeddings = co_occurrence_word_embeddings(tokens, 2);
        save('models.mat', 'bigramModel', 'embeddings');
    end

    vocab       = bigramModel.vocab;
    vocabLookup = bigramModel.vocabLookup;
    nVocab      = numel(vocab);

    % ══════════════════════════════════════
    %  MODERN LIGHT COLOUR PALETTE
    % ══════════════════════════════════════
    BG        = [0.965 0.97 0.975];
    CARD      = [1 1 1];
    ACCENT    = [0.13 0.55 0.90];
    GREEN     = [0.18 0.72 0.42];
    PURPLE    = [0.52 0.36 0.82];
    ORANGE    = [0.90 0.52 0.12];
    RED       = [0.92 0.30 0.30];
    TEAL      = [0.15 0.65 0.60];
    TXT       = [0.15 0.16 0.20];
    SUBTXT    = [0.45 0.47 0.52];
    BORDER    = [0.88 0.89 0.91];

    % ══════════════════════════════════════
    %  MAIN FIGURE
    % ══════════════════════════════════════
    figW = 860;  figH = 650;
    fig = uifigure( ...
        'Name',    'Next Word Prediction', ...
        'Position', [100 60 figW figH], ...
        'Color',   BG, ...
        'WindowStyle', 'normal');
    fig.CloseRequestFcn = @(~,~)cleanup();

    % ──── HEADER ────
    pnlHeader = uipanel(fig, ...
        'Position', [0 figH-52 figW 52], ...
        'BackgroundColor', CARD, ...
        'BorderType', 'none');
    uilabel(pnlHeader, ...
        'Position', [20 10 figW-40 32], ...
        'Text', '  Next Word Prediction', ...
        'FontSize', 18, 'FontWeight', 'bold', ...
        'FontColor', TXT, ...
        'VerticalAlignment', 'center');
    % Blue accent line under header
    uipanel(fig, ...
        'Position', [0 figH-55 figW 3], ...
        'BackgroundColor', ACCENT, ...
        'BorderType', 'none');

    % ──── STATUS BAR ────
    pnlStatus = uipanel(fig, ...
        'Position', [0 0 figW 28], ...
        'BackgroundColor', CARD, ...
        'BorderType', 'none');
    lblStatus = uilabel(pnlStatus, ...
        'Position', [16 4 figW-32 20], ...
        'Text', sprintf('  Vocabulary: %d words  |  Ready', nVocab), ...
        'FontSize', 10, 'FontColor', SUBTXT);

    % ══════════════════════════════════════
    %  INPUT CARD
    % ══════════════════════════════════════
    inY = figH - 128;  inH = 62;
    pnlInput = uipanel(fig, ...
        'Position', [16 inY figW-32 inH], ...
        'BackgroundColor', CARD, ...
        'BorderType', 'line', 'HighlightColor', BORDER);

    uilabel(pnlInput, ...
        'Position', [16 18 60 24], ...
        'Text', 'Input', ...
        'FontSize', 11, 'FontWeight', 'bold', ...
        'FontColor', SUBTXT);

    editWord = uieditfield(pnlInput, 'text', ...
        'Position', [78 14 180 30], ...
        'FontSize', 13, 'FontName', 'Consolas', ...
        'Placeholder', 'type a word...');

    btnPredict = uibutton(pnlInput, 'push', ...
        'Position', [274 14 90 30], ...
        'Text', 'Predict', 'FontSize', 11, 'FontWeight', 'bold', ...
        'BackgroundColor', ACCENT, 'FontColor', [1 1 1]);
    btnPredict.ButtonPushedFcn = @(~,~)onPredict();

    btnLetter = uibutton(pnlInput, 'push', ...
        'Position', [374 14 100 30], ...
        'Text', 'Letter', 'FontSize', 11, 'FontWeight', 'bold', ...
        'BackgroundColor', PURPLE, 'FontColor', [1 1 1]);
    btnLetter.ButtonPushedFcn = @(~,~)onLetterMatch();

    btnClear = uibutton(pnlInput, 'push', ...
        'Position', [484 14 80 30], ...
        'Text', 'Clear', 'FontSize', 11, 'FontWeight', 'bold', ...
        'BackgroundColor', RED, 'FontColor', [1 1 1]);
    btnClear.ButtonPushedFcn = @(~,~)onClear();

    btnChart = uibutton(pnlInput, 'push', ...
        'Position', [574 14 80 30], ...
        'Text', 'Chart', 'FontSize', 11, 'FontWeight', 'bold', ...
        'BackgroundColor', TEAL, 'FontColor', [1 1 1]);
    btnChart.ButtonPushedFcn = @(~,~)onChart();

    % ══════════════════════════════════════
    %  RESULT CARDS
    % ══════════════════════════════════════
    cardW = figW - 32;
    cardH = 155;
    gap   = 12;

    % ── Bigram Card ──
    yBigram = inY - gap - cardH;
    pnlBigram = uipanel(fig, ...
        'Position', [16 yBigram cardW cardH], ...
        'BackgroundColor', CARD, ...
        'BorderType', 'line', 'HighlightColor', BORDER);
    uilabel(pnlBigram, ...
        'Position', [16 120 cardW-32 24], ...
        'Text', 'Bigram Model', ...
        'FontSize', 13, 'FontWeight', 'bold', ...
        'FontColor', GREEN);
    lblBigram = uilabel(pnlBigram, ...
        'Position', [16 8 cardW-32 108], ...
        'Text', '  Enter a word and click Predict', ...
        'FontSize', 12, 'FontColor', SUBTXT, ...
        'VerticalAlignment', 'top', 'WordWrap', 'on');

    % ── Vector Card ──
    yVector = yBigram - gap - cardH;
    pnlVector = uipanel(fig, ...
        'Position', [16 yVector cardW cardH], ...
        'BackgroundColor', CARD, ...
        'BorderType', 'line', 'HighlightColor', BORDER);
    uilabel(pnlVector, ...
        'Position', [16 120 cardW-32 24], ...
        'Text', 'Vector Similarity', ...
        'FontSize', 13, 'FontWeight', 'bold', ...
        'FontColor', PURPLE);
    lblVector = uilabel(pnlVector, ...
        'Position', [16 8 cardW-32 108], ...
        'Text', '  Enter a word and click Predict', ...
        'FontSize', 12, 'FontColor', SUBTXT, ...
        'VerticalAlignment', 'top', 'WordWrap', 'on');

    % ── Letter Match Card ──
    yLetter = yVector - gap - cardH;
    pnlLetter = uipanel(fig, ...
        'Position', [16 yLetter cardW cardH], ...
        'BackgroundColor', CARD, ...
        'BorderType', 'line', 'HighlightColor', BORDER);
    uilabel(pnlLetter, ...
        'Position', [16 120 cardW-32 24], ...
        'Text', 'Letter Match', ...
        'FontSize', 13, 'FontWeight', 'bold', ...
        'FontColor', ORANGE);
    lblLetter = uilabel(pnlLetter, ...
        'Position', [16 8 cardW-32 108], ...
        'Text', '  Enter a letter (a-z) and click Letter', ...
        'FontSize', 12, 'FontColor', SUBTXT, ...
        'VerticalAlignment', 'top', 'WordWrap', 'on');

    chartFig = [];

    % ══════════════════════════════════════
    %  CALLBACKS
    % ══════════════════════════════════════

    function onPredict()
        raw = editWord.Value;
        if isempty(raw) || (iscell(raw) && isempty(raw{1}))
            uialert(fig, 'Please enter a word.', 'Input Required');
            return;
        end
        if iscell(raw), raw = raw{1}; end
        word = lower(strtrim(raw));
        if isempty(word)
            uialert(fig, 'Please enter a word.', 'Input Required');
            return;
        end

        bigramPreds = prediction_words_bigram(word, bigramModel, 5);
        if isKey(vocabLookup, word)
            inVocab = true;
        else
            inVocab = false;
        end

        vecPreds = predict_vector_similar(word, embeddings, 5);

        if inVocab
            lblBigram.Text = sprintf('  "%s"  -->  %s', word, strjoin(bigramPreds, '  |  '));
            lblBigram.FontColor = TXT;
        else
            lblBigram.Text = sprintf('  "%s"  (unknown)  -->  %s', word, strjoin(bigramPreds, '  |  '));
            lblBigram.FontColor = SUBTXT;
        end

        if isempty(vecPreds)
            lblVector.Text = sprintf('  No similar words found for "%s"', word);
            lblVector.FontColor = SUBTXT;
        elseif inVocab
            lblVector.Text = sprintf('  "%s"  -->  %s', word, strjoin(vecPreds, '  |  '));
            lblVector.FontColor = TXT;
        else
            lblVector.Text = sprintf('  "%s"  (unknown)  -->  %s', word, strjoin(vecPreds, '  |  '));
            lblVector.FontColor = SUBTXT;
        end

        lblStatus.Text = sprintf('  Predicted for "%s"', word);
        lblStatus.FontColor = GREEN;
        pause(0.4);
        lblStatus.FontColor = SUBTXT;
        lblStatus.Text = sprintf('  Vocabulary: %d words  |  Ready', nVocab);
    end

    function onLetterMatch()
        raw = editWord.Value;
        if isempty(raw) || (iscell(raw) && isempty(raw{1}))
            uialert(fig, 'Please enter a letter.', 'Input Required');
            return;
        end
        if iscell(raw), raw = raw{1}; end
        ch = lower(strtrim(raw));
        if isempty(ch)
            uialert(fig, 'Please enter a letter.', 'Input Required');
            return;
        end
        ch = ch(1);
        if ch < 'a' || ch > 'z'
            uialert(fig, 'Please enter a valid letter (a-z).', 'Invalid Input');
            return;
        end
        mask = cellfun(@(w) ~isempty(w) && w(1) == ch, vocab);
        matches = vocab(mask);
        total = sum(mask);
        if numel(matches) > 30
            matches = matches(1:30);
        end
        if isempty(matches)
            lblLetter.Text = sprintf('  No words start with "%s"', ch);
            lblLetter.FontColor = SUBTXT;
        else
            lblLetter.Text = sprintf('  "%s" -- %d matches\n  %s', ...
                upper(ch), total, strjoin(matches, '  |  '));
            lblLetter.FontColor = TXT;
        end
        lblStatus.Text = sprintf('  Letter "%s" -- %d matches found', ch, total);
        lblStatus.FontColor = ORANGE;
        pause(0.4);
        lblStatus.FontColor = SUBTXT;
        lblStatus.Text = sprintf('  Vocabulary: %d words  |  Ready', nVocab);
    end

    function onClear()
        editWord.Value = '';
        lblBigram.Text  = '  Enter a word and click Predict';
        lblBigram.FontColor = SUBTXT;
        lblVector.Text  = '  Enter a word and click Predict';
        lblVector.FontColor = SUBTXT;
        lblLetter.Text  = '  Enter a letter (a-z) and click Letter';
        lblLetter.FontColor = SUBTXT;
        if ~isempty(chartFig) && isvalid(chartFig)
            delete(chartFig);
            chartFig = [];
        end
        lblStatus.Text = sprintf('  Vocabulary: %d words  |  Ready', nVocab);
        lblStatus.FontColor = SUBTXT;
    end

    function onChart()
        raw = editWord.Value;
        if isempty(raw) || (iscell(raw) && isempty(raw{1}))
            uialert(fig, 'Enter a word first, then click Chart.', 'Input Required');
            return;
        end
        if iscell(raw), raw = raw{1}; end
        word = lower(strtrim(raw));
        if ~isKey(vocabLookup, word)
            uialert(fig, sprintf('"%s" is not in the vocabulary.', word), 'Unknown Word');
            return;
        end
        idx = vocabLookup(word);
        preds = prediction_words_bigram(word, bigramModel, 5);
        probs = bigramModel.probs(idx, :);
        showChartFigure(word, preds, probs);
    end

    function showChartFigure(word, preds, probs)
        if ~isempty(chartFig) && isvalid(chartFig)
            delete(chartFig);
        end
        chartFig = figure( ...
            'Name',       sprintf('Predictions for "%s"', word), ...
            'Position',   [200 120 640 420], ...
            'Color',      [0.98 0.985 0.99], ...
            'NumberTitle','off', 'MenuBar', 'none', 'ToolBar', 'none');

        vals = zeros(1, numel(preds));
        for i = 1:numel(preds)
            if isKey(vocabLookup, preds{i})
                wi = vocabLookup(preds{i});
                vals(i) = full(probs(wi));
            end
        end

        ax = axes(chartFig, 'Position', [0.10 0.15 0.85 0.72]);
        bar(ax, 1:numel(preds), vals, ...
            'FaceColor', ACCENT, 'EdgeColor', 'none', 'BarWidth', 0.55);
        ax.XTick = 1:numel(preds);
        ax.XTickLabel = preds;
        ax.XTickLabelRotation = 20;
        ax.FontSize = 12;
        ax.Color = [0.98 0.985 0.99];
        ax.XColor = [0.5 0.5 0.55];
        ax.YColor = [0.5 0.5 0.55];
        ylabel(ax, 'Probability', 'FontSize', 11);
        title(ax, sprintf('Top predictions for "%s"', word), ...
            'FontSize', 14, 'FontWeight', 'bold');
        grid(ax, 'on');
        ax.GridAlpha = 0.15;
        ax.GridColor = [0.8 0.8 0.85];
    end

    function cleanup()
        if ~isempty(chartFig) && isvalid(chartFig)
            delete(chartFig);
        end
        delete(fig);
    end
end