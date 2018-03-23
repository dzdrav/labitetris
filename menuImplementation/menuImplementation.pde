/*
TODO
--popraviti slova na tetrisu
posttaviti globalni font
popraviti glazbicu kada se resetira gejm
--popraviti item outline
*/
// sound library
import ddf.minim.*;

color white = color (0xFF, 0xFF, 0xFF);
color blue = color (0x00, 0x00, 0xFF);
color red = color (0xFF, 0x00, 0x00);
color gray = color (0x80, 0x80, 0x80);
color green = color (0x00, 0xFF, 0x00);
color black = color (0x00, 0x00, 0x00);

int w = 12;
int h = 25;
int sizeOfCube = 30;
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

int txtSize = 25;
int textColor = color(34, 230, 190);

Boolean gameOver = false;
Boolean gameOn = false;
Boolean isSoundOn = true;


int state_init = 0;
int state_run = 1;
int state_end = 2;

int velicina_kvadrata = 20;
int broj_kvadrata_x = 40;
int broj_kvadrata_y = 35;
int dim_tekst_okvira = 100;
int tekst_pomak = dim_tekst_okvira / 4;
int sirina = 800;
int pocetak_teksta_y = (broj_kvadrata_y + 1) * velicina_kvadrata;

String[] figureNames = {"figure-one.png"
        ,"figure-two.png"
        ,"figure-three.png"
        ,"figure-four.png"
        ,"figure-five.png"
        ,"figure-six.png"
        ,"figure-seven.png"};
// elementi polja su sličice koje predstavljaju kvadratić n-te figurice
PImage[] figures = new PImage[figureNames.length];

Menu mainMenu;
MazeGame mazeGame;
TetrisGame tetrisGame;

PImage menu_background;
PImage icon_speaker;
PImage icon_muted;
int selectedItem=100;
PFont font;
Button muteButton;

Minim minim;
AudioPlayer tetrisPlayer;
AudioPlayer player;
AudioPlayer win_sound;
String music_name = "theme_music_maze.mp3";
String music_win = "music_win.mp3";
String music_tetris = "theme_music.mp3";
String menu_background_path = "menu_background.jpg";
String icon_speaker_path = "icon_speaker.png";
String icon_muted_path = "icon_muted.png";

void setup(){
  size(800, 800, P2D);
  smooth(4);
  // images loading
  icon_speaker = loadImage(icon_speaker_path);
  icon_muted = loadImage(icon_muted_path);
  menu_background = loadImage(menu_background_path);
  for (int i = 0; i < figureNames.length; ++i){
    figures[i] = loadImage(figureNames[i]);
  }
  // konstruktor: Menu(int textSize, PImage background)
  mainMenu = new Menu(22, menu_background);
  mainMenu.AddMenuItem("Tetris");
  mainMenu.AddMenuItem("Pravila tetrisa");
  mainMenu.AddMenuItem("Labirint");
  mainMenu.AddMenuItem("Pravila labirinta");
  muteButton = new Button(width - 2 * mainMenu.GetItemHeight()
    , height - 2 * mainMenu.GetItemHeight()
    , mainMenu.GetItemHeight()
    , mainMenu.GetItemHeight()
    , icon_speaker
    , icon_muted
    );
  mainMenu.AddButton(muteButton);

  tetrisGame = new TetrisGame();
  mazeGame = new MazeGame ();

  // sound loading
  minim = new Minim(this);
  player = minim.loadFile(music_name);
  win_sound = minim.loadFile(music_win);
  tetrisPlayer = minim.loadFile(music_tetris);

  font = createFont("Arial",20,true);  // Loading font
  textFont(font);
  background(white);
  noFill();
  noStroke ();
}

