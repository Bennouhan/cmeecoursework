import tensorflow as tf
gpus = tf.config.experimental.list_physical_devices('GPU')
tf.config.experimental.set_memory_growth(gpus[0], True)

#ignore
################################################################################
############################# Same as previous script ##########################
################################################################################
# (see 6.3 script for explanation of this code, this is condensed)

### Inspecting the data of the Jena weather dataset

import os
data_dir = '/home/bennouhan/Downloads/jena_climate'
fname = os.path.join(data_dir, 'jena_climate_2009_2016.csv')
f = open(fname)
data = f.read()
f.close()
lines = data.split('\n')
header = lines[0].split(',')
lines = lines[1:]

print(header)
print(len(lines))

### Parsing the data

import numpy as np
float_data = np.zeros((len(lines), len(header) - 1))
for i, line in enumerate(lines):
    values = [float(x) for x in line.split(',')[1:]]
    float_data[i, :] = values

### Normalising the data
mean = float_data[:200000].mean(axis=0)
float_data -= mean
std = float_data[:200000].std(axis=0)
float_data /= std

def generator(data, lookback, delay, min_index, max_index, shuffle=False, batch_size=128, step=6):
    if max_index is None:
        max_index = len(data) - delay - 1
    i = min_index + lookback
    while 1:
        if shuffle:
            rows = np.random.randint( min_index + lookback, max_index, size=batch_size)
        else:
            if i + batch_size >= max_index:
                i = min_index + lookback
            rows = np.arange(i, min(i + batch_size, max_index))
            i += len(rows)
        samples = np.zeros((len(rows), lookback // step, data.shape[-1]))
        targets = np.zeros((len(rows),))
        for j, row in enumerate(rows):
            indices = range(rows[j] - lookback, rows[j], step)
            samples[j] = data[indices]
            targets[j] = data[rows[j] + delay][1]
        yield samples, targets


################################################################################
################################################################################




lookback = 1440
step = 6
delay = 144
batch_size = 128
train_size = 200000
val_size = 100000

train_gen = generator(float_data, lookback=lookback, delay=delay, 
min_index=0,            max_index=train_size,     shuffle=True, step=step, batch_size=batch_size)
val_gen = generator(float_data, lookback=lookback, delay=delay,
min_index=train_size+1, max_index=train_size+val_size,          step=step, batch_size=batch_size)
test_gen = generator(float_data, lookback=lookback, delay=delay,
min_index=train_size+val_size+1 , max_index=None,               step=step, batch_size=batch_size)  
val_steps = (300000 - 200001 - lookback)
test_steps = (len(float_data) - 300001 - lookback)




##### START


## See page 225 for pre-application background info on 1D convnets and pooling


##### Implementing a 1D convnet

# In Keras, you use a 1D convnet via the Conv1D layer, which has an interface similar to Conv2D.
# It takes as input 3D tensors with shape (samples, time, features) and returns similarly shaped 3D tensors.
# The convolution window is a 1D window on the temporal axis: axis 1 in the input tensor.
# Let’s build a simple two-layer 1D convnet and apply it to the IMDB sentiment- classification task you’re already familiar with.
# As a reminder, this is the code for obtaining and preprocessing the data.

### Preparing the IMDB data (as done previously)

from keras.datasets import imdb
from keras.preprocessing import sequence

max_features = 10000
max_len = 500

print('Loading data...')
(x_train, y_train), (x_test, y_test) = imdb.load_data(num_words=max_features)
print(len(x_train), 'train sequences')
print(len(x_test), 'test sequences')

print('Pad sequences (samples x time)')
x_train = sequence.pad_sequences(x_train, maxlen=max_len)
x_test = sequence.pad_sequences(x_test, maxlen=max_len)
print('x_train shape:', x_train.shape)
print('x_test shape:', x_test.shape)


### Training and evaluating a simple 1D convnet on the IMDB data

# 1D convnets are structured in the same way as their 2D counterparts, which you used in chapter 5:
#   they consist of a stack of Conv1D and MaxPooling1D layers, ending in either a global pooling layer or a Flatten layer
# These turn the 3D outputs into 2D outputs, allowing you to add one or more Dense layers to the model for classification or regression.

# One difference, though, is the fact that you can afford to use larger convolution windows with 1D convnets.
# With a 2D convolution layer, a 3 × 3 convolution window contains 3 × 3 = 9 feature vectors;
#   but with a 1D convolution layer, a convolution window of size 3 contains only 3 feature vectors.
# You can thus easily afford 1D convolution windows of size 7 or 9

from keras.models import Sequential
from keras import layers
from keras.optimizers import RMSprop

model = Sequential()
model.add(layers.Embedding(max_features, 128, input_length=max_len))
model.add(layers.Conv1D(32, 7, activation='relu'))
model.add(layers.MaxPooling1D(5))
model.add(layers.Conv1D(32, 7, activation='relu'))
model.add(layers.GlobalMaxPooling1D())
model.add(layers.Dense(1))

model.summary()

model.compile(optimizer=RMSprop(lr=1e-4), loss='binary_crossentropy', metrics=['acc'])
history = model.fit(x_train, y_train, epochs=10, batch_size=16, validation_split=0.2) #BS was 128, ran out of memory so dropped, higher may be fine eg 64 and 32



### Plotting results 


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



# Validation accuracy is somewhat less than that of the LSTM, but runtime is faster on both CPU and GPU (the exact increase in speed will vary greatly depending on your exact configuration).
# At this point, you could retrain this model for the right number of epochs (eight) and run it on the test set.
# This is a convincing demonstration that a 1D convnet can offer a fast, cheap alternative to a recurrent network on a word-level sentiment-classification task.






### Training and evaluating a simple 1D convnet on the Jena data
# (Uses code at very top, further explained in 6.3 script)


# Because 1D convnets process input patches independently, they aren’t sensitive to the order of the timesteps (beyond a local scale, the size of the convolution windows), unlike RNNs.
# Of course, to recognize longer-term patterns, you can stack many convolution layers and pooling layers, resulting in upper layers that will see long chunks of the original inputs—but that’s still a fairly weak way to induce order sensitivity.
# One way to evidence this weakness is to try 1D convnets on the temperature-forecasting problem, where order-sensitivity is key to producing good predictions.
# The following example reuses the following variables defined previously: float_data, train_gen, val_gen, and val_steps.



from keras.models import Sequential
from keras import layers
from keras.optimizers import RMSprop

model = Sequential()
model.add(layers.Conv1D(32, 5, activation='relu', input_shape=(None, float_data.shape[-1])))
model.add(layers.MaxPooling1D(3))
model.add(layers.Conv1D(32, 5, activation='relu'))
model.add(layers.MaxPooling1D(3))
model.add(layers.Conv1D(32, 5, activation='relu'))
model.add(layers.GlobalMaxPooling1D())
model.add(layers.Dense(1))

model.compile(optimizer=RMSprop(), loss='mae')
history = model.fit_generator(train_gen, steps_per_epoch=500, epochs=20, validation_data=val_gen, validation_steps=val_size//batch_size)


## Plotting (no accuracy metric for second plot, loss only)

import matplotlib.pyplot as plt

loss = history.history['loss']
val_loss = history.history['val_loss']
epochs = range(1, len(loss) + 1)

plt.figure()
plt.plot(epochs, loss, 'bo', label='Training loss')
plt.plot(epochs, val_loss, 'b', label='Validation loss')
plt.title('Training and validation loss')
plt.legend()
plt.show()


# The validation MAE stays in the 0.40s: you can’t even beat the common-sense baseline using the small convnet.
# Again, this is because the convnet looks for patterns anywhere in the input timeseries and has no knowledge of the temporal position of a pattern it sees (toward the beginning, toward the end, and so on).
# Because more recent data points should be interpreted differently from older data points in the case of this specific forecasting problem, the convnet fails at producing meaningful results.
# This limitation of convnets isn’t an issue with the IMDB data, because patterns of keywords associated with a positive or negative sentiment are informative independently of where they’re found in the input sentences.




##### Combining CNNs and RNNs to process long sequences



### Preparing higher-resolution data generators for the Jena dataset

# One strategy to combine the speed and lightness of convnets with the order-sensitivity of RNNs is to use a 1D convnet as a preprocessing step before an RNN (see figure 6.30).
# This is especially beneficial when you’re dealing with sequences that are so long they can’t realistically be processed with RNNs, such as sequences with thousands of steps.
# The convnet will turn the long input sequence into much shorter (downsampled) sequences of higher-level features.
# This sequence of extracted features then becomes the input to the RNN part of the network.
# This technique isn’t seen often in research papers and practical applications, possibly because it isn’t well known.
# It’s effective and ought to be more common.
# Let’s try it on the temperature-forecasting dataset.
# Because this strategy allows you to manipulate much longer sequences, you can either look at data from longer ago (by increasing the lookback parameter of the data generator) or look at high-resolution timeseries (by decreasing the step parameter of the generator).
# Here, somewhat arbitrarily, you’ll use a step that’s half as large, resulting in a timeseries twice as long, where the temperature data is sampled at a rate of 1 point per 30 minutes.
# The example reuses the generator function defined earlier.


step = 3 # was 6 before (1 per hour), now 1 per 30mins
lookback = 720 # same as before
delay = 144 # same as before
batch_size = 64 #128 too big, changed to 64
train_size = 200000
val_size = 100000


train_gen = generator(float_data, lookback=lookback, delay=delay, min_index=0, max_index=200000, shuffle=True,     step=step, batch_size=batch_size)
val_gen = generator(float_data, lookback=lookback, delay=delay, min_index=200001, max_index=300000, step=step, batch_size=batch_size)
test_gen = generator(float_data, lookback=lookback, delay=delay, min_index=300001, max_index=None,   step=step, batch_size=batch_size)

val_steps = (300000 - 200001 - lookback) // batch_size
test_steps = (len(float_data) - 300001 - lookback) // batch_size

# This is the model, starting with two Conv1D layers and following up with a GRU layer.

### Model combining a 1D convolutional base and a GRU layer



from keras.models import Sequential
from keras import layers
from keras.optimizers import RMSprop

model = Sequential()
model.add(layers.Conv1D(32, 5, activation='relu', input_shape=(None, float_data.shape[-1])))
model.add(layers.MaxPooling1D(3))
model.add(layers.Conv1D(32, 5, activation='relu'))
model.add(layers.GRU(32, dropout=0.1, recurrent_dropout=0.5)) #this issue is expected since the recurrent dropout is not implemented in the Nvidia's cudnn kernel. We have to fallback to use the generic kernel when user specify the recurrent dropout. See the docstring of GRU and LSTM for the criteria of using cudnn kernel
model.add(layers.Dense(1))

model.summary()

model.compile(optimizer=RMSprop(), loss='mae')
history = model.fit(train_gen, steps_per_epoch=500, epochs=2, validation_data=val_gen, validation_steps=val_steps) #epoch was 20, too long

# Judging from the validation loss, this setup isn’t as good as the regularized GRU alone, but it’s significantly faster.
# It looks at twice as much data, which in this case doesn’t appear to be hugely helpful but may be important for other datasets.

# Because RNNs are extremely expensive for processing very long sequences, but 1D convnets are cheap, it can be a good idea to use a 1D convnet as a prepro- cessing step before an RNN, shortening the sequence and extracting useful rep- resentations for the RNN to process.