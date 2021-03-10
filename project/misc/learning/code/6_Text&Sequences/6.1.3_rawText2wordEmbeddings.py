import tensorflow as tf
gpus = tf.config.experimental.list_physical_devices('GPU')
tf.config.experimental.set_memory_growth(gpus[0], True)


##### Putting it all together: from raw text to word embeddings

# using a model similar to the one we just went over: embedding sentences in sequences of vectors, flattening them, and training a Dense layer on top.
# But you’ll do so using pretrained word embeddings; and instead of using the pretokenized IMDB data packaged in Keras, you’ll start from scratch by downloading the original text data.

### DOWNLOADING THE IMDB DATA AS RAW TEXT
# 
# First, head to http://mng.bz/0tIo and download the raw IMDB dataset
# Uncompress it
# unzip ~/Downloads/aclImdb.zip -d ~/Downloads

### Organising directories and processing the labels of the raw IMDB data
#
# Now, let’s collect the individual training reviews into a list of strings, one string per review
# You’ll also collect the review labels (positive/negative) into a labels list

import os

imdb_dir = '/home/bennouhan/Downloads/aclImdb'
train_dir = os.path.join(imdb_dir, 'train')

labels = []
texts = []

for label_type in ['neg', 'pos']:
    dir_name = os.path.join(train_dir, label_type)
    for fname in os.listdir(dir_name):
        if fname[-4:] == '.txt':
            f = open(os.path.join(dir_name, fname))
            texts.append(f.read())
            f.close()
            if label_type == 'neg':
                labels.append(0)
            else:
                labels.append(1)

### TOKENIZING the text of the raw IMDB data

# Let’s vectorize the text and prepare a training and validation split, using the concepts introduced earlier in this section.
# Because pretrained word embeddings are meant to be particularly useful on problems where little training data is available (otherwise, task-specific embeddings are likely to outperform them), we’ll add the following twist: 
#    restricting the training data to the first 200 samples.
# So you’ll learn to classify movie reviews after looking at just 200 examples.

from keras.preprocessing.text import Tokenizer
from keras.preprocessing.sequence import pad_sequences
import numpy as np

maxlen = 100 #Cuts off reviews after 100 words
training_samples = 200 #training_samples = 200
validation_samples = 10000 #Validates on 10,000 samples
max_words = 10000 #Considers only the top 10,000 words in the dataset

tokenizer = Tokenizer(num_words=max_words)
tokenizer.fit_on_texts(texts)
sequences = tokenizer.texts_to_sequences(texts)

word_index = tokenizer.word_index
print('Found %s unique tokens.' % len(word_index))

data = pad_sequences(sequences, maxlen=maxlen)

labels = np.asarray(labels)
print('Shape of data tensor:', data.shape)
print('Shape of label tensor:', labels.shape)

# Splits the data into a training set and a validation set, but first shuffles the data, because you’re starting with data in which samples are ordered (all negative first, then all positive)
indices = np.arange(data.shape[0])
np.random.shuffle(indices)
data = data[indices]
labels = labels[indices]

x_train = data[:training_samples]
y_train = labels[:training_samples]
x_val = data[training_samples: training_samples + validation_samples]
y_val = labels[training_samples: training_samples + validation_samples]



### Downloading and PREPROCESSING THE EMBEDDINGS

# Go to https://nlp.stanford.edu/projects/glove, and download the precomputed embeddings from 2014 English Wikipedia.
# It’s an 822 MB zip file called glove.6B.zip, containing 100-dimensional embedding vectors for 400,000 words (or nonword tokens).
# should be: http://nlp.stanford.edu/data/glove.6B.zip
# Unzip it.
# unzip ~/Downloads/glove.6B.zip -d ~/Downloads/glove.6B

# Let’s parse the unzipped file (a .txt file) to build an index that maps words (as strings) to their vector representation (as number vectors)

glove_dir = '/home/bennouhan/Downloads/glove.6B'

embeddings_index = {}
f = open(os.path.join(glove_dir, 'glove.6B.100d.txt'))
for line in f:
    values = line.split()
    word = values[0]
    coefs = np.asarray(values[1:], dtype='float32')
    embeddings_index[word] = coefs

f.close()

print('Found %s word vectors.' % len(embeddings_index))


### Preparing the GloVe word-embeddings matrix

# Next, you’ll build an embedding matrix that you can load into an Embedding layer.
# It must be a matrix of shape (max_words, embedding_dim), where each entry i contains the embedding_dim-dimensional vector for the word of index i in the reference word index (built during tokenization).
# Note that index 0 isn’t supposed to stand for any word or token—it’s a placeholder.

embedding_dim = 100

embedding_matrix = np.zeros((max_words, embedding_dim))
for word, i in word_index.items():
    if i < max_words:
        embedding_vector = embeddings_index.get(word)
        if embedding_vector is not None:
            embedding_matrix[i] = embedding_vector
            #Words not found in the embedding index will be all zeros.


