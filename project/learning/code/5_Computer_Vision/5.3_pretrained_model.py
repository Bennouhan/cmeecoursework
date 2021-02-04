### NB needed for conv network!!!
# (https://github.com/tensorflow/tensorflow/issues/24496)
import tensorflow as tf
gpus = tf.config.experimental.list_physical_devices('GPU')
tf.config.experimental.set_memory_growth(gpus[0], True)



### Instantiating the VGG16 convolutional base
from keras.applications import VGG16

conv_base = VGG16(weights='imagenet',
                  include_top=False,
                  input_shape=(150, 150, 3))
# weights - specifies the weight checkpoint from which to initialize the model
# include_top - refers to including (or not) the densely connected classifier on top of the network. By default, this densely connected classifier corresponds to the 1,000 classes from ImageNet. Because you intend to use your own densely connected classifier (with only two classes: cat and dog), you don’t need to include it.
# input_shape - is the shape of the image tensors that you’ll feed to the network. This argument is purely optional: if you don’t pass it, the network will be able to process inputs of any size

# see pg 146 for VGG16 architecture diagram
# final feature map has shape (4, 4, 512). That’s the feature on top of which you’ll stick a densely connected classifier

### Options for how to use the pre-trained model:

# Option 1
# Running the convolutional base over your dataset, recording its output to a Numpy array on disk, and then using this data as input to a standalone, densely connected classifier similar to those you saw in part 1 of this book.
# This solution is fast and cheap to run, because it only requires running the convolutional base once for every input image, and the convolutional base is by far the most expensive part of the pipeline.
# But for the same reason, this technique won’t allow you to use data augmentation.

# Option 2
# Extending the model you have (conv_base) by adding Dense layers on top, and running the whole thing end to end on the input data.
# This will allow you to use data augmentation, because every input image goes through the convolutional base every time it’s seen by the model.
# But for the same reason, this technique is far more expensive than the first.


##### FAST FEATURE EXTRACTION WITHOUT DATA AUGMENTATION (Option 1)
# You’ll start by running instances of the previously introduced ImageDataGenerator to extract images as Numpy arrays as well as their labels
# You’ll extract features from these images by calling the predict method of the conv_base model.

### Extracting features using the pretrained convolutional base

import os
import numpy as np
from keras.preprocessing.image import ImageDataGenerator
import keras.backend as K ### for debugging with K.clear_session() and no predic


base_dir = '/home/bennouhan/cmeecoursework/project/learning/data/Chap5'
train_dir = os.path.join(base_dir, 'train')
validation_dir = os.path.join(base_dir, 'validation')
test_dir = os.path.join(base_dir, 'test')

datagen = ImageDataGenerator(rescale=1./255)
batch_size = 2 #was 20, changing to 1 in inteslf doesnt help debug but see below

def extract_features(directory, sample_count):
    features = np.zeros(shape=(sample_count, 4, 4, 512))
    labels = np.zeros(shape=(sample_count))
    generator = datagen.flow_from_directory(
        directory,
        target_size=(150, 150),
        batch_size=batch_size,
        class_mode='binary')
    i=0
    for inputs_batch, labels_batch in generator:
        features_batch = conv_base.predict_on_batch(inputs_batch)
        features[i * batch_size : (i + 1) * batch_size] = features_batch
        labels[i * batch_size : (i + 1) * batch_size] = labels_batch
        i+=1
        K.clear_session() ###adding this, removing predict from conv_base.predict, and batch to 1 or 2 didnt get rid of memory warning but allowed it to complete
        if i * batch_size >= sample_count:
            break
    return features, labels


