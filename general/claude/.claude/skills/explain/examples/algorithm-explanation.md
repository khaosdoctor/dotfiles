# Example: Algorithm Explanation

## Scenario
Understanding a complex algorithm's implementation, logic, and performance characteristics.

## Request
```
Explain the search algorithm in src/utils/fuzzy-search.ts and analyze its complexity
```

## Sample Code

```typescript
// src/utils/fuzzy-search.ts
export function fuzzySearch<T>(
  items: T[],
  query: string,
  keys: (keyof T)[],
  threshold: number = 0.6
): T[] {
  const normalizedQuery = query.toLowerCase().trim();

  if (!normalizedQuery) return items;

  const results = items.map(item => {
    let maxScore = 0;

    for (const key of keys) {
      const value = String(item[key]).toLowerCase();
      const score = calculateSimilarity(normalizedQuery, value);

      if (score > maxScore) {
        maxScore = score;
      }
    }

    return { item, score: maxScore };
  });

  return results
    .filter(result => result.score >= threshold)
    .sort((a, b) => b.score - a.score)
    .map(result => result.item);
}

function calculateSimilarity(query: string, target: string): number {
  if (query === target) return 1.0;
  if (!query || !target) return 0;

  // Levenshtein distance algorithm
  const matrix: number[][] = [];

  for (let i = 0; i <= target.length; i++) {
    matrix[i] = [i];
  }

  for (let j = 0; j <= query.length; j++) {
    matrix[0][j] = j;
  }

  for (let i = 1; i <= target.length; i++) {
    for (let j = 1; j <= query.length; j++) {
      const cost = target[i - 1] === query[j - 1] ? 0 : 1;

      matrix[i][j] = Math.min(
        matrix[i - 1][j] + 1,      // deletion
        matrix[i][j - 1] + 1,      // insertion
        matrix[i - 1][j - 1] + cost // substitution
      );
    }
  }

  const distance = matrix[target.length][query.length];
  const maxLength = Math.max(query.length, target.length);

  return 1 - distance / maxLength;
}
```

## Expected Output

```markdown
# Algorithm Explanation: Fuzzy Search

**Location**: src/utils/fuzzy-search.ts
**Purpose**: Fuzzy string matching to find items that approximately match a search query

## Overview

This implementation uses the **Levenshtein distance algorithm** to perform fuzzy string matching. It calculates how similar strings are by measuring the minimum number of single-character edits (insertions, deletions, substitutions) needed to transform one string into another.

---

## High-Level Flow

```
Input: items[], query, keys[], threshold
    ↓
Normalize query (lowercase, trim)
    ↓
For each item:
  For each searchable key:
    Calculate similarity score
  Keep maximum score
    ↓
Filter by threshold
    ↓
Sort by score (descending)
    ↓
Return matched items
```

---

## Function: fuzzySearch

### Signature
```typescript
function fuzzySearch<T>(
  items: T[],           // Array of objects to search
  query: string,        // Search query
  keys: (keyof T)[],   // Object properties to search in
  threshold: number = 0.6 // Minimum similarity score (0-1)
): T[]
```

### Step-by-Step Execution

#### Step 1: Normalize Query (lines 8-10)
```typescript
const normalizedQuery = query.toLowerCase().trim();
if (!normalizedQuery) return items;
```

**Purpose**: Ensure consistent comparison
- Convert to lowercase for case-insensitive matching
- Remove leading/trailing whitespace
- Return all items if query is empty

**Example**:
```typescript
"  Hello World  " → "hello world"
```

---

#### Step 2: Calculate Scores for Each Item (lines 12-24)
```typescript
const results = items.map(item => {
  let maxScore = 0;

  for (const key of keys) {
    const value = String(item[key]).toLowerCase();
    const score = calculateSimilarity(normalizedQuery, value);

    if (score > maxScore) {
      maxScore = score;
    }
  }

  return { item, score: maxScore };
});
```

**Purpose**: Score each item by comparing query against specified fields

**Process**:
1. For each item in the input array
2. For each searchable key (e.g., 'name', 'email', 'description')
3. Convert field value to lowercase string
4. Calculate similarity score (0.0 to 1.0)
5. Keep the highest score across all keys
6. Return item with its best score

**Example**:
```typescript
// Input
items = [
  { name: "John Doe", email: "john@example.com" },
  { name: "Jane Smith", email: "jane@example.com" }
]
query = "john"
keys = ["name", "email"]

// After scoring
results = [
  { item: {name: "John Doe", ...}, score: 0.75 },  // High match on 'name'
  { item: {name: "Jane Smith", ...}, score: 0.20 }  // Low match
]
```

---

#### Step 3: Filter, Sort, Extract (lines 26-29)
```typescript
return results
  .filter(result => result.score >= threshold)
  .sort((a, b) => b.score - a.score)
  .map(result => result.item);
