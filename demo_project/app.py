#!/usr/bin/env python
"""Demo project to showcase pipreqs system package detection."""

# Standard library imports
import os
import sys
import json

# Data science packages (available via apt)
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from scipy import stats

# Web framework (available via apt)
from flask import Flask, jsonify
import requests

# Database (available via apt)
import sqlalchemy
from sqlalchemy.orm import sessionmaker

# Utilities (some via apt, some not)
import click
import docopt
from tqdm import tqdm
import yaml

# Development tools (typically pipx)
import black
import mypy
import flake8

# Machine learning (some via apt)
from sklearn.ensemble import RandomForestClassifier
import tensorflow as tf

# Visualization
import seaborn as sns
import plotly.express as px

# AWS SDK (pip only)
import boto3

# Some package that doesn't exist
# import nonexistent_package

app = Flask(__name__)

@app.route('/')
def hello():
    return jsonify({'message': 'Hello, World!'})

if __name__ == '__main__':
    print("Demo application")