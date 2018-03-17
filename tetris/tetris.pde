int w = 16;
int h = 25;
int sizeOfCube = 45;
int dt; // delay between each move
int currentTime;
Grid grid;
Piece piece;
Piece nextPiece;
Pieces pieces;
Score score;
int rotation = 0;//rotation status, from 0 to 3
int level = 1;
int numberOfFullLines = 0;


int txtSize = 30;
int textColor = color(34, 230, 190);

Boolean gameOver = false;
Boolean gameOn = false;

// sound
import ddf.minim.*;

Minim minim;
AudioPlayer player;
String music_name = "theme_music.mp3";

// dzdrav: shape texture files
String[] figureNames = {"figure-one.png"
        ,"figure-two.png"
        ,"figure-three.png"
        ,"figure-four.png"
        ,"figure-five.png"
        ,"figure-six.png"
        ,"figure-seven.png"};
PImage[] figures = new PImage[figureNames.length];

void setup() {
  size(1250, 1205, P2D);
  textSize(30);
  // dzdrav loading textures for the shapes
  for (int i = 0; i < figureNames.length; ++i){
    figures[i] = loadImage(figureNames[i]);
  }
  // dzdrav: loading music
  minim = new Minim(this);
  player = minim.loadFile(music_name);
}

void initialize() {
  level = 1;
  numberOfFullLines = 0;
  dt = 1000;
  currentTime = millis();
  score = new Score();
  grid = new Grid();
  pieces = new Pieces();
  piece = new Piece(-1);
  nextPiece = new Piece(-1);
}

void draw() {
  background(60);

  if(grid != null) {
    grid.drawGrid();
    int timer = millis();
    if (gameOn) {
      //promjena vremena ide po sekundama, svaku sekundu se spušta oblik
      if (timer - currentTime > dt) {
        currentTime = timer;
        piece.oneStepDown();
      }
    }
    piece.display(false);
    score.display();
    if (!player.isPlaying()){
      player.loop();
    }
  }
  if (gameOver) {
    noStroke();
    fill(255, 60);
    rect(200, 260, 240, 2*txtSize, 3);
    fill(textColor);
    text("Game Over", 225, 290);
    player.pause();
  }
  if (!gameOn) {
    noStroke();
    fill(255, 60);
    rect(200, 190, 500, 2*txtSize, 3);
    fill(textColor);
    text("press 's' to start playing!", 210, 220);
  }
}

void goToNextPiece() {
  //nextPiece je globalna varijabla, u init je postavljena na random piece
  piece = new Piece(nextPiece.kind);
  nextPiece = new Piece(-1);
  rotation = 0;
}

void goToNextLevel() {
  score.addLevelPoints();
  level = 1 + int(numberOfFullLines / 10);
  //sa svakim levelom idu kockice još malo brže :)
  dt *= .8;
}

void keyPressed() {
  if (key == CODED && gameOn) {
    switch(keyCode) {
    case LEFT:
    case RIGHT:
    case DOWN:
    case UP:
    case SHIFT:
      piece.inputKey(keyCode);
      break;
    }
  } else if (keyCode == 83) {// "s"
    if(!gameOn) {
      initialize();
      //soundGameStart();
      gameOver = false;
      gameOn = true;
    }
  } else if (keyCode == 80) {// "p"
      if(gameOn) {
        if(looping) {
        noStroke();
        fill(255, 60);
        rect(150, 190, 500, 2*txtSize, 3);
        fill(textColor);
        text("press 'p' to resume playing!", 170, 220);
        player.pause();
        noLoop();
        }
        else {
          loop();
          player.loop();
        }
      }
  }
}

class Grid {
  int [][] cells = new int[w][h];

  Grid() {
    for (int i = 0; i < w; i ++)
      for (int j = 0; j < h; j ++)
        cells[i][j] = 0;
  }

  Boolean isFree(int x, int y) {
    if (x > -1 && x < w && y > -1 && y < h)
      return cells[x][y] == 0;
    else if (y < 0)
      return true;
   //println("WARNING: trying to access out of bond cell, x: "+x+" y: "+y);
    return false;
  }

