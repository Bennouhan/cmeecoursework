############################################################
##### House Prices Dataset

### Regression

# build a network to classify Reuters newswires into 46 mutually
# exclusive topics
# Because you have many classes, this problem is an instance of multi- class classification;
#   and because each data point should be classified into only one cate- gory, the problem is more specifically an instance of single-label, multiclass classification.
# If each data point could belong to multiple categories (in this case, topics), you’d be facing a multilabel, multiclass classification problem

# You’ll work with the Reuters dataset, a set of short newswires and their topics, published by Reuters in 1986
#   It’s a simple, widely used toy dataset for text classification.
#   There are 46 different topics; some topics are more represented than others, but each topic has at least 10 examples in the training set
# You have 8,982 training examples and 2,246 test examples

from keras.datasets import reuters

(train_data, train_labels), (test_data, test_labels) = reuters.load_data( num_words=10000)
# num_words=10000 means you’ll only keep the top 10,000 most frequently occurring words in the training data. Rare words will be discarded. This allows you to work with vector data of manageable size

# train_data and test_data are lists of newswires, each a list of word indices(encoding a sequence of words)
# The label associated with an example is an integer between 0 and 45—a topic index

# see page 78 to find how to decode back to words

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


## vectorise  with one-hot coding: (see alternative at bottom)

# One-hot encoding is a widely used format for categorical data, also called categorical encoding
# For a more detailed explanation of one-hot encoding, see section 6.1
# In this case, one-hot encoding of the labels consists of embedding each label as an all-zero vector with a 1 in the place of the label index:

# def to_one_hot(labels, dimension=46):
#     results = np.zeros((len(labels), dimension))
#     for i, label in enumerate(labels):
#         results[i, label] = 1.
#     return results

# one_hot_train_labels = to_one_hot(train_labels)
# one_hot_test_labels = to_one_hot(test_labels)

# However, keras has a built-in way of doing this:

from keras.utils.np_utils import to_categorical

one_hot_train_labels = to_categorical(train_labels)
one_hot_test_labels = to_categorical(test_labels)


### Building the network

# Similar to IMDB version, but number of output classes is now 46, not 2
# hence, dimensionality of the output space is much larger.
# In a stack of Dense layers like that you’ve been using, each layer can only access information present in the output of the previous layer
# If one layer drops some information relevant to the classification problem, this information can never be recovered by later layers 
# This is because each layer can potentially become an information bottleneck
# 
# In the previous example, you used 16-dimensional intermediate layers, but a 16-dimensional space may be too limited to learn to separate 46 different classes: such small layers may act as information bottlenecks, permanently dropping relevant information
# For this reason you’ll use larger layers. Let’s go with 64 units.

from keras import models
from keras import layers

model = models.Sequential()
model.add(layers.Dense(64, activation='relu', input_shape=(10000,)))
model.add(layers.Dense(64, activation='relu'))
model.add(layers.Dense(46, activation='softmax'))

# You end the network with a Dense layer of size 46
#   This means for each input sample, the network will output a 46-dimensional vector
#   Each entry in this vec- tor (each dimension) will encode a different output class.

# The last layer uses a softmax activation
#   It means the network will output a probability distribution over the 46 different output classes
#   ie for every input sample, the network will produce a 46- dimensional output vector, where output[i] is the probability that the sample belongs to class i.
#   The 46 scores will sum to 1

### Complation step
# model.compile(optimizer='rmsprop', loss='categorical_crossentropy', metrics=['acc'])
# The best loss function to use in this case is categorical_crossentropy
# It measures the distance between two probability distributions: here, between the probability distribution output by the network and the true distribution of the labels
# By minimizing the distance between these two distributions, you train the network to output something as close as possible to the true labels

model.compile(optimizer='rmsprop', loss='categorical_crossentropy', metrics=['acc'])


### Validating your approach - Let’s set apart 1,000 samples in the training data to use as a validation set.

x_val = x_train[:1000]
partial_x_train = x_train[1000:]

y_val = one_hot_train_labels[:1000]
partial_y_train = one_hot_train_labels[1000:]


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

#Plotting the training and validation loss
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

### what these show:

# The network begins to overfit after nine epochs.
# Let’s train a new network from scratch for nine epochs and then evaluate it on the test set.




### Let’s train a new network from scratch for four epochs and then evaluate it on the test data


model = models.Sequential()
model.add(layers.Dense(64, activation='relu', input_shape=(10000,)))
model.add(layers.Dense(64, activation='relu'))
model.add(layers.Dense(46, activation='softmax'))

model.compile(optimizer='rmsprop', loss='categorical_crossentropy', metrics=['accuracy'])
model.fit(partial_x_train, partial_y_train, epochs=9, batch_size=512, validation_data=(x_val, y_val))
results = model.evaluate(x_test, one_hot_test_labels)
print(results)

# This approach reaches an accuracy of ~80%.
# With a balanced binary classification problem, the accuracy reached by a purely random classifier would be 50%
# But in this case it’s closer to 19%, so the results seem pretty good, at least when compared to a random baseline:

### Generating predictions for new data

predictions = model.predict(x_test)

# Each entry in predictions is a vector of length 46:
    # predictions[0].shape #=(46,)

# The coefficients in this vector sum to 1:
    # np.sum(predictions[0])

# The largest entry is the predicted class—the class with the highest probability:
    # np.argmax(predictions[0])

################################################################
### Further Info

### A different way to handle the labels and the loss
# We mentioned earlier that another way to encode the labels would be to cast them as an integer tensor, like this:
    # y_train = np.array(train_labels)
    # y_test = np.array(test_labels)

# The only thing this approach would change is the choice of the loss function. 
# The loss function used in listing 3.21, categorical_crossentropy, expects the labels to follow a categorical encoding.
# With integer labels, you should use sparse_categorical_ crossentropy:

    # model.compile(optimizer='rmsprop', loss='sparse_categorical_crossentropy', metrics=['acc'])

# This new loss function is still mathematically the same as categorical_crossentropy; it just has a different interface.



### The importance of having sufficiently large intermediate layers

# We mentioned earlier that because the final outputs are 46-dimensional, you should avoid intermediate layers with many fewer than 46 hidden units
# Now let’s see what happens when you introduce an information bottleneck by having intermediate layers that are significantly less than 46-dimensional: for example, 4-dimensional.

    # model = models.Sequential()
    # model.add(layers.Dense(64, activation='relu', input_shape=(10000,)))
    # model.add(layers.Dense(4, activation='relu'))
    # model.add(layers.Dense(46, activation='softmax'))

    # model.compile(optimizer='rmsprop', loss='categorical_crossentropy', metrics=['accuracy'])
    # model.fit(partial_x_train, partial_y_train, epochs=20, batch_size=128, validation_data=(x_val, y_val))

# The network now peaks at ~71% validation accuracy, an 8% absolute drop.
# This drop is mostly due to the fact that you’re trying to compress a lot of information (enough information to recover the separation hyperplanes of 46 classes) into an intermediate space that is too low-dimensional.
# The network is able to cram most of the necessary information into these eight-dimensional representations, but not all of it.