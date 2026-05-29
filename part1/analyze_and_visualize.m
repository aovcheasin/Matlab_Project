function analyze_and_visualize(corpusPath)
% ANALYZE_AND_VISUALIZE - Corpus analysis and visualization
%   Analyzes text corpus and generates statistics
%
%   Input:
%       corpusPath - path to text corpus file (default: 'corpus.txt')
if nargin < 1, corpusPath = 'corpus.txt'; end

    % Preprocess text
    [tokens, vocabulary, wordFreq] = text_processing(corpusPath);
    
    % Calculate basic statistics
    vocabSize = length(vocabulary);
    totalWords = length(tokens);
    avgWordLen = mean(cellfun(@length, tokens));
    
    % Display statistics
    fprintf('=== Corpus Statistics ===\n');
    fprintf('Total words: %d\n', totalWords);
    fprintf('Vocabulary size: %d\n', vocabSize);
    fprintf('Average word length: %.2f characters\n', avgWordLen);
    fprintf('\n');
    
    % Display most common words
    fprintf('=== Top 20 Most Common Words ===\n');
    for i = 1:min(20, length(wordFreq.words))
        fprintf('%2d. %s: %d\n', i, wordFreq.words{i}, wordFreq.counts(i));
    end
    
    % Plot word frequency distribution
    figure;
    subplot(2, 2, 1);
    plot(wordFreq.counts(1:min(100, end)));
    title('Top 100 Word Frequencies');
    xlabel('Word Rank');
    ylabel('Frequency');
    
    % Plot vocabulary growth
    subplot(2, 2, 2);
    cumulativeWords = cumsum(wordFreq.counts);
    plot(cumulativeWords / cumulativeWords(end) * 100);
    title('Vocabulary Coverage %');
    xlabel('Number of Unique Words');
    ylabel('Coverage %');
    
    % Word length distribution
    subplot(2, 2, 3);
    wordLengths = cellfun(@length, tokens);
    histogram(wordLengths, 0:15);
    title('Word Length Distribution');
    xlabel('Word Length');
    ylabel('Frequency');
    
    % Zipf's law plot (log-log)
    subplot(2, 2, 4);
    ranks = 1:length(wordFreq.counts);
    loglog(ranks, wordFreq.counts, 'b.');
    title('Word Frequency (Zipf''s Law)');
    xlabel('Rank');
    ylabel('Frequency');
    grid on;
end