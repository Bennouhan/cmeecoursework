import tensorflow as tf
gpus = tf.config.experimental.list_physical_devices('GPU')
tf.config.experimental.set_memory_growth(gpus[0], True)


##### Functional API

# In the functional API, you directly manipulate tensors, and you use layers as functions that take tensors and return tensors (hence, the name functional API):

from keras import Input, layers

input_tensor = Input(shape=(32,)) # a tensor
dense = layers.Dense(32, activation='relu') # A layer is a function.
output_tensor = dense(input_tensor) # A layer may be called on a tensor, and it returns a tensor

# Let’s start with a minimal example that shows side by side a simple Sequential model and its equivalent in the functional API:

from keras.models import Sequential, Model
from keras import layers
from keras import Input

# Sequential model, which you already know about
seq_model = Sequential()
seq_model.add(layers.Dense(32, activation='relu', input_shape=(64,)))
seq_model.add(layers.Dense(32, activation='relu'))
seq_model.add(layers.Dense(10, activation='softmax'))

# Its functional equivalent
input_tensor = Input(shape=(64,))
x = layers.Dense(32, activation='relu')(input_tensor)
x = layers.Dense(32, activation='relu')(x)
output_tensor = layers.Dense(10, activation='softmax')(x)

# The Model class turns an input tensor and output tensor into a model
model = Model(input_tensor, output_tensor)
model.summary()


#The only part that may seem a bit magical at this point is instantiating a Model object using only an input tensor and an output tensor.
# Behind the scenes, Keras retrieves every layer involved in going from input_tensor to output_tensor, bringing them together into a graph-like data structure—a Model.
# Of course, the reason it works is that output_tensor was obtained by repeatedly transforming input_tensor.
# If you tried to build a model from inputs and outputs that weren’t related, you’d get a RuntimeError


### When it comes to compiling, training, or evaluating such an instance of Model, the API is the same as that of Sequential:

# Compiles the model
model.compile(optimizer='rmsprop', loss='categorical_crossentropy')

import numpy as np

# Generates dummy Numpy data to train on
x_train = np.random.random((1000, 64))
y_train = np.random.random((1000, 10))

# Trains the model for 10 epochs
model.fit(x_train, y_train, epochs=10, batch_size=128)
# Evaluates the model
score = model.evaluate(x_train, y_train)


##### Multi-input models

# The functional API can be used to build models that have multiple inputs.
# Typically, such models at some point merge their different input branches using a layer that can combine several tensors:
#    by adding them, concatenating them, and so on.
# This is usually done via a Keras merge operation such as keras.layers.add, keras.layers.concatenate, and so on.
# Let’s look at a very simple example of a multi-input model: a question-answering model.
# A typical question-answering model has two inputs: a natural-language question
# and a text snippet (such as a news article) providing information to be used for answering the question.
# The model must then produce an answer.
# In the simplest possible setup, this is a one-word answer obtained via a softmax over some predefined vocabulary (see figure 7.6 pg 238).



### Functional API implementation of a two-input question-answering model

# Following is an example of how you can build such a model with the functional API.
# You set up two independent branches, encoding the text input and the question input as representation vectors
# Then, concatenate these vectors
# Finally, add a softmax classifier on top of the concatenated representations

from keras.models import Model
from keras import layers
from keras import Input

text_vocabulary_size = 10000
question_vocabulary_size = 10000
answer_vocabulary_size = 500

# The text input is a variable- length sequence of integers. Note that you can optionally name the inputs.
text_input = Input(shape=(None,), dtype='int32', name='text')

# Embeds the inputs into a sequence of vectors of size 64
embedded_text = layers.Embedding( 64, text_vocabulary_size)(text_input)

# Encodes the vectors in a single vector via an LSTM
encoded_text = layers.LSTM(32)(embedded_text)

# Same process (with different layer instances) for the question
question_input = Input(shape=(None,),dtype='int32',name='question')

embedded_question = layers.Embedding(32, question_vocabulary_size)(question_input)
encoded_question = layers.LSTM(16)(embedded_question)

# Concatenates the encoded question and encoded text
concatenated = layers.concatenate([encoded_text, encoded_question], axis=-1)

# Adds a softmax classifier on top
answer = layers.Dense(answer_vocabulary_size,activation='softmax')(concatenated)

# At model instantiation, you specify the two inputs and the output.
model = Model([text_input, question_input], answer)
model.compile(optimizer='rmsprop', loss='categorical_crossentropy', metrics=['acc'])


### Feeding data to a multi-input model import

# Now, how do you train this two-input model?
# There are two possible APIs: you can feed the model a list of Numpy arrays as inputs, or you can feed it a dictionary that maps input names to Numpy arrays.
# Ofc, the latter option is available only if you give names to your inputs.


import numpy as np

num_samples = 1000
max_length = 100

# Generates dummy Numpy data
text = np.random.randint(1, text_vocabulary_size,size=(num_samples, max_length))

question = np.random.randint(1, question_vocabulary_size,size=(num_samples, max_length))

