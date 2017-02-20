// http://forum.luminous-landscape.com/index.php?topic=52364.0

PFont f;
boolean showExtras = true;
boolean showCursor = true;

float s = 3;
float e = 2;
color color0;
color color0b;
color color1;
color color1b;
color color2;
color color2b;
color color3;
color color3b;
color color4;
color color4b;
color colorGrey;

float cp1x = 0;
float cp1y = 0;
float cp2x = 0;
float cp2y = 0;

float lineWidth = 4;

void setup() 
{
  size(1024, 768, P2D);
  pixelDensity(displayDensity()); 
  
  f = createFont( "Arial", 30, true ); 
  cursor(CROSS);
  colorMode(HSB);
  strokeWeight(2);
  
  color0 = color(0, 255, 255);
  color0b = color(0, 255, 175);
  color1 = color(30, 255, 255);
  color1b = color(30, 255, 175);
  color2 = color(90, 255, 255);
  color2b = color(90, 255, 127);
  color3 = color(160, 255, 255);
  color3b = color(160, 255, 200);
  colorGrey = color(0, 0, 100);
  color4 = color(210, 255, 255);
  color4b = color(210, 255, 225);
}

void draw() 
{
  background(50);
  
  // determine inputs inside of chart-drawable area
  float tInputX = min( 1 , max( 0, (mouseX - (0.1 * width))/((float)width * 0.8) ) );  
  float tInputY = min( 1 , max( 0, (mouseY - (0.1 * height))/((float)height * 0.8) ) ) ; 
  
  // x: input
  // (a,b): turning point (inflection)
  // s: slope influence at ends
  // e: contrast strength (slope influence at inflection)
  float x = 0;
  float a = tInputX;
  float b = 1-tInputY;
  float pointX = 0;
  float pointY = 0;
  float pointY2 = 0;
  float pointY3 = 0;
  float pointY4 = 0;
  float fn = 0;
  float tE = e * tInputY;
  
  showChartExtras(tInputX, tInputY);
  
  if( showCursor )
  {
    cursor();
  }
  else 
  {
    noCursor();
  }
  
  // bezier points for section e
  cp1x = width - 400 * e * (1-a); // control point 1, x
  cp1y = 75 * s * (1-b);
  cp2x = 400 * e * a;
  cp2y = height - 75 * s * b;
    
  for( int tX = 0; tX < width; tX++ )
  {
    x = tX/(float)width;
    pointX = width * x;
    
    if( tX < width * a )
    {
      fn = a * pow( (x/a), tE );
      
      // a, curve passes through (a,a)
      pointY = fn; 
      pointY *= height;
      
      // b, curve passes through (a,a) with endpoint slope modification
      pointY2 = ( (1-s) * x ) + ( s * fn );
      pointY2 *= height;
      
      // c, curve passes through (a,b) with endpoint slope modification
      pointY3 = pow( ( (1-s) * x ) + ( s * fn ), ( log(b)/log(a) ) ); 
      pointY3 *= height; 
    }
    else
    {
      fn = (1-a) * pow( ( (1-x)/(1-a) ), tE );
      
      // a
      pointY = 1 - fn; 
      pointY *= height;
      
      // b
      pointY2 = ( (1-s) * x ) + ( s * (1-fn) );   
      pointY2 *= height;
      
      // c
      pointY3 = pow( ( (1-s) * x ) + ( s * (1-fn) ), ( log(b)/log(a) ) );    
      pointY3 *= height;  
    }
    
    // d, simple curve through (0.5, 0.5) with endpoint slope modification
    if( x < 0.5 )
    {
      fn = 0.5 * pow( (x/0.5), tInputX * s );
      pointY4 = fn;
      pointY4 *= height;
    }
    else
    {
      fn = 0.5 * pow( (1-x) / 0.5 , tInputX * s );
      pointY4 = 1 - fn;
      pointY4 *= height;
    }

    // draw curves
   
    strokeWeight( lineWidth );
     
    //a
    stroke(color0);
    plotPoint( pointX, pointY );
      
    //b
    stroke(color1);
    plotPoint( pointX, pointY2 );    
    
    //c
    stroke(color2);
    plotPoint( pointX, pointY3 );
    
    //d
    stroke(color3);
    plotPoint( pointX, pointY4 );
    
    //e, bezier
    stroke( color4 );
    float tPointX = bezierPoint(width, cp1x, cp2x, 0, x);
    float tPointY = bezierPoint(0, cp1y, cp2y, height, x);
    plotPoint( tPointX, height - tPointY ); // invert the Y to conform with other line drawing types
  } 
}

