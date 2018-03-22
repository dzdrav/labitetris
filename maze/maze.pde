// Simple maze game
//
// As any maze game, you start from somewhere (red square) and you have to find
// the exit (green square) as fast as possible.
// Each step is counted, so at the end, you will know how many steps you have walked
// in conparaison to the minimal needed steps to escape.

// Keys :
// R : Restart the game. A new maze is generated and time is cleared
// SPACE : Start the game
// ARROW LEFT : Left
// ARROW RIGHT : Right
// ARROW UP : Up
// ARROW DOWN : Down
color white = color (0xFF, 0xFF, 0xFF);
color blue = color (0x00, 0x00, 0xFF);
color red = color (0xFF, 0x00, 0x00);
color gray = color (0x80, 0x80, 0x80);
color green = color (0x00, 0xFF, 0x00);
color black = color (0x00, 0x00, 0x00);

int state_init = 0;
int state_run = 1;
int state_end = 2;

int velicina_kvadrata = 20;
int broj_kvadrata_x = 40;
int broj_kvadrata_y = 35;
int dim_tekst_okvira = 100;
int tekst_pomak = dim_tekst_okvira / 4;
int sirina = 630;
int pocetak_teksta_y = (broj_kvadrata_y + 1) * velicina_kvadrata;
// u setup() ide size(broj_kvadrata_x * velicina_kvadrata ,broj_kvadrata_y * velicina_kvadrata + dim_tekst_okvira)
//ali processing ne dozvoljava da budu varijable u size, pa moramo brojeve uvrstit


//=============== GAME ================
class MazeGame {
  MazeGame () {
    Reset();
  }

    void Reset () {
      _state = state_init;

       int p = int (random(1,6));
       //veći p = lakši labirint (u smislu glađih zidova)

      _maze = new Maze(broj_kvadrata_y, broj_kvadrata_x , p);
      _maze.compute ();
      _maze.show (velicina_kvadrata);

      _needToRedraw = true;

      _startTime = 0;
      _endTime = 0;

      ClearTextArea();

      textAlign(CENTER);
      fill(black);
      text("Press SPACE to start", sirina / 2, pocetak_teksta_y);
    }

    void Start() {
     if (_state == state_init) {
       Run();

       // glazba se ponavlja (loop)
       if (!player.isPlaying()){
         player.loop();
       }
       return;
     }
    }
    void Move () {
      if (_state == state_run) {
        if (keyCode == LEFT) _maze.goLeft();
        else if (keyCode == RIGHT) _maze.goRight();
        else if (keyCode == DOWN) _maze.goDown();
        else if (keyCode == UP) _maze.goUp();
      }
    }
    
    int getState(){
      return _state;
    }

    void Run() {
      _state = state_run;
      _startTime = millis();

      // Clear and draw score
      ClearTextArea();
    }

    void End() {
      _state = state_end;
      _endTime = millis();

      ClearTextArea();

      textAlign(CENTER);
      fill(black);
      text("FINISHED in",sirina / 2, pocetak_teksta_y);
      int delta = (_endTime - _startTime) / 1000;
      int m = delta / 60;
      int s = (delta - m*60);
      String ti = "Time : " + m + "'" + s + "\"";
      text(ti ,sirina / 2, pocetak_teksta_y + tekst_pomak);
      String p = "Current : " + _maze.getStep() + " steps";
      text(p , sirina / 2, pocetak_teksta_y + 2*tekst_pomak);
      String d = "Best : " + _maze.getMaxDistance () + " steps";
      text(d , sirina / 2, pocetak_teksta_y + 3*tekst_pomak);

      // pauziranje pozadinske glazbe
      player.pause();
      player.rewind();
      // pobjednička glazba
      win_sound.play();
    }

    void ClearTextArea () {
      fill (white);
      rect(0, velicina_kvadrata * broj_kvadrata_y ,broj_kvadrata_x * velicina_kvadrata , dim_tekst_okvira);
    }

    void KeyPressed (int k) {
      if (k == 'r') Reset(); // Resetting game
      if (k == ' ') Start(); // Start

      Move ();
    }

    void Manage() {
      if (_state == state_run) {
        if (_maze.AtEnd()) End();
        else { // Updating current time
          fill (white);
          rect(0, velicina_kvadrata * broj_kvadrata_y ,broj_kvadrata_x * velicina_kvadrata , dim_tekst_okvira);
          fill (black);
          int delta = (millis() - _startTime) / 1000;
          int m = delta / 60;
          int s = (delta - m*60);
          String ti = "Time : " + m + "'" + s + "\"";
          text(ti ,sirina / 2, pocetak_teksta_y + tekst_pomak);
        }
      }
   }

