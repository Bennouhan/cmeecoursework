### NB needed for conv network!!!
# (https://github.com/tensorflow/tensorflow/issues/24496)
import tensorflow as tf
from tensorflow.compat.v1 import InteractiveSession
from tensorflow.compat.v1 import ConfigProto
config = ConfigProto()
config.gpu_options.allow_growth = True
session = InteractiveSession(config=config)


#we’ll focus on classifying images as dogs or cats
# dataset containing 4,000 pictures of cats and dogs (2,000 cats, 2,000 dogs)
# We’ll use 2,000 pictures for training
#           1,000 for validation
#           1,000 for testing

### Downloading and unzipping data with bash
# download from https://www.kaggle.com/c/dogs-vs-cats/data
# unzip ~/Downloads/dogs-vs-cats.zip -d ~/Downloads
# unzip ~/Downloads/train.zip -d ~/Downloads



### Copying images to training, validation, and test directories

import os, shutil

### Set directories which do and will containt the photos
original_dataset_dir = '/home/bennouhan/Downloads/train'#/train
base_dir = '/home/bennouhan/cmeecoursework/project/learning/data/Chap5'
try: #creates if not there
    os.mkdir(base_dir)
    ### Create directories for the training, validation, and test splits
    train_dir = os.path.join(base_dir, 'train')
    os.mkdir(train_dir)
    validation_dir = os.path.join(base_dir, 'validation')
    os.mkdir(validation_dir)
    test_dir = os.path.join(base_dir, 'test')
    os.mkdir(test_dir)
    ### Creates subdirs in each for cats and dogs
    train_cats_dir = os.path.join(train_dir, 'cats')
    os.mkdir(train_cats_dir)
    train_dogs_dir = os.path.join(train_dir, 'dogs')
    os.mkdir(train_dogs_dir)
    #
    validation_cats_dir = os.path.join(validation_dir, 'cats')
    os.mkdir(validation_cats_dir)
    validation_dogs_dir = os.path.join(validation_dir, 'dogs')
    os.mkdir(validation_dogs_dir)
    #
    test_cats_dir = os.path.join(test_dir, 'cats')
    os.mkdir(test_cats_dir)
    test_dogs_dir = os.path.join(test_dir, 'dogs')
    os.mkdir(test_dogs_dir)
except: #passes if they are
    pass


### Copies photos into respective directories for use
fnames = ['cat.{}.jpg'.format(i) for i in range(1000)]
for fname in fnames:
    src = os.path.join(original_dataset_dir, fname)
    dst = os.path.join(train_cats_dir, fname)
    shutil.copyfile(src, dst)

fnames = ['cat.{}.jpg'.format(i) for i in range(1000, 1500)]
for fname in fnames:
    src = os.path.join(original_dataset_dir, fname)
    dst = os.path.join(validation_cats_dir, fname)
    shutil.copyfile(src, dst)

fnames = ['cat.{}.jpg'.format(i) for i in range(1500, 2000)]
for fname in fnames:
    src = os.path.join(original_dataset_dir, fname)
    dst = os.path.join(test_cats_dir, fname)
    shutil.copyfile(src, dst)

fnames = ['dog.{}.jpg'.format(i) for i in range(1000)]
for fname in fnames:
    src = os.path.join(original_dataset_dir, fname)
    dst = os.path.join(train_dogs_dir, fname)
    shutil.copyfile(src, dst)

fnames = ['dog.{}.jpg'.format(i) for i in range(1000, 1500)]
for fname in fnames:
    src = os.path.join(original_dataset_dir, fname)
    dst = os.path.join(validation_dogs_dir, fname)
    shutil.copyfile(src, dst)

fnames = ['dog.{}.jpg'.format(i) for i in range(1500, 2000)]
for fname in fnames:
    src = os.path.join(original_dataset_dir, fname)
    dst = os.path.join(test_dogs_dir, fname)
    shutil.copyfile(src, dst)

