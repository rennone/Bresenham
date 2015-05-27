
Map map;
void setup()
{
  size(500, 600);  
  map = new Map(new PVector(50,50), 8, 50);
  noLoop();
}

void draw()
{
  map.draw(); 
}

void mousePressed()
{
  PVector p = map.pVectorToCell( new PVector(mouseX, mouseY));
  map.change(p);
  println( str(p.x) + "," + str(p.y));
  
  if(map.buttonPushed(mouseX, mouseY)) 
    map.changeButton();
    
  redraw();
}

class Map
{
  PVector leftTop;
  int mapSize;
  int cellSize;  
  PVector st, gl;
  
  final int LOAD=0, START=1, GOAL=2, PASS=3;
  
  PVector buttonLeftTop, buttonSize;
  int buttonKind;
  public Map(PVector _leftTop, int _mapSize, int _cellSize)
  {
    mapSize = _mapSize;
    leftTop = _leftTop;
    cellSize = _cellSize;
    st = new PVector(0,0);
    gl = new PVector(_mapSize-1, _mapSize-1);
    
    buttonLeftTop = new PVector(leftTop.x, leftTop.y+mapSize*cellSize + 10);
    buttonSize    = new PVector(100, 50);
    buttonKind = START;    
  }
  
  class Cell
 {
   PVector pos;
   float fraction;
   Cell(PVector p, int f)
   {
     pos = p;
     fraction = f;
   }
   Cell(int i, int j, float f)
   {
     pos = new PVector(i,j);
     fraction = f;
   }
 } 
  
  public ArrayList<Cell> bresenham(PVector st, PVector gl)
  {
    ArrayList<Cell> res = new ArrayList<Cell>();
    int stIntX = (int)st.x;
    int stIntY = (int)st.y;
    int enIntX = (int)gl.x;
    int enIntY = (int)gl.y;
    
    int stCol = stIntX;
    int stRow = stIntY;
    int enCol = enIntX;
    int enRow = enIntY;
    
    int nextCol = stCol;
    int nextRow = stRow;
    
    float deltaCol = gl.x - st.x;
    float deltaRow = gl.y - st.y;
    
    int stpCol = deltaCol < 0 ? -1 : 1;
    int stpRow = deltaRow < 0 ? -1 : 1;
       
    deltaCol = abs(deltaCol);
    deltaRow = abs(deltaRow);

    float a = abs(st.x - stIntX);// / ( abs(st.x - stIntX) + abs(st.y - stIntY) );
    float b = abs(st.y - stIntY);// / ( abs(st.x - stIntX) + abs(st.y - stIntY) );

    if( deltaCol > deltaRow)
    {
      float fraction = -deltaCol + deltaRow + deltaCol*b - deltaRow*a;
      //println(str(fraction) + "-" + str(deltaCol) + "-" + str(deltaRow) + "-" + str(abs(st.x - stIntX)) + "-" + abs(st.y - stIntY));
      while(nextCol != enCol)
      {
        if(fraction >= 0){
          nextRow += stpRow;
          fraction -= deltaCol;
          if( abs(fraction) != deltaCol)
          res.add(new Cell(nextCol, nextRow, fraction));        
        }
        nextCol+=stpCol;
        fraction += deltaRow;
        res.add(new Cell(nextCol, nextRow, fraction));                 
      }      
    }
    else
    {
      float fraction = -deltaRow + deltaCol - deltaCol*b + deltaRow*a;
      while(nextRow != enRow)
      {
        if( fraction >= 0){
          fraction -= deltaRow;
          nextCol += stpCol;
          if( abs(fraction) != deltaRow)
          res.add(new Cell(nextCol, nextRow, fraction));
        }
        nextRow += stpRow;
        fraction += deltaCol;     
        res.add(new Cell(nextCol, nextRow, fraction));   
      }      
    }
    return res;
  }
  