  Boolean pieceFits() {
    int x = piece.x;
    int y = piece.y;
    int[][][] pos = piece.pos;
    Boolean pieceOneStepDownOk = true;
    for (int i = 0; i < 4; i ++) {
      int tmpx = pos[rotation][i][0]+x;
      int tmpy = pos[rotation][i][1]+y;
      if (tmpy >= h || !isFree(tmpx, tmpy)) {
        pieceOneStepDownOk = false;
        break;
      }
    }
    return pieceOneStepDownOk;
  }

  void addPieceToGrid() {
    int x = piece.x;
    int y = piece.y;
    //println("addPieceToGrid x: "+x+" y: "+y);
    int[][][] pos = piece.pos;
    for (int i = 0; i < 4; i ++) {
      if(pos[rotation][i][1]+y >= 0){
        cells[pos[rotation][i][0]+x][pos[rotation][i][1]+y] = piece.c;
      }else{
        gameOn = false;
        gameOver = true;
        //println("game over");
        return;
      }
    }
    score.addPiecePoints();
    checkFullLines();
    goToNextPiece();
    drawGrid();
  }

//check for full lines and delete them
  void checkFullLines() {
    int nb = 0; //number of full lines
    for (int j = 0; j < h; j ++) {
      Boolean fullLine = true;
      for (int i = 0; i < w; i++) {
        fullLine = cells[i][j] != 0;
        if (!fullLine)
          break;
      }
      // this jth line if full, delete it
      if (fullLine) {
        nb++;
        for (int k = j; k > 0; k--) {
          for (int i = 0; i < w; i++)
            cells[i][k] = cells[i][k-1];
        }
        // top line will be empty
        for (int i = 0; i < w; i++) {
          cells[i][0] = 0;
        }
      }
    }
    checkLevelAddPoints(nb);
  }

  void checkLevelAddPoints(int nb) {
    //println("deleted lines: "+nb);
    numberOfFullLines += nb;
    if (int(numberOfFullLines / 10) > level-1) {
      goToNextLevel();
    }
    score.addLinePoints(nb);
  }

  void setToBottom() {
    //int originalY = piece.y;
    int j = 0;
    for (j = 0; j < h; j ++) {
      if (!pieceFits())
        break;
      else
        piece.y++;
    }
    piece.y--;
    addPieceToGrid();
  }

  void drawGrid() {
    stroke(120);
    pushMatrix();
    translate(200, 40);
    for (int i = 0; i <= w; i ++)
      line(i*sizeOfCube, 0, i*sizeOfCube, h*sizeOfCube);
    for (int j = 0; j <= h; j ++)
      line(0, j*sizeOfCube, w*sizeOfCube, j*sizeOfCube);

    stroke(80);
    for (int i = 0; i < w; i ++) {
      for (int j = 0; j < h; j ++) {
        if (cells[i][j] != 0) {
          fill(cells[i][j]);
          rect(i*sizeOfCube, j*sizeOfCube, sizeOfCube, sizeOfCube);
        }
      }
    }
    popMatrix();
  }
}

class Piece {
  final color[] colors = {
    color(128, 12, 128), //purple
    color(230, 12, 12), //red
    color(12, 230, 12), //green
    color(9, 239, 230), //cyan
    color(230, 230, 9), //yellow
    color(230, 128, 9), //orange
    color(12, 12, 230) //blue
  };

  // [rotation][block nb][x or y]
  final int[][][] pos;
  int x = int(w/2);
  int y = 0;
  int kind;
  int c;

  Piece(int k) {
    kind = k < 0 ? int(random(0, 7)) : k;
    c = colors[kind];
    rotation = 0;
    pos = pieces.pos[kind];
  }

  void display(Boolean still) {
    stroke(250);
    fill(c);
    //texture(texture);
    pushMatrix();
    if (!still) {
      translate(200, 40);
      translate(x*sizeOfCube, y*sizeOfCube);
    }
    int rot = still ? 0 : rotation;
    for (int i = 0; i < 4; i++) {
      //rect(pos[rot][i][0] * sizeOfCube, pos[rot][i][1] * sizeOfCube, 20, 20);
      //image(texture, pos[rot][i][0] * sizeOfCube, pos[rot][i][1] * sizeOfCube, 20, 20);
      image(figures[kind], pos[rot][i][0] * sizeOfCube, pos[rot][i][1] * sizeOfCube, sizeOfCube, sizeOfCube);
    }
    popMatrix();
  }

  // goes down if can else piece is added to grid
  void oneStepDown() {
    y += 1;
    if(!grid.pieceFits()){
      piece.y -= 1;
      grid.addPieceToGrid();
    }
  }
  //go one step left
  void oneStepLeft() {
    x -= 1;
  }