void draw(){
  switch(selectedItem){
    case 0:
      // pokreni tetris
      textSize(txtSize);
      tetrisGame.Manage();
      break;
    case 1:
      // pravila tetrisa
      println("Gumb 2");
      break;
    case 2:
      // pokreni labirint
        colorMode(RGB, height, height, height);
      if (mazeGame.getState() == state_init) {
        mazeGame._maze.show(velicina_kvadrata);
        mazeGame._needToRedraw = true;

        mazeGame._startTime = 0;
        mazeGame._endTime = 0;

        mazeGame.ClearTextArea();

        textAlign(CENTER);
        fill(black);
        text("Press SPACE to start", sirina / 2, pocetak_teksta_y);
      }
      mazeGame.Manage();
      break;
    case 3:
      // pravila labirinta
      background(white);
      PFont f;
      f = createFont("Arial",16,true);
      String pravila= " Labirint je igra u kojoj je cilj doći od početne točke (crvena) do krajnje (zelena). \n "
        +  " Igrač se po labirintu pomiče pomoću strelica.\n "
        +  "Gore, dolje, lijevo i desno. \n"
        + "Za početak igre pritisnite razmak. \n "
        + "Za ponovno iscrtavanje pritisnite 'r'. \n"
        +" Sretno!";
      textAlign(LEFT);
      textFont(f,16);
      fill(0);
      text(pravila, 10, 100);
      println("Gumb 4");
      break;
  default:mainMenu.Display();
      break;
  }
}

// TODO dodati povratak u Main menu
void keyPressed() {
  switch(selectedItem){
    case 0:
      // igraj tetris
      tetrisGame.KeyPressed(key);
      break;
    case 2:
      // igraj labirint
      mazeGame.KeyPressed (key);
      break;
  }
}

// u ovoj funkciji pokrećemo opcije iz menija
void mouseClicked(){
  // koji item je kliknut?
  int selection = mainMenu.SelectedItem();
  switch(selection){
    case 0:
      // pokreni tetris
      println("Gumb 1");
      selectedItem=0;
      break;
    case 1:
      // pravila tetrisa
      println("Gumb 2");
      break;
    case 2:
      // pokreni labirint
      println("Gumb 3");
      selectedItem=2;
      break;
    case 3:
      // pravila labirinta
      println("Gumb 4");
      selectedItem=3;
      break;
      // mute sound
    case -5:
      if (isSoundOn){
        isSoundOn = false;
        println("Sound muted");
      } else {
        isSoundOn = true;
        println("Sound ON");
      }
      break;
    // itd...
  }
}

/* glavni izbornik koji ispisuje iteme u pravokutnicima
 * određujemo boje, accent boje (kada je item označen) veličinu fonta itd.
 * sve to navodimo u konstruktoru
 * nove stavke dodajemo AddMenuItem() metodom
 */
class Menu{
  // lista itema (string)
  private ArrayList<String> m_items = new ArrayList<String>();
  private ArrayList<Button> m_buttons = new ArrayList<Button>();
  // lista koja sadrži središta svih itema (za njihovo crtanje na ekran)
  // menu itemi se crtaju na temelju lokacije središta, širine i visine
  private IntList m_centers;
  // ostale varijable članice
  private int m_spacing = 0;
  private int m_itemHeight = 0;
  private int m_itemWidth = 0;
  private int m_textSize;
  private color m_itemColor;
  private color m_itemAccentColor;
  private color m_textColor;
  private color m_textAccentColor;
  private PImage m_background = null;
  private PFont m_menuFont;

  // konstruktor
  Menu(int textSize){
    m_textSize = textSize;
    // defaultne boje, mogu se promijeniti setterima
    m_itemColor = #FF00FF;
    m_itemAccentColor = #1FE3F4;
    m_textColor = color(255,255,255);
    m_textAccentColor = color(0,0,0);
    // postavljanje fonta
    m_menuFont = createFont("PressStart2P.ttf", m_textSize, true);
    textFont(m_menuFont);
    textSize(m_textSize);
    m_itemHeight = int(textAscent() + textDescent());
    m_itemHeight *= 2.5;
    m_spacing = m_itemHeight / 2;
  }
  // konstruktor koji prima PImage background
  Menu(int textSize, PImage bg){
    this(textSize);
    m_background = bg;
  }
  // nakon svakog umetanja itema, ažurira listu središta menu itema
  private void UpdateCenters(){
    int topBegin = m_items.size() * m_itemHeight + (m_items.size() - 1) * m_spacing;
    topBegin = (height - topBegin) / 2 + (m_itemHeight / 2);
    m_centers = new IntList();
    for(int i = 0; i < m_items.size(); ++i){
      m_centers.append(topBegin);
      topBegin += (m_spacing + m_itemHeight);
    }
  }

  public void AddButton(Button button){
    m_buttons.add(button);
  }

