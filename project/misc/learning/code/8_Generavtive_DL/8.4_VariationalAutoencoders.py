import tensorflow as tf
gpus = tf.config.experimental.list_physical_devices('GPU')
tf.config.experimental.set_memory_growth(gpus[0], True)

##### Variational autoencoders in Keras

# In this section and the next, we’ll review some high-level concepts pertaining to image generation, alongside implementations details relative to the two main techniques in this domain:
# variational autoencoders (VAEs)
# and generative adversarial networks (GANs)



### VAE encoder network

# The following listing shows the encoder network you’ll use, mapping images to the parameters of a probability distribution over the latent space.
# It’s a simple convnet that maps the input image x to two vectors, z_mean and z_log_var

import keras
from keras import layers
from keras import backend as K
from keras.models import Model
import numpy as np

img_shape = (28, 28, 1)
batch_size = 16
latent_dim = 2 #Dimensionality of the latent space: a 2D plane

input_img = keras.Input(shape=img_shape)

x = layers.Conv2D(32, 3, padding='same', activation='relu')(input_img)
x = layers.Conv2D(64, 3, padding='same', activation='relu', strides=(2, 2))(x)
x = layers.Conv2D(64, 3, padding='same', activation='relu')(x)
x = layers.Conv2D(64, 3, padding='same', activation='relu')(x) 
shape_before_flattening = K.int_shape(x)

x = layers.Flatten()(x)
x = layers.Dense(32, activation='relu')(x)

# The input image ends up being encoded into these two parameters
z_mean = layers.Dense(latent_dim)(x)
z_log_var = layers.Dense(latent_dim)(x)



### Latent-space-sampling function

# Next is the code for using z_mean and z_log_var, the parameters of the statistical distribution assumed to have produced input_img, to generate a latent space point z.
# Here, you wrap some arbitrary code (built on top of Keras backend primitives) into a Lambda layer.
# In Keras, everything needs to be a layer, so code that isn’t part of a built-in layer should be wrapped in a Lambda (or in a custom layer).

def sampling(args):
    z_mean, z_log_var = args
    epsilon = K.random_normal(shape=(K.shape(z_mean)[0], latent_dim),
                              mean=0., stddev=1.)
    return z_mean + K.exp(z_log_var) * epsilon

z = layers.Lambda(sampling)([z_mean, z_log_var])



### VAE decoder network, mapping latent space points to images decoder_input

# The following listing shows the decoder implementation.
# You reshape the vector z to the dimensions of an image and then use a few convolution layers to obtain a final image output that has the same dimensions as the original input_img.

# Input where you’ll feed z
decoder_input = layers.Input(K.int_shape(z)[1:])

# Upsamples the input
x = layers.Dense(np.prod(shape_before_flattening[1:]),
                 activation='relu')(decoder_input)

# Reshapes z into a feature map of the same shape as the feature map just before the last Flatten layer in the encoder model
x = layers.Reshape(shape_before_flattening[1:])(x)

### Uses a Conv2DTranspose layer and Conv2D layer to decode z into a feature map the same size as the original image input
x = layers.Conv2DTranspose(32, 3,
                           padding='same',
                           activation='relu',
                           strides=(2, 2))(x)
x = layers.Conv2D(1, 3,
                  padding='same',
                  activation='sigmoid')(x)

# Instantiates the decoder model, turning “decoder_input” into the decoded image
decoder = Model(decoder_input, x)

# Applies it to z to recover the decoded z
z_decoded = decoder(z)



### Custom layer used to compute the VAE loss class

# The dual loss of a VAE doesn’t fit the traditional expectation of a sample-wise function of the form loss(input, target).
# Thus, you’ll set up the loss by writing a custom layer that internally uses the built-in add_loss layer method to create an arbitrary loss.

class CustomVariationalLayer(keras.layers.Layer):
    def vae_loss(self, x, z_decoded):
        x = K.flatten(x)
        z_decoded = K.flatten(z_decoded)
        xent_loss = keras.metrics.binary_crossentropy(x, z_decoded)
        kl_loss = -5e-4 * K.mean(
            1 + z_log_var - K.square(z_mean) - K.exp(z_log_var), axis=-1)
        return K.mean(xent_loss + kl_loss)
    # You implement custom layers by writing a call method.
    def call(self, inputs):
        x = inputs[0]
        z_decoded = inputs[1]
        loss = self.vae_loss(x, z_decoded)
        self.add_loss(loss, inputs=inputs)
        return x #not used but something must be returned

# Calls the custom layer on the input and the decoded output to obtain the final model output
y = CustomVariationalLayer()([input_img, z_decoded])#gives warning not sure if significant


### Training the VAE

# Finally, you’re ready to instantiate and train the model.
# Because the loss is taken care of in the custom layer, you don’t specify an external loss at compile time (loss=None), which in turn means you won’t pass target data during training (as you can see, you only pass x_train to the model in fit).

from keras.datasets import mnist

vae = Model(input_img, y)
vae.compile(optimizer='rmsprop', loss=None)
vae.summary()

(x_train, _), (x_test, y_test) = mnist.load_data()

x_train = x_train.astype('float32') / 255.
x_train = x_train.reshape(x_train.shape + (1,))
x_test = x_test.astype('float32') / 255.
x_test = x_test.reshape(x_test.shape + (1,))

vae.fit(x=x_train, y=None,
        shuffle=True,
        epochs=10,
        batch_size=batch_size,
        validation_data=(x_test, None))
# Gives following error: TypeError: Tensors are unhashable. (KerasTensor(type_spec=TensorSpec(shape=(), dtype=tf.float32, name=None), name='tf.math.reduce_sum_2/Sum:0', description="created by layer 'tf.math.reduce_sum_2'"))Instead, use tensor.ref() as the key.


### Sampling a grid of points from the 2D latent space and decoding them to images

# Once such a model is trained — on MNIST, in this case — you can use the decoder network to turn arbitrary latent space vectors into images.

import matplotlib.pyplot as plt
from scipy.stats import norm

n=15 # You'll display a grid of 15x15 digits (255 total)
digit_size = 28
figure = np.zeros((digit_size * n, digit_size * n))
### Transforms linearly-spaced coordinates using the SciPy ppf function to produce values of the latent variable z
# (because the prior of the latent space is Gaussian)
grid_x = norm.ppf(np.linspace(0.05, 0.95, n))
grid_y = norm.ppf(np.linspace(0.05, 0.95, n))

for i, yi in enumerate(grid_x):
    for j, xi in enumerate(grid_y):
        z_sample = np.array([[xi, yi]])
        # Repeats z multiple times to form a complete batch
        z_sample = np.tile(z_sample, batch_size).reshape(batch_size, 2)
        # Decodes the batch into digit images
        x_decoded = decoder.predict(z_sample, batch_size=batch_size)
        ### Reshapes the first digit in the batch from 28 × 28 × 1 to 28 × 28
        digit = x_decoded[0].reshape(digit_size, digit_size)
        figure[i * digit_size: (i + 1) * digit_size,
               j * digit_size: (j + 1) * digit_size] = digit

plt.figure(figsize=(10, 10))
plt.imshow(figure, cmap='Greys_r')
plt.show()
# still creates something in spite of error


### Outcome

# The grid of sampled digits (see figure 8.14 pf 303) shows a completely continuous distribution of the different digit classes, with one digit morphing into another as you follow a path through latent space.
# Specific directions in this space have a meaning:
#     for example, there’s a direction for “four-ness,” “one-ness,” and so on.

# In the next section, we’ll cover in detail the other major tool for generating artificial images: generative adversarial networks (GANs).
