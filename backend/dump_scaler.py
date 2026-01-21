import json
import joblib
from pathlib import Path

root = Path(__file__).resolve().parent.parent
joblib_path = root / 'frontend' / 'assets' / 'ml' / 'model.joblib'
out_path = root / 'backend' / 'models' / 'scaler_params.json'

scaler = joblib.load(joblib_path)
out_path.write_text(json.dumps({
    'mean': scaler.mean_.tolist(),
    'scale': scaler.scale_.tolist(),
}, indent=2))
print(f'Wrote scaler params to {out_path}')