train_features, train_labels = extract_features(train_dir, 2000)
# only above gives memory error with batch=2, not two below - 2000 vs 1000?
validation_features, validation_labels = extract_features(validation_dir, 1000) 
test_features, test_labels = extract_features(test_dir, 1000)
#gave an error but then didnt, so run twice if gives an issue
# but after the first time, gave a shit tonne of issues, still not solved, see https://github.com/keras-team/keras/issues/13118
# here suggests having predict in the loop is the issue.
# NEED TO RESTART PYTHON AFTER EACH USE (and use nvidia-smi and sudo kill -9 <PID> to check for and kill python processes)
# nvidia-smi keeps showing 983mb for python process; limited to that in some way? also says type "C", others are type "G"; only working with CPU?

# The extracted features are currently of shape (samples, 4, 4, 512).
# You’ll feed them to a densely connected classifier, so first you must flatten them to (samples, 8192):

train_features = np.reshape(train_features, (2000, 4*4* 512)) 
validation_features = np.reshape(validation_features, (1000, 4*4* 512)) 
test_features = np.reshape(test_features, (1000, 4*4* 512))

# At this point, you can define your densely connected classifier (note the use of drop- out for regularization) and train it on the data and labels that you just recorded.

### Defining and training the densely connected classifier

from keras import models
from keras import layers
from keras import optimizers

model = models.Sequential()
model.add(layers.Dense(256, activation='relu', input_dim=4 * 4 * 512))
model.add(layers.Dropout(0.5))
model.add(layers.Dense(1, activation='sigmoid'))
model.compile(optimizer=optimizers.RMSprop(lr=2e-5),
              loss='binary_crossentropy',
              metrics=['acc'])

history = model.fit(train_features, train_labels,
                    epochs=30,
                    batch_size=20,
                    validation_data=(validation_features, validation_labels))
# Training is very fast, because you only have to deal with two Dense layers—an epoch takes less than one second even on CPU

### Plotting the results

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

# You reach a validation accuracy of about 90%—much better than you achieved in the previous section with the small model trained from scratch.
# But the plots also indicate that you’re overfitting almost from the start—despite using dropout with a fairly large rate.
# That’s because this technique doesn’t use data augmentation, which is essential for preventing overfitting with small image datasets.











################################################################################
##### FEATURE EXTRACTION WITH DATA AUGMENTATION (Option 2)

# (RECAP) Option 2
# Extending the model you have (conv_base) by adding Dense layers on top, and running the whole thing end to end on the input data.
# This will allow you to use data augmentation, because every input image goes through the convolutional base every time it’s seen by the model.
# But for the same reason, this technique is far more expensive than the first.

# NOTE This technique is so expensive that you should only attempt it if you have access to a GPU—it’s absolutely intractable on CPU.
# If you can’t run your code on GPU, then the previous technique is the way to go.

################################################################################
### (Repeated from earlier - assume it's necessary)
################################################################################
# NB cant get past error, even when fixing the above one
# But book says may not be able to work... (should on a GPU tho, and it worked once before this fucking mess started)
# Leaving for now, hopefully will not need to be fixed in the future

import tensorflow as tf
gpus = tf.config.experimental.list_physical_devices('GPU')
tf.config.experimental.set_memory_growth(gpus[0], True)


### Instantiating the VGG16 convolutional base
from keras.applications import VGG16

conv_base = VGG16(weights='imagenet',
                  include_top=False,
                  input_shape=(150, 150, 3))

import os
import numpy as np
from keras.preprocessing.image import ImageDataGenerator
import keras.backend as K ### for debugging with K.clear_session() and no predic


base_dir = '/home/bennouhan/cmeecoursework/project/learning/data/Chap5'
train_dir = os.path.join(base_dir, 'train')
validation_dir = os.path.join(base_dir, 'validation')
test_dir = os.path.join(base_dir, 'test')

datagen = ImageDataGenerator(rescale=1./255)
batch_size = 2 #was 20, changing to 1 in inteslf doesnt help debug but see below