void keyPressed() {
  if (key == CODED)
  {
    if (keyCode == UP)
    {
      s += 0.25;
    }
    else if(keyCode == DOWN)
    {
      s += -0.25;
    }
    else if (keyCode == LEFT)
    {
      e -= 0.1;
    }
    else if(keyCode == RIGHT)
    {
      e -= -0.1;
    }
  }
  else if( key == 'h' || key == 'H' )
  {
    showExtras = !showExtras;
  }
  else if( key == 'c' || key == 'C' )
  {
    showCursor = !showCursor;
  }
  else if( key == 's' || key == 'S' )
  {
    saveImage();
  }
}

// plot with some padding around the graph to see the slope of the end-points when the
// lines go outside the bounds of the graph
void plotPoint( float pX, float pY )
{
  point( 0.1 * width + 0.8 * pX, height - (0.1 * height + 0.8 * pY) );
}

float chartSpaceX( float pX )
{
  return ( 0.1 * width ) + ( 0.8 * pX );
}

float chartSpaceY( float pY )
{
  return ( 0.1 * height ) + ( 0.8 * pY );
}

void showChartExtras( float tA, float tB )
{
  if( showExtras )
  {
    textFont( f, 20 );                  
    fill(175); 
    String tDisplay = "Inflection Point Slope: " + e + 
    "\nEnd Point Slope: " + s + 
    "\nMouse Coords: " + tA + ", " + tB;
    text( tDisplay, 10, 25 );   
    
    strokeWeight( max( 1, lineWidth - 1 ) );
    noFill();
    
    stroke( colorGrey );
    rect( 0.1 * width, 
       (0.1 * height),
       (width * 0.8),
       (height * 0.8) );
    line( 0.1 * width,
       0.9 * height,
       0.9 * width, 
       0.1 * height );
       
    stroke( color2b );
    //noFill();
    rect( 0.1 * width, 
       (0.1 * height) + tB * (height * 0.8),
       (width * 0.8) * tA,
       (height * 0.8) - tB * (height * 0.8) );
       
    stroke( color3b );
    //noFill();
    rect( 0.1 * width, 
       (0.1 * height) + 0.5 * (height * 0.8),
       (width * 0.8) * 0.5,
       (height * 0.8) - 0.5 * (height * 0.8) );
       
    stroke( color0b );
    //noFill();
    rect( 0.1 * width, 
       (0.1 * height) + (height * 0.8) - ( tA * (height * 0.8) ),
       (width * 0.8) * tA,
       (height * 0.8) * tA );
       
    stroke( color4b );
    //noFill();
    line( chartSpaceX(cp1x), chartSpaceY(cp1y), chartSpaceX(width), chartSpaceY(1) );
    line( chartSpaceX(cp2x), chartSpaceY(cp2y), chartSpaceX(0), chartSpaceY(height) );
  }
}

void saveImage()
{
  int d = day();    // Values from 1 - 31
  int m = month();  // Values from 1 - 12
  int y = year();   // 2003, 2004, 2005, etc.
  int s = second();  // Values from 0 - 59
  int min = minute();  // Values from 0 - 59
  int h = hour();    // Values from 0 - 23
    save("Curves_" + 
    y + "_" +
    m + "_" +
    d + "_" +
    h + "_" +
    min + "_" +
    s + 
    ".png");
}