  // menu item get/set
  public void AddMenuItem(String item){
    m_items.add(item);
    UpdateCenters();
    // ažuriranje širine menu itema
    textFont(m_menuFont);
    textSize(m_textSize);
    if (textWidth(item) > m_itemWidth){
      m_itemWidth = int(textWidth(item) + 4 * textWidth('c'));
    }
  }
  public String GetMenuItem(int i){
    return m_items.get(i);
  }

  // iscrtava i-ti item
  void DrawMenuItem(int i, color bgColor, color textColor){
    if (i <= m_items.size()){
      rectMode(CENTER);
      stroke(black);
      textAlign(CENTER, CENTER);
      textFont(m_menuFont);
      textSize(m_textSize);
      fill(bgColor);
      rect(width / 2, m_centers.get(i), m_itemWidth, m_itemHeight,3,12,3,12);
      fill(textColor);
      text(m_items.get(i), width / 2, m_centers.get(i));
      rectMode(CORNER);
    }
    else
      println("DrawMenuItem: index " + i + " out of range: ");
  }

  // vraća indeks kliknutog itema ili -1 ako nijedan nije kliknut
  //BUG oprez: ovo je hardkodirano za samo jedan gumb na 0-om indeksu
  // ovdje dodati podršku za registriranje klika na nove gumbove
  public int SelectedItem(){
    for (int i = 0; i < m_items.size(); ++i){
      if (MouseOverItem(i))
        return i;
    }
    // dodajemo specifičan kod: -5 za klik na Mute gumb
    if (m_buttons.get(0).MouseOverItem())
      return -5;
    return -1;
  }

  // nalazi li se kursor iznad i-tog itema
  public boolean MouseOverItem(int i){
    if(mouseX < (width / 2) + (m_itemWidth / 2) &&
      mouseX > (width / 2) - (m_itemWidth / 2) &&
      mouseY < (m_centers.get(i) + m_itemHeight / 2) &&
      mouseY > (m_centers.get(i) - m_itemHeight / 2)
        )
      return true;
    else
      return false;
  }

  // item height getter
  public int GetItemHeight(){
    return m_itemHeight;
  }

  // color get/set
  public color itemColor(){
    return m_itemColor;
  }
  public void SetItemColor(color value){
    m_itemColor = value;
  }
  public color itemAccentColor(){
    return m_itemAccentColor;
  }
  public void SetItemAccentColor(color value){
    m_itemAccentColor = value;
  }
  public color textColor(){
    return m_textColor;
  }
  public void SetTextColor(color value){
    m_textColor = value;
  }
  public color textAccentColor(){
    return m_textAccentColor;
  }
  public void SetTextAccentColor(color value){
    m_textAccentColor = value;
  }

  // prikazuje meni sa svim stavkama
  void Display(){
    if (m_background != null){
      background(m_background);
    }
    for (int i = 0; i < m_items.size(); ++i){
      if (MouseOverItem(i))
        DrawMenuItem(i, m_itemAccentColor, m_textAccentColor);
      else
        DrawMenuItem(i, m_itemColor, m_textColor);
    }
    // sound icon
    // BUG pripaziti ako odlučimo dodati više gumbova da se prikažu ovdje
    Boolean selected = false;
    if (m_buttons.get(0).MouseOverItem())
      selected = true;
    // Display(boolean accent, boolean state)
    m_buttons.get(0).Display(selected, isSoundOn);
  }
}

/* Button može imati dva stanja, svako predstavljeno jednom ikonicom
 * stanje se mijenja klikom na gumb
 * TODO lako se implementira mogućnost promjene boja i oblika gumba
 */
class Button{
  private int m_width;
  private int m_height;
  private int m_x;
  private int m_y;
  private float m_alpha;
  private color m_color;
  private color m_accent_color;
  private PImage m_true_icon;
  private PImage m_false_icon;
  private Boolean m_state;

  // konstruktor
  Button(int x, int y, int p_width, int p_height, PImage p_true, PImage p_false){
    m_x = x;
    m_y = y;
    m_width = p_width;
    m_height = p_height;
    m_alpha = 0.25;
    m_color = #E8E288;
    m_accent_color = #1FE3F4;
    m_true_icon = p_true;
    m_false_icon = p_false;
    m_state = true;
  }

