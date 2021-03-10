import tensorflow as tf
gpus = tf.config.experimental.list_physical_devices('GPU')
tf.config.experimental.set_memory_growth(gpus[0], True)



##### One-hot encoding of words and characters
# One-hot encoding is the most common, most basic way to turn a token into a vector.
# You saw it in action in the initial IMDB and Reuters examples in chapter 3 (done with words, in that case).
# It consists of associating a unique integer index with every word and then turning this integer index i into a binary vector of size N (the size of the vocabulary);
#   the vector is all zeros except for the ith entry, which is 1.
# Of course, one-hot encoding can be done at the character level, as well.
# To unambiguously drive home what one-hot encoding is and how to implement it, listings 6.1 and 6.2 show two toy examples:
#   one for words, the other for characters

### Word-level one-hot encoding (toy example)

import numpy as np

# Initial data: one entry per sample (in this example, a sample is a sentence, but it could be an entire document)
samples = ['The cat sat on the mat.', 'The dog ate my homework.']

# Builds an index of all tokens in the data
token_index = {}
for sample in samples:
    # Tokenizes the samples via the split method. In real life, you’d also strip punctuation and special characters from the samples.
    for word in sample.split():
        if word not in token_index:
            # Assigns a unique index to each unique word. Note that you don’t attribute index 0 to anything.
            token_index[word] = len(token_index) + 1 #where results are stored

# Vectorizes the samples. You’ll only consider the first max_length words in each sample.
max_length = 10

results = np.zeros(shape=(len(samples),
                            max_length,
                            max(token_index.values()) + 1))

for i, sample in enumerate(samples):
    for j, word in list(enumerate(sample.split()))[:max_length]:
        index = token_index.get(word)
        results[i, j, index] = 1.



### Character-level one-hot encoding (toy example)

import string

samples = ['The cat sat on the mat.', 'The dog ate my homework.']
characters = string.printable #All printable ASCII characters
token_index = dict(zip(range(1, len(characters) + 1), characters))

max_length = 50
results = np.zeros((len(samples), max_length, max(token_index.keys()) + 1))
for i, sample in enumerate(samples):
    for j, character in enumerate(sample):
        index = token_index.get(character)
        results[i, j, index] = 1.


### Using Keras for word-level one-hot encoding

# Keras has built-in utilities for doing one-hot encoding of text at the word level or character level, starting from raw text data.
# You should use these utilities, because they take care of a number of important features such as stripping special characters from strings and only taking into account the N most common words in your dataset (a common restriction, to avoid dealing with very large input vector spaces)

from keras.preprocessing.text import Tokenizer

samples = ['The cat sat on the mat.', 'The dog ate my homework.']

# Creates a tokenizer, configured to only take into account the 1,000 most common words
tokenizer = Tokenizer(num_words=1000)
tokenizer.fit_on_texts(samples) #Builds the word index Listing

# Turns strings into lists of integer indices
sequences = tokenizer.texts_to_sequences(samples)

# You could also directly get the one-hot binary representations. Vectorization modes other than one-hot encoding are supported by this tokenizer.
one_hot_results = tokenizer.texts_to_matrix(samples, mode='binary')

# How you can recover the word index that was computed
word_index = tokenizer.word_index
print('Found %s unique tokens.' % len(word_index))



### Word-level one-hot encoding with hashing trick (toy example)
samples = ['The cat sat on the mat.', 'The dog ate my homework.']

# Stores the words as vectors of size 1,000.
# If you have close to 1,000 words (or more), you’ll see many hash collisions, which will decrease the accuracy of this encoding method
dimensionality = 1000
max_length = 10

results = np.zeros((len(samples), max_length, dimensionality))
for i, sample in enumerate(samples):
    for j, word in list(enumerate(sample.split()))[:max_length]:
        index = abs(hash(word)) % dimensionality #hashes word into random integert between 0 and 1000
        results[i, j, index] = 1.





##### Instantiating an Embedding layer
from keras.layers import Embedding

#The Embedding layer takes at least two arguments:
#     the number of possible tokens (here, 1,000: 1 + maximum word index)
# and the dimensionality of the embeddings (here, 64).
embedding_layer = Embedding(1000, 64)

# The Embedding layer is best understood as a dictionary that maps integer indices (which stand for specific words) to dense vectors.
# It takes integers as input, it looks up these integers in an internal dictionary, and it returns the associated vectors.
# It’s effectively a dictionary lookup (see figure 6.4 page 186)


##### Loading the IMDB data for use with an Embedding layer

# you’ll quickly prepare the data.
# You’ll restrict the movie reviews to the top 10,000 most common words (as you did the first time you worked with this dataset) and cut off the reviews after only 20 words.
# The network will:
#   learn 8-dimensional embeddings for each of the 10,000 words
#   turn the input integer sequences (2D integer tensor) into embedded sequences (3D float tensor)
#   flatten the tensor to 2D
#   and train a single Dense layer on top for classification.

from keras.datasets import imdb
from keras import preprocessing

max_features = 10000
maxlen = 20

(x_train, y_train), (x_test, y_test) = imdb.load_data( num_words=max_features)
# gives warning about ndarray, dtype=object... still seems to work tho?

x_train = preprocessing.sequence.pad_sequences(x_train, maxlen=maxlen)
x_test = preprocessing.sequence.pad_sequences(x_test, maxlen=maxlen)



##### Using an Embedding layer and classifier on the IMDB data

from keras.models import Sequential
from keras.layers import Flatten, Dense

#Specifies the maximum input length to the Embedding layer so you can later flatten the embedded inputs.
# After the Embedding layer, the activations have shape (samples, maxlen, 8).
model = Sequential()
model.add(Embedding(10000, 8, input_length=maxlen))

#Flattens the 3D tensor of embeddings into a 2D tensor of shape (samples, maxlen * 8)
model.add(Flatten())

#Adds the classifier on top
model.add(Dense(1, activation='sigmoid'))
model.compile(optimizer='rmsprop', loss='binary_crossentropy', metrics=['acc'])
model.summary()

history = model.fit(x_train, y_train, epochs=10, batch_size=32, validation_split=0.2)

# You get to a validation accuracy of ~76%, which is pretty good considering that you’re only looking at the first 20 words in every review.
# But note that merely flattening the embedded sequences and training a single Dense layer on top leads to a model that treats each word in the input sequence separately, without considering inter-word relationships and sentence structure
# (for example, this model would likely treat both “this movie is a bomb” and “this movie is the bomb” as being negative reviews).
# It’s much better to add recurrent layers or 1D convolutional layers on top of the embedded sequences to learn features that take into account each sequence as a whole.
# That’s what we’ll focus on in the next few sections


##### Alternative: USING PRETRAINED WORD EMBEDDINGS

# Instead of learning word embeddings jointly with the problem you want to solve,
# you can load embedding vectors from a precomputed embedding space that you know is highly structured and exhibits useful properties—that captures generic aspects of language structure.
# The rationale behind using pretrained word embeddings in natural-language processing is much the same as for using pretrained convnets in image classification: you don’t have enough data available to learn truly powerful features on your own, but you expect the features that you need to be fairly generic—that is, common visual features or semantic features.
# In this case, it makes sense to reuse features learned on a different problem.

# Such word embeddings are generally computed using word-occurrence statistics
# (observations about what words co-occur in sentences or documents), using a variety of techniques, some involving neural networks, others not.

# See page 188 for some examples of pretrained ones