### Defining a model (same architecture as previously)

from keras.models import Sequential
from keras.layers import Embedding, Flatten, Dense

model = Sequential()
model.add(Embedding(max_words, embedding_dim, input_length=maxlen))
model.add(Flatten())
model.add(Dense(32, activation='relu'))
model.add(Dense(1, activation='sigmoid'))
model.summary()


### Loading pretrained word embeddings into the Embedding layer
#
# The Embedding layer has a single weight matrix: a 2D float matrix where each entry i is the word vector meant to be associated with index i.
# Simple enough. Load the GloVe matrix you prepared into the Embedding layer, the first layer in the model.

model.layers[0].set_weights([embedding_matrix])
model.layers[0].trainable = False

# Additionally, you’ll freeze the Embedding layer (set its trainable attribute to False), following the same rationale you’re already familiar with in the context of pretrained convnet features:
#    when parts of a model are pretrained (like your Embedding layer) and parts are randomly initialized (like your classifier), the pretrained parts shouldn’t be updated during training, to avoid forgetting what they already know.
#    The large gradient updates triggered by the randomly initialized layers would be disruptive to the already-learned features.



### TRAINING AND EVALUATING THE MODEL

model.compile(optimizer='rmsprop', loss='binary_crossentropy', metrics=['acc'])
history = model.fit(x_train, y_train, epochs=10, batch_size=32, validation_data=(x_val, y_val))
model.save_weights('/home/bennouhan/cmeecoursework/project/learning/code/6_Text&Sequences/pre_trained_glove_model.h5')
####NB this path is not tested but should work


### Plotting the results

import matplotlib.pyplot as plt

acc = history.history['acc']
val_acc = history.history['val_acc']
loss = history.history['loss']
val_loss = history.history['val_loss']
epochs = range(1, len(acc) + 1)

plt.plot(epochs, acc, 'bo', label='Training acc')
plt.plot(epochs, val_acc, 'b', label='Validation acc')
plt.title('Training and validation accuracy')
plt.legend()

plt.figure()

plt.plot(epochs, loss, 'bo', label='Training loss')
plt.plot(epochs, val_loss, 'b', label='Validation loss')
plt.title('Training and validation loss')
plt.legend()

plt.show()

# The model quickly starts overfitting, which is unsurprising given the small number of training samples.
# Validation accuracy has high variance for the same reason, but it seems to reach the high 50s.
# Note that your mileage may vary: because you have so few training samples, performance is heavily dependent on exactly which 200 samples you choose—and you’re choosing them at random.

# If this works poorly for you, try choosing a different random set of 200 samples, for the sake of the exercise (in real life, you don’t get to choose your training data).


### Training the same model without pretrained word embeddings

# You can also train the same model without loading the pretrained word embeddings and without freezing the embedding layer.
# In that case, you’ll learn a task-specific embedding of the input tokens, which is generally more powerful than pretrained word embeddings when lots of data is available.
# But in this case, you have only 200 training samples.
# Let’s try it (see figures 6.7 and 6.8, generated running the above plotting on the below model).

from keras.models import Sequential
from keras.layers import Embedding, Flatten, Dense

model = Sequential()
model.add(Embedding(max_words, embedding_dim, input_length=maxlen))
model.add(Flatten())
model.add(Dense(32, activation='relu'))
model.add(Dense(1, activation='sigmoid'))
model.summary()

model.compile(optimizer='rmsprop', loss='binary_crossentropy', metrics=['acc'])
history = model.fit(x_train, y_train, epochs=10, batch_size=32, validation_data=(x_val, y_val))

# Validation accuracy stalls in the low 50s.
# So in this case, pretrained word embeddings outperform jointly learned embeddings.
# If you increase the number of training samples, this will quickly stop being the case—try it as an exercise.


### Tokenizing the data of the test set

# Finally, let’s evaluate the model on the test data.

# First, you need to tokenize the test:

test_dir = os.path.join(imdb_dir, 'test')

labels = []
texts = []

for label_type in ['neg', 'pos']:
    dir_name = os.path.join(test_dir, label_type)
    for fname in sorted(os.listdir(dir_name)):
        if fname[-4:] == '.txt':
            f = open(os.path.join(dir_name, fname))
            texts.append(f.read())
            f.close()
            if label_type == 'neg':
                labels.append(0)
            else:
                labels.append(1)

sequences = tokenizer.texts_to_sequences(texts)
x_test = pad_sequences(sequences, maxlen=maxlen)
y_test = np.asarray(labels)

# Next, load and evaluate the first model:

model.load_weights('pre_trained_glove_model.h5')
model.evaluate(x_test, y_test)

# You get an appalling test accuracy of 56%. Working with just a handful of training samples is difficult!
