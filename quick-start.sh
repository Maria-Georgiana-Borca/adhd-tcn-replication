#!/bin/bash

# Quick Start Script for ADHD-TCN Replication
# This script helps you quickly set up and run the project using Docker

set -e

echo "======================================"
echo "ADHD-TCN Replication - Quick Start"
echo "======================================"
echo ""

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first:"
    echo "   https://docs.docker.com/get-docker/"
    exit 1
fi

echo "✅ Docker is installed"
echo ""

# Check if docker-compose is available
if command -v docker-compose &> /dev/null; then
    COMPOSE_CMD="docker-compose"
elif docker compose version &> /dev/null; then
    COMPOSE_CMD="docker compose"
else
    echo "⚠️  docker-compose not found, using docker run instead"
    COMPOSE_CMD=""
fi

# Create necessary directories
echo "📁 Creating necessary directories..."
mkdir -p data/raw/aal_tcs
mkdir -p data/raw/phenotypic
mkdir -p data/processed
mkdir -p data/interim
mkdir -p models
mkdir -p results
mkdir -p artifacts/models

echo "✅ Directories created"
echo ""

# Check if data exists
if [ ! "$(ls -A data/raw/aal_tcs)" ]; then
    echo "⚠️  WARNING: data/raw/aal_tcs is empty"
    echo "   Please download the ADHD-200 dataset first:"
    echo "   https://www.nitrc.org/frs/?group_id=383"
    echo ""
    echo "   Required files:"
    echo "   - ADHD200_AAL_TCs_filtfix.tar"
    echo "   - ADHD200_training_pheno.tar"
    echo ""
    read -p "   Continue anyway? (y/n) " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Build or pull image
echo "🐳 Building Docker image..."
if [ -n "$COMPOSE_CMD" ]; then
    $COMPOSE_CMD build
else
    docker build -t adhd-tcn-replication .
fi

echo "✅ Docker image ready"
echo ""

# Start container
echo "🚀 Starting Jupyter Lab..."
echo ""
echo "   Access Jupyter Lab at: http://localhost:8888"
echo "   Press Ctrl+C to stop"
echo ""

if [ -n "$COMPOSE_CMD" ]; then
    $COMPOSE_CMD up
else
    docker run -it --rm \
        -p 8888:8888 \
        -v "$(pwd)/data:/app/data" \
        -v "$(pwd)/models:/app/models" \
        -v "$(pwd)/results:/app/results" \
        -v "$(pwd)/artifacts:/app/artifacts" \
        -v "$(pwd)/notebooks:/app/notebooks" \
        adhd-tcn-replication
fi
