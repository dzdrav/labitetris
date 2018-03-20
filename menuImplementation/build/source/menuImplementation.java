import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class menuImplementation extends PApplet {

// menu globalan jer mu pristupamo i u draw() i u mouseClicked()
Menu mainMenu;

public void setup(){
  
  // konstruktor: Menu(spacing, itemHeight, itemWidth, textSize)
  mainMenu = new Menu(30, 60, 250, 20);
  mainMenu.AddMenuItem("Tetris");
  mainMenu.AddMenuItem("Pravila tetrisa");
  mainMenu.AddMenuItem("Labirint");
  mainMenu.AddMenuItem("Pravila labirinta");
}

public void draw(){
  background(60);
  mainMenu.Display();
}

// u ovoj funkciji pokre\u0107emo opcije iz menija
public void mouseClicked(){
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
 * odre\u0111ujemo boje, accent boje (kada je item ozna\u010den) veli\u010dinu fonta itd.
 * sve to navodimo u konstruktoru
 * nove stavke dodajemo AddMenuItem() metodom
 */
class Menu{
  // lista itema (string)
  private ArrayList<String> m_items = new ArrayList<String>();
  // lista koja sadr\u017ei sredi\u0161ta svih itema (za njihovo crtanje na ekran)
  // menu itemi se crtaju na temelju lokacije sredi\u0161ta, \u0161irine i visine
  private IntList m_centers;
  // ostale varijable \u010dlanice
  private int m_spacing;
  private int m_itemHeight;
  private int m_itemWidth;
  private int m_textSize;
  private int m_itemColor;
  private int m_itemAccentColor;
  private int m_textColor;
  private int m_textAccentColor;

  // konstruktor
  Menu(int spacing, int itemHeight, int itemWidth, int textSize){
    //m_length = 0;
    m_spacing = spacing;
    m_itemHeight = itemHeight;
    m_itemWidth = itemWidth;
    m_textSize = textSize;
    m_itemColor = color(130,130,130);
    m_itemAccentColor = color(200,200,200);
    m_textColor = color(255,255,255);
    m_textAccentColor = color(0,0,0);
  }
  // nakon svakog umetanja itema, a\u017eurira listu sredi\u0161ta menu itema
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
  public void AddMenuItem(String item){
    m_items.add(item);
    UpdateCenters();
    //m_length += 1;
  }
  public String GetMenuItem(int i){
    return m_items.get(i);
  }

  // iscrtava i-ti item
  public void DrawMenuItem(int i, int bgColor, int textColor){
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

  // vra\u0107a indeks kliknutog itema ili -1 ako nijedan nije kliknut
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
  public int itemColor(){
    return m_itemColor;
  }
  public int itemAccentColor(){
    return m_itemAccentColor;
  }
  public int textColor(){
    return m_textColor;
  }
  public int textAccentColor(){
    return m_textAccentColor;
  }

  // prikazuje meni sa svim stavkama
  public void Display(){
    for (int i = 0; i < m_items.size(); ++i){
      if (MouseOverItem(i))
        DrawMenuItem(i, m_itemAccentColor, m_textAccentColor);
      else
        DrawMenuItem(i, m_itemColor, m_textColor);
    }
  }
}
  public void settings() {  size(800, 800, P2D); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "menuImplementation" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
