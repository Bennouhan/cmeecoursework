import tensorflow as tf
gpus = tf.config.experimental.list_physical_devices('GPU')
tf.config.experimental.set_memory_growth(gpus[0], True)


#largely skipped this section code-wise and just read the theory - go back and cover if deemed necesssary