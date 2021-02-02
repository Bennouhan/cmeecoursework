############################################################
##### IMDB Dataset

### Two-class aka binary classification

# set of 50,000 highly polarized reviews from the Internet Movie Database. They’re split into:
#  25,000 reviews for training and
#  25,000 reviews for testing
#  each set consisting of 50% negative and 50% positive reviews.

from keras.datasets import imdb

(train_data, train_labels), (test_data, test_labels) = imdb.load_data( num_words=10000)
# num_words=10000 means you’ll only keep the top 10,000 most frequently occurring words in the training data. Rare words will be discarded. This allows you to work with vector data of manageable size. train_data and

# test_data are lists of reviews; each review is a list of word indices(encoding a sequence of words)

# train_labels and test_labels are lists of 0s and 1s, where 0 stands for negative and 1 stands for positive, eg:

# train_data[0]
# train_labels[0]

# Because you’re restricting yourself to the top 10,000 most frequent words, no word index will exceed 10,000:
#   max([max(sequence) for sequence in train_data])
# to decode them back into English, see pg 69 lmao


### Preparing the data

# You can’t feed lists of integers into a neural network. You have to turn your lists into tensors:

import numpy as np

### Function to convery lists of integers into tensors
def vectorize_sequences(sequences, dimension=10000):
    results = np.zeros((len(sequences), dimension))
    for i, sequence in enumerate(sequences):
        results[i, sequence] = 1.
    return results


x_train = vectorize_sequences(train_data)
x_test = vectorize_sequences(test_data)

# they're now arrays:
#   x_train[0]

#vectoris labels:
y_train = np.asarray(train_labels).astype('float32')
y_test = np.asarray(test_labels).astype('float32')


### Building the network
# The intermediate layers will use relu as their activation function, and the final layer will use a sigmoid activation so as to output a probability (a score between 0 and 1,

from keras import models
from keras import layers

model = models.Sequential()
model.add(layers.Dense(16, activation='relu', input_shape=(10000,)))
model.add(layers.Dense(16, activation='relu'))
model.add(layers.Dense(1, activation='sigmoid'))

### Complation step
model.compile(optimizer='rmsprop', loss='binary_crossentropy', metrics=['acc'])
#the step where you configure the model with the rmsprop optimizer and the binary_crossentropy loss function. Note that you’ll also monitor accuracy during training
#You’re passing your optimizer, loss function, and metrics as strings


# Configuring the optimizer - configure the parameters of your optimizer by passing an optimizer class instance as the optimizer argument:
#   from keras import optimizers
#   model.compile(optimizer=optimizers.RMSprop(lr=0.001), loss='binary_crossentropy', metrics=['accuracy'])

# Using custom losses and metrics - pass a custom loss function or metric function by passing function objects as the loss and/or metrics arguments:
#   from keras import losses
#   from keras import metrics
#   model.compile(optimizer=optimizers.RMSprop(lr=0.001), loss=losses.binary_crossentropy, metrics=[metrics.binary_accuracy])

### Validating your approach - Setting aside a validation set
# In order to monitor during training the accuracy of the model on data it has never seen before, you’ll create a validation set by setting apart 10,000 samples from the original training data.

x_val = x_train[:10000]
partial_x_train = x_train[10000:]
y_val = y_train[:10000]
partial_y_train = y_train[10000:]

### Training the model
# train the model for 20 epochs in mini-batches of 512 samples
# also monitor loss and accuracy on the 10,000 samples that you set apart
#   You do so by passing the validation data as the validation_data argument.

history = model.fit(partial_x_train, partial_y_train, epochs=20, batch_size=512, validation_data=(x_val, y_val))

### Visualising results
#call to model.fit() returns a History object. This object has a member history, which is a dictionary containing data about everything that happened during training:

history_dict = history.history
history_dict.keys()
# dictionary contains four entries: one per metric that was being monitored during training and during validation. can plot with matplotlib:

#Plotting the training and validation loss import
import matplotlib.pyplot as plt

history_dict = history.history
loss_values = history_dict['loss']
val_loss_values = history_dict['val_loss']

epochs = range(1, len(loss_values) + 1) #= num epochs - altered from original

plt.plot(epochs, loss_values, 'bo', label='Training loss')
plt.plot(epochs, val_loss_values, 'b', label='Validation loss')
plt.title('Training and validation loss')
plt.xlabel('Epochs')
plt.ylabel('Loss')
plt.legend()

plt.show()


#Plotting the training and validation accuracy
plt.clf()
acc_values = history_dict['acc']
val_acc_values = history_dict['val_acc']

plt.plot(epochs, acc_values, 'bo', label='Training acc') #altered from original
plt.plot(epochs, val_acc_values, 'b', label='Validation acc')
plt.title('Training and validation accuracy')
plt.xlabel('Epochs')
plt.ylabel('Loss')
plt.legend()

plt.show()

# what these show:

# the training loss decreases with every epoch, and the training accuracy increases with every epoch
# That’s what you would expect when running gradient- descent optimization—the quantity you’re trying to minimize should be less with every iteration
# But that isn’t the case for the validation loss and accuracy: they seem to peak at the fourth epoch
# This is an example of what we warned against earlier: a model that performs better on the training data isn’t necessarily a model that will do better on data it has never seen before
# In precise terms, what you’re seeing is overfit- ting: after the second epoch, you’re overoptimizing on the training data, and you end up learning representations that are specific to the training data and don’t generalize to data outside of the training set
# In this case, to prevent overfitting, you could stop training after three epochs
# In general, you can use a range of techniques to mitigate overfitting, which we’ll cover in chapter 4

### Let’s train a new network from scratch for four epochs and then evaluate it on the test data

model = models.Sequential()
model.add(layers.Dense(16, activation='relu', input_shape=(10000,)))
model.add(layers.Dense(16, activation='relu'))
model.add(layers.Dense(1, activation='sigmoid'))

model.compile(optimizer='rmsprop', loss='binary_crossentropy', metrics=['accuracy'])

model.fit(x_train, y_train, epochs=4, batch_size=512)
results = model.evaluate(x_test, y_test)
#This fairly naive approach achieves an accuracy of 88%. With state-of-the-art approaches, you should be able to get close to 95%.

### Testing on test set
# After having trained a network, you’ll want to use it in a practical setting. You can gen- erate the likelihood of reviews being positive by using the predict method

model.predict(x_test)