### Tests it worked
print('total training cat images:', len(os.listdir(train_cats_dir)))
print('total training dog images:', len(os.listdir(train_dogs_dir)))
print('total validation cat images:', len(os.listdir(validation_cats_dir)))
print('total validation dog images:', len(os.listdir(validation_dogs_dir)))
print('total test cat images:', len(os.listdir(test_cats_dir)))
print('total test dog images:', len(os.listdir(test_dogs_dir)))

# the convnet will be a stack of alternated Conv2D (with relu activation) and MaxPooling2D layers.
# because you’re dealing with bigger images and a more complex problem, you’ll
# make your network larger, accordingly:
#    it will have one more Conv2D + MaxPooling2D stage
#    This serves both to augment the capacity of the network and to further reduce the size of the feature maps so they aren’t overly large when you reach the Flatten layer
# Here, because you start from inputs of size 150 × 150 (a somewhat arbitrary choice), you end up with feature maps of size 7 × 7 just before the Flatten layer.

# NOTE The depth of the feature maps progressively increases in the network (from 32 to 128), whereas the size of the feature maps decreases (from 148 × 148 to 7 × 7).
# This is a pattern you’ll see in almost all convnets.

# Because you’re attacking a binary-classification problem, you’ll end the network with a single unit (a Dense layer of size 1) and a sigmoid activation
# This unit will encode the probability that the network is looking at one class or the other

### Instantiating a small convnet for dogs vs. cats classification
from keras import layers
from keras import models

model = models.Sequential()
model.add(layers.Conv2D(32, (3, 3), activation='relu', input_shape=(150, 150, 3)))
model.add(layers.MaxPooling2D((2, 2)))
model.add(layers.Conv2D(64, (3, 3), activation='relu'))
model.add(layers.MaxPooling2D((2, 2)))
model.add(layers.Conv2D(128, (3, 3), activation='relu'))
model.add(layers.MaxPooling2D((2, 2)))
model.add(layers.Conv2D(128, (3, 3), activation='relu'))
model.add(layers.MaxPooling2D((2, 2)))
model.add(layers.Flatten())
model.add(layers.Dense(512, activation='relu'))
model.add(layers.Dense(1, activation='sigmoid'))
# see page 134 for how dimensions change with each layer

### Compilation step
#For the compilation step, you’ll go with the RMSprop optimizer, as usual
# Because you ended the network with a single sigmoid unit, you’ll use binary crossentropy as the loss
#   (as a reminder, check out table 4.1 for a cheatsheet on what loss function to use in various situations).
from keras import optimizers

model.compile(loss='binary_crossentropy', optimizer=optimizers.RMSprop(lr=1e-4), metrics=['acc'])

##### Data processing

# data should be formatted into appropriately preprocessed floating-point tensors before being fed into the network
# Currently, the data sits on a drive as JPEG files, so the steps for getting it into the network are roughly as follows:
#   1 Read the picture files.
#   2 Decode the JPEG content to RGB grids of pixels.
#   3 Convert these into floating-point tensors.
#   4 Rescale the pixel values (between 0 and 255) to the [0, 1] interval (neural networks prefer to deal with small input values)
# Keras has a module with image-processing helper tools, located at keras.preprocessing.image
# In particular, it contains the class ImageDataGenerator, which lets you quickly set up Python generators that can automatically turn image files on disk into batches of preprocessed tensors

### Using ImageDataGenerator to read images from directories from

from keras.preprocessing.image import ImageDataGenerator

train_datagen = ImageDataGenerator(rescale=1./255) #Rescales all images by 1/255
test_datagen = ImageDataGenerator(rescale=1./255)
train_generator = train_datagen.flow_from_directory(train_dir, target_size=(150, 150), batch_size=20, class_mode='binary')
#resizes all images to 150 × 150. Using binary_crossentropy loss, so you need binary labels for class mode
validation_generator = test_datagen.flow_from_directory(validation_dir, target_size=(150, 150), batch_size=20, class_mode='binary')
#pg 136 for details on what a generator is

### Fitting the model using a batch generator

