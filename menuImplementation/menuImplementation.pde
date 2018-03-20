// menu globalan jer mu pristupamo i u draw() i u mouseClicked()
Menu mainMenu;
PImage menu_background;

void setup(){
  size(800, 800, P2D);
  menu_background = loadImage("menu_background.jpg");
  //background(menu_background);
  // konstruktor: Menu(spacing, itemHeight, itemWidth, textSize, background)
  mainMenu = new Menu(30, 60, 250, 20, menu_background);
  mainMenu.AddMenuItem("Tetris");
  mainMenu.AddMenuItem("Pravila tetrisa");
  mainMenu.AddMenuItem("Labirint");
  mainMenu.AddMenuItem("Pravila labirinta");
}

void draw(){
  background(60);
  mainMenu.Display();
}

// u ovoj funkciji pokrećemo opcije iz menija
void mouseClicked(){
  // koji item je kliknut?
  int selection = mainMenu.SelectedItem();
  switch(selection){
    case 0:
      // pokreni tetris
      println("Gumb 1");
      break;
    case 1:
      // pravila tetrisa
      println("Gumb 2");
      break;
    case 2:
      // pokreni labirint
      println("Gumb 3");
      break;
    case 3:
      // pravila labirinta
      println("Gumb 4");
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
  // lista koja sadrži središta svih itema (za njihovo crtanje na ekran)
  // menu itemi se crtaju na temelju lokacije središta, širine i visine
  private IntList m_centers;
  // ostale varijable članice
  private int m_spacing;
  private int m_itemHeight;
  private int m_itemWidth;
  private int m_textSize;
  private color m_itemColor;
  private color m_itemAccentColor;
  private color m_textColor;
  private color m_textAccentColor;
  private PImage m_background = null;

  // konstruktor
  Menu(int spacing, int itemHeight, int itemWidth, int textSize){
    m_spacing = spacing;
    m_itemHeight = itemHeight;
    m_itemWidth = itemWidth;
    m_textSize = textSize;
    // defaultne boje, mogu se promijeniti setterima
    m_itemColor = #ED4A3B;
    m_itemAccentColor = #1FE3F4;
    m_textColor = color(255,255,255);
    m_textAccentColor = color(0,0,0);
  }
  // konstruktor koji prima PImage background
  Menu(int spacing, int itemHeight, int itemWidth, int textSize, PImage bg){
    this(spacing, itemHeight, itemWidth, textSize);
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

  // menu item get/set
  void AddMenuItem(String item){
    m_items.add(item);
    UpdateCenters();
  }
  String GetMenuItem(int i){
    return m_items.get(i);
  }

  // iscrtava i-ti item
  void DrawMenuItem(int i, color bgColor, color textColor){
    if (i <= m_items.size()){
      rectMode(CENTER);
      textAlign(CENTER, CENTER);
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
  public int SelectedItem(){
    for (int i = 0; i < m_items.size(); ++i){
      if (MouseOverItem(i))
        return i;
    }
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
  }
}
