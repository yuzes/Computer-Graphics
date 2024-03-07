// Create polygonalized implicit surfaces.

// for object rotation by mouse
int mouseX_old = 0;
int mouseY_old = 0;

PMatrix3D rot_mat;

// camera parameters
float camera_default = 6.0;
float camera_distance = camera_default;

boolean edge_flag = false;      // draw the polygon edges?
boolean normal_flag = false;   // use smooth normals during shading?
boolean random_color_flag = false;
boolean custom_flag = false;

// iso-surface threshold
float threshold = 1.0;  


PVector[] randomSpheres = new PVector[10];
color[] random_colors = new color[10];

int timer;  // used to time parts of the code

void setup()
{
  size (750, 750, OPENGL);
  
  // set up the rotation matrix
  rot_mat = (PMatrix3D) getMatrix();
  rot_mat.reset();
  
  // specify our implicit function is that of a sphere, then do isosurface extraction
  set_implicit (a_sphere);
  set_threshold (1.0);
  isosurface();
}

void draw()
{
  background (100, 100, 180);    // clear the screen

  perspective (PI*0.2, 1.0, 0.01, 1000.0);
  camera (0, 0, camera_distance, 0, 0, 0, 0, 1, 0);   // place the camera in the scene

  // create two directional light sources
  directionalLight (100, 100, 100, -0.7, 0.7, -1);
  directionalLight (182, 182, 182, 0, 0, -1);
  
  pushMatrix();

  // decide if we are going to draw the polygon edges
  if (edge_flag)
    stroke (0);  // black edges
  else
    noStroke();  // no edges

  fill (250, 250, 250);          // set the polygon color to white
  ambient (200, 200, 200);
  specular (0, 0, 0);            // turn off specular highlights
  shininess (1.0);
  
  applyMatrix (rot_mat);   // rotate the object using the global rotation matrix

  // draw the polygons from the implicit surface
  draw_surface();
  
  popMatrix();
}

// remember where the user clicked
void mousePressed()
{
  mouseX_old = mouseX;
  mouseY_old = mouseY;
}

// change the object rotation matrix while the mouse is being dragged
void mouseDragged()
{
  if (!mousePressed)
    return;

  float dx = mouseX - mouseX_old;
  float dy = mouseY - mouseY_old;
  dy *= -1;

  float len = sqrt (dx*dx + dy*dy);
  if (len == 0)
    len = 1;

  dx /= len;
  dy /= len;
  PMatrix3D rmat = (PMatrix3D) getMatrix();
  rmat.reset();
  rmat.rotate (len * 0.005, dy, dx, 0);
  rot_mat.preApply (rmat);

  mouseX_old = mouseX;
  mouseY_old = mouseY;
}

// handle keystrokes
void keyPressed()
{
  if (key == CODED) {
    if (keyCode == UP) {
      camera_distance *= 0.9;
    }
    else if (keyCode == DOWN) {
      camera_distance /= 0.9;
    }
    return;
  }
  
  if (key == ',') {  // decrease the grid resolution
    if (gsize > 10) {
      gsize -= 10;
      isosurface();
    }
    return;
  }
  if (key == '.') {  // increase the grid resolution
    gsize += 10;
    isosurface();
    return;
  }
  if (key == 'n') {
    normal_flag = !normal_flag;
    return;
  }
  
  random_color_flag = false;
  if (key == 'e') {
    edge_flag = !edge_flag;
  }
  if (key == 'r') {  // reset camera view and rotation
    rot_mat.reset();
    camera_distance = camera_default;
  }
  if (key == 'w') {  // write triangles to a file
    String filename = "implicit_mesh.cli";
    write_triangles (filename);
    println ("wrote triangles to file: " + filename);
  }
  if (key == '1') {
    set_threshold (1.0);
    set_implicit (a_sphere);
    isosurface();
  }
  if (key == '!') {
    set_threshold (1.0);
    set_implicit (flat_sphere);
    isosurface();
  }
  if (key == '2'){
    set_threshold(0.2);
    set_implicit (blobby_sphere);
    isosurface();
  }
  if (key == '@'){
    random_color_flag = true;
    for (int i = 0; i < 10; i++) {
      randomSpheres[i] = new PVector(random(-1.5, 1.5), random(-1.5, 1.5), random(-1.5, 1.5));
      random_colors[i] = color(int(random(0,255)),int(random(0,255)),int(random(0,255)));
    }
    set_threshold(0.2);
    set_implicit(ten_blobbys);
    isosurface();
  }
  if (key == '3'){
    set_threshold(0.5);
    set_implicit (implicit_line);
    isosurface();
  }
  if (key == '#'){
    set_threshold(0.4);
    set_implicit (implicit_square);
    isosurface();
  }
  if (key == '4'){
    set_threshold(0.8);
    set_implicit (implicit_torus);
    isosurface();
  }
  if (key == '$'){
    set_threshold(0.8);
    set_implicit (blobby_tori);
    isosurface();
  }
  if (key == '5'){
    set_threshold(1.7);
    set_implicit (implicit_line_offset);
    isosurface();
  }
  if (key == '%'){
    set_threshold(1.7);
    set_implicit (implicit_line_twist);
    isosurface();
  }
  if (key == '6'){
    x_min = -1.5;
    x_max = 1.5;
    k_1 = 0.3;
    k_2 = 1;
    set_threshold(1.7);
    set_implicit (implicit_line_taper);
    isosurface();
  }
  if (key == '^'){
    x_min = -1.5;
    x_max = 1.5;
    k_1 = 0.3;
    k_2 = 1;
    set_threshold(1.2);
    set_implicit (implicit_line_twist_taper);
    isosurface();
  }
  if (key == '7'){
    set_threshold (0.1);
    set_implicit (intersection_sphere);
    isosurface();
  }
  if (key == '&'){
    set_threshold (0.1);
    set_implicit (difference_sphere);
    isosurface();
  }
  if (key == '8'){
    set_threshold(0.5);
    morphing_t -= 0.1;
    if(morphing_t < 0) morphing_t += 1;
    set_implicit(morphing);
    isosurface();
  }
  if (key == '9'){
    set_threshold(0.5);
    morphing_t += 0.1;
    if(morphing_t > 1) morphing_t -= 1;
    set_implicit(morphing);
    isosurface();
  }
  if (key == '0'){
    random_color_flag = true;
    for (int i = 0; i < 10; i++) {
      random_colors[i] = color(int(random(0,255)),int(random(0,255)),int(random(0,255)));
    }
    randomSpheres[0] = new PVector(0,-1,0);
    randomSpheres[1] = new PVector(0,0,0);
    randomSpheres[2] = new PVector(0,1,0);
    randomSpheres[3] = new PVector(0,2,0);
    randomSpheres[4] = new PVector(1,1,0);
    randomSpheres[5] = new PVector(-1,1,0);
    randomSpheres[6] = new PVector(1,-1,0);
    randomSpheres[7] = new PVector(-1,-1,0);
    randomSpheres[8] = new PVector(0,2,0);
    randomSpheres[9] = new PVector(0,2,0);
    set_threshold(0.2);
    set_implicit(my_implicit_surface);
    isosurface();
  }
}

void reset_timer()
{
  timer = millis();
}

void print_timer()
{
  int new_timer = millis();
  int diff = new_timer - timer;
  float seconds = diff / 1000.0;
  println ("timer = " + seconds);
}
