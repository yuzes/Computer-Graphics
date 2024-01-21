// This is the starter code for the CS 6491 Ray Tracing project.
//
// The most important part of the code is the interpreter, which will help
// you parse the scene description (.cli) files.

boolean debug_flag = false;

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
  Scene scene = new Scene();
  Triangle buffer = new Triangle();
  color surface_color = color(0,0,0);
  colorMode(RGB, 1.0);
  for (int i = 0; i < str.length; i++) {
    
    String[] token = splitTokens (str[i], " ");   // get a line and separate the tokens
    if (token.length == 0) continue;              // skip blank lines

    if (token[0].equals("fov")) {
      scene.fov = int(token[1]);
    } else if (token[0].equals("background")) {
      float r = float(token[1]);  // this is how to get a float value from a line in the scene description file
      float g = float(token[2]);
      float b = float(token[3]);
      println ("background = " + r + " " + g + " " + b);
      scene.background_color = color(r, g, b);
    }
    else if (token[0].equals("light")) {
      scene.light_position = new PVector(float(token[1]),float(token[2]),float(token[3]));
      scene.light_color = color(float(token[4]),float(token[5]),float(token[6]));
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
      PVector AB = PVector.sub(B, A);
      PVector AC = PVector.sub(C, A);
      PVector N = AB.cross(AC).normalize(); // a, b, c
      tri.N = N.copy();
      scene.addTriangle(tri);
      buffer = new Triangle();
    }
    else if (token[0].equals("render")) {
      draw_scene(scene);   // this is where you should perform the scene rendering
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
  for(int y = 0; y < height; y++) {
    for(int x = 0; x < width; x++) {
      
      // Maybe set debug flag true for ONE pixel.
      // Have your routines (like ray/triangle intersection) 
      // print information when this flag is set.
      debug_flag = false;
      if (x == 150 && y == 150)
        debug_flag = true;

      // create and cast an eye ray in order to calculate the pixel color
      float k = tan(radians(s.fov*0.5));
      float x_p = (x - width/2) * 2 * k / width;
      float y_p = (height - y - height/2) * 2 * k / height;
      float z_p = -1;
      
      Ray r = new Ray(0.0, 0.0, 0.0, x_p, y_p, z_p);
      color color_c = s.background_color;
      for(int i = 0; i < s.triangles.size(); i++) {
        Triangle tri = s.triangles.get(i);
        PVector P = rayTriangleIntersection(r, tri);
        if(P.z == 0) {
          println("No intersection at : " + x + ", " + y);
          break;
        }
        PVector L = s.light_position.sub(P).normalize();
        PVector N = tri.N;
        //float NDL = max(N.dot(L), 0);
        int surface_red = tri.surface_color >> 16 & 0xFF;
        int surface_green = tri.surface_color >> 8 & 0xFF;
        int surface_blue = tri.surface_color & 0XFF;
        int light_red = (s.light_color >> 16) & 0xFF;
        int light_green = (s.light_color >> 8) & 0xFF;
        int light_blue = (s.light_color) & 0xFF;
        float NDL = max(N.dot(L), 0);
        color_c = color(surface_red * light_red * NDL, surface_green * light_green * NDL, surface_blue * light_blue * NDL);
      }
      
      // set the pixel color
      color c = color_c;  // you should use the correct pixel color here
      set (x, y, c);                   // make a tiny rectangle to fill the pixel
    }
  }
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
  float t = -d / (a * r.direction.x + b * r.direction.y + c * r.direction.z);
  PVector P = r.direction.mult(t);
  if (P.dot(N) > 0) tri.N.mult(-1);
  if(insideTriangle(A, B, C, N, P)){
    return P;
  }else {
    return new PVector(0,0,0);
  }
}


// return true if P is inside triangle ABC
boolean insideTriangle(PVector A, PVector B, PVector C, PVector N, PVector P){
  boolean side1 = side(A, B, N, P);
  boolean side2 = side(A, C, N, P);
  boolean side3 = side(B, C, N, P);
  
  return side1 == side2 && side2 == side3;
}


// return whether OX cross OP has the same side as ON
boolean side(PVector O, PVector X, PVector N, PVector P){
  PVector OX = X.sub(O);
  PVector OP = P.sub(O);
  PVector cross = OX.cross(OP);
  return N.dot(cross) >= 0;
}

// prints mouse location clicks, for help in debugging
void mousePressed() {
  println ("You pressed the mouse at " + mouseX + " " + mouseY);
}

// you don't need to add anything in the "draw" function for this project
void draw() {
}
