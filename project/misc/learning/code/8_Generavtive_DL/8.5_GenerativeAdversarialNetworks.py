import tensorflow as tf
gpus = tf.config.experimental.list_physical_devices('GPU')
tf.config.experimental.set_memory_growth(gpus[0], True)

##### generative adversarial networks in Keras

# In this section and the next, we’ll review some high-level concepts pertaining to image generation, alongside implementations details relative to the two main techniques in this domain:
# variational autoencoders (VAEs)
# and generative adversarial networks (GANs)



### A schematic GAN implementation

# In this section, we’ll explain how to implement a GAN in Keras, in its barest form
# Because GANs are advanced, diving deeply into the technical details would be out of scope for this book.
# The specific implementation is a deep convolutional GAN (DCGAN): a GAN where the generator and discriminator are deep convnets.
# In particular, it uses a Conv2DTranspose layer for image upsampling in the generator.
# You’ll train the GAN on images from CIFAR10, a dataset of 50,000 32 × 32 RGB images belonging to 10 classes (5,000 images per class).
# To make things easier, you’ll only use images belonging to the class “frog.”
# Schematically, the GAN looks like this:

# 1 A generator network maps vectors of shape (latent_dim,) to images of shape (32, 32, 3).
# 2 A discriminator network maps images of shape (32, 32, 3) to a binary score estimating the probability that the image is real.
# 3 A gan network chains the generator and the discriminator together: gan(x) = discriminator(generator(x)). Thus this gan network maps latent space vec- tors to the discriminator’s assessment of the realism of these latent vectors as decoded by the generator.
# 4 You train the discriminator using examples of real and fake images along with “real”/“fake” labels, just as you train any regular image-classification model.
# 5 To train the generator, you use the gradients of the generator’s weights with regard to the loss of the gan model. This means, at every step, you move the weights of the generator in a direction that makes the discriminator more likely to classify as “real” the images decoded by the generator. In other words, you train the generator to fool the discriminator.




### A bag of tricks

# The process of training GANs and tuning GAN implementations is notoriously difficult.
# There are a number of known tricks you should keep in mind.
# Like most things in deep learning, it’s more alchemy than science:
#   these tricks are heuristics, not theory-backed guidelines.
# They’re supported by a level of intuitive understanding of the phenomenon at hand, and they’re known to work well empirically, although not necessarily in every context.
# Here are a few of the tricks used in the implementation of the GAN generator and discriminator in this section.
# It isn’t an exhaustive list of GAN-related tips; you’ll find many more across the GAN literature:

# -  We use tanh as the last activation in the generator, instead of sigmoid, which is more commonly found in other types of models.
# -  We sample points from the latent space using a normal distribution (Gaussian distribution), not a uniform distribution.
# -  Stochasticity is good to induce robustness. Because GAN training results in a dynamic equilibrium, GANs are likely to get stuck in all sorts of ways. Introducing randomness during training helps prevent this. We introduce randomness in two ways: by using dropout in the discriminator and by adding random noise to the labels for the discriminator.
# -  Sparse gradients can hinder GAN training. In deep learning, sparsity is often a desirable property, but not in GANs. Two things can induce gradient sparsity: max pooling operations and ReLU activations. Instead of max pooling, we recommend using strided convolutions for downsampling, and we recommend using a LeakyReLU layer instead of a ReLU activation. It’s similar to ReLU, but it relaxes sparsity constraints by allowing small negative activation values.
# -  In generated images, it’s common to see checkerboard artifacts caused by unequal coverage of the pixel space in the generator (see figure 8.17 pg 308). To fix this, we use a kernel size that’s divisible by the stride size whenever we use a strided Conv2DTranpose or Conv2D in both the generator and the discriminator.
# Below is an example of how one would carry one out in Keras.


### GAN generator network

# First, let’s develop a generator model that turns a vector (from the latent space — during training it will be sampled at random) into a candidate image.
# One of the many issues that commonly arise with GANs is that the generator gets stuck with generated images that look like noise.
# A possible solution is to use dropout on both the discriminator & generator.

import keras
from keras import layers
import numpy as np

latent_dim = 32
height = 32
width = 32
channels = 3

generator_input = keras.Input(shape=(latent_dim,))

### Transforms the input into a 16x16 128-channel feature map
x = layers.Dense(128 * 16 * 16)(generator_input)
x = layers.LeakyReLU()(x)
x = layers.Reshape((16, 16, 128))(x)

x = layers.Conv2D(256, 5, padding='same')(x)
x = layers.LeakyReLU()(x)

### Upsamples to 32x32
x = layers.Conv2DTranspose(256, 4, strides=2, padding='same')(x)
x = layers.LeakyReLU()(x)

x = layers.Conv2D(256, 5, padding='same')(x)
x = layers.LeakyReLU()(x)
x = layers.Conv2D(256, 5, padding='same')(x)
x = layers.LeakyReLU()(x)

### Produces a 32x32 1-channel feature map (shape of a CIFAR10 image)
x = layers.Conv2D(channels, 7, activation='tanh', padding='same')(x)
generator = keras.models.Model(generator_input, x) #Instantiates the generator model, which maps the input of shape (latent_dim,) into an image of shape (32,32,3)
generator.summary()




### The GAN discriminator network

# Next, you’ll develop a discriminator model that takes as input a candidate image
# (real or synthetic) and classifies it into one of two classes:
#     “generated image” or
#     “real image that comes from the training set.”