history = model.fit_generator( train_generator, steps_per_epoch=100, epochs=30, validation_data=validation_generator, validation_steps=50)
# using the fit_generator method, the equivalent of fit for data generators like this one.
# GENERATOR
# It expects as its first argument a Python generator that will yield batches of inputs and targets indefinitely, like this one does
# STEPS PER EPOCH
# Because the data is being generated endlessly, the Keras model needs to know how many samples to draw from the generator before declaring an epoch over
# This is the role of the steps_per_epoch argument:
#   after having drawn steps_per_epoch batches from the generator
#   —that is, after having run for steps_per_epoch gradient descent steps—
#   the fitting process will go to the next epoch
# In this case, batches are 20 samples, so it will take 100 batches until you see your target of 2,000 samples.
# VALIDATION DATA
# When using fit_generator, you can pass a validation_data argument, much as
# with the fit method
# It’s important to note that this argument is allowed to be a data generator, but it could also be a tuple of Numpy arrays
# VALIDATION STEPS
# If you pass a generator as validation_data, then this generator is expected to yield batches of validation data endlessly
# thus you should also specify the validation_steps argument, which tells the process how many batches to draw from the validation

### Save model 
model.save('/home/bennouhan/cmeecoursework/project/learning/code/5_Computer_Vision/cats_and_dogs_small_1.h5')
# It’s good practice to always save your models after training.


### Displaying loss and accuracy to help refine

import matplotlib.pyplot as plt

# Sets variables from history
acc = history.history['acc']
val_acc = history.history['val_acc']
loss = history.history['loss']
val_loss = history.history['val_loss']
epochs = range(1, len(acc) + 1)

# Training and validation accuracy
plt.plot(epochs, acc, 'bo', label='Training acc')
plt.plot(epochs, val_acc, 'b', label='Validation acc')
plt.title('Training and validation accuracy')
plt.legend()
plt.figure()

# Training and validation loss
plt.plot(epochs, loss, 'bo', label='Training loss')
plt.plot(epochs, val_loss, 'b', label='Validation loss')
plt.title('Training and validation loss')
plt.legend()
plt.show()

# These plots are characteristic of overfitting.
# The training accuracy increases linearly over time, until it reaches nearly 100%, whereas the validation accuracy stalls at 70–72%.
# The validation loss reaches its minimum after only five epochs and then stalls, whereas the training loss keeps decreasing linearly until it reaches nearly 0.
# Because you have relatively few training samples (2,000), overfitting will be your number-one concern.
# You already know about a number of techniques that can help mitigate overfitting, such as dropout and weight decay (L2 regularization).
# We’re now going to work with a new one, specific to computer vision and used almost universally when processing images with deep-learning models: data augmentation.

### Data augmentation

# Data augmentation takes the approach of generating more training data from existing training samples, by augmenting the samples via a number of random transformations that yield believable-looking images
# The goal is that at training time, your model will never see the exact same picture twice
# This helps expose the model to more aspects of the data and generalize better
# In Keras, this can be done by configuring a number of random transformations to be performed on the images read by the ImageDataGenerator instance
# Let’s get started with an example.

datagen = ImageDataGenerator(rotation_range=40, width_shift_range=0.2, height_shift_range=0.2, shear_range=0.2, zoom_range=0.2, horizontal_flip=True, fill_mode='nearest')
# Just a few of the options available:
# - rotation_range is a value in degrees (0–180), a range within which to ran- domly rotate pictures.
# - width_shift and height_shift are ranges (as a fraction of total width or height) within which to randomly translate pictures vertically or horizontally.
# - shear_range is for randomly applying shearing transformations.
# - zoom_range is for randomly zooming inside pictures.
# - horizontal_flip is for randomly flipping half the images horizontally—rele- vant when there are no assumptions of horizontal asymmetry (for example, real-world pictures).
# - fill_mode is the strategy used for filling in newly created pixels, which can appear after a rotation or a width/height shift.

# see pgs 139 and 140 to see how to display some examples, not necessary right now though (expand on this and add code if computer vision is relevent to proj)



