import tensorflow as tf
gpus = tf.config.experimental.list_physical_devices('GPU')
tf.config.experimental.set_memory_growth(gpus[0], True)


# We’ll cover the following techniques:
# ? Recurrent dropout—This is a specific, built-in way to use dropout to fight overfit- ting in recurrent layers.
# ? Stacking recurrent layers—This increases the representational power of the net- work (at the cost of higher computational loads).
# ? Bidirectional recurrent layers—These present the same information to a recurrent network in different ways, increasing accuracy and mitigating forgetting issues - see next script

# In this dataset, 14 different quantities (such air temperature, atmospheric pres- sure, humidity, wind direction, and so on) were recorded every 10 minutes, over several years.
# The original data goes back to 2003, but this example is limited to data from 2009–2016.
# This dataset is perfect for learning to work with numerical timeseries.
# You’ll use it to build a model that takes as input some data from the recent past (a few days’ worth of data points) and predicts the air temperature 24 hours in the future.

### Download and uncompress the data

# cd ~/Downloads
# mkdir jena_climate
# cd jena_climate
# wget https://s3.amazonaws.com/keras-datasets/jena_climate_2009_2016.csv.zip
# unzip jena_climate_2009_2016.csv.zip


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




### Plotting the temperature timeseries

from matplotlib import pyplot as plt

temp = float_data[:, 1] #<1> temperature (in degrees Celsius)
plt.plot(range(len(temp)), temp)
#plt.show() #unhash to show plot

### Plotting the first 10 days of the temperature timeseries

plt.plot(range(1440), temp[:1440])
#plt.show() #unhash to show plot

# you can see daily periodicity, especially evident for the last 4 days.
# Also note that this 10-day period must be coming from a fairly cold winter month.
# If you were trying to predict average temperature for the next month given a few months of past data, the problem would be easy, due to the reliable year-scale periodicity of the data.
# But looking at the data over a scale of days, the temperature looks a lot more chaotic.
# Is this timeseries predictable at a daily scale?



### Preparing the data

lookback = 720 #—Observations will go back 5 days
steps = 6 #—Observations will be sampled at one data point per hour
delay = 144 #—Targets will be 24 hours in the future.


# ? Preprocess the data to a format a neural network can ingest.
# This is easy: the data is already numerical, so you don’t need to do any vectorization.
# But each timeseries in the data is on a different scale (for example, temperature is typically between -20 and +30, but atmospheric pressure, measured in mbar, is around 1,000).
# You’ll normalize each timeseries independently so that they all take small values on a similar scale.

# ? Write a Python generator that takes the current array of float data and yields batches of data from the recent past, along with a target temperature in the future.
# Because the samples in the dataset are highly redundant (sample N and sample N + 1 will have most of their timesteps in common), it would be wasteful to explicitly allocate every sample.
# Instead, you’ll generate the samples on the fly using the original data.


### Normalising the data

mean = float_data[:200000].mean(axis=0)
float_data -= mean
std = float_data[:200000].std(axis=0)
float_data /= std


# preprocess the data by subtracting the mean of each timeseries and dividing by the standard deviation. You’re going to use the first 200,000 timesteps as training data, so compute the mean and standard deviation only on this fraction of the data.

### Generator yielding timeseries samples and their targets

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


# the data generator you’ll use.
# It yields a tuple (samples, targets), where samples is one batch of input data and targets is the corresponding array of target temperatures.
# It takes the following arguments:

# ? data—The original array of floating-point data, which you normalized in listing 6.32.
# ? lookback—How many timesteps back the input data should go.

# ? delay—How many timesteps in the future the target should be.

# ? min_index and max_index—Indices in the data array that delimit which time- steps to draw from. This is useful for keeping a segment of the data for validation and another for testing.

# ? shuffle—Whether to shuffle the samples or draw them in chronological order.

# ? batch_size—The number of samples per batch.

# ? step—The period, in timesteps, at which you sample data. You’ll set it to 6 in order to draw one data point every hour.



### Preparing the training, validation, and test generators

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

#How many steps to draw from val_gen in order to see the entire validation set
val_steps = (300000 - 200001 - lookback)
#How many steps to draw from test_gen in order to see the entire test set
test_steps = (len(float_data) - 300001 - lookback)

# Now, let’s use the abstract generator function to instantiate three generators:
# one for training
# one for validation
# and one for testing.

# Each will look at different temporal segments of the original data:
# the training generator looks at the first 200,000 timesteps,
# the validation generator looks at the following 100,000,
# and the test generator looks at the remainder.




##### A common-sense, non-machine-learning baseline 