    int _state;
    boolean _needToRedraw;

    int _startTime;
    int _endTime;

    Maze _maze;
};

int WALL=0;
int BORDER=1;
int PAS=2;
//=============== NODE ================
class Node {
  int _x;
  int _y;
  int _dir;
  int _distance;

  Node (int x, int y, int dir, int distance)  {
    _x = x;
    _y = y;
    _dir = dir;
    _distance = distance;
  }

  int getX () { return _x; }
  int getY () { return _y; }
  int getDir () { return _dir; }
  int getDistance () { return _distance; }

};

//=============== MAZE ================
class Maze {
  Maze (int h, int w, int p) {
    _h = h;
    _w = w;
    _sx = 1;
    _sy = 1;
    _dirs = 0;
    _p = p;

    _m = new int [_h][_w];
    _nodes = new ArrayList();

   // reset();
  }


void show (int velicina_kvadrata) {

  _d = velicina_kvadrata;

  // Maze
  for (int j = 0; j < _h; ++j) {
    for (int k = 0; k < _w; ++k) {
      color col = red;
      int val = _m[j][k];
      if (val == WALL || val == BORDER) col = gray;
      else if (val == PAS) col = white;

      rectMode(CORNER);
      fill(col);
      rect(k*_d, j*_d, _d, _d);
    }
  }

  // Starting point
  fill(red);
  rect(_sx*_d, _sy*_d, _d, _d);

  // Ending point
  fill(green);
  rect(_ex*_d, _ey*_d, _d, _d);
  }

  void checkNode (Node aNode) {
      int x = aNode.getX();
      int y = aNode.getY();
      int distance = aNode.getDistance();

      switch (aNode.getDir()) {
      case 1: if (TestN (x, y-1)) addNode (x, y-1, distance+1); break; // North
      case 2: if (TestE (x+1, y)) addNode (x+1, y, distance+1); break; // East
      case 3: if (TestS (x, y+1)) addNode (x, y+1, distance+1); break; // South
      case 4: if (TestW (x-1, y)) addNode (x-1, y, distance+1); break; // West
      default: break;
      }
  }

  boolean TestN (int x, int y) {
    if (_m[y][x] != WALL) return false;
    if (_m[y-1][x] == PAS) return false;
    if (_m[y][x-1] == PAS) return false;
    if (_m[y][x+1] == PAS) return false;
    return true;
  }

  boolean TestE (int x, int y) {
    if (_m[y][x] != WALL) return false;
    if (_m[y][x+1] == PAS) return false;
    if (_m[y-1][x] == PAS) return false;
    if (_m[y+1][x] == PAS) return false;
    return true;
}

  boolean TestS (int x, int y) {
    if (_m[y][x] != WALL) return false;
    if (_m[y][x-1] == PAS) return false;
    if (_m[y][x+1] == PAS) return false;
    if (_m[y+1][x] == PAS) return false;
    return true;
  }

  boolean TestW (int x, int y){
    if (_m[y][x] != WALL) return false;
    if (_m[y][x-1] == PAS) return false;
    if (_m[y-1][x] == PAS) return false;
    if (_m[y+1][x] == PAS) return false;
    return true;
  }

  void reset () {
    for (int y = 0; y < _h; ++y) {
      for (int x = 0; x < _w; ++x) {
        _m[y][x]= WALL;
      }
    }

    for (int y= 0; y < _h; ++y) {
      _m[y][0] = BORDER;
      _m[y][_w-1] = BORDER;
    }

    for (int x= 0; x < _w; ++x) {
      _m[0][x] = BORDER;
      _m[_h-1][x] = BORDER;
    }

    _sx = int (random (1, _w-1));
    _sy = int (random (1, _h-1));
    _ex = _sx;
    _ey = _sy;
    _mx = _sx;
    _my = _sy;

    _maxdistance=0;

     _d = 4;
    _dirs = int (random (0, 24));
  }

  void addNode (int x, int y, int distance) {
    // Compute new directions
    if (_p > 1) {
      if (int(random (0, _p)) == 0) {
          _dirs = int(random (0, 24)); // Select moves order
      }
    }
    else {
      _dirs = int (random (0, 24)); // Select moves order
    }

    for (int idx = 0; idx < 4; ++idx) {
      int direction = dirset[_dirs][idx];
      _nodes.add (new Node (x, y, direction, distance));  // Adds 4 Nodes
    }

    _m[y][x] = PAS; // OK we walked on it

    if (distance > _maxdistance) {
      _maxdistance = distance;
      _ex = x;
      _ey = y;
    }
  }