   public ArrayList<Cell> bresenhamInt(PVector st, PVector gl)
  {
    ArrayList<Cell> res = new ArrayList<Cell>();
    int stIntX = (int)st.x;
    int stIntY = (int)st.y;
    int enIntX = (int)gl.x;
    int enIntY = (int)gl.y;
    
    int stCol = stIntX;
    int stRow = stIntY;
    int enCol = enIntX;
    int enRow = enIntY;
    
    int nextCol = stCol;
    int nextRow = stRow;
    
    int deltaCol = enCol - stCol;
    int deltaRow = enRow - stRow;
    
    int stpCol = deltaCol < 0 ? -1 : 1;
    int stpRow = deltaRow < 0 ? -1 : 1;
       
    deltaCol = abs(deltaCol*2);
    deltaRow = abs(deltaRow*2);
    if( deltaCol > deltaRow)
    {
      int fraction = -deltaCol/2 + deltaRow/2;
      while(nextCol != enCol)
      {
        if(fraction >= 0){
          nextRow += stpRow;
          fraction -= deltaCol;
          if( abs(fraction) != deltaCol)
          res.add(new Cell(nextCol, nextRow, fraction));        
        }
        nextCol+=stpCol;
        fraction += deltaRow;
        res.add(new Cell(nextCol, nextRow, fraction));                 
      }      
    }
    else
    {
      int fraction = deltaCol/2 - deltaRow/2;
      while(nextRow != enRow)
      {
        if( fraction >= 0){
          fraction -= deltaRow;
          nextCol += stpCol;
          if( abs(fraction) != deltaRow)
          res.add(new Cell(nextCol, nextRow, fraction));
        }
        nextRow += stpRow;
        fraction += deltaCol;     
        res.add(new Cell(nextCol, nextRow, fraction));   
      }      
    }
    return res;
  }
  
  void clamp()
  {
    st.x = floor(st.x);// + 0.5;
    st.y = floor(st.y);// + 0.5;
    gl.x = floor(gl.y);// + 0.5;
    gl.y = floor(gl.y);// + 0.5;
  }
  public void draw()
  {
    background(200);
    //clamp();
    
    ArrayList<Cell> pass = bresenham(st, gl);
    for(int i=0; i < pass.size(); i++)
    {
      Cell c = pass.get(i);
      fill(color(255,0,0));
      rect(c.pos.x*cellSize + leftTop.x, c.pos.y*cellSize+leftTop.y, cellSize, cellSize);
      fill(color(0));
      text(str(c.fraction),c.pos.x*cellSize + leftTop.x, c.pos.y*cellSize+leftTop.y + cellSize/2 );
    }
    
    for(int i=0; i<=mapSize; i++)
    {
      stroke(color(0,0,255));
      line( leftTop.x + i*cellSize, leftTop.y,
           leftTop.x + i*cellSize, leftTop.y + mapSize*cellSize );          
       line( leftTop.x                   , leftTop.y + i*cellSize,
             leftTop.x + mapSize*cellSize, leftTop.y +  i*cellSize );   
    }
    
    //ボタンの描画
    fill(getColor(buttonKind));
    stroke(255);
    rect(buttonLeftTop.x, buttonLeftTop.y, buttonSize.x, buttonSize.y);
    fill(255,255,0);
    
    //ラインの描画
    stroke(color(0,0,0));
    PVector s = cellToPVector(st.x, st.y);
    PVector g = cellToPVector(gl.x, gl.y);
    line( s.x, s.y, g.x, g.y);
  }
  
  public int getColor(int a)
  {
    return color( 100*( a&1), 100*(a>>1), 0);
  }

  public boolean buttonPushed(int x, int y)
  {
    return buttonLeftTop.x <= x && x <= buttonLeftTop.x+buttonSize.x &&
    buttonLeftTop.y <= y && y <= buttonLeftTop.y + buttonSize.y;
  }
  
  public void changeButton()
  {
    buttonKind = buttonKind == START ? GOAL : START;
  }
  
  public boolean inRegion(PVector p)
  {
    if( p==null || p.x<0 || p.x>=mapSize || p.y<0 || p.y>=mapSize)
     return false;
     
    return true; 
  }
  
  public void change(PVector p)
  {
    if(!inRegion(p)) return;
    if(buttonKind == START)
      st = p;
    else
       gl = p;
  }
  
  public PVector pVectorToCell(PVector vec) { return new PVector( (vec.x - leftTop.x)/cellSize, (vec.y - leftTop.y)/cellSize);} 
  public PVector cellToPVector(float i, float j){ return new PVector(leftTop.x + i*cellSize, leftTop.y + j*cellSize);}
}
