"""
Regroup exercises CSV so each exercise has multiple questions.
Groups by: module + category + difficulty
"""
import pandas as pd

# Read the CSV
df = pd.read_csv('data/exercises.csv')

# Create new exercise_id by grouping: module prefix + category + difficulty
def create_grouped_exercise_id(row):
    module_prefix = row['module'][0].upper()  # W or C (writing/comprehension)
    
    # Map category to short code
    category_map = {
        'haiwan': 'ANI',
        'makanan': 'FOOD',
        'anggota_badan': 'BODY',
        'kata_kerja': 'KK'
    }
    cat_code = category_map.get(row['category'], 'UNK')
    
    # Map difficulty to letter
    diff_map = {
        'easy': 'E',
        'medium': 'M',
        'hard': 'H'
    }
    diff_code = diff_map.get(row['difficulty'], 'X')
    
    return f"EX_{module_prefix}_{cat_code}_{diff_code}"

# Apply the grouping
df['exercise_id'] = df.apply(create_grouped_exercise_id, axis=1)

# Save the regrouped CSV
df.to_csv('data/exercises.csv', index=False)

print("✅ Regrouped exercises successfully!")
print(f"   Total rows: {len(df)}")
print(f"   Unique exercises: {df['exercise_id'].nunique()}")
print("\nExercise groups:")
for ex_id in sorted(df['exercise_id'].unique()):
    count = len(df[df['exercise_id'] == ex_id])
    print(f"  {ex_id}: {count} questions")
