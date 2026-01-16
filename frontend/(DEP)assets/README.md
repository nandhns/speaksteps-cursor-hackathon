# SpeakSteps Assets

Place your TFLite model files here:

- `model.tflite` - Standard FP32 model
- `model_float16.tflite` - Float16 quantized model (optional, smaller)

## Generating the Model

Run the ML notebook (`speaksteps_ml_notebook.ipynb`) to generate the TFLite models,
then copy them to this directory.

```bash
# From project root:
cp model.tflite frontend/assets/
cp model_float16.tflite frontend/assets/
```

