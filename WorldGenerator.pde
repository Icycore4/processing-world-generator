int gridWidth = 1000;
int gridHeight = 700;
float heightScale = 0.1;
float tempScale = 0.08;

float[][] heightMap;
float[][] tempMap;

// Camera/movement variables
float camX = 0;
float camY = 0;
float zoomLevel = 1.0;
float minZoom = 0.2;
float maxZoom = 10.0;

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
    camX -= (mouseX - pmouseX) * 2 / zoomLevel;
    camY -= (mouseY - pmouseY) * 2 / zoomLevel;
  }
  
  // Keyboard controls for camera
  if (keyPressed) {
    if (key == 'w' || key == 'W') camY -= 10 / zoomLevel;
    if (key == 's' || key == 'S') camY += 10 / zoomLevel;
    if (key == 'a' || key == 'A') camX -= 10 / zoomLevel;
    if (key == 'd' || key == 'D') camX += 10 / zoomLevel;
  }
  
  drawWorld();
  drawHUD();
}

void generateWorld() {
  heightMap = new float[gridWidth][gridHeight];
  tempMap = new float[gridWidth][gridHeight];
  
  // Generate smooth height map using Perlin noise
  for (int x = 0; x < gridWidth; x++) {
    for (int y = 0; y < gridHeight; y++) {
      heightMap[x][y] = noise(x * heightScale, y * heightScale);
      tempMap[x][y] = noise(1000 + x * tempScale, 1000 + y * tempScale);
    }
  }
}

void drawWorld() {
  pushMatrix();
  
  // Apply zoom around center
  translate(width / 2, height / 2);
  scale(zoomLevel);
  translate(-width / 2, -height / 2);
  
  // Apply camera pan
  translate(-camX, -camY);
  
  noStroke();
  
  // Draw with smooth interpolation
  for (int x = 0; x < gridWidth - 1; x++) {
    for (int y = 0; y < gridHeight - 1; y++) {
      // Get the four corner heights and temperatures
      float h1 = heightMap[x][y];
      float h2 = heightMap[x + 1][y];
      float h3 = heightMap[x + 1][y + 1];
      float h4 = heightMap[x][y + 1];
      
      float t1 = tempMap[x][y];
      float t2 = tempMap[x + 1][y];
      float t3 = tempMap[x + 1][y + 1];
      float t4 = tempMap[x][y + 1];
      
      // Draw smoothly interpolated quad
      drawSmoothTile(x, y, h1, h2, h3, h4, t1, t2, t3, t4, 5);
    }
  }
  
  popMatrix();
}

void drawSmoothTile(int gridX, int gridY, float h1, float h2, float h3, float h4, float t1, float t2, float t3, float t4, float tileSize) {
  float x1 = gridX * tileSize;
  float y1 = gridY * tileSize;
  float x2 = (gridX + 1) * tileSize;
  float y2 = (gridY + 1) * tileSize;
  
  int subdivisions = 4;
  float step = 1.0 / subdivisions;
  
  // Create subdivided mesh for smooth terrain
  for (int i = 0; i < subdivisions; i++) {
    for (int j = 0; j < subdivisions; j++) {
      // Interpolate positions
      float sx1 = x1 + i * (x2 - x1) * step;
      float sy1 = y1 + j * (y2 - y1) * step;
      float sx2 = sx1 + (x2 - x1) * step;
      float sy2 = sy1 + (y2 - y1) * step;
      
      // Interpolate height and temperature at corners
      float u1 = i * step;
      float v1 = j * step;
      float u2 = (i + 1) * step;
      float v2 = (j + 1) * step;
      
      float h_tl = bilinearInterpolate(h1, h2, h3, h4, u1, v1);
      float h_tr = bilinearInterpolate(h1, h2, h3, h4, u2, v1);
      float h_br = bilinearInterpolate(h1, h2, h3, h4, u2, v2);
      float h_bl = bilinearInterpolate(h1, h2, h3, h4, u1, v2);
      
      float t_tl = bilinearInterpolate(t1, t2, t3, t4, u1, v1);
      float t_tr = bilinearInterpolate(t1, t2, t3, t4, u2, v1);
      float t_br = bilinearInterpolate(t1, t2, t3, t4, u2, v2);
      float t_bl = bilinearInterpolate(t1, t2, t3, t4, u1, v2);
      
      // Use average height to determine terrain type
      float avgHeight = (h_tl + h_tr + h_br + h_bl) / 4.0;
      float avgTemp = (t_tl + t_tr + t_br + t_bl) / 4.0;
      
      fill(getTerrainColor(avgHeight, avgTemp));
      
      beginShape();
      vertex(sx1, sy1);
      vertex(sx2, sy1);
      vertex(sx2, sy2);
      vertex(sx1, sy2);
      endShape(CLOSE);
    }
  }
}

float bilinearInterpolate(float v1, float v2, float v3, float v4, float u, float v) {
  // v1 = top-left, v2 = top-right, v3 = bottom-right, v4 = bottom-left
  float top = lerp(v1, v2, u);
  float bottom = lerp(v4, v3, u);
  return lerp(top, bottom, v);
}

color getTerrainColor(float height, float temp) {
  if (height < 0.35) {
    return color(64, 164, 223); // Water
  } else if (height < 0.40) {
    return color(238, 214, 175); // Beach
  } else if (height < 0.75) {
    // Main terrain - varies by temperature
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
  } else {
    return color(128, 128, 128); // Mountains
  }
}

void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  zoomLevel *= pow(1.1, -e);
  zoomLevel = constrain(zoomLevel, minZoom, maxZoom);
}

void drawHUD() {
  fill(255);
  textSize(14);
  text("Mouse: Pan | W/A/S/D: Move | Scroll: Zoom", 10, 20);
  text("CamX: " + (int)camX + " CamY: " + (int)camY + " Zoom: " + String.format("%.2f", zoomLevel) + "x", 10, 40);
}
