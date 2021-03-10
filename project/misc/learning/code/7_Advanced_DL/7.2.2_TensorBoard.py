import tensorflow as tf
gpus = tf.config.experimental.list_physical_devices('GPU')
tf.config.experimental.set_memory_growth(gpus[0], True)

##### TensorBoard

# The key purpose of TensorBoard is to help you visually monitor everything that
# goes on inside your model during training.
# If you’re monitoring more information than just the model’s final loss, you can develop a clearer vision of what the model does and doesn’t do, and you can make progress more quickly.
# TensorBoard gives you access to several neat features, all in your browser:

# ? Visually monitoring metrics during training
# ? Visualizing your model architecture
# ? Visualizing histograms of activations and gradients
# ? Exploring embeddings in 3D

### Text-classification model to use with TensorBoard

# Let’s demonstrate these features on a simple example.
# You’ll train a 1D convnet on the IMDB sentiment-analysis task.
# The model is similar to the one you saw in the last section of chapter 6. 
# You’ll consider only the top 2,000 words in the IMDB vocabulary, to make visualizing word embeddings more tractable.

import keras
from keras import layers
from keras.datasets import imdb
from keras.preprocessing import sequence

max_features = 2000 #Number of words to consider as features
max_len = 500 #Cuts off texts after this number of words (among max_features most common words)

(x_train, y_train), (x_test, y_test) = imdb.load_data(num_words=max_features)
x_train = sequence.pad_sequences(x_train, maxlen=max_len)
x_test = sequence.pad_sequences(x_test, maxlen=max_len)

model = keras.models.Sequential()
model.add(layers.Embedding(max_features,128,input_length=max_len, name='embed'))
model.add(layers.Conv1D(32, 7, activation='relu'))
model.add(layers.MaxPooling1D(5))
model.add(layers.Conv1D(32, 7, activation='relu'))
model.add(layers.GlobalMaxPooling1D())
model.add(layers.Dense(1))
model.summary()

model.compile(optimizer='rmsprop', loss='binary_crossentropy', metrics=['acc'])

### Creating a directory for TensorBoard log files

#Before you start using TensorBoard, you need to create a directory where you’ll store the log files it generates

import os

my_log_dir = '/home/bennouhan/cmeecoursework/project/misc/my_log_dir'
try: #creates if not there
    os.mkdir(my_log_dir)
except: #passes if they are
    pass


### Training the model with a TensorBoard callback

# Let’s launch the training with a TensorBoard callback instance. This callback will write log events to disk at the specified location

callbacks = [
    keras.callbacks.TensorBoard(
        log_dir='my_log_dir',
        histogram_freq=1,
        embeddings_freq=1,)]

history = model.fit(x_train, y_train,
                    epochs=2, #was 20, shortened
                    batch_size=128, # oom error but runs so left it this high
                    validation_split=0.2,
                    callbacks=callbacks)

# At this point, you can launch the TensorBoard server from the command line, instructing it to read the logs the callback is currently writing.
# The tensorboard utility should have been automatically installed on your machine the moment you installed TensorFlow (for example, via pip):


# quit()
# cd /home/bennouhan/cmeecoursework/project/misc/my_log_dir
# tensorboard --logdir=my_log_dir


# You can then browse to http://localhost:6006 and look at your model training (see figure 7.10 pg 254).
# In addition to live graphs of the training and validation metrics, you get access to the Histograms tab, where you can find pretty visualizations of histograms of activation values taken by your layers (see figure 7.11).

# See pages 254 to 257 for various visualisation options

# NB not sure what happens in that dir if multiple models save, overwritten or what?


##### Keras alternative

# Note that Keras also provides another, cleaner way to plot models as graphs of layers rather than graphs of TensorFlow operations (page 257):
# the utility keras.utils.plot_model.

# Using it requires that you’ve installed the Python pydot and pydot-ng libraries as well as the graphviz library.
# Let’s take a quick look:

from keras.utils import plot_model
plot_model(model, to_file='model.png')

## NB requires:
# pip3 install pydot
# sudo apt update
# sudo apt install graphviz #in bash obvs

# You also have the option of displaying shape information in the graph of layers.
# This example visualizes model topology using plot_model and the show_shapes option (see figure 7.15 pg 258, same as below if it works):

from keras.utils import plot_model
plot_model(model, show_shapes=True, to_file='model.png')

### NB filepathing is a bit weird here, sort out if you're gunna use this *which seems like you should)

### NB, bit of code in 7.3 on
#
# - BATCH NORMALIZATION
# - DEPTHWISE SEPARABLE CONVOLUTION
# - Model ensembling
# - Hyperparameter optimization
# 
# , but not enough to justify a script