def extract_features(directory, sample_count):
    features = np.zeros(shape=(sample_count, 4, 4, 512))
    labels = np.zeros(shape=(sample_count))
    generator = datagen.flow_from_directory(
        directory,
        target_size=(150, 150),
        batch_size=batch_size,
        class_mode='binary')
    i=0
    for inputs_batch, labels_batch in generator:
        features_batch = conv_base.predict_on_batch(inputs_batch)
        features[i * batch_size : (i + 1) * batch_size] = features_batch
        labels[i * batch_size : (i + 1) * batch_size] = labels_batch
        i+=1
        K.clear_session() ###adding this, removing predict from conv_base.predict, and batch to 1 or 2 didnt get rid of memory warning but allowed it to complete
        if i * batch_size >= sample_count:
            break
    return features, labels


train_features, train_labels = extract_features(train_dir, 2000)
# only above gives memory error with batch=2, not two below - 2000 vs 1000?
validation_features, validation_labels = extract_features(validation_dir, 1000) 
test_features, test_labels = extract_features(test_dir, 1000)
#gave an error but then didnt, so run twice if gives an issue
# but after the first time, gave a shit tonne of issues, still not solved, see https://github.com/keras-team/keras/issues/13118
# here suggests having predict in the loop is the issue.
# NEED TO RESTART PYTHON AFTER EACH USE (and use nvidia-smi and sudo kill -9 <PID> to check for and kill python processes)
# nvidia-smi keeps showing 983mb for python process; limited to that in some way?

# The extracted features are currently of shape (samples, 4, 4, 512).
# You’ll feed them to a densely connected classifier, so first you must flatten them to (samples, 8192):

train_features = np.reshape(train_features, (2000, 4*4* 512)) 
validation_features = np.reshape(validation_features, (1000, 4*4* 512)) 
test_features = np.reshape(test_features, (1000, 4*4* 512))



################################################################################

### Adding a densely connected classifier on top of the convolutional base
# Because models behave just like layers, you can add a model (like conv_base) to a Sequential model just like you would add a layer

from keras import models
from keras import layers
model = models.Sequential()
model.add(conv_base)
model.add(layers.Flatten())
model.add(layers.Dense(256, activation='relu'))
model.add(layers.Dense(1, activation='sigmoid'))
# see page 150 for architecture diagram. had 14,714,688 parameters, added 2,000,000 with the first dense layer above; very large!


### Freezing the network

# Before you compile and train the model, it’s very important to freeze the convolutional base
# Freezing a layer or set of layers means preventing their weights from being updated during training
# If you don’t do this, then the representations that were previously learned by the convolutional base will be modified during training
# Because the Dense layers on top are randomly initialized, very large weight updates would be propagated through the network, effectively destroying the representations previously learned.
# In Keras, you freeze a network by setting its trainable attribute to False:

print('This is the number of trainable weights ' 'before freezing the conv base:', len(model.trainable_weights))
conv_base.trainable = False
print('This is the number of trainable weights ' 'after freezing the conv base:', len(model.trainable_weights))

# With this setup, only the weights from the two Dense layers that you added will be trained
# That’s a total of four weight tensors: two per layer (the main weight matrix and the bias vector)
# Note that in order for these changes to take effect, you must first compile the model
# If you ever modify weight trainability after compilation, you should then recompile the model, or these changes will be ignored



### Training the model end to end with a frozen convolutional base
# Now you can start training your model, with the same data-augmentation configu- ration that you used in the previous example.

from keras.preprocessing.image import ImageDataGenerator
from keras import optimizers

train_datagen = ImageDataGenerator( rescale=1./255,
                                    rotation_range=40,
                                    width_shift_range=0.2,
                                    height_shift_range=0.2,
                                    shear_range=0.2,
                                    zoom_range=0.2,
                                    horizontal_flip=True,
                                    fill_mode='nearest')

# Note that the validation data shouldn’t be augmented!
test_datagen = ImageDataGenerator(rescale=1./255)

train_generator = train_datagen.flow_from_directory(
            train_dir, #target directory
            target_size=(150, 150), #Resizes all images to 150 × 150
            batch_size=20,
            class_mode='binary') #since binary_crossentropy was used

