### NB needed for conv network!!!
import tensorflow as tf
from tensorflow.compat.v1 import InteractiveSession
from tensorflow.compat.v1 import ConfigProto
config = ConfigProto()
config.gpu_options.allow_growth = True
session = InteractiveSession(config=config)

# Above is needed for convnets to work, such as below. 
# see https://github.com/tensorflow/tensorflow/issues/24496

#############################################################

from keras import layers
from keras import models

model = models.Sequential()
model.add(layers.Conv2D(32, (3, 3), activation='relu', input_shape=(28, 28, 1)))
model.add(layers.MaxPooling2D((2, 2)))
model.add(layers.Conv2D(64, (3, 3), activation='relu'))#(3,3) is the size of the patches extracted from the inputs being 3x3 pixels; 32 filters
model.add(layers.MaxPooling2D((2, 2))) #2x2 windows, stride 2
model.add(layers.Conv2D(64, (3, 3), activation='relu')) #depth (no. filters computed) ends up as 64
model.add(layers.Flatten())
model.add(layers.Dense(64, activation='relu'))
model.add(layers.Dense(10, activation='softmax'))


from keras.datasets import mnist
from keras.utils import to_categorical
(train_images, train_labels), (test_images, test_labels) = mnist.load_data()
train_images = train_images.reshape((60000, 28, 28, 1))
train_images = train_images.astype('float32') / 255
test_images = test_images.reshape((10000, 28, 28, 1))
test_images = test_images.astype('float32') / 255
train_labels = to_categorical(train_labels)
test_labels = to_categorical(test_labels)
model.compile(optimizer='rmsprop', loss='categorical_crossentropy', metrics=['accuracy'])
model.fit(train_images, train_labels, epochs=5, batch_size=64)

#Let’s evaluate the model on the test data:
test_loss, test_acc = model.evaluate(test_images, test_labels)
test_acc