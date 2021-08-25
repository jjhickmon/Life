static int cell_size = 10;
static int rows = 600 / cell_size;
static int columns = 800 / cell_size;
static Cell[][] grid = new Cell[rows][columns];
static Cell[][] empty_grid = new Cell[rows][columns];
boolean running = false;
boolean m_locked = false; //locks mouse
boolean lock_live = false;
boolean lock_dead = false;
int sleep_time = 20; // time between updates in milliseconds

void setup(){
  size(800, 600);
  surface.setTitle("Game of Life: Stopped - " + sleep_time + " ms");
  for(int row = 0; row < rows; row++){
    for(int col = 0; col < columns; col++){
      grid[row][col] = new Cell(col * cell_size, row * cell_size, 255);
      empty_grid[row][col] = new Cell(col * cell_size, row * cell_size, 255);
    }
  }
}

int getNeighbors(Cell cell, Cell[][] g){
    int total = 0;
    int r = (cell.y/cell.size);
    int c = (cell.x/cell.size);
    for(int i = r - 1; i <= r + 1; i++){
      for(int j = c - 1; j <= c + 1; j++){
        if(i == r && j == c){ continue; }
        if(g[Math.floorMod(i, rows)][Math.floorMod(j, columns)].isDead == false){
          total++;
        }
      }
    }
    return total;
  }

void updateGrid(){
  // deep copy
  Cell[][] old_grid = new Cell[rows][columns];
  for(int row = 0; row < rows; row++){
    for(int col = 0; col < columns; col++){
      old_grid[row][col] = new Cell(grid[row][col]);
    }
  }
  
  // game logic
  for(int row = 0; row < rows; row++){
    for(int col = 0; col < columns; col++){
      Cell old_cell = old_grid[row][col];
      if(old_cell.isDead && (getNeighbors(old_cell, old_grid) == 3)){
        grid[row][col].isDead = false;
      } else if (!old_cell.isDead && (getNeighbors(old_cell, old_grid) == 2 || getNeighbors(old_cell, old_grid) == 3)){
        grid[row][col].isDead = false;
      } else {
        grid[row][col].isDead = true;
      }
    }
  }
  
  // update grid
  for(int row = 0; row < rows; row++){
    for(int col = 0; col < columns; col++){
      grid[row][col].update();
    }
  }
}

void draw(){
  // update grid
  if(running){
    updateGrid();
    // delay time
    try{
    Thread.sleep(sleep_time);
    } catch (InterruptedException e){
      Thread.currentThread().interrupt();
    }
  }
  
  
  for(Cell[] row : grid){
    for(Cell cell : row){
      cell.draw();
    }
  }
}

void mouseReleased(){
  m_locked = false;
}

void mousePressed(){
  Cell cell = grid[(int)Math.round(mouseY/cell_size)][(int)Math.round(mouseX/cell_size)];
  if (!m_locked){
    if(cell.isDead){ cell.isDead = false; lock_live = true; lock_dead = false; }
    else if(!cell.isDead){ cell.isDead = false; lock_dead = true; lock_live = false; }
    m_locked = true;
    cell.update();
  }
}

void mouseDragged(){
  Cell cell = grid[(int)Math.round(mouseY/cell_size)][(int)Math.round(mouseX/cell_size)];
  if(lock_live){
    if(cell.isDead){ cell.isDead = false; cell.update(); }
  } else if(lock_dead){
    if(!cell.isDead){ cell.isDead = true; cell.update(); }
  }
}

void keyPressed() {
  if (key == ' ') {
    running = !running;
  }
  if (key == '-'){
    if(sleep_time > 10){
      sleep_time -= 10;
    }
  }
  if (key == '=' || key == '+'){
    sleep_time += 10;
  }
  
  if(running){
      surface.setTitle("Game of Life: Running - " + sleep_time + " ms");
  } else {
      surface.setTitle("Game of Life: Stopped - " + sleep_time + " ms");
  }
}

class Cell {
  color c;
  int x;
  int y;
  int row;
  int col;
  int size;
  boolean isDead;
  
  Cell(Cell cell){
    x = cell.x;
    y = cell.y;
    row = cell.row;
    col = cell.col;
    c = cell.c;
    size = cell.size;
    isDead = cell.isDead;
  }
  
  Cell(int x_pos, int y_pos, color c_color){
    x = x_pos;
    y = y_pos;
    row = y/cell_size;
    col = x/cell_size;
    c = c_color;
    size = cell_size;
    isDead = true;
  }
  
  void update(){
    if(this.isDead){
      c = 255;
    } else {
      c = 0;
    }
  }
  
  void draw(){
    fill(c, c, c);
    rect(x, y, size, size);
  }
}
