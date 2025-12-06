"""
SpeakSteps Placeholder Image Generator
======================================
Generates placeholder PNG images for therapy exercises with item names overlaid.
Creates a CSV mapping question IDs to image filenames.
"""

import os
import csv
import random
from PIL import Image, ImageDraw, ImageFont

# =============================================================================
# CONFIGURATION
# =============================================================================

# Output directory for images
OUTPUT_DIR = "images"

# CSV output file
CSV_OUTPUT = "image_mapping.csv"

# Image dimensions
IMAGE_WIDTH = 100
IMAGE_HEIGHT = 100

# Items by category (10 items per category = 40 total)
ITEMS_BY_CATEGORY = {
    "animals": [
        "dog", "cat", "bird", "fish", "horse",
        "cow", "pig", "duck", "frog", "lion"
    ],
    "body_parts": [
        "hand", "foot", "arm", "leg", "head",
        "eye", "ear", "nose", "mouth", "knee"
    ],
    "clothing": [
        "shirt", "pants", "dress", "shoe", "hat",
        "sock", "jacket", "coat", "glove", "belt"
    ],
    "food": [
        "apple", "bread", "milk", "egg", "rice",
        "cheese", "banana", "orange", "carrot", "cake"
    ]
}

# Color palettes for backgrounds (light, pleasant colors)
BACKGROUND_COLORS = [
    (255, 182, 193),  # Light pink
    (173, 216, 230),  # Light blue
    (144, 238, 144),  # Light green
    (255, 255, 224),  # Light yellow
    (230, 230, 250),  # Lavender
    (255, 218, 185),  # Peach
    (176, 224, 230),  # Powder blue
    (255, 228, 196),  # Bisque
    (240, 255, 240),  # Honeydew
    (255, 240, 245),  # Lavender blush
    (240, 248, 255),  # Alice blue
    (245, 245, 220),  # Beige
    (255, 250, 205),  # Lemon chiffon
    (250, 240, 230),  # Linen
    (245, 255, 250),  # Mint cream
]

# Text color (dark for contrast)
TEXT_COLOR = (50, 50, 50)

# Border color
BORDER_COLOR = (100, 100, 100)


# =============================================================================
# HELPER FUNCTIONS
# =============================================================================

def get_font(size=14):
    """
    Get a font for text rendering.
    Falls back to default if custom fonts unavailable.
    """
    # Try to use a nice font if available
    font_options = [
        "arial.ttf",
        "Arial.ttf",
        "DejaVuSans.ttf",
        "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf",
        "C:/Windows/Fonts/arial.ttf",
    ]
    
    for font_path in font_options:
        try:
            return ImageFont.truetype(font_path, size)
        except (OSError, IOError):
            continue
    
    # Fallback to default bitmap font
    return ImageFont.load_default()


