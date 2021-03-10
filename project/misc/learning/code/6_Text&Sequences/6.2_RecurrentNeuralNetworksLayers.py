import tensorflow as tf
gpus = tf.config.experimental.list_physical_devices('GPU')
tf.config.experimental.set_memory_growth(gpus[0], True)

# To make these notions of loop and state clear, let’s implement the forward pass of a toy RNN in Numpy.
# This RNN takes as input a sequence of vectors, which you’ll encode as a 2D tensor of size (timesteps, input_features).
# It loops over timesteps, and at each timestep, it considers its current state at t and the input at t (of shape (input_ features,), and combines them to obtain the output at t. 
# You’ll then set the state for the next step to be this previous output.
# For the first timestep, the previous output isn’t defined; hence, there is no current state.
# So, you’ll initialize the state as an all-zero vector called the initial state of the network.

### SimpleRNN layer, from first principles, to show how it works (but single sequence rather than a batch as usual)

import numpy as np

timesteps = 100 #Number of timesteps in the input sequence
input_features = 32 #Dimensionality of the input feature space
output_features = 64 #Dimensionality of the output feature space

#Input data: random noise for the sake of the example
inputs = np.random.random((timesteps,input_features))

#Initial state: an all-zero vector
state_t = np.zeros((output_features,))

#Creates random weight metrics
W = np.random.random((output_features,input_features))
U = np.random.random((output_features,output_features))
b = np.random.random((output_features,))

successive_outputs = []

# input_t is a vector of shape (input_features,).
for input_t in inputs:
    # Combines the input with the current state (the previous output) to obtain the current output
    output_t = np.tanh(np.dot(W,input_t) + np.dot(U,state_t) + b)
    #Stores this output in a list
    successive_outputs.append(output_t)
    #Updates the state of the network for the next timestep
    state_t = output_t

#The final output is a 2D tensor of shape (timesteps, output_features).
final_output_sequence = np.concatenate(successive_outputs,axis=0)

# Easy enough: in summary, an RNN is a for loop that reuses quantities computed during the previous iteration of the loop, nothing more.
# Of course, there are many different RNNs fitting this definition that you could build—this example is one of the simplest RNN formulations.
# RNNs are characterized by their step function, such as the following function in this case (see figure 6.10, page 198): 
output_t = np.tanh(np.dot(W, input_t) + np.dot(U, state_t) + b)

# NOTE In this example, the final output is a 2D tensor of shape (timesteps, output_features), where each timestep is the output of the loop at time t.
# Each timestep t in the output tensor contains information about timesteps 0 to t in the input sequence—about the entire past.
# For this reason, in many cases, you don’t need this full sequence of outputs; you just need the last output (output_t at the end of the loop), because it already contains information about the entire sequence.


### A Recuirrent layer in Keras

# The process you just naively implemented in Numpy corresponds to an actual Keras layer—the SimpleRNN layer:
# from keras.layers import SimpleRNN
# There is one minor difference: SimpleRNN processes batches of sequences, like all other Keras layers, not a single sequence as in the Numpy example.
# This means it takes inputs of shape (batch_size, timesteps, input_features), rather than (timesteps, input_features).
# Like all recurrent layers in Keras, SimpleRNN can be run in two different modes:
#   it can return either the full sequences of successive outputs for each timestep (a 3D ten- sor of shape (batch_size, timesteps, output_features)) 
#   or only the last output for each input sequence (a 2D tensor of shape (batch_size, output_features)).
# These two modes are controlled by the return_sequences constructor argument.
# Let’s look at an example that uses SimpleRNN and returns only the output at the last timestep:

from keras.models import Sequential
from keras.layers import Embedding, SimpleRNN

model = Sequential()
model.add(Embedding(10000, 32))
model.add(SimpleRNN(32))
model.summary()

# The following example returns the full state sequence:

model = Sequential()
model.add(Embedding(10000, 32))
model.add(SimpleRNN(32, return_sequences=True))
model.summary()

# It’s sometimes useful to stack several recurrent layers one after the other in order to increase the representational power of a network.
# In such a setup, you have to get all of the intermediate layers to return full sequence of outputs:

model = Sequential()
model.add(Embedding(10000, 32))
model.add(SimpleRNN(32, return_sequences=True))
model.add(SimpleRNN(32, return_sequences=True))
model.add(SimpleRNN(32, return_sequences=True))
model.add(SimpleRNN(32)) #Last layer only returns the last output
model.summary()

### Preparing the IMDB dataset

# Now, let’s use such a model on the IMDB movie-review-classification problem
# First, preprocess the data:

from keras.datasets import imdb
from keras.preprocessing import sequence

max_features = 10000
maxlen = 500
batch_size = 32

print('Loading data...')
(input_train, y_train), (input_test, y_test) = imdb.load_data( num_words=max_features)
print(len(input_train), 'train sequences')
print(len(input_test), 'test sequences')

print('Pad sequences (samples x time)')
input_train = sequence.pad_sequences(input_train, maxlen=maxlen)
input_test = sequence.pad_sequences(input_test, maxlen=maxlen)
print('input_train shape:', input_train.shape)
print('input_test shape:', input_test.shape)

