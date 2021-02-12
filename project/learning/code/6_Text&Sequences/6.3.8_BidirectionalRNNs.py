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

################################################################################
################################################################################




##### START



# We’ll cover the following techniques:
# ? Recurrent dropout—This is a specific, built-in way to use dropout to fight overfit- ting in recurrent layers. - previous script
# ? Stacking recurrent layers—This increases the representational power of the net- work (at the cost of higher computational loads). - previous script
# ? Bidirectional recurrent layers—These present the same information to a recurrent network in different ways, increasing accuracy and mitigating forgetting issues


##### Using bidirectional RNNs

# The last technique introduced in this section is called bidirectional RNNs.
# A bidirectional RNN is a common RNN variant that can offer greater performance than a regular RNN on certain tasks.
# It’s frequently used in natural-language processing—you could call it the Swiss Army knife of deep learning for natural-language processing.
# ##RNNs are notably order dependent###, or time dependent: they process the timesteps of their input sequences in order, and shuffling or reversing the timesteps can completely change the representations the RNN extracts from the sequence.
# This is precisely the reason they perform well on problems where order is meaningful, such as the temperature-forecasting problem.
# A bidirectional RNN exploits the order sensitivity of RNNs:
#    it consists of using two regular RNNs, such as the GRU and LSTM layers you’re already familiar with, each of which processes the input sequence in one direction (chronologically and antichronologically),
#    and then merging their representations
# By processing a sequence both ways, a bidirectional RNN can catch patterns that may be overlooked by a unidirectional RNN.

# Remarkably, the fact that the RNN layers in this section have processed sequences in chronological order (older timesteps first) may have been an arbitrary decision.
# At least, it’s a decision we made no attempt to question so far.
# Could the RNNs have performed well enough if they processed input sequences in antichronological order, for instance (newer timesteps first)?

# Let’s try this in practice and see what happens.
# All you need to do is write a variant of the data generator where the input sequences are reverted along the time dimension (replace the last line with yield samples[:, ::-1, :], targets).
# Training the same one-GRU-layer network that you used in the first experiment in this section, you get the results shown in figure 6.24.

### (the fig is similar to the previous, but fluctuates around 0.4 not 0.25)

# The reversed-order GRU strongly underperforms even the common-sense baseline, indicating that in this case, chronological processing is important to the success of your approach.
# This makes perfect sense: the underlying GRU layer will typically be better at remembering the recent past than the distant past, and naturally the more recent weather data points are more predictive than older data points for the problem (that’s what makes the common-sense baseline fairly strong).
# Thus the chronological version of the layer is bound to outperform the reversed-order version.
###Importantly, this isn’t true for many other problems,### including natural language:
#   intuitively, the importance of a word in understanding a sentence isn’t usually dependent on its position in the sentence.
# Let’s try the same trick on the LSTM IMDB example from section 6.2.

from keras.datasets import imdb
from keras.preprocessing import sequence
from keras import layers
from keras.models import Sequential

max_features = 10000 # no. words to consider as features
maxlen = 500 # Cuts off texts after this number of words (among the max_features most common words)

(x_train, y_train), (x_test, y_test) = imdb.load_data( num_words=max_features)

# reverses sequences
x_train = [x[::-1] for x in x_train]
x_test = [x[::-1] for x in x_test]

# pads sequences
x_train = sequence.pad_sequences(x_train, maxlen=maxlen)
x_test = sequence.pad_sequences(x_test, maxlen=maxlen)

model = Sequential()
model.add(layers.Embedding(max_features, 128))
model.add(layers.LSTM(32))
model.add(layers.Dense(1, activation='sigmoid'))

model.compile(optimizer='rmsprop', loss='binary_crossentropy', metrics=['acc'])
history = model.fit(x_train, y_train, epochs=10, batch_size=128, validation_split=0.2)


### Plotting results (not confirmed to work with these, test)


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


