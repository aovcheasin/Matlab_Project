# Next Word Prediction — Project Report

**Prepared by:** Mr. Nop Phearum
**Project:** MATLAB Next Word Prediction System
**Language:** MATLAB

---

## Table of Contents

1. [Introduction](#1-introduction)
2. [System Architecture](#2-system-architecture)
3. [Part 1: Data Preparation](#3-part-1-data-preparation)
4. [Part 2: N-gram Model Implementation](#4-part-2-n-gram-model-implementation)
5. [Part 3: Vector Representation](#5-part-3-vector-representation)
6. [Part 4: Model Evaluation](#6-part-4-model-evaluation)
7. [Part 5: Application and Documentation](#7-part-5-application-and-documentation)
8. [Results and Analysis](#8-results-and-analysis)
9. [Strengths and Weaknesses](#9-strengths-and-weaknesses)
10. [Suggestions for Improvement](#10-suggestions-for-improvement)
11. [Conclusion](#11-conclusion)

---

## 1. Introduction

This project implements a **next word prediction system** using statistical language models and vector space methods in MATLAB. Given one or more input words, the system predicts the most likely word to follow. Three approaches are implemented and compared:

- **Bigram model** — predicts based on single-word context
- **Trigram model** — predicts based on two-word context (extra credit)
- **Vector similarity model** — predicts based on word embedding cosine similarity

The system is demonstrated through an interactive MATLAB GUI that allows users to enter a word and see real-time predictions from both the bigram and vector models.

---

## 2. System Architecture

```
corpus.txt
    │
    ▼
┌─────────────────────┐
│  text_processing()  │  Part 1: Clean, tokenize, build vocabulary
└────────┬────────────┘
         │ tokens
         ├──────────────────────────────────┐
         ▼                                  ▼
┌──────────────────┐            ┌─────────────────────────┐
│ train_bigram_    │            │ co_occurrence_word_     │
│ model()          │            │ embeddings()            │
│                  │            │                         │
│ train_trigram_   │            │ one_hot_encoding()      │
│ model()          │            └───────────┬─────────────┘
└────────┬─────────┘                        │
         │                                  ▼
         │                     ┌─────────────────────────┐
         │                     │ predict_vector_similar()│
         │                     └───────────┬─────────────┘
         ▼                                 │
┌──────────────────────┐                   │
│prediction_words_     │                   │
│bigram() / trigram()  │                   │
└────────┬─────────────┘                   │
         │                                 │
         ▼                                 ▼
┌─────────────────────────────────────────────────────┐
│              Evaluation (Part 4)                     │
│  split_corpus() → evaluate_accuracy() → perplexity  │
└────────────────────────┬────────────────────────────┘
                         │
                         ▼
              ┌─────────────────────┐
              │  ui_demo() (Part 5) │
              │  Interactive GUI    │
              └─────────────────────┘
```

### File Inventory

| File | Part | Purpose |
|------|------|---------|
| `main.m` | — | Entry point: trains models, runs demo, saves models |
| `part1/text_processing.m` | 1 | Corpus reading, cleaning, tokenization, vocabulary |
| `part1/analyze_and_visualize.m` | 1 | Statistics and 4 visualization plots |
| `part2/train_bigram_model.m` | 2 | Bigram training with Laplace smoothing |
| `part2/train_trigram_model.m` | 2 | Trigram training with sparse storage and backoff |
| `part2/prediction_words_bigram.m` | 2 | Bigram next-word prediction |
| `part2/prediction_words_trigram.m` | 2 | Trigram next-word prediction with backoff |
| `part3/one_hot_encoding.m` | 3 | One-hot vector baseline encoding |
| `part3/co_occurrence_word_embeddings.m` | 3 | PPMI-weighted co-occurrence + SVD embeddings |
| `part3/predict_vector_similar.m` | 3 | Cosine similarity word prediction |
| `part3/compare_predictions.m` | 3 | Compares n-gram and vector predictions on test set |
| `part4/split_corpus.m` | 4 | Train/test split |
| `part4/evaluate_accuracy.m` | 4 | Top-k accuracy evaluation |
| `part4/measure_perplexity.m` | 4 | Perplexity measurement |
| `part4/compare_all_models.m` | 4 | End-to-end model comparison pipeline |
| `part5/ui_demo.m` | 5 | Interactive GUI with charts |
| `part5/save_load_model.m` | 5 | Model serialization |

---

## 3. Part 1: Data Preparation

### Corpus

The corpus consists of **1000 English sentences** stored in `corpus.txt`. Each line is prefixed with a line number (e.g., `1: `, `2: `, ..., `1000: `). The sentences are short, everyday English covering a variety of topics — personal anecdotes, descriptions, dialogue, and general statements.

### Preprocessing Pipeline (`text_processing.m`)

1. **Read file** — `fileread()` loads the entire corpus as a single string
2. **Split into lines** — split on newline characters
3. **Remove line number prefixes** — regex `^\d+:\s*` strips the `N: ` prefix from each line
4. **Lowercase conversion** — all text converted to lowercase
5. **Remove punctuation** — regex `[^a-z0-9\s]` replaces all non-alphanumeric characters with spaces
6. **Tokenization** — split on spaces and tab characters
7. **Remove empty tokens** — filter out empty strings from consecutive spaces
8. **Build vocabulary** — `unique(tokens, 'stable')` preserves first-occurrence order
9. **Compute frequencies** — `accumarray` counts occurrences, sorted descending

### Analysis and Visualization (`analyze_and_visualize.m`)

Four plots are generated:

| Plot | Description |
|------|-------------|
| Top 100 Word Frequencies | Bar chart of the 100 most common words ranked by frequency |
| Vocabulary Coverage % | Cumulative distribution showing what percentage of the corpus is covered by the top N words |
| Word Length Distribution | Histogram of word lengths (0–15 characters) |
| Zipf's Law | Log-log plot of rank vs. frequency, demonstrating the power-law distribution of natural language |

### Key Corpus Statistics

- **Total tokens:** approximately 10,000–13,000 words (depending on punctuation handling)
- **Vocabulary size:** approximately 2,500–3,000 unique words
- **Most frequent words:** expected to be function words (the, a, is, to, and, etc.) consistent with Zipf's law

---

## 4. Part 2: N-gram Model Implementation

### Bigram Model (`train_bigram_model.m`)

**Data structures:**
- `counts` — `vocabSize × vocabSize` matrix of bigram occurrence counts
- `probs` — `vocabSize × vocabSize` matrix of transition probabilities
- `vocabLookup` — `containers.Map` for O(1) word-to-index lookup
- `unigramProbs` — unigram probability distribution for backoff

**Training process:**
1. Build vocabulary and map each token to an index
2. Count all adjacent word pairs: for each position `i`, increment `counts[w_i][w_{i+1}]`
3. Apply **Laplace (add-1) smoothing**:

```
P(w2 | w1) = (count(w1, w2) + 1) / (count(w1) + vocabSize)
```

4. For words with no observed bigrams, assign uniform probability `1/vocabSize`
5. Store unigram probabilities for backoff when the input word is unknown

**Prediction (`prediction_words_bigram.m`):**
- If the input word exists in vocabulary: retrieve its probability row, sort descending, return top-k
- If the input word is unknown: fall back to unigram distribution (most frequent words overall)

### Trigram Model (`train_trigram_model.m`)

**Data structures:**
- `trigramCounts` — `containers.Map` with keys `"w1_w2"` mapping to sparse vectors of `w3` counts
- `bigramModel` — embedded bigram model for backoff

**Training process:**
1. For each position `i`, record the trigram `(w_i, w_{i+1}, w_{i+2})`
2. Store counts in a hash map keyed by the first two word indices
3. Reuse the bigram model as a fallback

**Prediction (`prediction_words_trigram.m`):**

Backoff chain:
```
trigram(w1, w2) → bigram(w2) → unigram
```

- If both context words exist and a trigram entry is found: return top-k from trigram distribution
- Otherwise: fall back to bigram with `w2` as context
- If `w2` is also unknown: fall back to unigram distribution

### Smoothing Technique

**Laplace smoothing** (add-1) is applied to the bigram model. This addresses the zero-probability problem for unseen bigrams by adding 1 to every count, ensuring no transition has exactly zero probability. The denominator is adjusted by `vocabSize` to maintain a valid probability distribution.

---

## 5. Part 3: Vector Representation

### One-Hot Encoding (`one_hot_encoding.m`)

A baseline representation where each word is a sparse binary vector of length `vocabSize` with a single 1 at the word's vocabulary index. This produces a `vocabSize × numTokens` sparse matrix. One-hot vectors are orthogonal — they capture no semantic similarity between words.

### Co-occurrence Word Embeddings (`co_occurrence_word_embeddings.m`)

This is the main embedding method, implementing a pipeline inspired by **GloVe** and **word2vec** approaches:

**Step 1 — Build co-occurrence matrix:**
- For each word at position `i`, look at surrounding words within a window of size `windowSize` (default: 2)
- Increment `coMatrix[center][context]` for each co-occurrence
- Result: a `vocabSize × vocabSize` sparse symmetric matrix

**Step 2 — PPMI weighting (Positive Pointwise Mutual Information):**

```
P(w, c) = coMatrix(w, c) / totalCount
P(w)    = sum(coMatrix(w, :)) / totalCount
P(c)    = sum(coMatrix(:, c)) / totalCount
PPMI(w, c) = max(0, log(P(w, c) / (P(w) * P(c))))
```

PPMI upweights word pairs that co-occur more often than expected by chance and sets negative values to zero. This produces a cleaner signal than raw co-occurrence counts.

**Step 3 — Dimensionality reduction via SVD:**
- Apply `svds(ppmiMatrix, 50)` to extract the top 50 singular vectors
- The resulting matrix `V` (vocabSize × 50) serves as the word embedding matrix
- Each word is represented as a dense 50-dimensional vector

### Vector Similarity Prediction (`predict_vector_similar.m`)

1. Look up the input word's 50-dimensional vector
2. Compute **cosine similarity** between this vector and every word vector in the vocabulary:

```
similarity(a, b) = (a · b) / (||a|| × ||b||)
```

3. Sort by similarity descending, exclude the query word itself, return top-k

### Prediction Comparison (`compare_predictions.m`)

Evaluates all three models on a test set of tokenized sentences:
- For each sentence, use the last word as the target and the preceding word(s) as context
- Check if the true next word appears in the top-10 predictions
- Report accuracy for bigram, trigram, and vector models

---

## 6. Part 4: Model Evaluation

### Corpus Splitting (`split_corpus.m`)

Splits the tokenized corpus into training and testing sets by token position:
- Default test ratio: 20%
- Training set: first 80% of tokens
- Test set: last 20% of tokens

### Accuracy Evaluation (`evaluate_accuracy.m`)

Computes **top-k accuracy**: for each test case, the prediction is considered correct if the true next word appears anywhere in the top-k predicted words.

```
accuracy = (# correct predictions) / (# total test cases)
```

### Perplexity Measurement (`measure_perplexity.m)`

Measures how well the bigram model predicts the test set:

```
perplexity = exp(-1/N × Σ log P(w_i | w_{i-1}))
```

Lower perplexity indicates better predictive performance. For unseen bigrams, the model falls back to `1/vocabSize` to avoid log(0).

### Full Comparison (`compare_all_models.m`)

End-to-end pipeline:
1. Train bigram model and embeddings on training set
2. Generate predictions for all bigram and vector test cases
3. Compute accuracy for both models
4. Measure bigram perplexity on test set
5. Return all results in a structured format

---

## 7. Part 5: Application and Documentation

### Interactive GUI (`ui_demo.m`)

A MATLAB `uifigure`-based application with the following features:

**Input options:**
- **Word input** — type a word and click "Predict" or press Enter
- **Letter match** — type a letter to see all vocabulary words starting with that letter
- **Clear** — reset all outputs

**Output displays:**
- **Bigram predictions** — top 5 most probable next words from the bigram model
- **Vector predictions** — top 5 most similar words from the embedding model
- **Bar chart** — visual probability distribution of bigram predictions
- **Probability text** — exact probability percentages for each prediction
- **Status bar** — shows vocabulary size and ready state

**Key design decisions:**
- If the input word is not in the vocabulary, the bigram model falls back to unigram predictions and the user is prompted to try letter match
- The letter match feature helps users discover vocabulary words
- All callbacks are implemented as nested functions sharing the model data

### Save/Load (`save_load_model.m`)

Simple serialization wrapper:
- `save_load_model('save', model, filename)` — saves model to .mat file
- `save_load_model('load', [], filename)` — loads model from .mat file

The `main.m` script automatically saves trained models to `models.mat` for the GUI to load.

---

## 8. Results and Analysis

### Expected Behavior by Model

| Model | Strengths | Weaknesses |
|-------|-----------|------------|
| **Bigram** | Captures local word order; fast lookup; works well for common word pairs | Limited context (1 word); sparse for rare words; cannot capture long-range dependencies |
| **Trigram** | Richer context (2 words); better predictions for common phrases | Even sparser; many trigram combinations unseen; requires more memory |
| **Vector** | Captures semantic similarity; generalizes to unseen word pairs; finds related words regardless of position | Does not model word order; predictions may be semantically related but syntactically inappropriate; quality depends on corpus size |

### Qualitative Comparison

- **Bigram** excels at predicting function words (articles, prepositions) that commonly follow a given word. For example, after "the" it will predict common nouns or adjectives.
- **Trigram** can capture phrases like "she was going" where the bigram "was going" alone might be ambiguous.
- **Vector** model finds semantically related words. For "dog", it might return "cat", "pet", "animal" — words that appear in similar contexts but may not be the most likely immediate successor.

### Quantitative Metrics

The evaluation framework supports:
- **Top-k accuracy** at any k (typically k=5 or k=10)
- **Perplexity** for the bigram model (lower is better; random baseline = vocabSize)

---

## 9. Strengths and Weaknesses

### Strengths

1. **Complete pipeline** — from raw text preprocessing through training, evaluation, and interactive demonstration
2. **Multiple approaches** — three distinct prediction methods implemented and comparable
3. **Proper smoothing** — Laplace smoothing handles unseen bigrams gracefully
4. **Backoff strategy** — trigram → bigram → unigram cascade ensures predictions are always available
5. **PPMI + SVD embeddings** — more sophisticated than raw co-occurrence; produces meaningful semantic vectors
6. **Interactive GUI** — user-friendly demonstration with real-time visualization
7. **Modular design** — each function has a single responsibility; easy to test and extend

### Weaknesses

1. **Small corpus** — 1000 sentences is insufficient for robust statistical estimation; many n-gram combinations are unseen
2. **Token-level split** — `split_corpus` splits on token boundaries rather than sentence boundaries, potentially creating artificial train-test contamination at split points
3. **Dense bigram matrix** — the `vocabSize × vocabSize` full matrix consumes O(V²) memory; a sparse representation would scale better
4. **PPMI double loop** — the nested for-loop over the full vocabulary in `co_occurrence_word_embeddings.m` is O(V²) and slow for large vocabularies; vectorized computation would be faster
5. **No cross-validation** — a single train/test split may not give reliable accuracy estimates
6. **Limited context window** — the default window size of 2 for co-occurrence may miss longer-range semantic relationships

---

## 10. Suggestions for Improvement

1. **Larger corpus** — use a dataset like the Brown Corpus, Gutenberg texts, or Wikipedia dumps for more robust training
2. **Sentence-aware splitting** — split the corpus by sentences rather than tokens to avoid mid-sentence train-test boundaries
3. **Interpolated backoff** — instead of hard backoff (trigram → bigram → unigram), use weighted interpolation: `P = λ₁P_trigram + λ₂P_bigram + λ₃P_unigram` with tuned λ values
4. **Kneser-Ney smoothing** — a more sophisticated smoothing technique that models the probability of a word being a "continuation" rather than its raw frequency
5. **Sparse bigram storage** — use `sparse` matrices for bigram counts to reduce memory for large vocabularies
6. **Vectorized PPMI** — replace the double loop with matrix operations for 10–100× speedup
7. **Cross-validation** — implement k-fold cross-validation for more reliable accuracy estimates
8. **Higher-dimensional embeddings** — experiment with 100–300 dimensional SVD vectors for richer semantic representations
9. **Combined predictions** — ensemble the n-gram and vector models by ranking words that score well under both approaches
10. **Keyboard/UI integration** — extend the GUI to support real-time prediction as the user types (autocomplete mode)

---

## 11. Conclusion

This project successfully implements a next word prediction system in MATLAB using three complementary approaches: bigram models, trigram models, and vector space similarity. The system demonstrates core natural language processing concepts including text preprocessing, n-gram language modeling, smoothing, backoff strategies, co-occurrence embeddings, PPMI weighting, SVD dimensionality reduction, and cosine similarity.

The interactive GUI provides an intuitive demonstration of how statistical and vector-based models produce different types of predictions. The evaluation framework allows quantitative comparison through top-k accuracy and perplexity metrics.

The modular, well-documented codebase provides a solid foundation for extension with larger corpora, more sophisticated smoothing techniques, and ensemble prediction methods.

---

## Appendix: How to Run

### Quick Start

```matlab
% From the project root directory:
>> main
```

This loads the corpus, trains both models, displays sample predictions, and saves `models.mat`.

### Interactive GUI

```matlab
>> ui_demo
```

### Run Analysis and Visualizations

```matlab
>> analyze_and_visualize('corpus.txt')
```

### Evaluate All Models

```matlab
>> [tokens, ~, ~] = text_processing('corpus.txt');
>> [trainSet, testSet] = split_corpus(tokens, 0.2);
>> results = compare_all_models(trainSet, testSet);
>> disp(results.accuracy);
>> fprintf('Perplexity: %.2f\n', results.perplexity);
```

### Individual Predictions

```matlab
>> [tokens, ~, ~] = text_processing('corpus.txt');
>> bigramModel = train_bigram_model(tokens);
>> embeddings = co_occurrence_word_embeddings(tokens, 2);
>> prediction_words_bigram('she', bigramModel, 5)
>> predict_vector_similar('she', embeddings, 5)
```
