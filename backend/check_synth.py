import pandas as pd
df = pd.read_csv('data/synth_speaksteps.csv')
print('First 5 rows:')
for idx in range(min(5, len(df))):
    row = df.iloc[idx]
    print(f"  {row['question_id']:15} {row['exercise_id']:20} {row['exercise_name']}")
print()
print('Unique exercise_ids in synth_speaksteps.csv:')
unique_ids = df['exercise_id'].unique()[:10]
for eid in unique_ids:
    print(f"  {eid}")
