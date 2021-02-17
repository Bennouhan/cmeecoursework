import tensorflow as tf
gpus = tf.config.experimental.list_physical_devices('GPU')
tf.config.experimental.set_memory_growth(gpus[0], True)



##### Neural style transfer in Keras

# Neural style transfer can be implemented using any pretrained convnet.
# Here, you’ll use the VGG19 network used by Gatys et al.
# VGG19 is a simple variant of the VGG16 network introduced in chapter 5, with three more convolutional layers.
# This is the general process:

# 1 Set up a network that computes VGG19 layer activations for the style-reference image, the target image, and the generated image at the same time.
# 2 Use the layer activations computed over these three images to define the loss function described earlier, which you’ll minimize in order to achieve style transfer.
# 3 Set up a gradient-descent process to minimize this loss function.



### Defining initial variables

# Let’s start by defining the paths to the style-reference image and the target image.
# Need to make sure that the processed images are a similar size (widely different sizes make style transfer more difficult)
# Hence you’ll later resize them all to a shared height of 400 px.

from keras.preprocessing.image import load_img, img_to_array

# NB NEED ACTUAL PATHS TO IMAGES HERE
target_image_path = 'img/portrait.jpg' #Path to the image you want to transform
style_reference_image_path = 'img/transfer_style_reference.jpg' #to style image

# Dimensions of the generated picture
width, height = load_img(target_image_path).size
img_height = 400
img_width = int(width * img_height / height)




#### Auxiliary functions

# You need some auxiliary functions for loading, preprocessing, and postprocessing the images that go in and out of the VGG19 convnet

import numpy as np from keras.applications
import vgg19

def preprocess_image(image_path):
    img = load_img(image_path, target_size=(img_height, img_width))
    img = img_to_array(img)
    img = np.expand_dims(img, axis=0)
    img = vgg19.preprocess_input(img)
    return img


def deprocess_image(x):
    ### Zero-centering by removing the mean pixel value from ImageNet.
    ### This reverses a transformation done by vgg19.preprocess_input.
    x[:, :, 0] += 103.939
    x[:, :, 1] += 116.779
    x[:, :, 2] += 123.68
    ### Converts images from 'BGR' to 'RGB'.
    ### This is also part of the reversal of vgg19.preprocess_input
    x = x[:, :, ::-1]
    x = np.clip(x, 0, 255).astype('uint8')
    return x




### Loading the pretrained VGG19 network and applying it to the three images from

# Let’s set up the VGG19 network.
# It takes as input a batch of three images:
#  - the style-reference image,
#  - the target image,
#  - and a placeholder that will contain the generated image.
# A placeholder is a symbolic tensor, the values of which are provided externally via Numpy arrays.
# The style-reference and target image are static and thus defined using       K.constant
# Whereas the values contained in the placeholder of the generated image will change over time.

from keras import backend as K

target_image = K.constant(preprocess_image(target_image_path)) 
style_reference_image = K.constant(preprocess_image(style_reference_image_path))
# Placeholder that will contain the generated image
combination_image = K.placeholder((1, img_height, img_width, 3))

### Combines the three images in a single batch
input_tensor = K.concatenate([target_image,
                              style_reference_image,
                              combination_image], axis=0)

### Builds the VGG19 network with the batch of three images as input.
### The model will be loaded with pretrained ImageNet weights.
model = vgg19.VGG19(input_tensor=input_tensor,
                    weights='imagenet',
                    include_top=False)
print('Model loaded.')




### Content loss

# Let’s define the content loss, which will make sure the top layer of the VGG19 convnet has a similar view of the target image and the generated image

def content_loss(base, combination):
    return K.sum(K.square(combination - base))




### Style loss

# Next is the style loss.
# It uses an auxiliary function to compute the Gram matrix of an input matrix:
#   a map of the correlations found in the original feature matrix.

def gram_matrix(x):
    features = K.batch_flatten(K.permute_dimensions(x, (2, 0, 1)))
    gram = K.dot(features, K.transpose(features))
    return gram


def style_loss(style, combination):
    S = gram_matrix(style)
    C = gram_matrix(combination)
    channels = 3
    size = img_height * img_width
    return K.sum(K.square(S - C)) / (4. * (channels ** 2) * (size ** 2))



### Total variation loss

# To these two loss components, you add a third:
#   the total variation loss, which operates on the pixels of the generated combination image.
# It encourages spatial continuity in the generated image, thus avoiding overly pixelated results.
# You can interpret it as a regularization loss.

def total_variation_loss(x):
    a = K.square(
        x[:, :img_height - 1, :img_width - 1, :] -
        x[:, 1:, :img_width - 1, :])
    b = K.square(
        x[:, :img_height - 1, :img_width - 1, :] -
        x[:, :img_height - 1, 1:, :])
    return K.sum(K.pow(a + b, 1.25))





### Defining the final loss that you’ll minimize

# The loss that you minimize is a weighted average of these three losses.
# To compute the content loss, you use only 1 upper layer - the block5_conv2 layer
# Whereas for the style loss, you use a list of layers than spans both low-level and high-level layers.
# You add the total variation loss at the end.
# Depending on the style-reference image and content image you’re using, you’ll
# likely want to tune the content_weight coefficient (the contribution of the content loss to the total loss).
# A higher content_weight means the target content will be more recognizable in the generated image.

