function ui_demo()
%UI_DEMO Interactive next-word prediction demo — Lightweight & Clean

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

    % ── Colour Palette (light & airy) ──
    BG    = [0.97 0.97 0.98];
    PANEL = [1 1 1];
    ACC   = [0.20 0.55 0.85];
    ACC_H = [0.15 0.45 0.70];
    GRN   = [0.22 0.65 0.35];
    PUR   = [0.55 0.35 0.80];
    RED   = [0.85 0.25 0.25];
    TXT   = [0.20 0.20 0.25];
    MUTED = [0.55 0.55 0.60];
    BORDER= [0.85 0.85 0.88];
    YLW   = [1.00 0.82 0.20];
    BAR_BG= [0.93 0.94 0.96];

    % ════════════════════════════════════════
    %  MAIN FIGURE
    % ════════════════════════════════════════
    fig = uifigure( ...
        'Name',    'Next Word Prediction', ...
        'Position', [100 80 820 600], ...
        'Color',   BG, ...
        'WindowStyle', 'normal');
    fig.CloseRequestFcn = @(~,~)cleanup();

    % ──── HEADER ────
    pnlHeader = uipanel(fig, ...
        'Position', [0 560 820 40], ...
        'BackgroundColor', ACC, ...
        'BorderType', 'none');
    uilabel(pnlHeader, ...
        'Position', [0 8 820 24], ...
        'Text', 'NEXT WORD PREDICTION', ...
        'FontSize', 16, 'FontWeight', 'bold', ...
        'FontColor', [1 1 1], ...
        'HorizontalAlignment', 'center');

    % ──── STATUS BAR ────
    pnlStatus = uipanel(fig, ...
        'Position', [0 0 820 22], ...
        'BackgroundColor', [0.92 0.92 0.94], ...
        'BorderType', 'line', 'HighlightColor', BORDER);
    lblStatus = uilabel(pnlStatus, ...
        'Position', [10 1 800 20], ...
        'Text', sprintf(' Ready  ·  Vocabulary: %d words', nVocab), ...
        'FontSize', 9, 'FontColor', MUTED);

    % ════════════════════════════════════════
    %  INPUT ROW
    % ════════════════════════════════════════
    pnlInput = uipanel(fig, ...
        'Position', [10 505 800 50], ...
        'BackgroundColor', PANEL, ...
        'BorderType', 'line', 'HighlightColor', BORDER);

    uilabel(pnlInput, ...
        'Position', [8 12 50 22], 'Text', 'Word:', ...
        'FontColor', TXT, 'FontWeight', 'bold', 'FontSize', 11);

    editWord = uieditfield(pnlInput, 'text', ...
        'Position', [58 10 180 26], ...
        'FontSize', 12, 'FontName', 'Consolas', ...
        'Placeholder', 'type a word ...');

    btnPredict = uibutton(pnlInput, 'push', ...
        'Position', [248 10 100 26], ...
        'Text', 'Predict', 'FontSize', 11, 'FontWeight', 'bold', ...
        'BackgroundColor', ACC, 'FontColor', [1 1 1]);
    btnPredict.ButtonPushedFcn = @(~,~)onPredict();

    btnLetter = uibutton(pnlInput, 'push', ...
        'Position', [358 10 110 26], ...
        'Text', 'Letter Match', 'FontSize', 11, ...
        'BackgroundColor', PUR, 'FontColor', [1 1 1]);
    btnLetter.ButtonPushedFcn = @(~,~)onLetterMatch();

    btnClear = uibutton(pnlInput, 'push', ...
        'Position', [478 10 90 26], ...
        'Text', 'Clear', 'FontSize', 11, ...
        'BackgroundColor', RED, 'FontColor', [1 1 1]);
    btnClear.ButtonPushedFcn = @(~,~)onClear();

    btnChart = uibutton(pnlInput, 'push', ...
        'Position', [578 10 100 26], ...
        'Text', 'Chart', 'FontSize', 11, ...
        'BackgroundColor', [0.30 0.65 0.55], 'FontColor', [1 1 1]);
    btnChart.ButtonPushedFcn = @(~,~)onChart();

    % ════════════════════════════════════════
    %  LEFT COLUMN  —  Results
    % ════════════════════════════════════════
    LEFT_X = 10;
    COL_W  = 395;

    % ── Bigram results ──
    pnlBigram = uipanel(fig, ...
        'Position', [LEFT_X 375 COL_W 125], ...
        'BackgroundColor', PANEL, ...
        'BorderType', 'line', 'HighlightColor', BORDER);
    uilabel(pnlBigram, ...
        'Position', [8 100 378 20], ...
        'Text', 'Bigram Prediction', ...
        'FontColor', GRN, 'FontWeight', 'bold', 'FontSize', 11);
    lblBigram = uilabel(pnlBigram, ...
        'Position', [8 5 378 95], ...
        'Text', '  —', ...
        'FontColor', TXT, 'FontSize', 11, ...
        'VerticalAlignment', 'top', 'WordWrap', 'on');

    % ── Vector results ──
    pnlVector = uipanel(fig, ...
        'Position', [LEFT_X 248 COL_W 122], ...
        'BackgroundColor', PANEL, ...
        'BorderType', 'line', 'HighlightColor', BORDER);
    uilabel(pnlVector, ...
        'Position', [8 96 378 20], ...
        'Text', 'Vector Prediction', ...
        'FontColor', PUR, 'FontWeight', 'bold', 'FontSize', 11);
    lblVector = uilabel(pnlVector, ...
        'Position', [8 5 378 90], ...
        'Text', '  —', ...
        'FontColor', TXT, 'FontSize', 11, ...
        'VerticalAlignment', 'top', 'WordWrap', 'on');

    % ── Letter match ──
    pnlLetter = uipanel(fig, ...
        'Position', [LEFT_X 130 COL_W 113], ...
        'BackgroundColor', PANEL, ...
        'BorderType', 'line', 'HighlightColor', BORDER);
    uilabel(pnlLetter, ...
        'Position', [8 88 378 20], ...
        'Text', 'Letter Match', ...
        'FontColor', [0.80 0.55 0.10], 'FontWeight', 'bold', 'FontSize', 11);
    lblLetter = uilabel(pnlLetter, ...
        'Position', [8 5 378 82], ...
        'Text', '  —', ...
        'FontColor', TXT, 'FontSize', 11, ...
        'VerticalAlignment', 'top', 'WordWrap', 'on');

    % ════════════════════════════════════════
    %  RIGHT COLUMN  —  Probability bars
    % ════════════════════════════════════════
    pnlProb = uipanel(fig, ...
        'Position', [415 130 395 370], ...
        'BackgroundColor', PANEL, ...
        'BorderType', 'line', 'HighlightColor', BORDER);
    uilabel(pnlProb, ...
        'Position', [8 342 378 20], ...
        'Text', 'Probability Preview', ...
        'FontColor', ACC, 'FontWeight', 'bold', 'FontSize', 11);
    lblProb = uilabel(pnlProb, ...
        'Position', [8 5 378 335], ...
        'Text', ' Enter a word and click  PREDICT  to see results.', ...
        'FontColor', MUTED, 'FontSize', 11, 'FontName', 'Consolas', ...
        'VerticalAlignment', 'top', 'WordWrap', 'on');

    % ── Chart axes (hidden until needed) ──
    axChart = uiaxes(fig, ...
        'Position', [425 140 375 355], ...
        'Visible', 'off', ...
        'Color', PANEL, ...
        'XColor', MUTED, 'YColor', MUTED, ...
        'GridColor', BORDER, 'GridAlpha', 0.5, ...
        'Box', 'on');
    axChart.XLabel.String = 'Word';
    axChart.YLabel.String = 'Probability';
    grid(axChart, 'on');

    % ════════════════════════════════════════
    %  CALLBACKS
    % ════════════════════════════════════════
    chartFig = [];

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

        % Predict bigram
        bigramPreds = prediction_words_bigram(word, bigramModel, 5);
        if isKey(vocabLookup, word)
            idx = vocabLookup(word);
            bigramProbs = bigramModel.probs(idx, :);
            inVocab = true;
        else
            bigramProbs = [];
            inVocab = false;
        end

        % Predict vector
        vecPreds = predict_vector_similar(word, embeddings, 5);

        % Update bigram label
        if inVocab
            lblBigram.Text = ['  ' strjoin(bigramPreds, '  ›  ')];
        else
            lblBigram.Text = ['  [not in vocab]  ' strjoin(bigramPreds, '  ›  ')];
        end

        % Update vector label
        if isempty(vecPreds)
            lblVector.Text = '  —';
        elseif inVocab
            lblVector.Text = ['  ' strjoin(vecPreds, '  ›  ')];
        else
            lblVector.Text = ['  [not in vocab]  ' strjoin(vecPreds, '  ›  ')];
        end

        % Update probability text
        updateProbDisplay(bigramPreds, bigramProbs);

        % Update chart axes
        plotBarChart(bigramPreds, bigramProbs);

        % Status
        if inVocab
            lblStatus.Text = sprintf(' Predicted for "%s"  ·  Bigram: %s  |  Vector: %s', ...
                word, strjoin(bigramPreds, ', '), strjoin(vecPreds, ', '));
            lblStatus.FontColor = GRN;
        else
            lblStatus.Text = sprintf(' "%s" not in vocabulary — using backoff predictions', word);
            lblStatus.FontColor = [0.80 0.55 0.10];
        end
        pause(0.3);
        lblStatus.FontColor = MUTED;
        lblStatus.Text = sprintf(' Ready  ·  Vocabulary: %d words', nVocab);
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
        if numel(matches) > 30
            matches = matches(1:30);
        end
        if isempty(matches)
            lblLetter.Text = sprintf('  No words start with "%s"', ch);
        else
            lblLetter.Text = ['  "' upper(ch) '":  ' strjoin(matches, '  ·  ')];
        end
        lblStatus.Text = sprintf(' Letter "%s" — %d matches found', ch, sum(mask));
    end

    function onClear()
        editWord.Value = '';
        lblBigram.Text  = '  —';
        lblVector.Text  = '  —';
        lblLetter.Text  = '  —';
        lblProb.Text    = ' Enter a word and click  PREDICT  to see results.';
        cla(axChart);
        axChart.Visible = 'off';
        lblProb.Visible = 'on';
        if ~isempty(chartFig) && isvalid(chartFig)
            delete(chartFig);
            chartFig = [];
        end
        lblStatus.Text = sprintf(' Cleared  ·  Vocabulary: %d words', nVocab);
        lblStatus.FontColor = MUTED;
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
            uialert(fig, sprintf('"%s" not in vocabulary.', word), 'Unknown Word');
            return;
        end
        idx = vocabLookup(word);
        preds = prediction_words_bigram(word, bigramModel, 5);
        probs = bigramModel.probs(idx, :);
        showChartFigure(word, preds, probs);
    end

    function updateProbDisplay(preds, probs)
        if isempty(preds)
            lblProb.Text = ' No predictions available.';
            return;
        end
        lines = {};
        lines{end+1} = sprintf('  %-14s %6s  %s', 'Word', 'Prob', 'Bar');
        lines{end+1} = repmat('─', 1, 50);
        for i = 1:numel(preds)
            if ~isempty(probs) && isKey(vocabLookup, preds{i})
                wi = vocabLookup(preds{i});
                p  = full(probs(wi));
            else
                p = 0;
            end
            n   = min(max(round(p * 100), 0), 25);
            bar = [repmat('█', 1, n) repmat('░', 1, 25-n)];
            lines{end+1} = sprintf('  %-14s %5.1f%%  %s', preds{i}, p*100, bar);
        end
        lblProb.Text = strjoin(lines, newline);
    end

    function plotBarChart(preds, probs)
        if isempty(preds)
            cla(axChart); axChart.Visible = 'off'; lblProb.Visible = 'on';
            return;
        end
        vals = zeros(1, numel(preds));
        for i = 1:numel(preds)
            if ~isempty(probs) && isKey(vocabLookup, preds{i})
                wi = vocabLookup(preds{i});
                vals(i) = full(probs(wi));
            else
                vals(i) = 1 / max(numel(preds), 1);
            end
        end
        cla(axChart);
        b = bar(axChart, 1:numel(preds), vals, ...
            'FaceColor', ACC, 'EdgeColor', 'none', 'BarWidth', 0.6);
        axChart.XTick = 1:numel(preds);
        axChart.XTickLabel = preds;
        axChart.XTickLabelRotation = 30;
        ylabel(axChart, 'Probability');
        grid(axChart, 'on');
        axChart.GridAlpha = 0.3;
        axChart.Visible = 'on';
        lblProb.Visible = 'off';
    end

    function showChartFigure(word, preds, probs)
        if ~isempty(chartFig) && isvalid(chartFig)
            delete(chartFig);
        end
        chartFig = figure( ...
            'Name',       sprintf('Probability Chart — "%s"', word), ...
            'Position',   [200 150 620 400], ...
            'Color',      [1 1 1], ...
            'NumberTitle','off', 'MenuBar', 'none', 'ToolBar', 'none');

        vals = zeros(1, numel(preds));
        for i = 1:numel(preds)
            if isKey(vocabLookup, preds{i})
                wi = vocabLookup(preds{i});
                vals(i) = full(probs(wi));
            end
        end

        ax = axes(chartFig, 'Position', [0.13 0.18 0.80 0.70]);
        b = bar(ax, 1:numel(preds), vals, ...
            'FaceColor', ACC, 'EdgeColor', 'none', 'BarWidth', 0.6);
        ax.XTick = 1:numel(preds);
        ax.XTickLabel = preds;
        ax.XTickLabelRotation = 30;
        ylabel(ax, 'Probability');
        title(ax, sprintf('Top predictions for "%s"', word), 'FontSize', 13);
        grid(ax, 'on');
        ax.GridAlpha = 0.3;
        ax.Color = [1 1 1];
    end

    function cleanup()
        if ~isempty(chartFig) && isvalid(chartFig)
            delete(chartFig);
        end
        delete(fig);
    end
end