discriminator_input = layers.Input(shape=(height, width, channels))
x = layers.Conv2D(128, 3)(discriminator_input)
x = layers.LeakyReLU()(x)
x = layers.Conv2D(128, 4, strides=2)(x)
x = layers.LeakyReLU()(x)
x = layers.Conv2D(128, 4, strides=2)(x)
x = layers.LeakyReLU()(x)
x = layers.Conv2D(128, 4, strides=2)(x)
x = layers.LeakyReLU()(x)
x = layers.Flatten()(x)

# One dropout layer: an important trick!
x = layers.Dropout(0.4)(x)

x = layers.Dense(1, activation='sigmoid')(x) #Classification layer

# Instantiates the discriminator model, which turns a (32, 32, 3) input into a binary classification decision (fake/real)
discriminator = keras.models.Model(discriminator_input, x)
discriminator.summary()

discriminator_optimizer = keras.optimizers.RMSprop(
    lr=0.0008,
    clipvalue=1.0, #Uses gradient clipping (by value) in the optimizer
    decay=1e-8) #To stabilize training, uses learning-rate decay
    
discriminator.compile(optimizer=discriminator_optimizer,        
                      loss='binary_crossentropy')




### Adversarial network discriminator.trainable

# Finally, you’ll set up the GAN, which chains the generator and the discriminator
# When trained, this model will move the generator in a direction that improves its ability to fool the discriminator.
# This model turns latent-space points into a classification decision — “fake” or “real” — and it’s meant to be trained with labels that are always “these are real images.”
# So, training gan will update the weights of generator in a way that makes discriminator more likely to predict “real” when looking at fake images.
# It’s very important to note that you set the discriminator to be frozen during training (non-trainable):
#   its weights won’t be updated when training gan.
# If the discriminator weights could be updated during this process, then you’d be training the discriminator to always predict “real,” which isn’t what you want!

# Sets discriminator weights to non-trainable (this will only apply to the gan model)
discriminator.trainable = False

gan_input = keras.Input(shape=(latent_dim,))
gan_output = discriminator(generator(gan_input))
gan = keras.models.Model(gan_input, gan_output)

gan_optimizer = keras.optimizers.RMSprop(lr=0.0004, clipvalue=1.0, decay=1e-8) 
gan.compile(optimizer=gan_optimizer, loss='binary_crossentropy')




### Implementing GAN training

# Now you can begin training.
# To recapitulate, this is what the training loop looks like schematically.
# For each epoch, you do the following:

# 1 Draw random points in the latent space (random noise).
# 2 Generate images with generator using this random noise.
# 3 Mix the generated images with real ones.
# 4 Train discriminator using these mixed images, with corresponding targets: either “real” (for the real images) or “fake” (for the generated images).
# 5 Draw new random points in the latent space.
# 6 Train gan using these random vectors, with targets that all say “these are real images.” This updates the weights of the generator (only, because the discriminator is frozen inside gan) to move them toward getting the discriminator to predict “these are real images” for generated images: this trains the generator to fool the discriminator.

# Let’s implement it.

import os
from keras.preprocessing import image

# Loads CIFAR10 data
(x_train, y_train), (_, _) = keras.datasets.cifar10.load_data()
# fails to load the dataset here, fix if ever want to use this. below unconfirmd

x_train = x_train[y_train.flatten() == 6] #Selects frog images (class 6)

x_train = x_train.reshape(
    (x_train.shape[0],) +
    (height, width, channels)).astype('float32') / 255. #Normalizes data

iterations = 10000
batch_size = 20
save_dir = 'your_dir' #Specifies where you want to save generated images

start = 0
# Samples random points in the latent space
for step in range(iterations):
    random_latent_vectors = np.random.normal(size=(batch_size, latent_dim))
    # Decodes them to fake images
    generated_images = generator.predict(random_latent_vectors)
    # Combines them with real images
    stop = start + batch_size
    real_images = x_train[start: stop]
    combined_images = np.concatenate([generated_images, real_images])
    # Assembles labels, discriminating real from fake images
    labels = np.concatenate([np.ones((batch_size, 1)),
                            np.zeros((batch_size, 1))])
    # Adds random noise to the labels - an important trick!
    labels += 0.05 * np.random.random(labels.shape)
    # Trains the discriminator
    d_loss = discriminator.train_on_batch(combined_images, labels)
    # Samples random points in the latent space
    random_latent_vectors = np.random.normal(size=(batch_size,latent_dim))
    # Assembles labels that say “these are all real images” (it’s a lie!)
    misleading_targets = np.zeros((batch_size, 1))
    # Trains the generator (via the gan model, where the discriminator weights are frozen)
    a_loss = gan.train_on_batch(random_latent_vectors,misleading_targets)
    start += batch_size
    if start > len(x_train) - batch_size:
        start = 0
    # Occasionally saves and plots (every 100 steps)
    if step % 100 == 0:
        gan.save_weights('gan.h5') #Saves model weights
        # Print loss metrics
        print('discriminator loss:', d_loss)
        print('adversarial loss:', a_loss)
        # Saves one generated image
        img = image.array_to_img(generated_images[0] * 255., scale=False)
        img.save(os.path.join(save_dir, 'generated_frog' + str(step) + '.png'))
        # Saves one real image for comparison
        img = image.array_to_img(real_images[0] * 255., scale=False)
        img.save(os.path.join(save_dir, 'real_frog' + str(step) + '.png'))



### Outcome

# When training, you may see the adversarial loss begin to increase considerably, while the discriminative loss tends to zero—the discriminator may end up dominating the generator.
# If that’s the case, try reducing the discriminator learning rate, and increase the dropout rate of the discriminator

# Figure 8.18 pg 335 - Play the discriminator: in each row, two images were dreamed up by the GAN, and one image comes from the training set.
# Can you tell them apart?
# (Answers: the real images in each column are middle, top, bottom, middle.)