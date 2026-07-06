int gridWidth = 1000;
int gridHeight = 700;
float tileSize = 5;
float heightScale = 0.1;
float tempScale = 0.08;

int[][] heightMap;
float[][] tempMap;

// Camera/movement variables
float camX = 0;
float camY = 0;

void settings() {
  size(1000, 1000);
}

void setup() {
  generateWorld();
}

void draw() {
  background(51);
  
  // Update camera position based on mouse movement
  if (mousePressed) {
    camX -= (mouseX - pmouseX) * 2;
    camY -= (mouseY - pmouseY) * 2;
  }
  
  // Keyboard controls for camera
  if (keyPressed) {
    if (key == 'w' || key == 'W') camY -= 10;
    if (key == 's' || key == 'S') camY += 10;
    if (key == 'a' || key == 'A') camX -= 10;
    if (key == 'd' || key == 'D') camX += 10;
  }
  
  drawWorld();
  drawHUD();
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
      } else if (heightValue < 0.40) {
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
  pushMatrix();
  translate(-camX, -camY);
  
  noStroke();
  
  for (int x = 0; x < gridWidth; x++) {
    for (int y = 0; y < gridHeight; y++) {
      int height = heightMap[x][y];
      float temp = tempMap[x][y];
      
      // Set color based on terrain type with smooth interpolation
      color c = getTerrainColor(height, temp);
      fill(c);
      
      rect(x * tileSize, y * tileSize, tileSize, tileSize);
    }
  }
  
  popMatrix();
}

color getTerrainColor(int height, float temp) {
  switch(height) {
    case 0: // Water
      return color(64, 164, 223);
    case 1: // Beach
      return color(238, 214, 175);
    case 2: // Main terrain - varies by temperature
      if (temp < 0.15) {
        return color(255, 255, 255); // Arctic plains (very cold)
      } else if (temp < 0.5) {
        return color(144, 238, 144); // Forest (slightly cold)
      } else if (temp < 0.7) {
        return color(144, 238, 144); // Plains (temperate)
      } else if (temp < 0.85) {
        return color(184, 184, 82); // Savannah (dark yellow, hot)
      } else {
        return color(255, 165, 0); // Desert (orange, very hot)
      }
    case 3: // Mountains
      return color(128, 128, 128);
  }
  return color(0);
}

void drawHUD() {
  fill(255);
  textSize(14);
  text("Mouse: Pan | W/A/S/D: Move", 10, 20);
  text("CamX: " + (int)camX + " CamY: " + (int)camY, 10, 40);
}
