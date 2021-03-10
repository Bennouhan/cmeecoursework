import tensorflow as tf
gpus = tf.config.experimental.list_physical_devices('GPU')
tf.config.experimental.set_memory_growth(gpus[0], True)




# The DeepDream algorithm is almost identical to the convnet filter-visualization technique introduced in chapter 5, consisting of running a convnet in reverse: 
# doing gradient ascent on the input to the convnet in order to maximize the activation of a specific filter in an upper layer of the convnet.
# DeepDream uses this same idea, with a few simple differences:

# ? With DeepDream, you try to maximize the activation of entire layers rather than that of a specific filter, thus mixing together visualizations of large numbers of features at once.
# ? You start not from blank, slightly noisy input, but rather from an existing image—thus the resulting effects latch on to preexisting visual patterns, distorting elements of the image in a somewhat artistic fashion.
# ? The input images are processed at different scales (called octaves), which improves the quality of the visualizations.



##### Implementing DeepDream in Keras




### Loading the pretrained Inception V3 model

from keras.applications import inception_v3
from keras import backend as K

#You won’t be training the model, so this command disables all training- specific operations.
K.set_learning_phase(0) #gives error saying add training=False to model(blah, blah, training=False) somewhere (adding to the model= right below doesnt work)

#Builds the Inception V3 network, without its convolutional base. The model will be loaded with pretrained ImageNet weights.
model = inception_v3.InceptionV3(weights='imagenet', include_top=False)




### Setting up the DeepDream configuration

# Next, you’ll compute the loss: the quantity you’ll seek to maximize during the gradient-ascent process.
# In chapter 5, for filter visualization, you tried to maximize the value of a specific filter in a specific layer.
# Here, you’ll simultaneously maximize the activation of all filters in a number of layers.
# Specifically, you’ll maximize a weighted sum of the L2 norm of the activations of a set of high-level layers.
# The exact set of layers you choose (as well as their contribution to the final loss) has a major influence on the visuals you’ll be able to produce, so you want to make these parameters easily configurable.
# Lower layers result in geometric patterns, whereas higher layers result in visuals in which you can recognize some classes from ImageNet (for example, birds or dogs).
# You’ll start from a somewhat arbitrary configuration involving four layers—but you’ll definitely want to explore many different configurations later.

# Dictionary mapping layer names to a coefficient quantifying how much the layer’s activation contributes to the loss you’ll seek to maximize.
# Note that the layer names are hardcoded in the built-in Inception V3 application.
layer_contributions = { 'mixed2': 0.2, 'mixed3': 3., 'mixed4': 2., 'mixed5': 1.5,}
# You can list all layer names using model.summary().




### Defining the loss to be maximized

# Now, let’s define a tensor that contains the loss: the weighted sum of the L2 norm of the activations of the layers in listing 8.9.

# Creates a dictionary that maps layer names to layer instances
layer_dict = dict([(layer.name, layer) for layer in model.layers])

# You’ll define the loss by adding layer contributions to this scalar variable.
loss = K.variable(0.) 

for layer_name in layer_contributions:
    coeff = layer_contributions[layer_name]
    activation = layer_dict[layer_name].output #Retrieves the layer’s output
    scaling = K.prod(K.cast(K.shape(activation), 'float32'))
    loss = loss + (coeff * K.sum(K.square(activation[:, 2: -2, 2: -2, :])) / scaling) # loss += lead to error for some reason
    # Adds the L2 norm of the features of a layer to the loss.
    # You avoid border artifacts by only involving nonborder pixels in the loss.




#TEST#
model = load_model('mymodel.h5')
sess = K.get_session()
grad_func = tf.gradients(model.output, model.input) # my equic is "grads"
gradients = sess.run(grad_func, feed_dict={model.input: X})[0]




inp = tf.Variable(np.random.normal(size=(25, 120)), dtype=tf.float32)
#my equiv is loss? altho dream is model.input

with tf.GradientTape() as tape:
    preds = model(inp)


grads = tape.gradient(preds, inp)

# my try
grads = tf.GradientTape().gradient(loss, dream)[0] #- doesnt work. if this is needed later, work out.

# Thanks! This works (I just had to change the input shape to be "size=(120,26)" since I have 26 input columns). The crux was using tf.Variable() to convert the data (X) from numpy to a tf variable (inp). I had tried tf.convert_to_tensor(), but this didn't work. – maurera Dec 2 '19 at 23:01

# Do you know 1) Why do you need to use tf.Variable() rather than inputting a numpy array directly? 2) Why do you call model(inp) rather than model.predict(inp)? (What's the different between model(X) and model.predict(X)?) – maurera Dec 2 '19 at 23:48

# I have no idea about variables, but model(x) and model.predict(x) do not do the same, predict works with numpy arrays, while model(x) does a symbolic computation that tensorflow can differentiate. – Dr. Snoopy

#END TEST#



### Gradient-ascent process

# This tensor holds the generated image: the dream.
dream = model.input

# Computes the gradients of the dream with regard to the loss
grads = K.gradients(loss, dream)[0] #

# Normalizes the gradients (important trick)
grads /= K.maximum(K.mean(K.abs(grads)), 1e-7)

# Sets up a Keras function to retrieve the value of the loss and gradients, given an input image
outputs = [loss, grads]
fetch_loss_and_grads = K.function([dream], outputs)

def eval_loss_and_grads(x):
    outs = fetch_loss_and_grads([x])
    loss_value = outs[0]
    grad_values = outs[1]
    return loss_value, grad_values

