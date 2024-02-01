// This is the starter code for the CS 6491 Ray Tracing project.
//
// The most important part of the code is the interpreter, which will help
// you parse the scene description (.cli) files.

boolean debug_flag = false;

Scene debug_scene = null;
Scene current_scene = null;
color surface_color = color(0,0,0);

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
    case '5': interpreter("s5.cli"); break;
    case '6': interpreter("s6.cli"); break;
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
  if(current_scene == null){
    current_scene = new Scene();
    current_scene.name = file;
  }
  Triangle buffer = new Triangle();
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
      PVector position = new PVector(float(token[1]),float(token[2]),float(token[3]));
      color light_color = color(float(token[4]),float(token[5]),float(token[6]));
      Light current_light = new Light(position, light_color);
      current_scene.lights.add(current_light);
    }
    else if (token[0].equals("surface")) {
      surface_color = color(float(token[1]), float(token[2]), float(token[3]));
    }    
    else if (token[0].equals("begin")) {
      buffer.surface_color = surface_color;
    }
    else if (token[0].equals("vertex")) {
      Matrix point = new Matrix(new float[][] {
                             {float(token[1])},
                             {float(token[2])},
                             {float(token[3])},
                             {1.0f}});
      Matrix C = current_scene.stack.peek();
      Matrix transform_point = C.mult(point);
      buffer.vertices.add(new PVector(transform_point.get(0,0), transform_point.get(1,0), transform_point.get(2,0)));
    }
    else if (token[0].equals("end")) {
      Triangle tri = new Triangle(buffer);
      PVector A = tri.vertices.get(0);
      PVector B = tri.vertices.get(1);
      PVector C = tri.vertices.get(2);
      PVector AB = B.copy().sub(A);
      PVector AC = C.copy().sub(A);
      PVector N = AB.cross(AC).normalize();
      tri.N = N.copy();
      current_scene.addTriangle(tri);
      buffer = new Triangle();
    }else if(token[0].equals("read")){
      interpreter(token[1]);
    }else if(token[0].equals("push")){
      current_scene.stack.push();
    }else if(token[0].equals("pop")){
      current_scene.stack.pop();
    }else if(token[0].equals("rotate")){
      float degree = float(token[1]);
      PVector axis = new PVector(float(token[2]), float(token[3]), float(token[4]));
      current_scene.stack.rotate(degree, axis);
    }else if(token[0].equals("translate")){
      current_scene.stack.translate(float(token[1]), float(token[2]), float(token[3]));
    }else if(token[0].equals("scale")){
      current_scene.stack.scale(float(token[1]), float(token[2]), float(token[3]));
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
      color color_c = getColor(x, y, s, eyePosition);
      set (x, y, color_c);                   // make a tiny rectangle to fill the pixel
    }
  }
  debug_flag = true;
  debug_scene = s;
}

// cast a ray and return the first hit triangle in scene s
RayTriangleIntersection castRay(Ray r, Scene s) {
  float min_t = Float.MAX_VALUE;
  Triangle closest_triangle = null;
  for(int i = 0; i < s.triangles.size(); i++) {
    Triangle tri = s.triangles.get(i);
    float t = rayTriangleIntersection(r, tri);
    if(t <= 0 || t > min_t) {
      continue;
    }
    if(t < min_t){
      min_t = t;
      closest_triangle = tri;
    }
  }
  if(closest_triangle == null) return null;
  return new RayTriangleIntersection(min_t, closest_triangle);
}

// return the color when shooting an eye ray from the origin
color getColor(int x, int y, Scene s, PVector origin){
  // create and cast an eye ray on pixel (x, y) in order to calculate the pixel color
  if(debug_flag){
    println("Start debugging " + s.name); 
  }
  float k = tan(radians(s.fov*0.5));
  float x_p = (x - width/2) * 2 * k / width;
  float y_p = (height/2 - y) * 2 * k / height;
  float z_p = -1;
  Ray r = new Ray(origin, new PVector(x_p, y_p, z_p), "EYE");
  RayTriangleIntersection intersection = castRay(r, s);
  if(intersection == null) return s.background_color;
  color color_c = color(0,0,0);
  Triangle closest_triangle = intersection.triangle;
  float min_t = intersection.t;
  color_c = closest_triangle.surface_color;
  PVector P = r.direction.copy().mult(min_t).add(r.origin);
  //PVector L = s.light_position.copy().sub(P).normalize();
  PVector N = closest_triangle.N;
  int surface_red = color_c >> 16 & 0xFF;
  int surface_green = color_c >> 8 & 0xFF;
  int surface_blue = color_c & 0XFF;
  float c_r = 0;
  float c_g = 0;
  float c_b = 0;
  for(Light l : s.lights){
    PVector L = l.position.copy().sub(P).normalize();
    int light_red = (l.light_color >> 16) & 0xFF;
    int light_green = (l.light_color >> 8) & 0xFF;
    int light_blue = (l.light_color) & 0xFF;
    float NDL = max(N.dot(L), 0);
    Ray shadowRay = new Ray(P, l.position.copy().sub(P), "SHADOW");
    if(debug_flag)
      println("Shadow ray: " + shadowRay.toString() + " to Light " + l.position + " with color " + colorStr(l.light_color));
    RayTriangleIntersection shadowIntersection = castRay(shadowRay, s);
    if(shadowIntersection == null || shadowIntersection.t >= 1){
      c_r += surface_red * light_red * NDL / 255;
      c_g += surface_green * light_green * NDL / 255;
      c_b += surface_blue * light_blue * NDL / 255;
    }else{
      if(debug_flag){
        println("\tShadowray & triangle intersect at: t = " + shadowIntersection.t + " on Triangle : " + colorStr(shadowIntersection.triangle.surface_color)); 
      }
      
    }
  }
  color_c = color(c_r, c_g, c_b);
  return color_c;
}

// calculate intersection between ray and triangle, return point at which ray and triangle intersect
float rayTriangleIntersection(Ray r, Triangle tri){
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
    return 0.0;
  float t = -(a*r.origin.x + b*r.origin.y + c*r.origin.z + d) / plane;
  if(t < 0.00001)
    return 0.0;
  PVector P = r.direction.copy().mult(t).add(r.origin);
  if (P.dot(tri.N) > 0 && r.type == "EYE") tri.N.mult(-1);
  if(insideTriangle(A, B, C, tri.N, P)){
    if(debug_flag){
      println("Hit point " + P + " inside triangle: " + colorStr(tri.surface_color) + " Triangle Normal: " + tri.N);
      println("O + t*d = " + r.origin + " + " + t + " * " + r.direction + " = " + r.origin.copy().add(r.direction.copy().mult(t)));
    }
    return t;
  }else {
    return 0.0;
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

String colorStr(color c){
  int r = (c >> 16) & 0xFF;
  int g = (c >> 8) & 0xFF;
  int b = c & 0xFF; 
  return r + " " + g + " " + b;
}


// prints mouse location clicks, for help in debugging
void mousePressed() {
  println ("\nYou pressed the mouse at " + mouseX + " " + mouseY);
  if(debug_scene != null){
    PVector eyePosition = new PVector(0,0,0);
    getColor(mouseX, mouseY, debug_scene, eyePosition);
  }
}

// you don't need to add anything in the "draw" function for this project
void draw() {
}