validation_generator = test_datagen.flow_from_directory(
            validation_dir,
            target_size=(150, 150),
            batch_size=20,
            class_mode='binary')

model.compile(loss='binary_crossentropy',
              optimizer=optimizers.RMSprop(lr=2e-5),
              metrics=['acc'])


# DEBUG ATTEMPT - NOT IN BOOK - trying to save model so I can kill processes and then fit it with a blank memory slate didnt work, same error

history = model.fit(train_generator,
                              steps_per_epoch=100,
                              epochs=30,
                              validation_data=validation_generator, 
                              validation_steps=50)
# swapped to just model.fit, _generator version is redundant and to-be deleted

### Plotting the results

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














################################################################################
##### Fine-tuning (Next Step)
### NB - code hasnt been tested as the above doesnt work 

# Another widely used technique for model reuse, complementary to feature extraction, is fine-tuning (see figure 5.19).
# Fine-tuning consists of unfreezing a few of the top layers of a frozen model base used for feature extraction, and jointly training both the newly added part of the model (in this case, the fully connected classifier) and these top layers.
# This is called fine-tuning because it slightly adjusts the more abstract representations of the model being reused, in order to make them more rele- vant for the problem at hand.

# it’s necessary to freeze the convolution base of VGG16 in order to be able to train a randomly initialized classifier on top.
# For the same reason, it’s only possible to fine-tune the top layers of the convolutional base once the classifier on top has already been trained.
# If the classifier isn’t already trained, then the error signal propagating through the network during training will be too large, and the representations previously learned by the layers being fine-tuned will be destroyed
# Thus the steps for fine-tuning a network are as follow:
#   1 Add your custom network on top of an already-trained base network.
#   2 Freeze the base network.
#   3 Train the part you added.
#   4 Unfreeze some layers in the base network.
#   5 Jointly train both these layers and the part you added.
# You already completed the first three steps when doing feature extraction. 
# Let’s proceed with step 4: you’ll unfreeze your conv_base and then freeze individual layers inside it


### Freezing all layers up to a specific one

# You’ll fine-tune the last three convolutional layers, which means all layers up to block4_pool should be frozen, and the layers block5_conv1, block5_conv2, and block5_conv3 should be trainable.
# Why not fine-tune more layers? Why not fine-tune the entire convolutional base?
# You could. But you need to consider the following: 
#   - Earlier layers in the convolutional base encode more-generic, reusable features, whereas layers higher up encode more-specialized features. It’s more useful to fine-tune the more specialized features, because these are the ones that need to be repurposed on your new problem. There would be fast-decreasing returns in fine-tuning lower layers.
#   - The more parameters you’re training, the more you’re at risk of overfitting. The convolutional base has 15 million parameters, so it would be risky to attempt to train it on your small dataset.
# Thus, in this situation, it’s a good strategy to fine-tune only the top two or three layers in the convolutional base.
# Let’s set this up, starting from where you left off in the pre- vious example

conv_base.trainable = True

set_trainable = False
for layer in conv_base.layers:
    if layer.name == 'block5_conv1':
        set_trainable = True
    if set_trainable:
        layer.trainable = True
    else: layer.trainable = False


### Fine-tuning the model

# Now you can begin fine-tuning the network.
# You’ll do this with the RMSProp optimizer, using a very low learning rate.
# The reason for using a low learning rate is that you want to limit the magnitude of the modifications you make to the representations of the three layers you’re fine-tuning.
# Updates that are too large may harm these rep- resentations.

model.compile(loss='binary_crossentropy',
              optimizer=optimizers.RMSprop(lr=1e-5),
              metrics=['acc'])

history = model.fit_generator( train_generator,
                               steps_per_epoch=100,
                               epochs=100,
                               validation_data=validation_generator,
                               validation_steps=50)


