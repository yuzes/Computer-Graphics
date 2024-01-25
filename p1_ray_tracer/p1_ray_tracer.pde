// This is the starter code for the CS 6491 Ray Tracing project.
//
// The most important part of the code is the interpreter, which will help
// you parse the scene description (.cli) files.

boolean debug_flag = false;

Scene debug_scene = null;
Scene current_scene = null;

void setup() {
  size (300, 300);  
  noStroke();
  background (0, 0, 0);
}

void keyPressed() {
  reset_scene();
  switch(key) {
    case '1': interpreter("s1.cli"); break;
    case '2': interpreter("s2.cli"); break;
    case '3': interpreter("s3.cli"); break;
    case '4': interpreter("s4.cli"); break;
  }
}

// this routine parses the text in a scene description file
void interpreter(String file) {
  
  println("Parsing '" + file + "'");
  String str[] = loadStrings (file);
  if (str == null){
    println ("Error! Failed to read the file.");
    return;
  }
  if(current_scene == null)
    current_scene = new Scene();
  Triangle buffer = new Triangle();
  color surface_color = color(0,0,0);
  colorMode(RGB, 1.0);
  for (int i = 0; i < str.length; i++) {
    
    String[] token = splitTokens (str[i], " ");   // get a line and separate the tokens
    if (token.length == 0) continue;              // skip blank lines

    if (token[0].equals("fov")) {
      current_scene.fov = int(token[1]);
    } else if (token[0].equals("background")) {
      float r = float(token[1]);  // this is how to get a float value from a line in the scene description file
      float g = float(token[2]);
      float b = float(token[3]);
      println ("background = " + r + " " + g + " " + b);
      current_scene.background_color = color(r, g, b);
    }
    else if (token[0].equals("light")) {
      current_scene.light_position = new PVector(float(token[1]),float(token[2]),float(token[3]));
      current_scene.light_color = color(float(token[4]),float(token[5]),float(token[6]));
    }
    else if (token[0].equals("surface")) {
      surface_color = color(float(token[1]), float(token[2]), float(token[3]));
    }    
    else if (token[0].equals("begin")) {
      buffer.surface_color = surface_color;
    }
    else if (token[0].equals("vertex")) {
      buffer.vertices.add(new PVector(float(token[1]), float(token[2]), float(token[3])));
    }
    else if (token[0].equals("end")) {
      Triangle tri = new Triangle(buffer);
      PVector A = tri.vertices.get(0);
      PVector B = tri.vertices.get(1);
      PVector C = tri.vertices.get(2);
      PVector AB = B.copy().sub(A);
      PVector AC = C.copy().sub(A);
      PVector N = AB.cross(AC).normalize(); // a, b, c
      tri.N = N.copy();
      current_scene.addTriangle(tri);
      buffer = new Triangle();
    }else if(token[0].equals("read")){
      interpreter(token[1]);
    }else if(token[0].equals("push")){
    
    
    }else if(token[0].equals("pop")){
    
    
    }else if(token[0].equals("rotate")){
    
    
    }else if(token[0].equals("translate")){
    
    
    }else if(token[0].equals("scale")){
    
    
    }else if (token[0].equals("render")) {
      draw_scene(current_scene);   // this is where you should perform the scene rendering
      current_scene = null;
    }
    else if (token[0].equals("#")) {
      // comment (ignore)
    }
    else {
      println ("unknown command: " + token[0]);
    }
  }
}

void reset_scene() {
  // reset your scene variables here
}

// This is where you should put your code for creating eye rays and tracing them.
void draw_scene(Scene s) {
  colorMode(RGB, 255, 255, 255);
  debug_flag = false;
  for(int y = 0; y < height; y++) {
    for(int x = 0; x < width; x++) {
      
      // Maybe set debug flag true for ONE pixel.
      // Have your routines (like ray/triangle intersection) 
      // print information when this flag is set.
      PVector eyePosition = new PVector(0,0,0);
      color color_c = castRay(x, y, s, eyePosition);
      
      // set the pixel color
      color c = color_c;  // you should use the correct pixel color here
      set (x, y, c);                   // make a tiny rectangle to fill the pixel
    }
  }
  debug_flag = true;
  debug_scene = s;
}

