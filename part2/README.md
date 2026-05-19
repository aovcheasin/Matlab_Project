# Part 2 — N-gram Model Implementation

## Files
- `train_bigram_model.m` - Trains bigram model with Laplace smoothing
- `train_trigram_model.m` - Trains trigram model with backoff to bigram
- `prediction_words_bigram.m` - Predicts next word given history
- `prediction_words_trigram.m` - Predicts next word using trigram with backoff

## Usage

```matlab
% Train bigram model
[tokens, ~, ~] = text_processing('corpus.txt');
model = train_bigram_model(tokens);

% Predict next word
nextWords = prediction_words_bigram('she', model, 5);

% Train trigram model (optional)
tmodel = train_trigram_model(tokens);
nextWords = prediction_words_trigram({'she', 'was'}, tmodel, 5);
```

## Features
- Bigram frequency counts with Laplace smoothing
- Trigram model with backoff to bigram/unigram
- Handles unknown words gracefully