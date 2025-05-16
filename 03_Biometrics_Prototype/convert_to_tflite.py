import tensorflow as tf
# 1. Load your Keras model
model = tf.keras.models.load_model('gru_model.h5')

# 2. Create converter and include SELECT_TF_OPS
converter = tf.lite.TFLiteConverter.from_keras_model(model)
converter.target_spec.supported_ops = [
    tf.lite.OpsSet.TFLITE_BUILTINS,     # Minimal TFLite ops
    tf.lite.OpsSet.SELECT_TF_OPS        # Any extra (e.g. CAST)
]
converter.optimizations = [tf.lite.Optimize.DEFAULT]

# 3. Convert and write out
tflite_model = converter.convert()
with open('assets/models/gru_model.tflite', 'wb') as f:
    f.write(tflite_model)

print("✅ Converted with SELECT_TF_OPS to assets/models/gru_model.tflite")