### Visualise results (exact same code as before)

# These curves look noisy.
# To make them more readable, you can smooth them by replacing every loss and accuracy with exponential moving averages of these quantities
# Here’s a trivial utility function to do this



def smooth_curve(points, factor=0.8):
    smoothed_points = []
    for point in points:
        if smoothed_points:
            previous = smoothed_points[-1]
            smoothed_points.append(previous * factor + point * (1 - factor))
        else:
            smoothed_points.append(point)
    return smoothed_points


plt.plot(epochs, smooth_curve(acc), 'bo', label='Smoothed training acc')
plt.plot(epochs, smooth_curve(val_acc), 'b', label='Smoothed validation acc')
plt.title('Training and validation accuracy')
plt.legend()

plt.figure()

plt.plot(epochs, smooth_curve(loss), 'bo', label='Smoothed training loss')
plt.plot(epochs, smooth_curve(val_loss), 'b', label='Smoothed validation loss')
plt.title('Training and validation loss')
plt.legend()

plt.show()


# The validation accuracy curve look much cleaner.
# You’re seeing a nice 1% absolute improvement in accuracy, from about 96% to above 97%.
# Note that the loss curve doesn’t show any real improvement (in fact, it’s deteriorating).
# You may wonder, how could accuracy stay stable or improve if the loss isn’t decreasing?
# The answer is simple:
#     what you display is an average of pointwise loss values;
#     but what matters for accuracy is the distribution of the loss values, not their average,
#     because accuracy is the result of a binary thresholding of the class probability predicted by the model.
#     The model may still be improving even if this isn’t reflected in the average loss.

### You can now finally evaluate this model on the test data:

test_generator = test_datagen.flow_from_directory( test_dir,
                                                   target_size=(150, 150),
                                                   batch_size=20,
                                                   class_mode='binary')

test_loss, test_acc = model.evaluate_generator(test_generator, steps=50)
print('test acc:', test_acc)

# Here you get a test accuracy of 97%.
# In the original Kaggle competition around this dataset, this would have been one of the top results.
# But using modern deep-learning techniques, you managed to reach this result using only a small fraction of the training data available (about 10%).
# There is a huge difference between being able to train on 20,000 samples compared to 2,000 samples!









################################################################################
#debugging tests, from https://github.com/keras-team/keras/issues/13118

import tensorflow as tf
gpus = tf.config.experimental.list_physical_devices('GPU')
tf.config.experimental.set_memory_growth(gpus[0], True)




import numpy as np
import keras
import keras.backend as K

X = np.random.rand(1, 224, 224, 3)

while True:
    model = keras.applications.mobilenet_v2.MobileNetV2()
    y = model.predict(X)[0]
    K.clear_session()

# gives: WARNING:tensorflow:11 out of the last 11 calls to <function Model.make_predict_function.<locals>.predict_function at 0x7f8ad8436790> triggered tf.function retracing. Tracing is expensive and the excessive number of tracings could be due to (1) creating @tf.function repeatedly in a loop, (2) passing tensors with different shapes, (3) passing Python objects instead of tensors. For (1), please define your @tf.function outside of the loop. For (2), @tf.function has experimental_relax_shapes=True option that relaxes argument shapes that can avoid unnecessary retracing. For (3), please refer to https://www.tensorflow.org/guide/function#controlling_retracing and https://www.tensorflow.org/api_docs/python/tf/function for  more details.

### BUT model( rather than model.predict( doesnt 


import numpy as np
import keras
import keras.backend as K

X = np.random.rand(1, 224, 224, 3)

while True:
    model = keras.applications.mobilenet_v2.MobileNetV2()
    y = model(X)[0]
    K.clear_session()



# so try  removing predict, and using k.clear_session() (requires above import)
#   also to try: model.predict_on_batch
# Uninstalling TF 2.3, installing TF-nightly 2.4 and reinstalling TF-2.3 seems to have fixed the issue thinking.