### Training the model with Embedding and SimpleRNN layers

#Let’s train a simple recurrent network using an Embedding layer and a SimpleRNN layer.

from keras.layers import Dense

model = Sequential()
model.add(Embedding(max_features, 32))
model.add(SimpleRNN(32))
model.add(Dense(1, activation='sigmoid'))

model.compile(optimizer='rmsprop', loss='binary_crossentropy', metrics=['acc']) 
history = model.fit(input_train, y_train, epochs=10, batch_size=128, validation_split=0.2)

### Plotting Results

# Now, let’s display the training and validation loss and accuracy (see figures 6.11 and 6.12).

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

# As a reminder, in chapter 3, the first naive approach to this dataset got you to a test accuracy of 88%.
# Unfortunately, this small recurrent network doesn’t perform well compared to this baseline (only 85% validation accuracy).
# Part of the problem is that your inputs only consider the first 500 words, rather than full sequences
# hence, the RNN has access to less information than the earlier baseline model.
# The remainder of the problem is that SimpleRNN isn’t good at processing long sequences, such as text.

# Other types of recurrent layers perform much better.
# Let’s look at some more-advanced layers.



##### Understanding the LSTM and GRU layers

#pg202 for more details on alternatives to SimpleRNN - LSTM and GRU

# # To understand this in detail, let’s start from the SimpleRNN cell (see figure 6.13).

# Because you’ll have a lot of weight matrices, index the W and U matrices in the cell with the letter o (Wo and Uo) for output.
# Let’s add to this picture an additional data flow that carries information across time-steps.
# Call its values at different timesteps Ct, where C stands for carry.
# This information will have the following impact on the cell:
#   it will be combined with the input connection and the recurrent connection (via a dense transformation: a dot product with a weight matrix followed by a bias add and the application of an activation function),
#   and it will affect the state being sent to the next timestep (via an activation function an a multiplication operation).
# Conceptually, the carry dataflow is a way to modulate the next output and the next state (see figure 6.14).

# Now the subtlety: the way the next value of the carry dataflow is computed
# It involves three distinct transformations.
# All three have the form of a SimpleRNN cell:
# y = activation(dot(state_t, U) + dot(input_t, W) + b)
# But all three transformations have their own weight matrices, which you’ll index with the letters i, f, and k.
# Here’s what you have so far (it may seem a bit arbitrary, but bear with me).

# Pseudocode details of the LSTM architecture (1/2)

# output_t = activation(dot(state_t, Uo) + dot(input_t, Wo) + dot(C_t, Vo) + bo)
# i_t = activation(dot(state_t, Ui) + dot(input_t, Wi) + bi)
# f_t = activation(dot(state_t, Uf) + dot(input_t, Wf) + bf)
# k_t = activation(dot(state_t, Uk) + dot(input_t, Wk) + bk)

# You obtain the new carry state (the next c_t) by combining i_t, f_t, and k_t

# Pseudocode details of the LSTM architecture (2/2)

# c_t+1 = i_t * k_t + c_t * f_t




##### A concrete LSTM example in Keras

# Now let’s switch to more practical concerns: you’ll set up a model using an LSTM layer and train it on the IMDB data (see figures 6.16 and 6.17)
# The network is similar to the one with SimpleRNN that was just presented
# You only specify the output dimensionality of the LSTM layer; leave every other argument (there are many) at the Keras defaults.
# Keras has good defaults, and things will almost always “just work” without you having to spend time tuning parameters by hand.

from keras.layers import LSTM

model = Sequential()
model.add(Embedding(max_features, 32))
model.add(LSTM(32))
model.add(Dense(1, activation='sigmoid'))

model.compile(optimizer='rmsprop', loss='binary_crossentropy', metrics=['acc'])
history = model.fit(input_train, y_train, epochs=10, batch_size=128, validation_split=0.2)

### visualising results (exactly same method and code as before)

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

# This time, you achieve up to 89% validation accuracy.
# Not bad: certainly much better than the SimpleRNN network
# because LSTM suffers much less from the vanishing-gradient problem
# and slightly better than the fully connected approach from chapter 3, even though you’re looking at less data than you were in chapter 3
# You’re truncating sequences after 500 timesteps, whereas in chapter 3, you were considering full sequences

# But this result isn’t groundbreaking for such a computationally intensive approach.
# Why isn’t LSTM performing better? One reason is that you made no effort to tune hyperparameters such as the embeddings dimensionality or the LSTM output dimensionality.
# Another may be lack of regularization.
# But honestly, the primary reason is that analyzing the global, long-term structure of the reviews (what LSTM is good at) isn’t helpful for a sentiment-analysis problem
# Such a basic problem is well solved by looking at what words occur in each review, and at what frequency.
# That’s what the first fully connected approach looked at.
# But there are far more difficult natural-language-processing problems out there, where the strength of LSTM will become apparent:
# in particular, question-answering and machine translation.
