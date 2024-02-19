// This is the starter code for the CS 6491 Ray Tracing project.
//
// The most important part of the code is the interpreter, which will help
// you parse the scene description (.cli) files.

//comment
boolean debug_flag = false;

Scene debug_scene = null;
Scene current_scene = null;
color surface_color = color(0,0,0);
int timer;  // global variable
ArrayList<Object> accelerationList;

void setup() {
  size (300,300);  
  noStroke();
  background (0, 0, 0);
}

void keyPressed() {
  reset_scene();
  switch(key) {
    case '1': interpreter("s01.cli"); break;
    case '2': interpreter("s02.cli"); break;
    case '3': interpreter("s03.cli"); break;
    case '4': interpreter("s04.cli"); break;
    case '5': interpreter("s05.cli"); break;
    case '6': interpreter("s06.cli"); break;
    case '7': interpreter("s07.cli"); break;
    case '8': interpreter("s08.cli"); break;
    case '9': interpreter("s09.cli"); break;
    case '0': interpreter("s10.cli"); break;
    case 'a': interpreter("s11.cli"); break;
    case 's': interpreter("s12.cli"); break;
    case 'd': interpreter("s13.cli"); break;
    case 'q': interpreter("myscene.cli"); break;
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
      Matrix point_m = new Matrix(new float[][] {
                             {float(token[1])},
                             {float(token[2])},
                             {float(token[3])},
                             {1.0f}});
      PVector point = new PVector(float(token[1]), float(token[2]),float(token[3]));
      Matrix C = current_scene.stack.peek();
      Matrix transform_point = C.mult(point_m);
      PVector vertex = new PVector(transform_point.get(0,0), transform_point.get(1,0), transform_point.get(2,0));
      //PVector vertex = point.copy();
      buffer.vertices.add(vertex);
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
      Matrix C_t = current_scene.stack.peek();
      Matrix inv = C_t.invert();
      tri.transformation = C_t;
      tri.inverseTransformation = inv;
      if(accelerationList != null){
        accelerationList.add(tri);
      }else{
        current_scene.addObject(tri); 
      }
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
      timer = millis();
      draw_scene(current_scene);   // this is where you should perform the scene rendering
      current_scene = null;
      int new_timer = millis();
      int diff = new_timer - timer;
      float seconds = diff / 1000.0;
      println ("timer = " + seconds);
    }
    //
    // new material for p2
    
    
    else if(token[0].equals("box")){
      Matrix C = current_scene.stack.peek();
      PVector min = new PVector(float(token[1]),float(token[2]),float(token[3]));
      PVector max = new PVector(float(token[4]),float(token[5]),float(token[6]));
      PVector min_transform = C.apply(min, false);
      PVector max_transform = C.apply(max, false);
      AABB bbox = new AABB(min_transform, max_transform, surface_color);
      current_scene.addObject(bbox);
    }
    else if(token[0].equals("named_object")){
      println("named_object " + token[1]);
      Object obj = current_scene.removeTail();
      current_scene.putInstance(token[1], obj);
    }
    else if(token[0].equals("instance")){
      Object obj = current_scene.getInstance(token[1]);
      Matrix C = current_scene.stack.peek();
      Matrix inv = C.invert();
      Instance objInstance = new Instance(obj, C, inv, surface_color);
      current_scene.addObject(objInstance);
    }
    else if(token[0].equals("begin_accel")){
      accelerationList = new ArrayList<Object>();
    }
    else if(token[0].equals("end_accel")){
      //println("Acceleration list has " + accelerationList.size() + " objects");
      BVH bvh = new BVH(accelerationList);
      current_scene.addObject(bvh);
      accelerationList = null;
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
IntersectionResult castRay(Ray r, ArrayList<Object> objects, int start, int end) {
  float min_t = Float.MAX_VALUE;
  IntersectionResult final_ir = null;
  for(int i = start; i <= end; i++) {
    Object obj = objects.get(i);
    IntersectionResult ir = obj.intersectRay(r);
    if(ir == null) continue;
    float t = ir.t;
    if(t <= 0 || t > min_t) {
      continue;
    }
    if(t < min_t){
      min_t = t;
      final_ir = ir;
    }
  }
  if(final_ir == null) return null;
  return new IntersectionResult(min_t, final_ir.c, final_ir.N.copy(), final_ir.hitpoint);
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
  IntersectionResult intersection = castRay(r, s.objects, 0, s.objects.size() - 1);
  if(intersection == null) return s.background_color;
  color color_c = color(0,0,0);
  PVector N = intersection.N;
  color_c = intersection.c;
  PVector P = intersection.hitpoint.copy();
  int surface_red = color_c >> 16 & 0xFF;
  int surface_green = color_c >> 8 & 0xFF;
  int surface_blue = color_c & 0XFF;
  float c_r = 0;
  float c_g = 0;
  float c_b = 0;
  for(Light l : s.lights){
    //PVector light_position_transform = s.stack.peek().invert().apply(l.position, false);
    PVector L = l.position.copy().sub(P).normalize();
    int light_red = (l.light_color >> 16) & 0xFF;
    int light_green = (l.light_color >> 8) & 0xFF;
    int light_blue = (l.light_color) & 0xFF;
    float NDL = max(N.copy().dot(L), 0);
    Ray shadowRay = new Ray(P, l.position.copy().sub(P), "SHADOW");
    IntersectionResult shadowIntersection = castRay(shadowRay, s.objects, 0, s.objects.size() - 1);
    //if(true){
    if(shadowIntersection == null || shadowIntersection.t < 0.00001){
      c_r += surface_red * light_red * NDL / 255;
      c_g += surface_green * light_green * NDL / 255;
      c_b += surface_blue * light_blue * NDL / 255;
    }else{
      if(debug_flag){
        //println("\tShadowray & triangle intersect at: t = " + shadowIntersection.t + " on Color : " + colorStr(shadowIntersection.c) + "Surface normal: " + shadowIntersection.N); 
      }
      
    }
  }
  color_c = color(c_r, c_g, c_b);
  return color_c;
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