# Before you start using black-box deep-learning models to solve the temperature- prediction problem, let’s try a simple, common-sense approach.
# It will serve as a sanity check, and it will establish a baseline that you’ll have to beat in order to demonstrate the usefulness of more-advanced machine-learning models.
# Such common-sense base-lines can be useful when you’re approaching a new problem for which there is no known solution (yet).
# A classic example is that of unbalanced classification tasks, where some classes are much more common than others.
# If your dataset contains 90% instances of class A and 10% instances of class B, then a common-sense approach to the classification task is to always predict “A” when presented with a new sample.
# Such a classifier is 90% accurate overall, and any learning-based approach should therefore beat this 90% score in order to demonstrate usefulness.
# Sometimes, such elementary baselines can prove surprisingly hard to beat.
# In this case, the temperature timeseries can safely be assumed to be continuous
# (the temperatures tomorrow are likely to be close to the temperatures today) as well as periodical with a daily period.
# Thus a common-sense approach is to always predict that the temperature 24 hours from now will be equal to the temperature right now.
# Let’s evaluate this approach, using the mean absolute error (MAE) metric:

# np.mean(np.abs(preds - targets))

### Computing the common-sense baseline MAE

def evaluate_naive_method():
    batch_maes = []
    for step in range(val_steps): #this works but val_steps = 98559 so takes a while. NB - can't use print to see progress, breaks due to how next() works
        samples, targets = next(val_gen) #this doesnt work
        preds = samples[:, -1, 1]
        mae = np.mean(np.abs(preds - targets))
        batch_maes.append(mae)
    print(np.mean(batch_maes))
    return(None)

# evaluate_naive_method() ###uses above function, takes ages but returns 0.2897

# This yields an MAE of 0.29.
# Because the temperature data has been normalized to be centered on 0 and have a standard deviation of 1, this number isn’t immediately interpretable.

celsius_mae = 0.29 * std[1]
celsius_mae

# It translates to an average absolute error of 0.29 × temperature_std degrees Celsius: 2.57˚C.
#That’s a fairly large average absolute error.
# Now the game is to use your knowledge of deep learning to do better



##### A basic machine-learning approach

# In the same way that it’s useful to establish a common-sense baseline before trying machine-learning approaches, it’s useful to try simple, cheap machine-learning models (such as small, densely connected networks) before looking into complicated and computationally expensive models such as RNNs.
# This is the best way to make sure any further complexity you throw at the problem is legitimate and delivers real benefits.
# The following listing shows a fully connected model that starts by flattening the data and then runs it through two Dense layers.
# Note the lack of activation function on the last Dense layer, which is typical for a regression problem.
# You use MAE as the loss; because you evaluate on the exact same data and with the exact same metric you did with the common-sense approach, the results will be directly comparable!

### Training and evaluating a densely connected model

from keras.models import Sequential
from keras import layers
from keras.optimizers import RMSprop