################################################################################
##### NEW MODEL BASED ON WHAT WE LEARNT ABOVE
################################################################################


### Defining a new convnet that includes dropout

model = models.Sequential()
model.add(layers.Conv2D(32, (3, 3), activation='relu', input_shape=(150, 150, 3)))
model.add(layers.MaxPooling2D((2, 2)))
model.add(layers.Conv2D(64, (3, 3), activation='relu'))
model.add(layers.MaxPooling2D((2, 2)))
model.add(layers.Conv2D(128, (3, 3), activation='relu'))
model.add(layers.MaxPooling2D((2, 2)))
model.add(layers.Conv2D(128, (3, 3), activation='relu'))
model.add(layers.MaxPooling2D((2, 2)))
model.add(layers.Flatten())
model.add(layers.Dropout(0.5))
model.add(layers.Dense(512, activation='relu'))
model.add(layers.Dense(1, activation='sigmoid'))
model.compile(loss='binary_crossentropy', optimizer=optimizers.RMSprop(lr=1e-4), metrics=['acc'])


### Training the convnet using data-augmentation generators and dropout
batch_size = 32
train_size = 2000
test_size = 1000
train_datagen = ImageDataGenerator( rescale=1./255, rotation_range=40, width_shift_range=0.2, height_shift_range=0.2, shear_range=0.2, zoom_range=0.2, horizontal_flip=True,)
test_datagen = ImageDataGenerator(rescale=1./255) #Note that the validation data shouldn’t be augmented!
train_generator = train_datagen.flow_from_directory(train_dir, target_size=(150, 150), batch_size=32, class_mode='binary')
validation_generator = test_datagen.flow_from_directory(
validation_dir, target_size=(150, 150), batch_size=32, class_mode='binary')
history = model.fit( train_generator, steps_per_epoch=train_size//batch_size, epochs=100, validation_data=validation_generator, validation_steps=test_size//batch_size)
# NOTE using model.fit rather than model.fit_generator - outdated
# NOTE got an error "tensorflow:Your input ran out of data; interrupting training"
#  to fix:
#    assigned batch_size = 32 at start and batch_size=batch_size later
#    assigned train_size and test_size above as apropriate
#    swapped steps_per_epoch=100 to =train_size//batch_size
#    swapped validation_steps=50 to =test_size//batch_size
#  see https://stackoverflow.com/questions/59864408/tensorflowyour-input-ran-out-of-data
#  Possible issue is with augmented data increasing samples to above 2000 and 1000 respectively, but above seems to work

### Saving the model
model.save('/home/bennouhan/cmeecoursework/project/learning/code/5_Computer_Vision/cats_and_dogs_small_2.h5')


### Displaying loss and accuracy to help refine

import matplotlib.pyplot as plt

# Sets variables from history
acc = history.history['acc']
val_acc = history.history['val_acc']
loss = history.history['loss']
val_loss = history.history['val_loss']
epochs = range(1, len(acc) + 1)

# Training and validation accuracy
plt.plot(epochs, acc, 'bo', label='Training acc')
plt.plot(epochs, val_acc, 'b', label='Validation acc')
plt.title('Training and validation accuracy')
plt.legend()
plt.figure()

# Training and validation loss
plt.plot(epochs, loss, 'bo', label='Training loss')
plt.plot(epochs, val_loss, 'b', label='Validation loss')
plt.title('Training and validation loss')
plt.legend()
plt.show()

# Thanks to data augmentation and dropout, you’re no longer overfitting: the training curves are closely tracking the validation curves
# You now reach an accuracy of 82%, a 15% relative improvement over the non-regularized model
# By using regularization techniques even further, and by tuning the network’s parameters (such as the number of filters per convolution layer, or the number of layers in the network), you may be able to get an even better accuracy, likely up to 86% or 87%
# But it would prove difficult to go any higher just by training your own convnet from scratch, because you have so little data to work with
# As a next step to improve your accuracy on this problem, you’ll have to use a pretrained model, which is the focus of the next two sections...