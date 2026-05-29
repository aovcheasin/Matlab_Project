# Next Word Prediction Project - EXPLAINME.md

**A beginner-friendly guide to understanding this MATLAB project**

---

## What is this project?

This is a **Next Word Prediction System** built in MATLAB. Given a word (or two words), it predicts what word(s) might come next in a sentence. Think of it like the autocomplete feature on your phone keyboard!

**Example:**
- You type: "she" → Project predicts: "was", "had", "is", etc.
- You type: "the big" → Project predicts: "house", "tree", "dog", etc.

---

## Project Structure (File Tree)

```
Matlab_Project/
│
├── main.m                    # Entry point - runs everything
├── corpus.txt                # Text data (1000 sentences)
├── models.mat                # Saved trained models
├── README.md                 # Project requirements
│
├── part1/                    # Part 1: Data Preparation (15%)
│   ├── text_processing.m     # Cleans and tokenizes text
│   └── analyze_and_visualize.m # Shows stats and graphs
│
├── part2/                    # Part 2: N-gram Model (30%)
│   ├── train_bigram_model.m  # Trains the bigram model
│   ├── train_trigram_model.m # Trains the trigram model
│   ├── prediction_words_bigram.m # Predicts 1 word back
│   └── prediction_words_trigram.m # Predicts 2 words back
│
├── part3/                    # Part 3: Vector Representation (25%)
│   ├── one_hot_encoding.m    # Simple word encoding
│   ├── co_occurrence_word_embeddings.m # Smart word embeddings
│   ├── predict_vector_similar.m # Predicts by similarity
│   └── compare_predictions.m # Compares different approaches
│
├── part4/                    # Part 4: Model Evaluation (15%)
│   ├── split_corpus.m        # Divides data into train/test
│   ├── evaluate_accuracy.m   # Measures prediction accuracy
│   ├── measure_perplexity.m  # Measures model quality
│   └── compare_all_models.m  # Compares all models together
│
└── part5/                    # Part 5: Application & Docs (15%)
    ├── ui_demo.m             # Interactive GUI
    ├── save_load_model.m     # Saves/loads models
    └── docs/
        ├── documentation.md  # Short docs
        └── REPORT.md         # Full detailed report
```

---

## How It Works: Step by Step

### Step 1: Text Processing (Part 1)

**File: `part1/text_processing.m`**

The computer needs to "understand" text, so we:

1. **Read the file** → Load `corpus.txt` as text
2. **Clean the text** → Remove numbers, punctuation, make everything lowercase
3. **Split into words** → Each sentence becomes a list of words (tokens)
4. **Build vocabulary** → Create a list of all unique words

**Example:**
```
Input: "Hello, World!"
Output: {"hello", "world"}
```

### Step 2: Train Prediction Models (Part 2)

**Files: `part2/train_bigram_model.m` and `part2/train_trigram_model.m`**

#### Bigram Model (2-word patterns)
- Learns patterns like: "she" → "was" (appears together often)
- Creates a giant table counting how often each word pair appears
- Uses **Laplace smoothing** so it can guess even for unseen pairs

**Example table:**
| After "she" | Probability |
|-------------|-------------|
| was         | 30%         |
| had         | 15%         |
| is          | 10%         |

#### Trigram Model (3-word patterns)
- Learns patterns like: "she was" → "happy"
- Uses the bigram model as a backup when data is sparse

### Step 3: Vector Representations (Part 3)

**File: `part3/co_occurrence_word_embeddings.m`**

Instead of counting exact pairs, we teach the computer word meanings:

1. **Find word friends** → Words that appear near each other in sentences
2. **Create word vectors** → Each word becomes a list of 50 numbers (like GPS coordinates for meaning)
3. **Similar words have similar coordinates** → "dog" is close to "cat", "pet", "animal"

**Example:**
```
Word "king" → [0.2, -0.5, 0.8, ..., 0.1] (50 numbers)
Word "queen" → [0.3, -0.4, 0.7, ..., 0.2] (similar pattern)
```

### Step 4: Evaluate Performance (Part 4)

**Files: `part4/evaluate_accuracy.m` and `part4/measure_perplexity.m`**

- **Split data** → 80% training, 20% testing
- **Check accuracy** → Does the right word appear in top predictions?
- **Perplexity** → Lower = better (measures surprise at test sentences)

### Step 5: Interactive Demo (Part 5)

**File: `part5/ui_demo.m`**

A graphical window where you can:
- Type any word from the vocabulary
- See predictions from both models
- View probability charts
- Explore words by starting letter

---

## Key Concepts Explained Simply

### What is an N-gram?
- **Unigram**: Single words (how often "the" appears)
- **Bigram**: Word pairs (how often "the cat" appears)
- **Trigram**: Word triplets (how often "the big cat" appears)

### What is Laplace Smoothing?
When we've never seen "purple elephant" in training, we give it a small probability (instead of zero) so the model can still make predictions.

### What is PPMI?
**Positive Pointwise Mutual Information** - A smart weighting that tells us if two words appearing together is special (more than random chance) or just coincidental.

### What is SVD?
**Singular Value Decomposition** - A math trick that shrinks those 50-number word descriptions from millions of dimensions down to just 50, making them easier to work with.

---

## How to Use This Project

### Quick Start
```matlab
% At MATLAB command prompt:
main
```

### Interactive Mode
```matlab
ui_demo
```

### Programmatic Usage
```matlab
% Load and process text
[tokens, vocab, freq] = text_processing('corpus.txt');

% Train models
bigramModel = train_bigram_model(tokens);
embeddings = co_occurrence_word_embeddings(tokens, 2);

% Make predictions
prediction_words_bigram('she', bigramModel, 5)
predict_vector_similar('she', embeddings, 5)
```

---

## Model Comparison

| Model | Context | Speed | Handles Rare Words | Finds Similar Words |
|-------|---------|-------|--------------------|---------------------|
| Bigram | 1 word back | Fast | ✅ (smoothing) | ❌ |
| Trigram | 2 words back | Fast | ⚠️ (backoff) | ❌ |
| Vector | All context | Medium | ✅ | ✅ |

---

## Data Summary

- **Source**: `corpus.txt` - 1000 English sentences
- **Size**: ~10,000-13,000 total words
- **Vocabulary**: ~2,500-3,000 unique words
- **Most common words**: "the", "and", "she", "was", "to"

---

## Requirements to Run

1. MATLAB (tested with R2019b or newer)
2. Signal Processing Toolbox (for `svds` function)
3. All `.m` files in their correct folders

---

## Project Phases Timeline

| Week | Tasks |
|------|-------|
| Week 1 | Text processing, n-gram models |
| Week 2-3 | Vector embeddings, evaluation, GUI, documentation |

---

## Grading Breakdown

| Part | Focus | Weight |
|------|-------|--------|
| Part 1 | Data Preparation | 15% |
| Part 2 | N-gram Models | 30% |
| Part 3 | Word Vectors | 25% |
| Part 4 | Evaluation | 15% |
| Part 5 | Application | 15% |

---

## Tips for Beginners

1. **Start with `main.m`** - It shows sample predictions
2. **Run `analyze_and_visualize('corpus.txt')`** - See the data statistics
3. **Try `ui_demo`** - Interactive way to explore predictions
4. **Read the REPORT.md** - Full technical details
5. **Modify `corpus.txt`** - Add your own sentences and see predictions change!

---

*This file was created to help beginners understand the entire project structure and functionality without needing to read every source file.*