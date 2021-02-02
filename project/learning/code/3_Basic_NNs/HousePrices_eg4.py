############################################################
##### House Prices Dataset

### Regression

# The two previous examples were considered classification problems, where the goal was to predict a single discrete label of an input data point
# Another common type of machine-learning problem is regression, which consists of predicting a continuous value instead of a discrete label
# For instance, predicting the temperature tomorrow, given meteorological data; or predicting the time that a software project will take to complete, given its specifications.
#     NOTE Don’t confuse regression and the algorithm logistic regression.
#     Confusingly, logistic regression isn’t a regression algorithm but a classification algorithm.





### The Boston Housing Price dataset

# You’ll attempt to predict the median price of homes in a given Boston suburb in the mid-1970s, given data points about the suburb at the time, such as the crime rate, the local property tax rate, and so on
# The dataset you’ll use has an interesting difference from the two previous examples
# It has relatively few data points: only 506, split between 404 training samples and 102 test samples
# And each feature in the input data (for example, the crime rate) has a different scale
# For instance, some values are proportions, which take values between 0 and 1; others take values between 1 and 12, others between 0 and 100, and so on.


from keras.datasets import boston_housing

(train_data, train_targets), (test_data, test_targets) = boston_housing.load_data()

# you have 404 training samples and 102 test samples, each with 13 numerical features, such as per capita crime rate, average number of rooms per dwell- ing, accessibility to highways, and so on
# The targets are the median values of owner-occupied homes, in thousands of dollars
# The prices are typically between $10,000 and $50,000
# If that sounds cheap, remember that this was the mid-1970s, and these prices aren’t adjusted for inflation.



### Preparing (normalising) the data

# It would be problematic to feed into a neural network values that all take wildly different ranges
# The network might be able to automatically adapt to such heterogeneous data, but it would definitely make learning more difficult
# A widespread best practice to deal with such data is to do feature-wise normalization
    # for each feature in the input data (a column in the input data matrix), you subtract the mean of the feature
    # and  then divide by the standard deviation, so that the feature is centered around 0 and has a unit standard deviation
# This is easily done in Numpy.

import numpy as np

mean = train_data.mean(axis=0)
train_data -= mean
std = train_data.std(axis=0)
train_data /= std

test_data -= mean
test_data /= std
# Note that the quantities used for normalizing the test data are computed using the training data!!!
# You should never use in your workflow any quantity computed on the test data, even for something as simple as data normalization.



### Building the network

# Because so few samples are available, you’ll use a very small network with two hidden layers, each with 64 units
# In general, the less training data you have, the worse overfitting will be, and using a small network is one way to mitigate overfitting.

from keras import models
from keras import layers

# Because you’ll need to instantiate the same model multiple times, you use a function to construct it.
def build_model():
    model = models.Sequential()
    model.add(layers.Dense(64, activation='relu', input_shape=(train_data.shape[1],)))
    model.add(layers.Dense(64, activation='relu'))
    model.add(layers.Dense(1))#linear layer
    model.compile(optimizer='rmsprop', loss='mse', metrics=['mae'])#**
    return model


# The network ends with a single unit and no activation (it will be a linear layer)
# This is a typical setup for scalar regression (a regression where you’re trying to predict a single continuous value)

# Applying an activation function would constrain the range the output can take; 
#   for instance, if you applied a sigmoid activation function to the last layer, the network could only learn to predict values between 0 and 1.
#   Here, because the last layer is purely linear, the network is free to learn to predict values in any range.

#** Note that you compile the network with the mse loss function—mean squared error, the square of the difference between the predictions and the targets
# This is a widely used loss function for regression problems
# You’re also monitoring a new metric during training: mean absolute error (MAE)
# It’s the absolute value of the difference between the predictions and the targets
# For instance, an MAE of 0.5 on this problem would mean your predictions are off by $500 on average.




### Validating your approach using K-fold validation (small dataset)

# To evaluate your network while you keep adjusting its parameters (such as the number of epochs used for training), you could split the data into a training set and a validation set, as you did in the previous examples
# But because you have so few data points, the validation set would end up being very small (for instance, about 100 examples)
# As a consequence, the validation scores might change a lot depending on which data points you chose to use for validation and which you chose for training:
#   the validation scores might have a high variance with regard to the validation split.
# This would prevent you from reliably evaluating your model
# The best practice in such situations is to use K-fold cross-validation
# It consists of:
#   splitting the available data into K partitions (typically K = 4 or 5)
#   instantiating K identical models
#   and training each one on K – 1 partitions while evaluating on the remaining partition
# The validation score for the model used is then the average of the K validation scores obtained
# In terms of code, this is straightforward.