  // prikaže gumb u trenutnom stanju
  public void Display(Boolean accent, Boolean state){
    ellipseMode(CENTER);
    stroke(black);
    //tint(255,126);
    int alpha = int(m_alpha * 256);
    if (accent){
      fill(m_accent_color, alpha);
    } else {
      fill(m_color, alpha);
    }
    ellipse(m_x, m_y, m_width, m_height);

    imageMode(CENTER);
    if (state){
      image(m_true_icon, m_x, m_y, m_width, m_height);
    } else {
      image(m_false_icon, m_x, m_y, m_width, m_height);
    }
    // vraćamo na default vrijednost
    imageMode(CORNER);
  }

  public boolean MouseOverItem(){
    if(mouseX < (m_x + m_width / 2) &&
      mouseX > (m_x - m_width / 2) &&
      mouseY < (m_y + m_height / 2) &&
      mouseY > (m_y - m_height / 2)
        )
      return true;
    else
      return false;
  }
}

class MazeGame {
  MazeGame () {
    //Reset();
      _state = state_init;

       int p = int (random(1,6));
       //veći p = lakši labirint (u smislu glađih zidova)

      _maze = new Maze(broj_kvadrata_y, broj_kvadrata_x , p);
      _maze.compute ();
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

    int getState() {
      return _state;
    }

    void Start() {
     if (_state == state_init) {
       Run();

       // glazba se ponavlja (loop)
       if (!player.isPlaying()){
         if (isSoundOn){
           player.loop();
         }
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
      if (isSoundOn){
        win_sound.play();
      }
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


//==============================================================

class TetrisGame {

 TetrisGame() {
      //initialize();
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

  void Manage() {
    background(60);
    textAlign(LEFT);
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
    // glazba se ponavlja (loop)
    if (!tetrisPlayer.isPlaying()){
      if (isSoundOn){
        tetrisPlayer.loop();
      }
    }
  }
    if (gameOver) {
        noStroke();
        fill(255, 60);
        rect(200, 260, 240, 2*txtSize, 3);
        fill(textColor);
        text("Game Over", 225, 290);

        // pauziranje glazbe
        tetrisPlayer.pause();
        tetrisPlayer.rewind();
      }
      if (!gameOn) {
        noStroke();
        fill(255, 60);
        rect(200, 190, 500, 2*txtSize, 3);
        textAlign(LEFT);
        textSize(txtSize / 2);
        fill(textColor);
        text("Press 's' to start playing!", 210, 220);
      }
  }

  void KeyPressed(int key) {
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
          gameOver = false;
          gameOn = true;
        }
      } else if (keyCode == 80) {// "p"
          if(gameOn) {
            if(looping) {
            noStroke();
            fill(255, 60);
            rect(200, 190, 500, 2*txtSize, 3);
            fill(textColor);
            text("press 'p' to resume playing!", 210, 220);
            tetrisPlayer.pause();
            noLoop();
            }
            else {
              loop();
              if (isSoundOn){
                tetrisPlayer.loop();
              }
            }
          }
      }
      else if (key == 'r') {
          gameOn = false;
          gameOver = false;
          grid = null;
          tetrisPlayer.rewind();
      }

  }

}

//================== GRID =================================

class Grid {
  int [][] cells = new int[w][h];

  Grid() {
    for (int i = 0; i < w; i ++)
      for (int j = 0; j < h; j ++)
        cells[i][j] = 0;
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

  int ColorToInt(color c){
    if (c == color(128, 12, 128))
        return 0;
    else if (c == color(230, 12, 12)) //red
        return 1;
    else if (c == color(12, 230, 12)) //green
        return 2;
    else if (c == color(9, 239, 230)) //cyan
        return 3;
    else if (c == color(230, 230, 9)) //yellow
        return 4;
    else if (c == color(230, 128, 9)) //orange
        return 5;
    else if (c == color(12, 12, 230)) //blue
        return 6;
    else
      return -1;
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
          //fill(cells[i][j]);
          //rect(i*sizeOfCube, j*sizeOfCube, sizeOfCube, sizeOfCube);
          //TODO
          image(figures[ColorToInt(cells[i][j])], i*sizeOfCube, j*sizeOfCube, sizeOfCube, sizeOfCube);
        }
      }
    }
    popMatrix();
  }
}

//======================== PIECE =====================

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
    pushMatrix();
    if (!still) {
      translate(200, 40);
      translate(x*sizeOfCube, y*sizeOfCube);
    }
    int rot = still ? 0 : rotation;
    for (int i = 0; i < 4; i++) {
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

//========================= PIECES ================================

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

//============================ SCORE ======================

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

    textAlign(LEFT);
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
    translate(600, 60);

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
