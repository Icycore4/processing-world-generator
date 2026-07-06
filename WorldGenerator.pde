int gridWidth = 100;
int gridHeight = 100;
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

// Simulation
ArrayList<Blob> blobs = new ArrayList<Blob>();
ArrayList<Bush> bushes = new ArrayList<Bush>();

PImage blobImage;

// Timing
int simulationStep = 0;

void settings() {
  size(1000, 1000);
}

void setup() {
  generateWorld();
  spawnInitialBushes();
  
  // Load blob image (placeholder - will use a circle if image not found)
  // blobImage = loadImage("blob.png");
}

void draw() {
  background(51);
  
  // Update camera position based on mouse movement
  if (mousePressed) {
    camX -= (mouseX - pmouseX) * 2 / zoomLevel;
    camY -= (mouseY - pmouseY) * 2 / zoomLevel;
  }
  
  // Spawn blob on click
  if (mousePressed) {
    float worldX = camX + (mouseX - width/2) / zoomLevel;
    float worldY = camY + (mouseY - height/2) / zoomLevel;
    spawnBlob(worldX / 5, worldY / 5); // Convert to grid coordinates
  }
  
  // Keyboard controls for camera
  if (keyPressed) {
    if (key == 'w' || key == 'W') camY -= 10 / zoomLevel;
    if (key == 's' || key == 'S') camY += 10 / zoomLevel;
    if (key == 'a' || key == 'A') camX -= 10 / zoomLevel;
    if (key == 'd' || key == 'D') camX += 10 / zoomLevel;
  }
  
  // Simulation updates
  if (frameCount % 5 == 0) {
    updateSimulation();
  }
  
  drawWorld();
  drawBlobs();
  drawBushes();
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

void spawnInitialBushes() {
  // Spawn bushes in grass biomes naturally
  for (int x = 0; x < gridWidth; x++) {
    for (int y = 0; y < gridHeight; y++) {
      float h = heightMap[x][y];
      float t = tempMap[x][y];
      
      // Spawn bushes in plains/forest (grass biomes)
      if (h >= 0.40 && h < 0.75 && t >= 0.35 && t < 0.7 && random(1) < 0.05) {
        bushes.add(new Bush(x + 0.5, y + 0.5, 3));
      }
    }
  }
}

void spawnBlob(float x, float y) {
  boolean isMale = random(1) < 0.5;
  blobs.add(new Blob(x, y, isMale, 100, 100)); // age 0, hunger 100, thirst 100
}

void updateSimulation() {
  // Update blobs
  for (int i = blobs.size() - 1; i >= 0; i--) {
    Blob b = blobs.get(i);
    b.update(heightMap, tempMap, bushes);
    
    if (b.isDead()) {
      blobs.remove(i);
    }
  }
  
  // Reproduction logic
  for (int i = 0; i < blobs.size(); i++) {
    for (int j = i + 1; j < blobs.size(); j++) {
      Blob b1 = blobs.get(i);
      Blob b2 = blobs.get(j);
      
      // Check if they can reproduce
      if (b1.canReproduce(b2)) {
        float childX = (b1.x + b2.x) / 2;
        float childY = (b1.y + b2.y) / 2;
        boolean childMale = random(1) < 0.5;
        
        Blob child = new Blob(childX, childY, childMale, 50, 50);
        blobs.add(child);
        
        // Reduce parents' energy
        b1.hunger += 20;
        b2.hunger += 20;
      }
    }
  }
  
  // Bush regrowth
  for (Bush bush : bushes) {
    bush.regrow();
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
  
  // Draw tiles
  for (int x = 0; x < gridWidth; x++) {
    for (int y = 0; y < gridHeight; y++) {
      float h = heightMap[x][y];
      float t = tempMap[x][y];
      
      color c = getTerrainColor(h, t);
      fill(c);
      
      rect(x * 5, y * 5, 5, 5);
    }
  }
  
  popMatrix();
}

void drawBlobs() {
  pushMatrix();
  
  translate(width / 2, height / 2);
  scale(zoomLevel);
  translate(-width / 2, -height / 2);
  translate(-camX, -camY);
  
  for (Blob b : blobs) {
    b.display();
  }
  
  popMatrix();
}

void drawBushes() {
  pushMatrix();
  
  translate(width / 2, height / 2);
  scale(zoomLevel);
  translate(-width / 2, -height / 2);
  translate(-camX, -camY);
  
  for (Bush bush : bushes) {
    bush.display();
  }
  
  popMatrix();
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
  text("Click to spawn blobs | W/A/S/D: Move | Scroll: Zoom", 10, 20);
  text("Blobs: " + blobs.size() + " | Bushes: " + bushes.size(), 10, 40);
  text("Zoom: " + String.format("%.2f", zoomLevel) + "x", 10, 60);
}

// Blob class
class Blob {
  float x, y;
  boolean isMale;
  int age;
  float hunger; // 0-100, higher is hungrier
  float thirst; // 0-100, higher is thirstier
  float speed = 0.05;
  float maxAge = 10000;
  
  Blob(float x, float y, boolean isMale, float hunger, float thirst) {
    this.x = x;
    this.y = y;
    this.isMale = isMale;
    this.age = 0;
    this.hunger = hunger;
    this.thirst = thirst;
  }
  
  void update(float[][] heightMap, float[][] tempMap, ArrayList<Bush> bushes) {
    age++;
    hunger += 0.5;
    thirst += 0.3;
    
    // Eat from nearby bushes
    for (Bush bush : bushes) {
      if (dist(x, y, bush.x, bush.y) < 1) {
        if (bush.fruits > 0) {
          hunger -= 10;
          bush.fruits--;
          hunger = max(0, hunger);
        }
      }
    }
    
    // Drink from water
    float h = getHeight(x, y, heightMap);
    if (h < 0.35) {
      thirst -= 5;
      thirst = max(0, thirst);
    }
    
    // Move towards food/water
    moveTowardsSurvival(heightMap, bushes);
    
    // Constrain to bounds
    x = constrain(x, 0, gridWidth - 0.1);
    y = constrain(y, 0, gridHeight - 0.1);
  }
  
  void moveTowardsSurvival(float[][] heightMap, ArrayList<Bush> bushes) {
    if (hunger > 50) {
      // Move towards nearest bush with fruit
      float closestDist = 10000;
      float targetX = x, targetY = y;
      
      for (Bush bush : bushes) {
        if (bush.fruits > 0) {
          float d = dist(x, y, bush.x, bush.y);
          if (d < closestDist) {
            closestDist = d;
            targetX = bush.x;
            targetY = bush.y;
          }
        }
      }
      
      if (closestDist < 10000) {
        x += (targetX - x) * speed;
        y += (targetY - y) * speed;
      }
    }
    
    if (thirst > 50) {
      // Move towards water
      boolean foundWater = false;
      for (float angle = 0; angle < TWO_PI; angle += PI / 4) {
        float nx = x + cos(angle);
        float ny = y + sin(angle);
        
        if (nx >= 0 && nx < gridWidth && ny >= 0 && ny < gridHeight) {
          float h = getHeight(nx, ny, heightMap);
          if (h < 0.35) {
            x += cos(angle) * speed;
            y += sin(angle) * speed;
            foundWater = true;
            break;
          }
        }
      }
    }
  }
  
  boolean canReproduce(Blob other) {
    if (this.isMale == other.isMale) return false; // Same gender
    if (this.hunger < 30 && other.hunger < 30) return false; // Both well-fed
    if (this.age < 100 || other.age < 100) return false; // Too young
    if (dist(this.x, this.y, other.x, other.y) > 2) return false; // Too far
    
    return true;
  }
  
  boolean isDead() {
    return age > maxAge || hunger > 100 || thirst > 100;
  }
  
  void display() {
    fill(isMale ? 100 : 200, 150, 100); // Brown/reddish for male, pinkish for female
    circle(x * 5, y * 5, 3);
  }
  
  float getHeight(float px, float py, float[][] heightMap) {
    int ix = (int)px;
    int iy = (int)py;
    if (ix >= 0 && ix < gridWidth && iy >= 0 && iy < gridHeight) {
      return heightMap[ix][iy];
    }
    return 0.5;
  }
}

// Bush class
class Bush {
  float x, y;
  int maxFruits = 3;
  int fruits;
  int regrowthCooldown = 0;
  int regrowthTime = 500;
  
  Bush(float x, float y, int fruits) {
    this.x = x;
    this.y = y;
    this.fruits = fruits;
  }
  
  void regrow() {
    if (fruits < maxFruits) {
      regrowthCooldown++;
      if (regrowthCooldown >= regrowthTime) {
        fruits++;
        regrowthCooldown = 0;
      }
    }
  }
  
  void display() {
    fill(34, 200, 34); // Green
    circle(x * 5, y * 5, 2);
    
    // Draw fruits as small dots
    fill(255, 0, 0); // Red
    for (int i = 0; i < fruits; i++) {
      float angle = TWO_PI * i / maxFruits;
      float fx = x + cos(angle) * 0.3;
      float fy = y + sin(angle) * 0.3;
      circle(fx * 5, fy * 5, 1);
    }
  }
}