color castRay(int x, int y, Scene s, PVector origin){
  // create and cast an eye ray in order to calculate the pixel color
  float k = tan(radians(s.fov*0.5));
  float x_p = (x - width/2) * 2 * k / width;
  float y_p = (height/2 - y) * 2 * k / height;
  float z_p = -1;
  Ray r = new Ray(origin.x, origin.y, origin.z, x_p, y_p, z_p);
  color color_c = s.background_color;
  float nearest_z = -Float.MAX_VALUE;
  for(int i = 0; i < s.triangles.size(); i++) {
    Triangle tri = s.triangles.get(i);
    PVector P = rayTriangleIntersection(r, tri);
    if(P.z > z_p) {
      continue;
    }
    if(P.z < nearest_z){
      break;
    }
    nearest_z = max(P.z, nearest_z);
    PVector L = s.light_position.copy().sub(P).normalize();
    PVector N = tri.N;
    //float NDL = max(N.dot(L), 0);
    int surface_red = tri.surface_color >> 16 & 0xFF;
    int surface_green = tri.surface_color >> 8 & 0xFF;
    int surface_blue = tri.surface_color & 0XFF;
    int light_red = (s.light_color >> 16) & 0xFF;
    int light_green = (s.light_color >> 8) & 0xFF;
    int light_blue = (s.light_color) & 0xFF;
    float NDL = max(N.dot(L), 0);
    color_c = color(surface_red * light_red * NDL / 255, surface_green * light_green * NDL / 255, surface_blue * light_blue * NDL / 255);
  }
  return color_c;
}

// calculate intersection between ray and triangle, return point at which ray and triangle intersect
PVector rayTriangleIntersection(Ray r, Triangle tri){
  //calculate plane of triangle and get a, b, c and d
  PVector A = tri.vertices.get(0);
  PVector B = tri.vertices.get(1);
  PVector C = tri.vertices.get(2);
  PVector N = tri.N; // a, b, c
  float a = N.x;
  float b = N.y;
  float c = N.z;
  float d = -(a * A.x + b * A.y + c * A.z);
  //calculate t and find intersection of ray and plane
  float plane = a * r.direction.x + b * r.direction.y + c * r.direction.z;
  if(plane == 0)
    return new PVector(0,0,0);
  float t = -(a*r.origin.x + b*r.origin.y + c*r.origin.z + d) / plane;
  if(t < 0)
    return new PVector(0,0,0);
  PVector P = r.direction.copy().mult(t);
  if (P.dot(tri.N) > 0) tri.N.mult(-1);
  //if(debug_flag){
  //  println("Ray Plane intersect at : " + r.direction + "*" + t);
  //  println("\tSurface Normal: " + tri.N);
  //}
  if(insideTriangle(A, B, C, tri.N, P)){
    return P;
  }else {
    return new PVector(0,0,0);
  }
}

// return true if P is inside triangle ABC
boolean insideTriangle(PVector A, PVector B, PVector C, PVector N, PVector P){
  boolean side1 = side(A, B, N, P);
  boolean side2 = side(B, C, N, P);
  boolean side3 = side(C, A, N, P);
  return side1 == side2 && side2 == side3;
}


// return whether OX cross OP has the same side as ON
boolean side(PVector O, PVector X, PVector N, PVector P){
  PVector OX = X.copy().sub(O);
  PVector OP = P.copy().sub(O);
  PVector cross = OX.cross(OP);
  return N.dot(cross) > 0;
}

// prints mouse location clicks, for help in debugging
void mousePressed() {
  println ("\nYou pressed the mouse at " + mouseX + " " + mouseY);
  if(debug_scene != null){
    PVector eyePosition = new PVector(0,0,0);
    castRay(mouseX, mouseY, debug_scene, eyePosition);
  }
}

// you don't need to add anything in the "draw" function for this project
void draw() {
}
