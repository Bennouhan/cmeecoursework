import tensorflow as tf
gpus = tf.config.experimental.list_physical_devices('GPU')
tf.config.experimental.set_memory_growth(gpus[0], True)


###### Callback options


# Here are some examples of ways you can use callbacks:
# 
# ? Model checkpointing—Saving the current weights of the model at different points during training.

# ? Early stopping—Interrupting training when the validation loss is no longer improving (and of course, saving the best model obtained during training).

# ? Dynamically adjusting the value of certain parameters during training—Such as the learning rate of the optimizer.

# ? Logging training and validation metrics during training, or visualizing the representa- tions learned by the model as they’re updated—The Keras progress bar that you’re familiar with is a callback!


# The keras.callbacks module includes a number of built-in callbacks (this is not an exhaustive list):
# keras.callbacks.ModelCheckpoint
# keras.callbacks.EarlyStopping
# keras.callbacks.LearningRateScheduler
# keras.callbacks.ReduceLROnPlateau
# keras.callbacks.CSVLogger

# Let’s review a few of them to give you an idea of how to use them


### THE MODELCHECKPOINT AND EARLYSTOPPING CALLBACKS

# You can use the EarlyStopping callback to interrupt training once a target metric being monitored has stopped improving for a fixed number of epochs.
# For instance, this callback allows you to interrupt training as soon as you start overfitting, thus avoiding having to retrain your model for a smaller number of epochs.
# This callback is typically used in combination with ModelCheckpoint, which lets you continually save the model during training
# (and, optionally, save only the current best model so far: the version of the model that achieved the best performance at the end of an epoch):

import keras

# Callbacks are passed to the model via the callbacks argument in fit, which takes a list of callbacks. You can pass any number of callbacks.
callbacks_list = [
    keras.callbacks.EarlyStopping( # Interrupts training when improvement stops
        monitor='acc', # Monitors the model’s validation accuracy
        patience=1,), # Interrupts training when accuracy has stopped improving for more than one epoch (that is, two epochs)
    keras.callbacks.ModelCheckpoint( # Saves the current weights after every epoch
        filepath='my_model.h5', # Path to the destination model file
        monitor='val_loss',
        save_best_only=True,)
] #     These two arguments mean you won’t overwrite the model file unless val_loss has improved, which allows you to keep the best model seen during training.

# (model needs to be assembled, there is no model so this wont run)

# You monitor accuracy, so it should be part of the model’s metrics.
model.compile(optimizer='rmsprop', loss='binary_crossentropy', metrics=['acc'])

# Note that because the callback will monitor validation loss and validation accuracy, you need to pass validation_data to the call to fit.
model.fit(x, y,
            epochs=10,
            batch_size=32,
            callbacks=callbacks_list,
            validation_data=(x_val, y_val))



### THE REDUCELRONPLATEAU CALLBACK

# You can use this callback to reduce the learning rate when the validation loss has stopped improving.
# Reducing or increasing the learning rate in case of a loss plateau is is an effective strategy to get out of local minima during training.
# The following example uses the ReduceLROnPlateau callback

callbacks_list = [
    keras.callbacks.ReduceLROnPlateau(
        monitor='val_loss', # Monitors the model's validation loss
        factor=0.1, # Divides the learning rate by 10 when triggered
        patience=10,)] # The callback is triggered after the validation loss has stopped improving for 10 epochs.

# Because the callback will monitor the validation loss, you need to pass validation_data to the call to fit.
model.fit(x, y,
        epochs=10,
        batch_size=32,
        callbacks=callbacks_list,
        validation_data=(x_val, y_val))


### Writing your own Callback

# If you need to take a specific action during training that isn’t covered by one of the built-in callbacks, you can write your own callback.
# Callbacks are implemented by subclassing the class keras.callbacks.Callback. 
# You can then implement any number of the following transparently named methods, which are called at various points during training:

on_epoch_begin #Called at the start of every epoch 
on_epoch_end #Called at the end of every epoch

on_batch_begin #Called right before processing each batch 
on_batch_end #Called right after processing each batch

on_train_begin #Called at the start of training 
on_train_end #Called at the end of training


# These methods all are called with a logs argument, which is a dictionary containing information about the previous batch, epoch, or training run: training and validation metrics, and so on.
# Additionally, the callback has access to the following attributes:

self.model #The model instance from which the callback is being called
self.validation_data #The value of what was passed to fit as validation data

# Here’s a simple example of a custom callback that saves to disk (as Numpy arrays) the activations of every layer of the model at the end of every epoch, computed on the first sample of the validation set:

import keras
import numpy as np

class ActivationLogger(keras.callbacks.Callback):
    def set_model(self, model):
        self.model = model #Called by the parent model before training, to inform the callback of what model will be calling it
        layer_outputs = [layer.output for layer in model.layers]
        self.activations_model = keras.models.Model(model.input, layer_outputs)
        # Model instance that returns the activations of every layer
    def on_epoch_end(self, epoch, logs=None):
        if self.validation_data is None:
            raise RuntimeError('Requires validation_data.')
    # Obtains the first input sample of the validation data
        validation_sample = self.validation_data[0][0:1]
        activations = self.activations_model.predict(validation_sample)
        # Saves arrays to disk
        f = open('activations_at_epoch_' + str(epoch) + '.npz', 'w')
        np.savez(f, activations)
        f.close()
        # NB above 5 lines of code up to validation_sample) were less indented by 1 in the book
    # ie here, but don't think that's right (but could be)

# This is all you need to know about callbacks—the rest is technical details, which you can easily look up.
# Now you’re equipped to perform any sort of logging or preprogrammed intervention on a Keras model during training.