model = Sequential()
model.add(layers.Flatten(input_shape=(lookback // step, float_data.shape[-1]))) 
model.add(layers.Dense(32, activation='relu'))
model.add(layers.Dense(1))
model.compile(optimizer=RMSprop(), loss='mae')
history = model.fit(train_gen, steps_per_epoch=500, epochs=20, validation_data=val_gen, validation_steps=val_size//batch_size)
# steps_per_epoch=train_size//batch_size, validation_steps=test_size//batch_size
# from           =500                                     =val_steps
########## removed _generator as have previously, this and above fixed bug but the above makes it take longer than would have otherwise
# could experiment with fewer steps, larger batchsize etc - eg 500 s/e works

### Plotting results

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

# Some of the validation losses are close to the no-learning baseline, but not reliably.
# This goes to show the merit of having this baseline in the first place: it turns out to be not easy to outperform.
# Your common sense contains a lot of valuable information that a machine-learning model doesn’t have access to.
# You may wonder, if a simple, well-performing model exists to go from the data to the targets (the common-sense baseline), why doesn’t the model you’re training find it and improve on it?
# Because this simple solution isn’t what your training setup is looking for.
# The space of models in which you’re searching for a solution—that is, your hypothesis space—is the space of all possible two-layer networks with the configuration you defined.
# These networks are already fairly complicated.
# When you’re looking for a solution with a space of complicated models, the simple, well-performing baseline may be unlearnable, even if it’s technically part of the hypothesis space.
# That is a pretty significant limitation of machine learning in general: unless the learning algorithm is hardcoded to look for a specific kind of simple model, parameter learning can sometimes fail to find a simple solution to a simple problem.


##### A first recurrent baseline

# The first fully connected approach didn’t do well, but that doesn’t mean machine learning isn’t applicable to this problem.
# The previous approach first flattened the timeseries, which removed the notion of time from the input data.
# Let’s instead look at the data as what it is: a sequence, where causality and order matter.
# You’ll try a recurrent-sequence processing model—it should be the perfect fit for such sequence data, precisely because it exploits the temporal ordering of data points, unlike the first approach.

# Instead of the LSTM layer introduced in the previous section, you’ll use the GRU layer, developed by Chung et al. in 2014.
# 5 Gated recurrent unit (GRU) layers work using the same principle as LSTM, but they’re somewhat streamlined and thus cheaper to run (although they may not have as much representational power as LSTM).
# This trade-off between computational expensiveness and representational power is seen everywhere in machine learning.

### Training and evaluating a GRU-based model

from keras.models import Sequential
from keras import layers
from keras.optimizers import RMSprop

model = Sequential()
model.add(layers.GRU(32, input_shape=(None, float_data.shape[-1])))
model.add(layers.Dense(1))

model.compile(optimizer=RMSprop(), loss='mae')
history = model.fit(train_gen, steps_per_epoch=500, epochs=20, validation_data=val_gen, validation_steps=val_size//batch_size)
#same subs as before

# (visualise with same code)
# Much better! You can significantly beat the common-sense baseline, demonstrating the value of machine learning as well as the superiority of recurrent networks compared to sequence-flattening dense networks on this type of task.
# The new validation MAE of ~0.265 (the low-point for val loss, before you start significantly overfitting) translates to a mean absolute error of 2.35˚C after denormalization.
# That’s a solid gain on the initial error of 2.57˚C, but you probably still have a bit of a margin for improvement.


##### Using recurrent dropout to fight overfitting

# It’s evident from the training and validation curves that the model is overfitting: the training and validation losses start to diverge considerably after a few epochs.
# You’re already familiar with a classic technique for fighting this phenomenon: dropout, which randomly zeros out input units of a layer in order to break happenstance correlations in the training data that the layer is exposed to.
# But how to correctly apply dropout in recurrent networks isn’t a trivial question.
# It has long been known that applying dropout before a recurrent layer hinders learning rather than helping with regularization.

# In 2015, Yarin Gal, as part of his PhD thesis on Bayesian deep learning, determined the proper way to use dropout with a recurrent network: the same dropout mask (the same pattern of dropped units) should be applied at every time-step, instead of a dropout mask that varies randomly betwen timesteps
# What’s more, to regularize the representations formed by the recurrent gates of layers like GRU and LSTM, a temporally constant dropout mask should be applied to the inner recurrent activations of the layer (a recurrent dropout mask).
# Using the same dropout mask at every timestep allows the network to properly propagate its learning error through time; a temporally random dropout mask would disrupt this error signal and be harmful to the learning process.


# Yarin Gal did his research using Keras and helped build this mechanism directly
# into Keras recurrent layers.
# Every recurrent layer in Keras has two dropout-related arguments: dropout, a float specifying the dropout rate for input units of the layer and recurrent_dropout, specifying the dropout rate of the recurrent units.
# Let’s add dropout and recurrent dropout to the GRU layer and see how doing so impacts overfitting.
# Because networks being regularized with dropout always take longer to fully converge, you’ll train the network for twice as many epochs. (but actualy no)

### Training and evaluating a dropout-regularized GRU-based model

from keras.models import Sequential
from keras import layers
from keras.optimizers import RMSprop

model = Sequential()
model.add(layers.GRU(32,
dropout=0.2, recurrent_dropout=0.2, input_shape=(None, float_data.shape[-1])))
model.add(layers.Dense(1))

model.compile(optimizer=RMSprop(), loss='mae')
history = model.fit_generator(train_gen, steps_per_epoch=500, epochs=20, validation_data=val_gen, validation_steps=val_size//batch_size)

# Success! You’re no longer overfitting during the first 30 epochs.
# But although you have more stable evaluation scores, your best scores aren’t much lower than they were previously, and it takes much more power


##### Stacking recurrent layers

# Because you’re no longer overfitting but seem to have hit a performance bottleneck, you should consider increasing the capacity of the network.
# Recall the description of the universal machine-learning workflow: it’s generally a good idea to increase the capacity of your network until overfitting becomes the primary obstacle (assuming you’re already taking basic steps to mitigate overfitting, such as using dropout).
# As long as you aren’t overfitting too badly, you’re likely under capacity.
# Increasing network capacity is typically done by increasing the number of units in the layers or adding more layers.
# Recurrent layer stacking is a classic way to build more-powerful recurrent networks:
# for instance, what currently powers the Google Translate algorithm is a stack of seven large LSTM layers—that’s huge.
# To stack recurrent layers on top of each other in Keras, all intermediate layers should return their full sequence of outputs (a 3D tensor) rather than their output at the last timestep.
# This is done by specifying return_sequences=True.

from keras.models import Sequential
from keras import layers
from keras.optimizers import RMSprop

model = Sequential()
model.add(layers.GRU(32,
dropout=0.1, recurrent_dropout=0.5, return_sequences=True, input_shape=(None, float_data.shape[-1])))
model.add(layers.GRU(64, activation='relu', dropout=0.1, recurrent_dropout=0.5))
model.add(layers.Dense(1))

model.compile(optimizer=RMSprop(), loss='mae')
history = model.fit_generator(train_gen, steps_per_epoch=500, epochs=10, validation_data=val_gen, validation_steps=val_size//batch_size) #was 40 epochs

# You can see that the added layer does improve the results a bit, though not significantly.
# You can draw two conclusions:
# ? Because you’re still not overfitting too badly, you could safely increase the size of your layers in a quest for validation-loss improvement. This has a non-negligible computational cost, though.
# ? Adding a layer didn’t help by a significant factor, so you may be seeing diminishing returns from increasing network capacity at this point
