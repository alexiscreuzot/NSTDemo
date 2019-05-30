import os
import coremltools

from coremltools.models.neural_network.quantization_utils import *

#--------------------------------------------------------
# Quantize .mlmodel files in the current directory
# make sure to save the original model as you can't "quantize back" nor
# re-quantize a quantized model
#--------------------------------------------------------

# Select quantization mode 
# [linear, linear_lut, kmeans_lut, custom_lut]
function = "linear" 
# Select number of bits per quantized weight
nbits = 8 
# Output directory
output_dir = "."

# Check if we need to create the output directory
if not os.path.exists(output_dir):
    os.makedirs(output_dir)

# List 
for file in os.listdir("."):
    if file.endswith(".mlmodel"):
        for file in os.listdir("."):
        model_name = file.split(".")[0]
        model = coremltools.models.MLModel(f"{model_name}.mlmodel")
        print(f"processing {function} on {nbits} bits")    
        lin_quant_model = quantize_weights(model, nbits, function)
        lin_quant_model.author = "Monoqle"
        lin_quant_model.license = "All rights reserved"
        lin_quant_model.short_description = f"{model_name}, {function} {nbits} bit"
        output_name = f"{model_name}_{function}_{nbits}"
        lin_quant_model.save(f"{output_dir}/{model_name}")