def generate_image(category, item, output_path):
    """
    Generate a single placeholder image with the item name overlaid.
    
    Args:
        category: Category name (e.g., 'animals')
        item: Item name (e.g., 'dog')
        output_path: Full path to save the image
    """
    # Pick a random background color
    bg_color = random.choice(BACKGROUND_COLORS)
    
    # Create new image with colored background
    image = Image.new('RGB', (IMAGE_WIDTH, IMAGE_HEIGHT), bg_color)
    
    # Create drawing context
    draw = ImageDraw.Draw(image)
    
    # Draw a subtle border (2px)
    draw.rectangle(
        [(0, 0), (IMAGE_WIDTH - 1, IMAGE_HEIGHT - 1)],
        outline=BORDER_COLOR,
        width=2
    )
    
    # Get font for text
    font_large = get_font(16)
    font_small = get_font(10)
    
    # Calculate text positions for centering
    # Item name (main text)
    item_text = item.upper()
    
    # Get text bounding box for centering
    try:
        # PIL 9.2.0+ method
        item_bbox = draw.textbbox((0, 0), item_text, font=font_large)
        item_width = item_bbox[2] - item_bbox[0]
        item_height = item_bbox[3] - item_bbox[1]
    except AttributeError:
        # Fallback for older PIL versions
        item_width, item_height = draw.textsize(item_text, font=font_large)
    
    # Center the item text
    item_x = (IMAGE_WIDTH - item_width) // 2
    item_y = (IMAGE_HEIGHT - item_height) // 2 - 5
    
    # Draw item name
    draw.text((item_x, item_y), item_text, fill=TEXT_COLOR, font=font_large)
    
    # Draw category label at bottom
    category_text = f"[{category}]"
    try:
        cat_bbox = draw.textbbox((0, 0), category_text, font=font_small)
        cat_width = cat_bbox[2] - cat_bbox[0]
    except AttributeError:
        cat_width, _ = draw.textsize(category_text, font=font_small)
    
    cat_x = (IMAGE_WIDTH - cat_width) // 2
    cat_y = IMAGE_HEIGHT - 20
    
    # Draw category in lighter color
    draw.text((cat_x, cat_y), category_text, fill=(120, 120, 120), font=font_small)
    
    # Draw a small icon placeholder (circle) at top
    icon_radius = 8
    icon_center = (IMAGE_WIDTH // 2, 20)
    draw.ellipse(
        [
            (icon_center[0] - icon_radius, icon_center[1] - icon_radius),
            (icon_center[0] + icon_radius, icon_center[1] + icon_radius)
        ],
        fill=(180, 180, 180),
        outline=BORDER_COLOR
    )
    
    # Save the image
    image.save(output_path, 'PNG')
    
    return bg_color


def generate_question_id(category, item, index):
    """
    Generate a unique question ID.
    
    Args:
        category: Category name
        item: Item name
        index: Sequential index
    
    Returns:
        Question ID string (e.g., 'Q_001_animals_dog')
    """
    return f"Q_{index:03d}_{category}_{item}"


# =============================================================================
# MAIN GENERATION FUNCTION
# =============================================================================

def generate_all_images():
    """
    Generate all placeholder images and create CSV mapping.
    """
    print("=" * 60)
    print("SPEAKSTEPS PLACEHOLDER IMAGE GENERATOR")
    print("=" * 60)
    
    # Create output directory if it doesn't exist
    if not os.path.exists(OUTPUT_DIR):
        os.makedirs(OUTPUT_DIR)
        print(f"✅ Created directory: {OUTPUT_DIR}/")
    else:
        print(f"📁 Using existing directory: {OUTPUT_DIR}/")
    
    # Prepare CSV data
    csv_rows = []
    image_count = 0
    
    print(f"\n🎨 Generating {sum(len(items) for items in ITEMS_BY_CATEGORY.values())} images...")
    print("-" * 60)
    
    # Iterate through categories and items
    for category, items in ITEMS_BY_CATEGORY.items():
        print(f"\n📂 Category: {category}")
        
        for item in items:
            image_count += 1
            
            # Generate filename: category_item.png
            filename = f"{category}_{item}.png"
            filepath = os.path.join(OUTPUT_DIR, filename)
            
            # Generate the image
            bg_color = generate_image(category, item, filepath)
            
            # Generate question ID
            question_id = generate_question_id(category, item, image_count)
            
            # Add to CSV data
            csv_rows.append({
                'question_id': question_id,
                'image_filename': filename,
                'category': category,
                'item': item,
                'image_path': filepath
            })
            
            # Print progress
            color_hex = '#{:02x}{:02x}{:02x}'.format(*bg_color)
            print(f"   ✓ {filename:<25} (bg: {color_hex})")
    
    # Write CSV mapping file
    print(f"\n📄 Writing CSV mapping: {CSV_OUTPUT}")
    
    with open(CSV_OUTPUT, 'w', newline='', encoding='utf-8') as csvfile:
        fieldnames = ['question_id', 'image_filename', 'category', 'item', 'image_path']
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        
        writer.writeheader()
        writer.writerows(csv_rows)
    
    # Print summary
    print("\n" + "=" * 60)
    print("✅ GENERATION COMPLETE!")
    print("=" * 60)
    print(f"""
📊 Summary:
   • Total images generated: {image_count}
   • Image dimensions: {IMAGE_WIDTH}x{IMAGE_HEIGHT} pixels
   • Output directory: {OUTPUT_DIR}/
   • CSV mapping file: {CSV_OUTPUT}
   
📂 Images by category:
   • animals:    {len(ITEMS_BY_CATEGORY['animals'])} images
   • body_parts: {len(ITEMS_BY_CATEGORY['body_parts'])} images
   • clothing:   {len(ITEMS_BY_CATEGORY['clothing'])} images
   • food:       {len(ITEMS_BY_CATEGORY['food'])} images
""")
    
    return csv_rows


# =============================================================================
# PREVIEW FUNCTION
# =============================================================================

def preview_csv():
    """
    Display first 10 rows of generated CSV.
    """
    print("\n📋 CSV Preview (first 10 rows):")
    print("-" * 80)
    
    try:
        with open(CSV_OUTPUT, 'r', encoding='utf-8') as f:
            reader = csv.DictReader(f)
            for i, row in enumerate(reader):
                if i >= 10:
                    print("   ... (more rows)")
                    break
                print(f"   {row['question_id']:<25} → {row['image_filename']}")
    except FileNotFoundError:
        print("   (CSV file not found - run generate_all_images() first)")


# =============================================================================
# MAIN EXECUTION
# =============================================================================

if __name__ == "__main__":
    # Set random seed for reproducibility
    random.seed(42)
    
    # Generate all images
    generate_all_images()
    
    # Show CSV preview
    preview_csv()

