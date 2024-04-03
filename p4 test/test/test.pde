void setup()
{
  size (800, 800, OPENGL);
}

void draw(){
  noStroke();
  background(0);
  pointLight(150, 250, 150, 40, 120, 200);
  beginShape();
  vertex(80, 80, -40);
  vertex(320, 80, 40);
  vertex(320, 320, -40);
  vertex(80, 320, 40);
  endShape(CLOSE); 
}
