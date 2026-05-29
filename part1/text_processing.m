function [tokens, vocabulary, wordFreq] = text_processing(corpusPath)
% TEXT_PROCESSING - Text preprocessing and tokenization
%   Reads corpus, cleans text, tokenizes, and builds vocabulary
%
%   Inputs:
%       corpusPath - path to text corpus file (default: 'corpus.txt')
%
%   Outputs:
%       tokens - cell array of all words
%       vocabulary - cell array of unique words
%       wordFreq - structure with word frequencies
if nargin < 1, corpusPath = 'corpus.txt'; end

    text = fileread(corpusPath);
    
    % Split into lines and process each line
    lines = strsplit(text, newline);
    cleanedLines = cell(size(lines));
    
    for i = 1:length(lines)
        line = lines{i};
        % Remove line number prefix (e.g., "1: ", "2: ", etc.)
        line = regexprep(line, '^\d+:\s*', '');
        % Convert to lowercase
        line = lower(line);
        cleanedLines{i} = line;
    end
    
    % Join back and process
    text = strjoin(cleanedLines, ' ');
    
    % Remove carriage returns and other special chars
    text = regexprep(text, '[\r]', ' ');
    
    % Replace smart quotes/apostrophe encodings with standard apostrophe
    text = strrep(text, char(8216), '''');
    text = strrep(text, char(8217), '''');
    text = strrep(text, char(8220), '"');
    text = strrep(text, char(8221), '"');
    % Remove punctuation and special characters (keep apostrophes within words)
    text = regexprep(text, '[^a-z0-9\s'']', ' ');
    % Remove standalone apostrophes
    text = regexprep(text, '(^|\s)''|''(\s|$)', ' ');
    
    % Split into tokens
    tokens = strsplit(text, {' ', char(9)});
    tokens = tokens(~cellfun('isempty', tokens));
    
    % Create vocabulary (unique words)
    [vocabulary, ~, idx] = unique(tokens, 'stable');
    
    % Calculate word frequencies
    counts = accumarray(idx, 1);
    [sortedCounts, sortIdx] = sort(counts, 'descend');
    
    wordFreq.words = vocabulary(sortIdx);
    wordFreq.counts = sortedCounts;
end