int gridWidth = 100;
int gridHeight = 100;
int tileSize = 2.5;
float heightScale = 0.1;
float tempScale = 0.08;

int[][] heightMap;
float[][] tempMap;

void settings() {
  size(1000, 1000);
}

void setup() {
  generateWorld();
}

void draw() {
  drawWorld();
  
  // Regenerate on mouse press
  if (mousePressed) {
    generateWorld();
  }
}

void generateWorld() {
  heightMap = new int[gridWidth][gridHeight];
  tempMap = new float[gridWidth][gridHeight];
  
  // Generate height map using Perlin noise
  for (int x = 0; x < gridWidth; x++) {
    for (int y = 0; y < gridHeight; y++) {
      float heightValue = noise(x * heightScale, y * heightScale);
      
      // Classify terrain based on height value
      if (heightValue < 0.35) {
        heightMap[x][y] = 0; // Water
      } else if (heightValue < 0.45) {
        heightMap[x][y] = 1; // Beach
      } else if (heightValue < 0.75) {
        heightMap[x][y] = 2; // Main terrain (plains/desert/savannah/forest/arctic - determined by temp)
      } else {
        heightMap[x][y] = 3; // Mountains
      }
    }
  }
  
  // Generate temperature map using separate Perlin noise
  for (int x = 0; x < gridWidth; x++) {
    for (int y = 0; y < gridHeight; y++) {
      tempMap[x][y] = noise(1000 + x * tempScale, 1000 + y * tempScale);
    }
  }
}

void drawWorld() {
  background(51);
  
  for (int x = 0; x < gridWidth; x++) {
    for (int y = 0; y < gridHeight; y++) {
      int height = heightMap[x][y];
      float temp = tempMap[x][y];
      
      // Set color based on terrain type
      switch(height) {
        case 0: // Water
          fill(64, 164, 223);
          break;
        case 1: // Beach
          fill(238, 214, 175);
          break;
        case 2: // Main terrain - varies by temperature
          if (temp < 0.2) {
            fill(255, 255, 255); // Arctic plains (very cold)
          } else if (temp < 0.35) {
            fill(144, 238, 144); // Forest (slightly cold)
          } else if (temp < 0.5) {
            fill(144, 238, 144); // Plains (temperate)
          } else if (temp < 0.7) {
            fill(184, 184, 82); // Savannah (dark yellow, hot)
          } else {
            fill(255, 165, 0); // Desert (orange, very hot)
          }
          break;
        case 3: // Mountains
          fill(128, 128, 128);
          break;
      }
      
      noStroke();
      rect(x * tileSize, y * tileSize, tileSize, tileSize);
    }
  }
}
