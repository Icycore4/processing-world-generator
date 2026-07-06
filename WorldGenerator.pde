int gridWidth = 100;
int gridHeight = 100;
int tileSize = 10;
float scale = 0.1;

int[][] worldMap;

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
  worldMap = new int[gridWidth][gridHeight];
  
  // Use Perlin noise for natural-looking terrain
  for (int x = 0; x < gridWidth; x++) {
    for (int y = 0; y < gridHeight; y++) {
      float value = noise(x * scale, y * scale);
      
      // Classify terrain based on noise value
      if (value < 0.35) {
        worldMap[x][y] = 0; // Water
      } else if (value < 0.45) {
        worldMap[x][y] = 1; // Sand/Desert
      } else if (value < 0.65) {
        worldMap[x][y] = 2; // Plains
      } else {
        worldMap[x][y] = 3; // Forest
      }
    }
  }
}

void drawWorld() {
  background(51);
  
  for (int x = 0; x < gridWidth; x++) {
    for (int y = 0; y < gridHeight; y++) {
      int tile = worldMap[x][y];
      
      // Set color based on terrain type
      switch(tile) {
        case 0: // Water
          fill(64, 164, 223);
          break;
        case 1: // Desert
          fill(238, 214, 175);
          break;
        case 2: // Plains
          fill(144, 238, 144);
          break;
        case 3: // Forest
          fill(34, 139, 34);
          break;
      }
      
      stroke(0);
      strokeWeight(0.5);
      rect(x * tileSize, y * tileSize, tileSize, tileSize);
    }
  }
}
