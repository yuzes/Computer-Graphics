// This is the starter code for the CS 6491 Ray Tracing project.
//
// The most important part of the code is the interpreter, which will help
// you parse the scene description (.cli) files.

//comment
boolean debug_flag = false;

Scene debug_scene = null;
Scene current_scene = null;
Material current_material = new Material();
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
    case '1': interpreter("s01a.cli"); break;
    case '2': interpreter("s02a.cli"); break;
    case '3': interpreter("s03a.cli"); break;
    case '4': interpreter("s04a.cli"); break;
    case '5': interpreter("s05a.cli"); break;
    case '6': interpreter("s06a.cli"); break;
    case '7': interpreter("s07a.cli"); break;
    case '8': interpreter("s08a.cli"); break;
    case '9': interpreter("s09a.cli"); break;
    
    case '!': interpreter("s01b.cli"); break;
    case '@': interpreter("s02b.cli"); break;
    case '#': interpreter("s03b.cli"); break;
    case '$': interpreter("s04b.cli"); break;
    case '%': interpreter("s05b.cli"); break;
    case '^': interpreter("s06b.cli"); break;
    case '&': interpreter("s07b.cli"); break;
    case '*': interpreter("s08b.cli"); break;
    case '(': interpreter("s09b.cli"); break;
    
    case 'q': interpreter("implicit_mesh.cli"); break;
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
      current_material = new Material();
      current_material.kd = color(float(token[1]), float(token[2]), float(token[3]));
    }    
    else if (token[0].equals("begin")) {
      buffer.material = current_material;
    }
    else if (token[0].equals("vertex")) {
      Matrix point_m = new Matrix(new float[][] {
                             {float(token[1])},
                             {float(token[2])},
                             {float(token[3])},
                             {1.0f}});
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
    }else if(token[0].equals("rotatex")){
      float degree = float(token[1]);
      PVector axis = new PVector(1,0,0);
      current_scene.stack.rotate(degree, axis);
    }else if(token[0].equals("rotatey")){
      float degree = float(token[1]);
      PVector axis = new PVector(0,1,0);
      current_scene.stack.rotate(degree, axis);
    }else if(token[0].equals("rotatez")){
      float degree = float(token[1]);
      PVector axis = new PVector(0,0,1);
      current_scene.stack.rotate(degree, axis);
    }else if(token[0].equals("translate")){
      current_scene.stack.translate(float(token[1]), float(token[2]), float(token[3]));
    }else if(token[0].equals("scale")){
      current_scene.stack.scale(float(token[1]), float(token[2]), float(token[3]));
    }else if (token[0].equals("render")) {
      timer = millis();
      draw_scene(current_scene);   // this is where you should perform the scene rendering
      //current_scene = null;
      int new_timer = millis();
      int diff = new_timer - timer;
      float seconds = diff / 1000.0;
      println ("timer = " + seconds + " sec");
    } 
    //
    // new material for p2
    
    
    else if(token[0].equals("box")){
      Matrix C = current_scene.stack.peek();
      PVector min = new PVector(float(token[1]),float(token[2]),float(token[3]));
      PVector max = new PVector(float(token[4]),float(token[5]),float(token[6]));
      PVector min_transform = C.apply(min, false);
      PVector max_transform = C.apply(max, false);
      AABB bbox = new AABB(min_transform, max_transform, current_material);
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
      Instance objInstance = new Instance(obj, C, inv, current_material);
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
    else if(token[0].equals("sphere")){
      Matrix center_m = new Matrix(new float[][] {
                             {float(token[2])},
                             {float(token[3])},
                             {float(token[4])},
                             {1.0f}});
      Matrix C = current_scene.stack.peek();
      Matrix transform_center = C.mult(center_m);
      PVector center = new PVector(transform_center.get(0,0), transform_center.get(1,0), transform_center.get(2,0));
      Sphere sph = new Sphere(center, float(token[1]));
      sph.material = current_material;
      current_scene.addObject(sph);
    }
    else if(token[0].equals("rays_per_pixel")){
      current_scene.rays_per_pixel = int(token[1]);
    }
    else if(token[0].equals("moving_object")){
      Object lastObject = current_scene.objects.get(current_scene.objects.size() - 1);
      lastObject.speed = new PVector(float(token[1]), float(token[2]), float(token[3]));
    }
    else if(token[0].equals("disk_light")){
      PVector center = new PVector(float(token[1]),float(token[2]),float(token[3]));
      float radius = float(token[4]);
      PVector direction = new PVector(float(token[5]),float(token[6]),float(token[7]));
      color light_color = color(float(token[8]),float(token[9]),float(token[10]));
      DiskLight d_light = new DiskLight(center, radius, direction, light_color);
      current_scene.lights.add(d_light);
    }
    else if(token[0].equals("lens")){
      current_scene.lens_radius = float(token[1]);
      current_scene.focal_length = float(token[2]);
    }
    else if(token[0].equals("glossy")){
      current_material = new Material();
      current_material.kd = color(float(token[1]), float(token[2]), float(token[3]));
      current_material.ks = color(float(token[4]), float(token[5]), float(token[6]));
      current_material.spec_pow = int(token[7]);
      current_material.k_refl = float(token[8]);
      current_material.gloss_radius = float(token[9]);
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
  current_scene = null;
}

// This is where you should put your code for creating eye rays and tracing them.
void draw_scene(Scene s) {
  colorMode(RGB, 255, 255, 255);
  debug_flag = false;
  for(int y = 0; y < height; y++) {
    for(int x = 0; x < width; x++) {
      color color_c = getColor(x, y, s);
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
  float motion_offset = -random(0,1);
  for(int i = start; i <= end; i++) {
    Object obj = objects.get(i);
    PVector new_origin = r.origin.copy().add(PVector.mult(obj.speed.copy(), motion_offset));
    Ray dr = new Ray(new_origin, r.direction.copy(), r.type);
    IntersectionResult ir = obj.intersectRay(dr);
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
  return new IntersectionResult(min_t, final_ir.m, final_ir.N.copy(), final_ir.hitpoint);
}

// return the color when shooting an eye ray from the origin
color getColor(int x, int y, Scene s){
  // create and cast an eye ray on pixel (x, y) in order to calculate the pixel color
  if(debug_flag){
    println("Start debugging " + s.name); 
  }
  float k = tan(radians(s.fov*0.5));
  int final_color_r = 0;
  int final_color_g = 0;
  int final_color_b = 0;
  for(int i = 0; i < s.rays_per_pixel; i++){
    float angle = random(0, TWO_PI);
  
    // Convert polar coordinates to Cartesian coordinates
    float r = sqrt(random(0, 1)) * current_scene.lens_radius;
    float dx = r * cos(angle);
    float dy = r * sin(angle);
    
    PVector O_lens = new PVector(dx,dy,0);
    float rx = s.rays_per_pixel > 1 ? random(0,1) : 0;
    float ry = s.rays_per_pixel > 1 ? random(0,1) : 0;
    float jx = x + rx;
    float jy = y + ry;
    float x_p = (jx - width/2) * 2 * k / width;
    float y_p = (height/2 - jy) * 2 * k / height;
    float z_p = -1;
    PVector direction;
    if(current_scene.focal_length == -1) {
      direction = new PVector(x_p, y_p, z_p); 
    }else{
      PVector dest = new PVector(current_scene.focal_length * x_p, current_scene.focal_length * y_p, -current_scene.focal_length);
      direction = dest.copy().sub(O_lens);
    }
    color color_ray = getColorByRay(s, new Ray(O_lens, direction, "EYE"));
    final_color_r += (color_ray >> 16) & 0xFF;
    final_color_g += (color_ray >> 8) & 0xFF;
    final_color_b += (color_ray) & 0xFF;
  }
  final_color_r /= s.rays_per_pixel;
  final_color_g /= s.rays_per_pixel;
  final_color_b /= s.rays_per_pixel;
  return color(final_color_r, final_color_g, final_color_b);
}

color getColorByRay(Scene s, Ray r) {
  IntersectionResult intersection = castRay(r, s.objects, 0, s.objects.size() - 1);
  if(intersection == null){
    return s.background_color;
  }
  float RDN = r.direction.copy().dot(intersection.N);
  PVector refl_direction = r.direction.copy().sub(intersection.N.copy().mult(2*RDN));
  float fuzz_x = random(-1, 1);
  float fuzz_y = random(-1, 1);
  float fuzz_z = random(-1, 1);
  PVector fuzz_factor = new PVector(fuzz_x, fuzz_y, fuzz_z);
  fuzz_factor.normalize().mult(intersection.m.gloss_radius);
  refl_direction.add(fuzz_factor);
  color refl_color = getColorByRay(s, new Ray(intersection.hitpoint.copy(), refl_direction.normalize(), "EYE"));
  float refl_r = intersection.m.k_refl * ((refl_color >> 16) & 0xFF);
  float refl_g = intersection.m.k_refl * ((refl_color >> 8) & 0xFF);
  float refl_b = intersection.m.k_refl * ((refl_color) & 0xFF);
  
  color kd = intersection.m.kd;
  color ks = intersection.m.ks;
  PVector N = intersection.N;
  PVector P = intersection.hitpoint.copy();
  int kdr = kd >> 16 & 0xFF;
  int kdg = kd >> 8 & 0xFF;
  int kdb = kd & 0XFF;
  int ksr = ks >> 16 & 0xFF;
  int ksg = ks >> 8 & 0xFF;
  int ksb = ks & 0XFF;
  float diffuse_r = 0;
  float diffuse_g = 0;
  float diffuse_b = 0;
  float specular_r = 0;
  float specular_g = 0;
  float specular_b = 0;
  PVector v = r.direction.mult(-1).normalize();
  for(Light l : s.lights){
    PVector L = l.position.copy().sub(P).normalize();
    PVector H = PVector.add(L, v).normalize();
    int light_red = (l.light_color >> 16) & 0xFF;
    int light_green = (l.light_color >> 8) & 0xFF;
    int light_blue = (l.light_color) & 0xFF;
    float NDL = max(N.copy().dot(L), 0);
    float NDH = max(pow(H.dot(N), intersection.m.spec_pow), 0);
    Ray shadowRay = getShadowRay(l, P);
    IntersectionResult shadowIntersection = castRay(shadowRay, s.objects, 0, s.objects.size() - 1);
    if(shadowIntersection == null || shadowIntersection.t < 0.00001){
      diffuse_r += kdr * light_red * NDL / 255;
      diffuse_g += kdg * light_green * NDL / 255;
      diffuse_b += kdb * light_blue * NDL / 255;
      specular_r += ksr * light_red * NDH / 255;
      specular_g += ksg * light_green * NDH / 255;
      specular_b += ksb * light_blue * NDH / 255;
    }else{
      
    }
  }
  return color(diffuse_r + specular_r + refl_r, 
               diffuse_g + specular_g + refl_g,  
               diffuse_b + specular_b + refl_b);
}

Ray getShadowRay(Light light, PVector origin) {
  // Generate a random radius within the disk
  if(light instanceof DiskLight) {
    DiskLight dl = (DiskLight) light;
    float angle = random(0, TWO_PI); // Random angle for polar coordinates
    float r = sqrt(random(0, 1)) * dl.radius; // Random radius for uniform distribution
    float x = r * cos(angle);
    float y = r * sin(angle);
    PVector normal = dl.direction.copy().normalize();
    PVector tangent = normal.cross(new PVector(0, 0, 1)); 
    if (tangent.mag() == 0) {
      tangent = new PVector(1, 0, 0);
    }
    tangent.normalize();
    PVector bitangent = normal.cross(tangent);
    PVector point = tangent.mult(x).add(bitangent.mult(y)).add(dl.position);
    return new Ray(origin, point.copy().sub(origin), "EYE");
  }else{
    return new Ray(origin, light.position.copy().sub(origin), "EYE"); 
  }
}


// prints mouse location clicks, for help in debugging
void mousePressed() {
  println ("\nYou pressed the mouse at " + mouseX + " " + mouseY);
  if(debug_scene != null){
    getColor(mouseX, mouseY, debug_scene);
  }
}

// you don't need to add anything in the "draw" function for this project
void draw() {
}