```

**Purpose**: Return only relevant results in order of relevance

**Process**:
1. **Filter**: Remove items below threshold (default 0.6)
2. **Sort**: Order by score descending (best matches first)
3. **Map**: Extract original items (discard scores)

**Example**:
```typescript
// After filtering (threshold = 0.6)
[{ item: {name: "John Doe"}, score: 0.75 }]

// After sorting (already sorted in this case)
[{ item: {name: "John Doe"}, score: 0.75 }]

// After mapping
[{ name: "John Doe", email: "john@example.com" }]
```

---

## Function: calculateSimilarity

### Purpose
Calculate how similar two strings are using Levenshtein distance algorithm.

### Signature
```typescript
function calculateSimilarity(query: string, target: string): number
```

**Returns**: Similarity score between 0.0 (completely different) and 1.0 (identical)

### Algorithm: Levenshtein Distance

**Definition**: Minimum number of single-character edits needed to transform one string into another.

**Three allowed operations**:
1. **Insertion**: Add a character
2. **Deletion**: Remove a character
3. **Substitution**: Replace a character

### Step-by-Step Execution

#### Step 1: Early Returns (lines 33-34)
```typescript
if (query === target) return 1.0;
if (!query || !target) return 0;
```

**Optimization**: Handle edge cases without computation

---

#### Step 2: Initialize Matrix (lines 37-44)
```typescript
const matrix: number[][] = [];

for (let i = 0; i <= target.length; i++) {
  matrix[i] = [i];
}

for (let j = 0; j <= query.length; j++) {
  matrix[0][j] = j;
}
```

**Purpose**: Create a 2D matrix to store edit distances

**Matrix structure**:
```
Example: query = "cat", target = "car"

      ""  c  a  t
  "" [ 0, 1, 2, 3 ]
  c  [ 1, ?, ?, ? ]
  a  [ 2, ?, ?, ? ]
  r  [ 3, ?, ?, ? ]
```

- First row: Distance from empty string to query (0, 1, 2, 3...)
- First column: Distance from empty string to target (0, 1, 2, 3...)

---

#### Step 3: Fill Matrix (lines 46-56)
```typescript
for (let i = 1; i <= target.length; i++) {
  for (let j = 1; j <= query.length; j++) {
    const cost = target[i - 1] === query[j - 1] ? 0 : 1;

    matrix[i][j] = Math.min(
      matrix[i - 1][j] + 1,      // deletion
      matrix[i][j - 1] + 1,      // insertion
      matrix[i - 1][j - 1] + cost // substitution
    );
  }
}
```

**Purpose**: Calculate minimum edits for each substring pair

**For each cell (i, j)**:
- Compare characters: `target[i-1]` vs `query[j-1]`
- If same: cost = 0 (no edit needed)
- If different: cost = 1 (substitution needed)
- Take minimum of:
  - `matrix[i-1][j] + 1`: Delete from target
  - `matrix[i][j-1] + 1`: Insert into target
  - `matrix[i-1][j-1] + cost`: Match or substitute

**Complete example**:
```
query = "cat", target = "car"

      ""  c  a  t
  "" [ 0, 1, 2, 3 ]
  c  [ 1, 0, 1, 2 ]  // c matches c (cost 0)
  a  [ 2, 1, 0, 1 ]  // a matches a (cost 0)
  r  [ 3, 2, 1, 1 ]  // r != t (cost 1)

Final distance: 1 (one substitution: t → r)
```

---

#### Step 4: Convert to Similarity Score (lines 58-61)
```typescript
const distance = matrix[target.length][query.length];
const maxLength = Math.max(query.length, target.length);

return 1 - distance / maxLength;
```

**Purpose**: Convert edit distance to similarity score (0-1 range)

**Formula**: `similarity = 1 - (distance / max_length)`

**Examples**:
```typescript
// Identical strings
"cat" vs "cat"
distance = 0, maxLength = 3
similarity = 1 - 0/3 = 1.0

// One character different
"cat" vs "car"
distance = 1, maxLength = 3
similarity = 1 - 1/3 = 0.67

// Completely different
"cat" vs "dog"
distance = 3, maxLength = 3
similarity = 1 - 3/3 = 0.0