# You get performance nearly identical to that of the chronological-order LSTM.
# Remarkably, on such a text dataset, reversed-order processing works just as well as chronological processing, confirming the hypothesis that, although word order does matter in understanding language, which order you use isn’t crucial.
# Importantly, an RNN trained on reversed sequences will learn different representations than one trained on the original sequences, much as you would have different mental models if time flowed backward in the real world—if you lived a life where you died on your first day and were born on your last day.
#  In machine learning, representations that are different yet useful are always worth exploiting, and the more they differ, the better:
#   they offer a new angle from which to look at your data, capturing aspects of the data that were missed by other approaches, and thus they can help boost performance on a task.
# This is the intuition behind ensembling, a concept we’ll explore in chapter 7.
# A bidirectional RNN exploits this idea to improve on the performance of chronological-order RNNs.
# It looks at its input sequence both ways (see figure 6.25), obtaining potentially richer representations and capturing patterns that may have been missed by the chronological-order version alone. (see pg 221 for figure)


### Training and evaluating a bidirectional LSTM

# To instantiate a bidirectional RNN in Keras, you use the Bidirectional layer, which takes as its first argument a recurrent layer instance.
# Bidirectional creates a second, separate instance of this recurrent layer and uses one instance for processing the input sequences in chronological order and the other instance for processing the input sequences in reversed order.
# Let’s try it on the IMDB sentiment-analysis task.

model = Sequential()
model.add(layers.Embedding(max_features, 32))
model.add(layers.Bidirectional(layers.LSTM(32)))
model.add(layers.Dense(1, activation='sigmoid'))

model.compile(optimizer='rmsprop', loss='binary_crossentropy', metrics=['acc']) 
history = model.fit(x_train, y_train, epochs=10, batch_size=128, validation_split=0.2)

# It performs slightly better than the regular LSTM you tried in the previous section, achieving over 89% validation accuracy.
# It also seems to overfit more quickly, which is unsurprising because a bidirectional layer has twice as many parameters as a chronological LSTM.
# With some regularization, the bidirectional approach would likely be a strong performer on this task.


### Training a bidirectional GRU on Jena Set




from keras.models import Sequential
from keras import layers
from keras.optimizers import RMSprop


model = Sequential()
model.add(layers.Bidirectional( layers.GRU(32), input_shape=(None, float_data.shape[-1])))
model.add(layers.Dense(1))

model.compile(optimizer=RMSprop(), loss='mae')
history = model.fit(train_gen, steps_per_epoch=500, epochs=40, validation_data=val_gen, validation_steps=val_size//batch_size)

# This performs about as well as the regular GRU layer.
# It’s easy to understand why: all the predictive capacity must come from the chronological half of the network, because the antichronological half is known to be severely underperforming on this task (again, because the recent past matters much more than the distant past in this case).




### Going Even Further

# There are many other things you could try, in order to improve performance on the temperature-forecasting problem:

# ? Adjust the number of units in each recurrent layer in the stacked setup.
#   The current choices are largely arbitrary and thus probably suboptimal.

# ? Adjust the learning rate used by the RMSprop optimizer.

# ? Try using LSTM layers instead of GRU layers.

# ? Try using a bigger densely connected regressor on top of the recurrent layers: that is, a bigger Dense layer or even a stack of Dense layers.

# ? Don’t forget to eventually run the best-performing models (in terms of validation MAE) on the test set!
#   Else, you’ll develop architectures that are overfitting the validation set.

# As always, deep learning is more an art than a science.
# We can provide guidelines that suggest what is likely to work or not work on a given problem, but, ultimately, every problem is unique; you’ll have to evaluate different strategies empirically.
# There is currently no theory that will tell you in advance precisely what you should do to optimally solve a problem.
# You must iterate!



### NOTE There are two important concepts we won’t cover in detail here:
# recurrent attention and sequence masking.
# Both tend to be especially relevant for natural-language processing, and they aren’t particularly applicable to the temperature-forecasting problem.
# We’ll leave them for future study outside of this book.