# Processing 2D World Generator

A procedurally generated 2D world with four different terrain types: water, desert, plains, and forest.

## Features

- **Perlin Noise Generation**: Creates natural-looking, continuous terrain
- **Four Terrain Types**:
  - 🌊 **Water** (Blue): Deep ocean areas
  - 🏜️ **Desert** (Sand): Arid regions
  - 🌾 **Plains** (Green): Grasslands
  - 🌲 **Forest** (Dark Green): Wooded areas
- **Customizable Parameters**: Adjust grid size, tile size, and noise scale
- **Interactive**: Click anywhere to generate a new random world

## How to Use

1. Open `WorldGenerator.pde` in Processing
2. Click the Play button to run
3. Click anywhere on the canvas to generate a new world

## Customization

Edit these variables in the code to change generation:

- `gridWidth` / `gridHeight`: Number of tiles (default: 100x100)
- `tileSize`: Size of each tile in pixels (default: 10)
- `scale`: Perlin noise scale - lower = more varied terrain, higher = larger regions (default: 0.1)

Adjust the noise thresholds in `generateWorld()` to change terrain distribution:
```java
if (value < 0.35) // Water threshold
else if (value < 0.45) // Desert threshold
else if (value < 0.65) // Plains threshold
else // Forest
```

## Example

Run the sketch to see a randomly generated world map with natural terrain clustering!