// Different lengths
"cat" vs "catalog"
distance = 4, maxLength = 7
similarity = 1 - 4/7 = 0.43
```

---

## Complexity Analysis

### Time Complexity

**fuzzySearch function**: `O(n * k * q * t)`
- `n` = number of items
- `k` = number of keys to search
- `q` = query length
- `t` = average target string length

**Breakdown**:
- Outer loop: `O(n)` - iterate through all items
- Key loop: `O(k)` - check each searchable field
- calculateSimilarity: `O(q * t)` - Levenshtein matrix
- Filter + sort: `O(n log n)` - sorting dominates

**Overall**: `O(n * k * q * t)` for the scoring phase

**calculateSimilarity function**: `O(m * n)`
- `m` = query length
- `n` = target length
- Creates matrix of size `(m+1) × (n+1)`
- Fills each cell once

### Space Complexity

**fuzzySearch**: `O(n)`
- Stores results array with all items and scores

**calculateSimilarity**: `O(m * n)`
- Matrix of size `(m+1) × (n+1)`
- This is the space bottleneck

---

## Performance Characteristics

### Strengths
✓ Accurate fuzzy matching
✓ Configurable threshold
✓ Multi-field search
✓ Language-agnostic

### Weaknesses
✗ Expensive for large datasets
✗ No indexing or caching
✗ Full scan on every search
✗ Memory intensive for long strings

### When It Works Well
- Small to medium datasets (< 10,000 items)
- Short strings (< 100 characters)
- User-facing autocomplete/search
- One-time searches

### When It Struggles
- Large datasets (> 100,000 items)
- Long strings (> 1,000 characters)
- Real-time search with high frequency
- Need sub-50ms response times

---

## Optimization Opportunities

### 1. Early Termination
```typescript
// Stop if score can't possibly meet threshold
if (maxScore < threshold && possibleMaxScore < threshold) {
  break;
}
```

### 2. Caching
```typescript
// Cache similarity calculations
const cache = new Map<string, number>();
const cacheKey = `${query}:${value}`;

if (cache.has(cacheKey)) {
  score = cache.get(cacheKey)!;
} else {
  score = calculateSimilarity(query, value);
  cache.set(cacheKey, score);
}
```

### 3. Indexing (for large datasets)
```typescript
// Pre-process items for faster searching
// Use n-grams, BK-trees, or search engines like MeiliSearch
```

### 4. Limit String Length
```typescript
// Truncate long strings to reduce complexity
const maxCompareLength = 100;
const truncatedValue = value.slice(0, maxCompareLength);
```

### 5. Web Workers (browser)
```typescript
// Offload computation to background thread
const worker = new Worker('fuzzy-search-worker.js');
worker.postMessage({ items, query, keys });
```

---

## Alternative Approaches

### For Better Performance
1. **Trie + fuzzy matching**: O(k * m) for prefix searches
2. **BK-tree**: O(log n) lookup with edit distance
3. **N-gram indexing**: Pre-compute substring indices
4. **Search engines**: Elasticsearch, MeiliSearch, Algolia

### For Different Use Cases
1. **Simple prefix matching**: Much faster but less flexible
2. **Regular expressions**: Pattern-based matching
3. **Soundex/Metaphone**: Phonetic matching
4. **TF-IDF**: Relevance-based document search

---

## Usage Examples

### Basic Search
```typescript
const users = [
  { name: "John Doe", email: "john@example.com" },
  { name: "Jane Smith", email: "jane@example.com" },
  { name: "Johnny Walker", email: "johnny@example.com" }
];

// Search in name field
const results = fuzzySearch(users, "john", ["name"]);
// Returns: [John Doe, Johnny Walker]
```

### Multi-Field Search
```typescript
// Search in both name and email
const results = fuzzySearch(users, "jane", ["name", "email"]);
// Returns: [Jane Smith] (high match on name)
```

### Custom Threshold
```typescript
// Only exact or very close matches
const results = fuzzySearch(users, "john", ["name"], 0.9);
// Returns: [John Doe] (Johnny Walker excluded)
```

---

## Testing Recommendations

```typescript
describe('fuzzySearch', () => {
  it('should find exact matches', () => {
    const results = fuzzySearch(users, 'John', ['name']);
    expect(results[0].name).toBe('John Doe');
  });

  it('should handle typos', () => {
    const results = fuzzySearch(users, 'Jhon', ['name']);
    expect(results[0].name).toBe('John Doe');
  });

  it('should respect threshold', () => {
    const results = fuzzySearch(users, 'xyz', ['name'], 0.6);
    expect(results).toHaveLength(0);
  });

  it('should search multiple fields', () => {
    const results = fuzzySearch(users, 'example', ['name', 'email']);
    expect(results.length).toBeGreaterThan(0);
  });
});

describe('calculateSimilarity', () => {
  it('should return 1.0 for identical strings', () => {
    expect(calculateSimilarity('cat', 'cat')).toBe(1.0);
  });

  it('should return 0 for empty strings', () => {
    expect(calculateSimilarity('', 'cat')).toBe(0);
  });

  it('should calculate correct distance', () => {
    expect(calculateSimilarity('cat', 'car')).toBeCloseTo(0.67, 2);
  });
});
```
```
