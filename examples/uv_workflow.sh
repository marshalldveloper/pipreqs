#!/bin/bash
# Example: UV + pipreqs workflow for a data science project

# Setup
echo "🚀 Setting up new project with UV + pipreqs..."
mkdir -p my_data_project
cd my_data_project

# Create sample Python files
cat > analysis.py << 'EOF'
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from sklearn.model_selection import train_test_split

def analyze_data(df):
    """Analyze dataset and create visualizations"""
    # Statistical analysis
    summary = df.describe()
    
    # Create plots
    plt.figure(figsize=(10, 6))
    df.hist()
    plt.savefig('analysis.png')
    
    return summary
EOF

cat > preprocessing.py << 'EOF'
import pandas as pd
from sklearn.preprocessing import StandardScaler

def preprocess_data(df):
    """Preprocess data for ML"""
    scaler = StandardScaler()
    scaled_data = scaler.fit_transform(df.select_dtypes(include=[np.number]))
    return scaled_data
EOF

# Step 1: Generate minimal requirements with pipreqs
echo "📋 Generating minimal requirements with pipreqs..."
pipreqs . --force

echo "Requirements generated:"
cat requirements.txt

# Step 2: Create UV virtual environment
echo "🔧 Creating UV virtual environment..."
uv venv

# Step 3: Activate and install with UV
echo "📦 Installing dependencies with UV (watch the speed!)..."
source .venv/bin/activate
time uv pip install -r requirements.txt

# Step 4: Show environment size
echo "💾 Environment size:"
du -sh .venv/

# Step 5: Demonstrate adding a new dependency
echo "➕ Adding new dependency..."
echo "import seaborn as sns" >> visualization.py

# Regenerate requirements
pipreqs . --force

# Sync with UV (only installs what's new)
echo "🔄 Syncing new dependencies..."
time uv pip sync requirements.txt

# Step 6: Clean unused dependencies
echo "🧹 Cleaning unused dependencies..."
# Remove an import
sed -i '/matplotlib/d' analysis.py

# Update requirements
pipreqs --clean requirements.txt .

# UV removes unused packages
uv pip sync requirements.txt

echo "✅ Workflow complete! Check the minimal .venv size and fast install times."