# This function runs gradient ascent for a number of iterations
def gradient_ascent(x, iterations, step, max_loss=None):
    for i in range(iterations):
        loss_value, grad_values = eval_loss_and_grads(x)
        if max_loss is not None and loss_value > max_loss:
            break
        print('...Loss value at', i, ':', loss_value)
        x += step * grad_values
    return x




### Running gradient ascent over different successive scales

# Finally: the actual DeepDream algorithm.
# First, you define a list of scales (also called octaves) at which to process the images.
# Each successive scale is larger than the previous one by a factor of 1.4 (it’s 40% larger): you start by processing a small image and then increasingly scale it up (see figure 8.4).
# For each successive scale, from the smallest to the largest, you run gradient ascent to maximize the loss you previously defined, at that scale.
# After each gradient ascent run, you upscale the resulting image by 40%.
# To avoid losing a lot of image detail after each successive scale-up (resulting in increasingly blurry or pixelated images), you can use a simple trick:
# after each scaleup, you’ll reinject the lost details back into the image, which is possible because you know what the original image should look like at the larger scale.
# Given a small image size S and a larger image size L, you can compute the difference between the original image resized to size L and the original resized to size S
# —this difference quantifies the details lost when going from S to L

import numpy as np

# Playing with these hyperparameters will let you achieve new effects.
step = 0.01 #Gradient ascent step size
num_octave = 3 #Number of scales at which to run gradient ascent
octave_scale = 1.4 #Size ratio between scales
iterations = 20 #Number of ascent steps to run at each scale

max_loss = 10. # If the loss grows larger than 10, you’ll interrupt the gradient-ascent process to avoid ugly artifacts

base_image_path = '...' #Fill this with the path to the image you want to use

img = preprocess_image(base_image_path) #Loads the base image into a Numpy array (function is defined in listing 8.13

# Prepares a list of shape tuples defining the different scales at which to run gradient ascent
original_shape = img.shape[1:3]
successive_shapes = [original_shape]
for i in range(1, num_octave):
    shape = tuple([int(dim / (octave_scale ** i)) for dim in original_shape])
    successive_shapes.append(shape)

# Reverses the list of shapes so they’re in increasing order
successive_shapes = successive_shapes[::-1]

# Resizes the Numpy array of the image to the smallest scale
original_img = np.copy(img)
shrunk_original_img = resize_img(img, successive_shapes[0])
for shape in successive_shapes:
    print('Processing image shape', shape)
    img = resize_img(img, shape) #Scales up the dream image
    img = gradient_ascent(img, #(&v)runs gradient ascent, altering the dream
                            iterations=iterations,
                            step=step,
                            max_loss=max_loss) 
    #Scales up the smaller version of the image: it will be pixellated.
    upscaled_shrunk_original_img = resize_img(shrunk_original_img, shape) 
    #Computes the high-quality version of the original image at this size
    same_size_original = resize_img(original_img, shape)
    #The difference between the two is the detail that was lost when scaling up.
    lost_detail = same_size_original - upscaled_shrunk_original_img

    img += lost_detail #Reinjects lost detail into the dream
    shrunk_original_img = resize_img(original_img, shape)
    save_img(img, fname='dream_at_scale_' + str(shape) + '.png')

save_img(img, fname='final_dream.png')



### Auxillary Functions

# Note that this code uses the following straightforward auxiliary Numpy functions, which all do as their names suggest.
# They require that you have SciPy installed!!!!

import scipy
from keras.preprocessing import image

### Utility function to resize image
def resize_img(img, size):
    img = np.copy(img)
    factors = (1,
               float(size[0]) / img.shape[1],
               float(size[1]) / img.shape[2],
               1)
    return scipy.ndimage.zoom(img, factors, order=1)

### Utility function to same image
def save_img(img, fname):
    pil_img = deprocess_image(np.copy(img))
    scipy.misc.imsave(fname, pil_img)

### Utility function to open, resize, and format pictures into tensors that Inception V3 can process
def preprocess_image(image_path):
    img = image.load_img(image_path)
    img = image.img_to_array(img)
    img = np.expand_dims(img, axis=0)
    img = inception_v3.preprocess_input(img)
    return img

### Utility function to convert a tensor into a valid image
def deprocess_image(x):
    if K.image_data_format() == 'channels_first':
        x = x.reshape((3, x.shape[2], x.shape[3]))
        x = x.transpose((1, 2, 0))
    else: #Undoes preprocessing performed by inception_v3.preprocess_ input
        x = x.reshape((x.shape[1], x.shape[2], 3))
    x/=2.
    x+=0.5
    x *= 255.
    x = np.clip(x, 0, 255).astype('uint8')
    return x


# NOTE Because the original Inception V3 network was trained to recognize concepts in images of size 299 × 299,
# and given that the process involves scaling the images down by a reasonable factor,
# the DeepDream implementation produces much better results on images that are somewhere between 300 × 300 and 400 × 400.
# Regardless, you can run the same code on images of any size and any ratio



### Outcome

# We strongly suggest that you explore what you can do by adjusting which layers you use in your loss.
# Layers that are lower in the network contain more-local, less-abstract representations and lead to dream patterns that look more geometric.
# Layers that are higher up lead to more-recognizable visual patterns based on the most common objects found in ImageNet, such as dog eyes, bird feathers etc
# You can use random generation of the parameters in the layer_contributions dictionary to quickly explore many different layer combinations.
# Figure 8.6 pg 286 shows a range of results obtained using different layer configurations, from an image of a delicious homemade pastry.