  //go one step right
  void oneStepRight() {
    x += 1;
  }

  void goToBottom() {
    grid.setToBottom();
  }

  void inputKey(int k) {
    switch(k) {
    case LEFT:
      oneStepLeft();
      if(grid.pieceFits()){
        //soundLeftRight();
      }else {
         oneStepRight();
      }
      break;
    case RIGHT:
      oneStepRight();
      if(grid.pieceFits()){
        //soundLeftRight();
      }else{
         oneStepLeft();
      }
      break;
    case DOWN:
      oneStepDown();
      break;
    case UP:
      rotation = (rotation+1)%4;
      if(!grid.pieceFits()){
         rotation = rotation-1 < 0 ? 3 : rotation-1;
         //soundRotationFail();
      }else{
        //soundRotation();
      }
      break;
    case SHIFT:
      goToBottom();
      break;
    }
  }
}

class Pieces {
  int[][][][] pos = new int [7][4][4][2];

  Pieces() {
    ////   @   ////
    //// @ @ @ ////
    pos[0][0][0][0] = -1;//piece 0, rotation 0, point nb 0, x
    pos[0][0][0][1] = 0;// piece 0, rotation 0, point nb 0, y
    pos[0][0][1][0] = 0;
    pos[0][0][1][1] = 0;
    pos[0][0][2][0] = 1;
    pos[0][0][2][1] = 0;
    pos[0][0][3][0] = 0;
    pos[0][0][3][1] = 1;

    pos[0][1][0][0] = 0;
    pos[0][1][0][1] = 0;
    pos[0][1][1][0] = 1;
    pos[0][1][1][1] = 0;
    pos[0][1][2][0] = 0;
    pos[0][1][2][1] = -1;
    pos[0][1][3][0] = 0;
    pos[0][1][3][1] = 1;

    pos[0][2][0][0] = -1;
    pos[0][2][0][1] = 0;
    pos[0][2][1][0] = 0;
    pos[0][2][1][1] = 0;
    pos[0][2][2][0] = 1;
    pos[0][2][2][1] = 0;
    pos[0][2][3][0] = 0;
    pos[0][2][3][1] = -1;

    pos[0][3][0][0] = -1;
    pos[0][3][0][1] = 0;
    pos[0][3][1][0] = 0;
    pos[0][3][1][1] = 0;
    pos[0][3][2][0] = 0;
    pos[0][3][2][1] = -1;
    pos[0][3][3][0] = 0;
    pos[0][3][3][1] = 1;

    //// @ @   ////
    ////   @ @ ////
    pos[1][0][0][0] = pos[1][2][0][0] = -1;//piece 1, rotation 0, point nb 0, x
    pos[1][0][0][1] = pos[1][2][0][1] = 1;// piece 1, rotation 0, point nb 0, y
    pos[1][0][1][0] = pos[1][2][1][0] = 0;
    pos[1][0][1][1] = pos[1][2][1][1] = 1;
    pos[1][0][2][0] = pos[1][2][2][0] = 0;
    pos[1][0][2][1] = pos[1][2][2][1] = 0;
    pos[1][0][3][0] = pos[1][2][3][0] = 1;
    pos[1][0][3][1] = pos[1][2][3][1] = 0;

    pos[1][1][0][0] = pos[1][3][0][0] = -1;
    pos[1][1][0][1] = pos[1][3][0][1] = 0;
    pos[1][1][1][0] = pos[1][3][1][0] = 0;
    pos[1][1][1][1] = pos[1][3][1][1] = 0;
    pos[1][1][2][0] = pos[1][3][2][0] = -1;
    pos[1][1][2][1] = pos[1][3][2][1] = -1;
    pos[1][1][3][0] = pos[1][3][3][0] = 0;
    pos[1][1][3][1] = pos[1][3][3][1] = 1;

    ////   @ @ ////
    //// @ @   ////
    pos[2][0][0][0] = pos[2][2][0][0] = 0;//piece 2, rotation 0 and 2, point nb 0, x
    pos[2][0][0][1] = pos[2][2][0][1] = 1;//piece 2, rotation 0 and 2, point nb 0, y
    pos[2][0][1][0] = pos[2][2][1][0] = 1;
    pos[2][0][1][1] = pos[2][2][1][1] = 1;
    pos[2][0][2][0] = pos[2][2][2][0] = -1;
    pos[2][0][2][1] = pos[2][2][2][1] = 0;
    pos[2][0][3][0] = pos[2][2][3][0] = 0;
    pos[2][0][3][1] = pos[2][2][3][1] = 0;

    pos[2][1][0][0] = pos[2][3][0][0] = 0;
    pos[2][1][0][1] = pos[2][3][0][1] = 0;
    pos[2][1][1][0] = pos[2][3][1][0] = 1;
    pos[2][1][1][1] = pos[2][3][1][1] = 0;
    pos[2][1][2][0] = pos[2][3][2][0] = 1;
    pos[2][1][2][1] = pos[2][3][2][1] = -1;
    pos[2][1][3][0] = pos[2][3][3][0] = 0;
    pos[2][1][3][1] = pos[2][3][3][1] = 1;

    ////// @ //////
    ////// @ //////
    ////// @ //////
    ////// @ //////
    pos[3][0][0][0] = pos[3][2][0][0] = 0;//piece 3, rotation 0 and 2, point nb 0, x
    pos[3][0][0][1] = pos[3][2][0][1] = -1;//piece 3, rotation 0 and 2, point nb 0, y
    pos[3][0][1][0] = pos[3][2][1][0] = 0;
    pos[3][0][1][1] = pos[3][2][1][1] = 0;
    pos[3][0][2][0] = pos[3][2][2][0] = 0;
    pos[3][0][2][1] = pos[3][2][2][1] = 1;
    pos[3][0][3][0] = pos[3][2][3][0] = 0;
    pos[3][0][3][1] = pos[3][2][3][1] = 2;

    pos[3][1][0][0] = pos[3][3][0][0] = -1;
    pos[3][1][0][1] = pos[3][3][0][1] = 0;
    pos[3][1][1][0] = pos[3][3][1][0] = 0;
    pos[3][1][1][1] = pos[3][3][1][1] = 0;
    pos[3][1][2][0] = pos[3][3][2][0] = 1;
    pos[3][1][2][1] = pos[3][3][2][1] = 0;
    pos[3][1][3][0] = pos[3][3][3][0] = 2;
    pos[3][1][3][1] = pos[3][3][3][1] = 0;

    //// @ @ ////
    //// @ @ ////
    //piece 4, all rotations are the same
    pos[4][0][0][0] = pos[4][1][0][0] = pos[4][2][0][0] = pos[4][3][0][0] = 0;
    pos[4][0][0][1] = pos[4][1][0][1] = pos[4][2][0][1] = pos[4][3][0][1] = 0;
    pos[4][0][1][0] = pos[4][1][1][0] = pos[4][2][1][0] = pos[4][3][1][0] = 1;
    pos[4][0][1][1] = pos[4][1][1][1] = pos[4][2][1][1] = pos[4][3][1][1] = 0;
    pos[4][0][2][0] = pos[4][1][2][0] = pos[4][2][2][0] = pos[4][3][2][0] = 0;
    pos[4][0][2][1] = pos[4][1][2][1] = pos[4][2][2][1] = pos[4][3][2][1] = 1;
    pos[4][0][3][0] = pos[4][1][3][0] = pos[4][2][3][0] = pos[4][3][3][0] = 1;
    pos[4][0][3][1] = pos[4][1][3][1] = pos[4][2][3][1] = pos[4][3][3][1] = 1;

    ///// @   ////
    ///// @   ////
    ///// @ @ ////
    pos[5][0][0][0] = 0;//piece 5, rotation 0, point nb 0, x
    pos[5][0][0][1] = 1;//piece 5, rotation 0, point nb 0, y
    pos[5][0][1][0] = 1;
    pos[5][0][1][1] = 1;
    pos[5][0][2][0] = 0;
    pos[5][0][2][1] = 0;
    pos[5][0][3][0] = 0;
    pos[5][0][3][1] = -1;

    pos[5][1][0][0] = 0;
    pos[5][1][0][1] = 0;
    pos[5][1][1][0] = 1;
    pos[5][1][1][1] = 0;
    pos[5][1][2][0] = 2;
    pos[5][1][2][1] = 0;
    pos[5][1][3][0] = 2;
    pos[5][1][3][1] = -1;

    pos[5][2][0][0] = 0;
    pos[5][2][0][1] = -1;
    pos[5][2][1][0] = 1;
    pos[5][2][1][1] = -1;
    pos[5][2][2][0] = 1;
    pos[5][2][2][1] = 0;
    pos[5][2][3][0] = 1;
    pos[5][2][3][1] = 1;

    pos[5][3][0][0] = 0;
    pos[5][3][0][1] = 0;
    pos[5][3][1][0] = 1;
    pos[5][3][1][1] = 0;
    pos[5][3][2][0] = 2;
    pos[5][3][2][1] = 0;
    pos[5][3][3][0] = 0;
    pos[5][3][3][1] = 1;

    ////   @ ////
    ////   @ ////
    //// @ @ ////
    pos[6][0][0][0] = 0;//piece 6, rotation 0, point nb 0, x
    pos[6][0][0][1] = 1;//piece 6, rotation 0, point nb 0, y
    pos[6][0][1][0] = 1;
    pos[6][0][1][1] = 1;
    pos[6][0][2][0] = 1;
    pos[6][0][2][1] = 0;
    pos[6][0][3][0] = 1;
    pos[6][0][3][1] = -1;

    pos[6][1][0][0] = 0;
    pos[6][1][0][1] = 0;
    pos[6][1][1][0] = 1;
    pos[6][1][1][1] = 0;
    pos[6][1][2][0] = 2;
    pos[6][1][2][1] = 0;
    pos[6][1][3][0] = 2;
    pos[6][1][3][1] = 1;

    pos[6][2][0][0] = 0;
    pos[6][2][0][1] = -1;
    pos[6][2][1][0] = 1;
    pos[6][2][1][1] = -1;
    pos[6][2][2][0] = 0;
    pos[6][2][2][1] = 0;
    pos[6][2][3][0] = 0;
    pos[6][2][3][1] = 1;

    pos[6][3][0][0] = 0;
    pos[6][3][0][1] = 0;
    pos[6][3][1][0] = 1;
    pos[6][3][1][1] = 0;
    pos[6][3][2][0] = 2;
    pos[6][3][2][1] = 0;
    pos[6][3][3][0] = 0;
    pos[6][3][3][1] = -1;
  }
}