outputs_dict = dict([(layer.name, layer.output) for layer in model.layers]) 
content_layer = 'block5_conv2' #Layer used for content loss
style_layers = ['block1_conv1', #(&v) Layers used for style loss
'block2_conv1', 'block3_conv1',
'block4_conv1', 'block5_conv1']

### Weights in the weighted average of the loss component
total_variation_weight = 1e-4
style_weight = 1.
content_weight = 0.025

### Adds the content loss
loss = K.variable(0.) #you define the loss by adding all components to this scalar variable
layer_features = outputs_dict[content_layer]
target_image_features = layer_features[0, :, :, :]
combination_features = layer_features[2, :, :, :]
loss += content_weight * content_loss(target_image_features, 
                                      combination_features)

### Adds a style loss component for each target
for layer_name in style_layers:
    layer_features = outputs_dict[layer_name]
    style_reference_features = layer_features[1, :, :, :]
    combination_features = layer_features[2, :, :, :]
    sl = style_loss(style_reference_features, combination_features)
    loss += (style_weight / len(style_layers)) * sl

# Adds the total variation loss
loss += total_variation_weight * total_variation_loss(combination_image)



### Setting up the gradient-descent process

# Finally, you’ll set up the gradient-descent process.
# In the original Gatys et al. paper, optimization is performed using the L-BFGS algorithm, so that’s what you’ll use here.
# This is a key difference from the DeepDream example in section 8.2
# The L-BFGS algorithm comes packaged with SciPy, but there are two slight limitations with the SciPy implementation:
# -  It requires that you pass the value of the loss function and the value of the gradients as two separate functions.
# -  It can only be applied to flat vectors, whereas you have a 3D image array.

# It would be inefficient to compute the value of the loss function and the value of the gradients independently, because doing so would lead to a lot of redundant computation between the two;
# the process would be almost twice as slow as computing them jointly.
# To bypass this, you’ll set up a Python class named Evaluator that:
# -  computes both the loss value and the gradients value at once
# -  returns the loss value when called the first time
# -  and caches the gradients for the next call.

# Gets the gradients of the generated image with regard to the loss
grads = K.gradients(loss, combination_image)[0]

# Function to fetch the values of the current loss and the current gradients
fetch_loss_and_grads = K.function([combination_image], [loss, grads])

### This class wraps fetch_loss_and_grads in a way that lets you retrieve the losses and gradients via two separate method calls, which is required by the SciPy optimizer you'll use.
class Evaluator(object):

    def __init__(self):
        self.loss_value = None
        self.grads_values = None

    def loss(self, x):
        assert self.loss_value is None
        x = x.reshape((1, img_height, img_width, 3))
        outs = fetch_loss_and_grads([x])
        loss_value = outs[0]
        grad_values = outs[1].flatten().astype('float64')
        self.loss_value = loss_value
        self.grad_values = grad_values
        return self.loss_value

    def grads(self, x):
        assert self.loss_value is not None
        grad_values = np.copy(self.grad_values)
        self.loss_value = None
        self.grad_values = None
        return grad_values

evaluator = Evaluator()



### Style-transfer loop

# Finally, you can run the gradient-ascent process using SciPy’s L-BFGS algorithm
# This saves the current generated image at each iteration of the algorithm
# (Here, a single iteration represents 20 steps of gradient ascent).


from scipy.optimize import fmin_l_bfgs_b
from scipy.misc import imsave
import time

result_prefix = 'my_result'
iterations = 20

x = preprocess_image(target_image_path) #This is the initial state: target image
x = x.flatten() # You flatten the image because scipy.optimize.fmin_l_bfgs_b can only process flat vectors.

### Runs L-BFGS optimization over the pixels of the generated image to minimize the neural style loss.
# Note that you have to pass the function that computes the loss and the function that computes the gradients as two separate arguments.
for i in range(iterations):
    print('Start of iteration', i)
    start_time = time.time()
    x, min_val, info = fmin_l_bfgs_b(evaluator.loss,
                                     x,
                                     fprime=evaluator.grads,
                                     maxfun=20)
    print('Current loss value:', min_val)
    ### Saves the current generated image
    img = x.copy().reshape((img_height, img_width, 3))
    img = deprocess_image(img)
    fname = result_prefix + '_at_iteration_%d.png' % i
    imsave(fname, img)
    print('Image saved as', fname)
    end_time = time.time()
    print('Iteration %d completed in %ds' % (i, end_time - start_time))



### Outcome

# Figure 8.8 pg 294 shows what you get.
# Keep in mind that what this technique achieves is merely a form of image retexturing, or texture transfer.
# It works best with style-reference images that are strongly textured and highly self-similar, and with content targets that don’t require high levels of detail in order to be recognizable.
# It typically can’t achieve fairly abstract feats such as transferring the style of one portrait to another.
# The algorithm is closer to classical signal processing than to AI, so don’t expect it to work like magic!

# Additionally, note that running this style-transfer algorithm is slow.
# But the transformation operated by the setup is simple enough that it can be learned by a small, fast feedforward convnet as well — as long as you have appropriate training data available.
# Fast style transfer can thus be achieved by first spending a lot of compute cycles to generate input-output training examples for a fixed style-reference image, using the method outlined here, and then training a simple convnet to learn this style-specific transformation.
# Once that’s done, stylizing a given image is instantaneous: it’s just a forward pass of this small convnet.