# answers are one-hot encoded, not integers
answers = np.random.randint(0, 1, size=(num_samples, answer_vocabulary_size))

########## WARNING: These are alternatives, and NEITHER WORK ###################
# Try and fix later if need be. see 2 root errors thing in error code
# Fitting using a list of inputs
model.fit([text, question], answers, epochs=10, batch_size=128)
# Fitting using a dictionary of inputs (only if inputs are named)
model.fit({'text': text, 'question': question}, answers, epochs=10, batch_size=128)





##### Multi-output models

# In the same way, you can use the functional API to build models with multiple outputs (or multiple heads).
# A simple example is a network that attempts to simultaneously predict different properties of the data, such:
#     as a network that takes as input a series of social media posts from a single anonymous person and tries to predict attributes of that person eg
#      age, gender, and income level (see figure 7.7).

### Functional API implementation of a three-output model

from keras import layers
from keras import Input
from keras.models import Model

vocabulary_size = 50000
num_income_groups = 10

posts_input = Input(shape=(None,), dtype='int32', name='posts')
embedded_posts = layers.Embedding(256, vocabulary_size)(posts_input)
x = layers.Conv1D(128, 5, activation='relu')(embedded_posts)
x = layers.MaxPooling1D(5)(x)
x = layers.Conv1D(256, 5, activation='relu')(x)
x = layers.Conv1D(256, 5, activation='relu')(x)
x = layers.MaxPooling1D(5)(x)
x = layers.Conv1D(256, 5, activation='relu')(x)
x = layers.Conv1D(256, 5, activation='relu')(x)
x = layers.GlobalMaxPooling1D()(x)
x = layers.Dense(128, activation='relu')(x)

# Outputs - Note that the output layers are given names.
age_prediction = layers.Dense(1, name='age')(x)
income_prediction = layers.Dense(num_income_groups, activation='softmax', name='income')(x)
gender_prediction = layers.Dense(1, activation='sigmoid', name='gender')(x)

model = Model(posts_input, [age_prediction, income_prediction, gender_prediction])


### Compilation options of a multi-output model: multiple losses

# training such a model requires the ability to specify different loss functions for different heads of the network:
#     for instance, age prediction is a scalar regression task, but gender prediction is a binary classification task, requiring a different training procedure.
# But because gradient descent requires you to minimize a scalar, you must combine these losses into a single value in order to train the model.
# The simplest way to combine different losses is to sum them all.
# In Keras, you can use either a list or a dictionary of losses in compile to specify different objects for different outputs; the resulting loss values are summed into a global loss, which is minimized during training

# These are equivalent
# (1st one is possible only if you give names to the output layers)
model.compile(optimizer='rmsprop',
              loss={'age': 'mse',
                    'income': 'categorical_crossentropy',
                    'gender': 'binary_crossentropy'})
# or, without names, just
# model.compile(optimizer='rmsprop', loss=['mse', 'categorical_crossentropy', 'binary_crossentropy'])


### Compilation options of a multi-output model: loss weighting
# NB - instead of above

# Note that very imbalanced loss contributions will cause the model representations to be optimized preferentially for the task with the largest individual loss, at the expense of the other tasks.
# To remedy this, you can assign different levels of importance to the loss values in their contribution to the final loss.
# This is useful in particular if the losses’ values use different scales.
# For instance, the mean squared error (MSE) loss used for the age-regression task typically takes a value around 3–5
# Whereas the crossentropy loss used for the gender-classification task can be as low as 0.1.
# In such a situation, to balance the contribution of the different losses, you can assign a weight of 10 to the crossentropy loss and a weight of 0.25 to the MSE loss.

# These are equivalent
# (1st one is possible only if you give names to the output layers)
model.compile(optimizer='rmsprop',
                loss={'age': 'mse',
                      'income': 'categorical_crossentropy',
                      'gender': 'binary_crossentropy'},
                loss_weights={'age': 0.25, 'income': 1., 'gender': 10.})
# or, without names, just
# model.compile(optimizer='rmsprop', loss=['mse', 'categorical_crossentropy', 'binary_crossentropy'], loss_weights=[0.25, 1., 10.])




### Feeding data to a multi-output model

# Much as in the case of multi-input models, you can pass Numpy data to the model for training either via a list of arrays or via a dictionary of arrays.

########## WARNING: These are alternatives, and NEITHER WORK ###################
# Try and fix later if need be. not sure if should be posts_input and eg age_predictions or what, but neither work

# age_targets, income_targets, and gender_targets are assumed to be Numpy arrays
model.fit(posts, [age_targets, income_targets, gender_targets], epochs=10, batch_size=64)

# Equivalent (possible only if you give names to the output layers)
model.fit(posts, {'age': age_targets,
                  'income': income_targets,
                  'gender': gender_targets},
                epochs=10, batch_size=64)



##### Directed acyclic graphs of layers

##### Layer weight sharing

##### Models as layers

# See the book starting pg 242 for these sections - could well be important but not enough code to justify a script