class Score {
  int points = 0;

//20 bodova po liniji, ako odjednom srušiš 4 i više linija dobivaš 200 bodova - kakti combo -->uvijek puta level
  void addLinePoints(int nb) {
    if (nb == 4) {
      points += level * 10 * 20;
    } else {
      points += level * nb * 20;
    }
  }

//5 bodova po obliku skalarno po levelima, 5,10,5.....
  void addPiecePoints() {
    points += level * 5;
  }

//100 bodova po levelu puta level
  void addLevelPoints() {
    points += level * 100;
  }

  void display() {
    pushMatrix();
    translate(40, 60);

    //score
    fill(textColor);
    text("score: ", 0, 0);
    fill(230, 230, 12);
    text(""+formatPoint(points), 0, txtSize);

    //level
    fill(textColor);
    text("level: ", 0, 3*txtSize);
    fill(230, 230, 12);
    text("" + level, 0, 4*txtSize);

    //lines
    fill(textColor);
    text("lines: ", 0, 6*txtSize);
    fill(230, 230, 12);
    text("" + numberOfFullLines, 0, 7*txtSize);
    popMatrix();

    pushMatrix();
    translate(980, 60);

    //score
    fill(textColor);
    text("next: ", 0, 0);

    translate(1.2*sizeOfCube, 1.5*sizeOfCube);
    nextPiece.display(true);
    popMatrix();
  }

  String formatPoint(int p) {
    String txt = "";
    int temp = int(p/1000000);
    if (temp > 0) {
      txt += temp + ".";
      p -= temp * 1000000;
    }

    temp = int(p/1000);
    if (txt != "") {
      if (temp == 0) {
        txt += "000";
      } else if (temp < 10) {
        txt += "00";
      } else if (temp < 100) {
        txt += "0";
      }
    }
    if (temp > 0) {
      txt += temp;
      p -= temp * 1000;
    }
    if (txt != "") {
      txt += ".";
    }

    if (txt != "") {
      if (p == 0)
        txt += "000";
      else if (p < 10)
        txt += "00" + p;
      else if (p < 100)
        txt += "0" + p;
      else
        txt += p;
    }
    else
      txt += p;

    return txt;
  }
}