  void compute () {
    reset ();

    addNode (_sx, _sy, 0); // inserting first node
    while (true) {
      int n = _nodes.size();
      if (n == 0) return; // The end

      Node node = (Node) _nodes.get(n - 1); // Taking last one
      _nodes.remove (n - 1);
      checkNode (node);
    }
  }

  int getCell (int y, int x) {
    if (x >= _w || x < 0) return 0;
    if (y >= _h || y < 0) return 0;
    return _m[y][x];
  }

  int getMaxDistance () { return _maxdistance; }
  int getStep () { return _step; }

  boolean AtEnd() {
    if (_my != _ey) return false;
    if (_mx != _ex) return false;
    return true;
  }

  void goLeft () {
     if (_m[_my][_mx-1]==PAS) {
        _step++;
       fill(0xFF, 0xFF, 0xFF);
       rect(_mx*_d, _my*_d, _d, _d);
       _mx--;
       fill(blue);
       rect(_mx*_d, _my*_d, _d, _d);
     }
  }

       void goRight () {
         if (_m[_my][_mx+1]==PAS) {
            _step++;
           fill(0xFF, 0xFF, 0xFF);
           rect(_mx*_d, _my*_d, _d, _d);
           _mx++;
           fill(blue);
           rect(_mx*_d, _my*_d, _d, _d);
         }
      }

  void goUp () {
     if (_m[_my-1][_mx]==PAS) {
        _step++;
       fill(0xFF, 0xFF, 0xFF);
       rect(_mx*_d, _my*_d, _d, _d);
       _my--;
       fill(blue);
       rect(_mx*_d, _my*_d, _d, _d);
     }
  }

       void goDown () {
         if (_m[_my+1][_mx]==PAS) {
            _step++;
           fill(0xFF, 0xFF, 0xFF);
           rect(_mx*_d, _my*_d, _d, _d);
           _my++;
           fill(blue);
           rect(_mx*_d, _my*_d, _d, _d);
         }
      }

  int [][]_m;
  int _h, _w; // H & W
  int _sx, _sy; // Starting point
  int _ex, _ey; // Ending point

  int _maxdistance; // Max distance between starting and ending point

  int _d; // Drawing size for cells

  // Navigation
  int _step; // user steps
  int _mx, _my; // Current user position

  int _dirs;
  int _p; // Change direction probablility : 1->each step, 4-> 1/4 step
  ArrayList _nodes;
};

int [][] dirset = {
    { 1, 2, 3, 4},
    { 1, 2, 4, 3},
    { 1, 3, 2, 4},
    { 1, 3, 4, 2},
    { 1, 4, 2, 3},
    { 1, 4, 3, 2},

    { 2, 1, 3, 4},
    { 2, 1, 4, 3},
    { 2, 3, 1, 4},
    { 2, 3, 4, 1},
    { 2, 4, 1, 3},
    { 2, 4, 3, 1},

    { 3, 1, 2, 4},
    { 3, 1, 4, 2},
    { 3, 2, 1, 4},
    { 3, 2, 4, 1},
    { 3, 4, 1, 2},
    { 3, 4, 2, 1},

    { 4, 1, 2, 3},
    { 4, 1, 3, 2},
    { 4, 2, 1 ,3},
    { 4, 2, 3, 1},
    { 4, 3, 1, 2},
    { 4, 3, 2, 1}
};

//=============== MAIN ================
MazeGame mazeGame;
PFont font;

// sound library
import ddf.minim.*;

Minim minim;
AudioPlayer player;
AudioPlayer win_sound;
String music_name = "theme_music_maze.mp3";
String music_win = "music_win.mp3";

void setup () {
  size (800,800);

  colorMode(RGB, height, height, height);
  background(white);
  noFill();
  noStroke ();

  font = createFont("Arial",20,true);  // Loading font
  textFont(font);

  // music setup
  minim = new Minim(this);
  player = minim.loadFile(music_name);
  win_sound = minim.loadFile(music_win);

  mazeGame = new MazeGame ();
}

void draw () {
  mazeGame.Manage();
}

void keyPressed() {
  mazeGame.KeyPressed (key);
}