import numpy as np
k=4
num_val_samples = len(train_data) // k
num_epochs = 100
all_scores = []

for i in range(k):
    print('processing fold #', i)
    # Prepares the validation data: data from partition #k
    val_data = train_data[i * num_val_samples: (i + 1) * num_val_samples] 
    val_targets = train_targets[i * num_val_samples: (i + 1) * num_val_samples]
    # Prepares the training data: data from all other partitions
    partial_train_data = np.concatenate( [train_data[:i * num_val_samples], train_data[(i + 1) * num_val_samples:]], axis=0)
    partial_train_targets = np.concatenate( [train_targets[:i * num_val_samples], train_targets[(i + 1) * num_val_samples:]], axis=0)
    # Builds the Keras model (already compiled)
    model = build_model()
    # Trains the model (in silent mode, verbose = 0)
    model.fit(partial_train_data, partial_train_targets, epochs=num_epochs, batch_size=1, verbose=0)
    # Evaluates the model on the validation data
    val_mse, val_mae = model.evaluate(val_data, val_targets, verbose=0)
    all_scores.append(val_mae)

np.mean(all_scores) # off by $2500ish on average - quite alot, range is 10-50k

### Again but with 500 epochs and saving validation logs at each fold


num_epochs = 500
Prepares the validation data:
all_mae_histories = []
for i in range(k):
    print('processing fold #', i)
    # Prepares the validation data: data from partition #k
    val_data = train_data[i * num_val_samples: (i + 1) * num_val_samples]
    val_targets = train_targets[i * num_val_samples: (i + 1) * num_val_samples]
    # Prepares the training data: data from all other partitions
    partial_train_data = np.concatenate( [train_data[:i * num_val_samples], train_data[(i + 1) * num_val_samples:]], axis=0)
    partial_train_targets = np.concatenate( [train_targets[:i * num_val_samples], train_targets[(i + 1) * num_val_samples:]], axis=0)
    # Builds the Keras model (already compiled)
    model = build_model()
    # Trains the model (in silent mode, verbose=0)
    history = model.fit(partial_train_data, partial_train_targets, validation_data=(val_data, val_targets), epochs=num_epochs, batch_size=1, verbose=0)
    mae_history = history.history['val_mae']
    all_mae_histories.append(mae_history)



# You can then compute the average of the per-epoch MAE scores for all folds:
average_mae_history = [ np.mean([x[i] for x in all_mae_histories]) for i in range(num_epochs)]


### Plotting validation scores

import matplotlib.pyplot as plt

plt.plot(range(1, len(average_mae_history) + 1), average_mae_history)
plt.xlabel('Epochs')
plt.ylabel('Validation MAE')
plt.show()
# It may be a little difficult to see the plot, due to scaling issues and relatively high variance
# 
# Let’s do the following:
#   Omit the first 10 data points, which are on a different scale than the rest of the curve.
#   Replace each point with an exponential moving average of the previous points, to obtain a smooth curve.



def smooth_curve(points, factor=0.9):
    smoothed_points = []
    for point in points:
        if smoothed_points:
            previous = smoothed_points[-1]
            smoothed_points.append(previous * factor + point * (1 - factor))
        else: smoothed_points.append(point)
    return smoothed_points


smooth_mae_history = smooth_curve(average_mae_history[10:])
plt.plot(range(1, len(smooth_mae_history) + 1), smooth_mae_history)
plt.xlabel('Epochs')
plt.ylabel('Validation MAE')
plt.show()
# According to this plot, validation MAE stops improving significantly after 80 epochs (the lowest steady(ish) point). Past that point, you start overfitting
#    Will change with different reruns

### Training the final model:

# Once you’re finished tuning other parameters of the model (in addition to the
# number of epochs, you could also adjust the size of the hidden layers):
#    train a final production model on all of the training data, with the best parameters
#    then look at its performance on the test data.

model = build_model()
model.fit(train_data, train_targets, epochs=80, batch_size=16, verbose=0)
test_mse_score, test_mae_score = model.evaluate(test_data, test_targets)

test_mae_score
#You’re still off by output x $1000