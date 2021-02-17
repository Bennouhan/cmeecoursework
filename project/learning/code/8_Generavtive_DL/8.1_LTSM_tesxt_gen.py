import tensorflow as tf
gpus = tf.config.experimental.list_physical_devices('GPU')
tf.config.experimental.set_memory_growth(gpus[0], True)


##### Implementing character-level LSTM text generation


### Reweighting a probability distribution to a different temperature
# (sampling strategy)


# In order to control the amount of stochasticity in the sampling process, we’ll introduce a parameter called the softmax temperature that characterizes the entropy of the probability distribution used for sampling.
# It characterizes how surprising or predictable the choice of the next character will be.
# Given a temperature value, a new probability distribution is computed from the original one (the softmax output of the model) by reweighting it in the following way.


import numpy as np
def reweight_distribution(original_distribution, temperature=0.5):
    # original_distribution is a 1D Numpy array of probability values that must sum to 1.
    # temperature is a factor quantifying the entropy of the output distribution.
    distribution = np.log(original_distribution) / temperature
    distribution = np.exp(distribution)
    return distribution / np.sum(distribution)
    # Returns a reweighted version of the original distribution.
    # The sum of the distribution may no longer be 1, so you divide it by its sum to obtain the new distribution.


# Higher temperatures result in sampling distributions of higher entropy that will generate more surprising and unstructured generated data, whereas a lower temperature will result in less randomness and much more predictable generated data (see fig 8.2 pg 274 to show this)




### Downloading and parsing the initial text file

# Let’s start by downloading the corpus and converting it to lowercase

import keras
import numpy as np

path = keras.utils.get_file(
    'nietzsche.txt',
    origin='https://s3.amazonaws.com/text-datasets/nietzsche.txt')
text = open(path).read().lower()
print('Corpus length:', len(text))



### Vectorizing sequences of characters

# Next, you’ll extract partially overlapping sequences of length maxlen, one-hot encode them, and pack them in a 3D Numpy array x of shape (sequences, maxlen, unique_characters).
# Simultaneously, you’ll prepare an array y containing the corresponding targets: the one-hot-encoded characters that come after each extracted sequence


maxlen = 60 # extract sequences of 60 characters.

step = 3 # sample a new sequence every three characters.

sentences = [] # Holds the extracted sequences

next_chars = [] # Holds the targets (the follow-up characters)

for i in range(0, len(text) - maxlen, step):
    sentences.append(text[i: i + maxlen])
    next_chars.append(text[i + maxlen])

print('Number of sequences:', len(sentences))

chars = sorted(list(set(text))) #List of unique characters in the corpus
print('Unique characters:', len(chars))
char_indices = dict((char, chars.index(char)) for char in chars)
# Dictionary that maps unique characters to their index in the list “chars”

print('Vectorization...')

# One-hot encodes the characters into binary arrays
x = np.zeros((len(sentences), maxlen, len(chars)), dtype=np.bool)
y = np.zeros((len(sentences), len(chars)), dtype=np.bool)
for i, sentence in enumerate(sentences):
    for t, char in enumerate(sentence):
        x[i, t, char_indices[char]] = 1
    y[i, char_indices[next_chars[i]]] = 1



### Single-layer LSTM model for next-character prediction

# This network is a single LSTM layer followed by a Dense classifier and softmax over all possible characters.
# But note that recurrent neural networks aren’t the only way to do sequence data generation; 1D convnets also have proven extremely successful at this task in recent times.

from keras import layers

model = keras.models.Sequential()
model.add(layers.LSTM(128, input_shape=(maxlen, len(chars))))
model.add(layers.Dense(len(chars), activation='softmax'))




### Model compilation configuration

# Because your targets are one-hot encoded, you’ll use categorical_crossentropy as the loss to train the model

optimizer = keras.optimizers.RMSprop(lr=0.01)
model.compile(loss='categorical_crossentropy', optimizer=optimizer)



### Function to sample the next character given the model’s predictions

# Given a trained model and a seed text snippet, you can generate new text by doing the following repeatedly:

# 1 Draw from the model a probability distribution for the next character, given the generated text available so far.
# 2 Reweight the distribution to a certain temperature.
# 3 Sample the next character at random according to the reweighted distribution.
# 4 Add the new character at the end of the available text.

# This is the code you use to reweight the original probability distribution coming out of the model and draw a character index from it (the sampling function).

def sample(preds, temperature=1.0):
    preds = np.asarray(preds).astype('float64')
    preds = np.log(preds) / temperature
    exp_preds = np.exp(preds)
    preds = exp_preds / np.sum(exp_preds)
    probas = np.random.multinomial(1, preds, 1)
    return np.argmax(probas)



### Text-generation loop

# Finally, the following loop repeatedly trains and generates text.
# You begin generating text using a range of different temperatures after every epoch.
# This allows you to see how the generated text evolves as the model begins to converge, as well as the impact of temperature in the sampling strategy.

import random
import sys

for epoch in range(1, 2): #Trains the model for 60 epochs
    print('epoch', epoch)
    model.fit(x, y, batch_size=128, epochs=1)#Fits model on data for 1 iteration
    ### Selects a text seed at random
    start_index = random.randint(0, len(text) - maxlen - 1)
    generated_text = text[start_index: start_index + maxlen]
    print('--- Generating with seed: "' + generated_text + '"')
    ### Tries a range of diferent sampling temperatures
    for temperature in [0.2, 0.5, 1.0, 1.2]:
        print('------ temperature:', temperature)
        sys.stdout.write(generated_text)
        for i in range(400): # Generates 400 characters starting from seed text
            ### One-hot encodes the characters generated so far
            sampled = np.zeros((1, maxlen, len(chars)))
            for t, char in enumerate(generated_text):
                sampled[0, t, char_indices[char]] = 1.
            ### Samples the next character
            preds = model.predict(sampled, verbose=0)[0]
            next_index = sample(preds, temperature)
            next_char = chars[next_index]
            generated_text += next_char
            generated_text = generated_text[1:]
            sys.stdout.write(next_char)


# this printo out indiv characters rather than as sentences, may wanna find a way to make a better output

### Results.... (see pages 277 onwards)

