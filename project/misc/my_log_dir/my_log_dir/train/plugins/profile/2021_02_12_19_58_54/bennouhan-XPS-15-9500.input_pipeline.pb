	�D�u��I@�D�u��I@!�D�u��I@	O�\@H�?O�\@H�?!O�\@H�?"w
=type.googleapis.com/tensorflow.profiler.PerGenericStepDetails6�D�u��I@OqN��?1���V�KE@AN����?I�[��b�@Y�������?*	�O��nz[@2U
Iterator::Model::ParallelMapV2��B��?!�v�_C5@)��B��?1�v�_C5@:Preprocessing2l
5Iterator::Model::ParallelMapV2::Zip[1]::ForeverRepeat%�����?!9�I�r�8@)�?k~���?1��VP�;3@:Preprocessing2F
Iterator::ModelV�&�5�?!��G��B@)�s���?1A���0@:Preprocessing2v
?Iterator::Model::ParallelMapV2::Zip[0]::FlatMap[0]::ConcatenateҊo(|��?!c!�ҶI;@)�vLݕ]�?1��|^�-@:Preprocessing2�
OIterator::Model::ParallelMapV2::Zip[0]::FlatMap[0]::Concatenate[0]::TensorSlice(F�̱�?!�sUG�~)@)(F�̱�?1�sUG�~)@:Preprocessing2Z
#Iterator::Model::ParallelMapV2::Zip�`TR'��?!�T�QO@)�R����?1�i9��s @:Preprocessing2x
AIterator::Model::ParallelMapV2::Zip[1]::ForeverRepeat::FromTensor�@���Fx?!�̏ݑ@)�@���Fx?1�̏ݑ@:Preprocessing2f
/Iterator::Model::ParallelMapV2::Zip[0]::FlatMap�ŊLà?! �	���=@)�0e��f?1�yv�@:Preprocessing:�
]Enqueuing data: you may want to combine small input data chunks into fewer but larger chunks.
�Data preprocessing: you may increase num_parallel_calls in <a href="https://www.tensorflow.org/api_docs/python/tf/data/Dataset#map" target="_blank">Dataset map()</a> or preprocess the data OFFLINE.
�Reading data from files in advance: you may tune parameters in the following tf.data API (<a href="https://www.tensorflow.org/api_docs/python/tf/data/Dataset#prefetch" target="_blank">prefetch size</a>, <a href="https://www.tensorflow.org/api_docs/python/tf/data/Dataset#interleave" target="_blank">interleave cycle_length</a>, <a href="https://www.tensorflow.org/api_docs/python/tf/data/TFRecordDataset#class_tfrecorddataset" target="_blank">reader buffer_size</a>)
�Reading data from files on demand: you should read data IN ADVANCE using the following tf.data API (<a href="https://www.tensorflow.org/api_docs/python/tf/data/Dataset#prefetch" target="_blank">prefetch</a>, <a href="https://www.tensorflow.org/api_docs/python/tf/data/Dataset#interleave" target="_blank">interleave</a>, <a href="https://www.tensorflow.org/api_docs/python/tf/data/TFRecordDataset#class_tfrecorddataset" target="_blank">reader buffer</a>)
�Other data reading or processing: you may consider using the <a href="https://www.tensorflow.org/programmers_guide/datasets" target="_blank">tf.data API</a> (if you are not using it now)�
:type.googleapis.com/tensorflow.profiler.BottleneckAnalysis�
device�Your program is NOT input-bound because only 0.4% of the total step time sampled is waiting for input. Therefore, you should focus on reducing other time.moderate"�13.5 % of the total step time sampled is spent on 'Kernel Launch'. It could be due to CPU contention with tf.data. In this case, you may try to set the environment variable TF_GPU_THREAD_MODE=gpu_private.*no9P�\@H�?I|^�+T0@Qos����T@Zno#You may skip the rest of this page.B�
@type.googleapis.com/tensorflow.profiler.GenericStepTimeBreakdown�
	OqN��?OqN��?!OqN��?      ��!       "	���V�KE@���V�KE@!���V�KE@*      ��!       2	N����?N����?!N����?:	�[��b�@�[��b�@!�[��b�@B      ��!       J	�������?�������?!�������?R      ��!       Z	�������?�������?!�������?b      ��!       JGPUYP�\@H�?b q|^�+T0@yos����T@