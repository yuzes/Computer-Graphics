// Polygon mesh manipulation starter code.

// for object rotation by mouse
int mouseX_old = 0;
int mouseY_old = 0;
PMatrix3D rot_mat;

// camera parameters
float camera_default = 6.0;
float camera_distance = camera_default;
boolean debugflag = false;
boolean display_edge = false;
boolean random_color_flag = false;
boolean per_vertex_normal = false;
boolean visualize_edge = false;
ArrayList<Integer> random_colors;
int current_eid = 0;


//
Mesh current_mesh  = null;

void setup()
{
  size (800, 800, OPENGL);
  rot_mat = (PMatrix3D) getMatrix();
  rot_mat.reset();
}

void draw()
{
  background (130, 130, 220);    // clear the screen to black

  perspective (PI*0.2, 1.0, 0.01, 1000.0);
  camera (0, 0, camera_distance, 0, 0, 0, 0, 1, 0);   // place the camera in the scene
  
  // create an ambient light source
  ambientLight (52, 52, 52);

  // create two directional light sources
  lightSpecular (0, 0, 0);
  directionalLight (150, 150, 150, -0.7, 0.7, -1);
  directionalLight (152, 152, 152, 0, 0, -1);
  
  pushMatrix();

  stroke (0);                    // draw polygons with black edges
  fill (200, 200, 200);          // set the polygon color to white
  
  ambient (200, 200, 200);
  specular (0, 0, 0);            // turn off specular highlights
  shininess (1.0);
  
  applyMatrix (rot_mat);   // rotate the object using the global rotation matrix
  
  // THIS IS WHERE YOU SHOULD DRAW YOUR MESH
  if(display_edge) noStroke();
  
  if(current_mesh != null){
      
      for(Face face : current_mesh.faces){
        Edge edge = current_mesh.edges.get(face.eid);
        if(random_color_flag){
          color c = face.c;
          fill((c >> 16) & 0xFF, (c >> 8) & 0xFF, c & 0xFF);
        }
        beginShape();
        if(!per_vertex_normal){
          normal(face.N.x, face.N.y, face.N.z); 
        }
        for(int i = 0; i < face.num_vert; i++){
          Vertex vert = current_mesh.vertices.get(edge.vid);
          edge = current_mesh.edges.get(edge.next);
          if(per_vertex_normal){
            normal(vert.N.x, vert.N.y, vert.N.z); 
          }
          vertex(vert.p.x, vert.p.y, vert.p.z);
        }
        endShape(CLOSE);
      }
      if(visualize_edge){
          Edge current_e = current_mesh.edges.get(current_eid);
          Face current_f = current_mesh.faces.get(current_e.fid);
          Vertex v_src = current_mesh.vertices.get(current_e.vid);
          Edge next_e = current_mesh.edges.get(current_e.next);
          Vertex v_dest = current_mesh.vertices.get(next_e.vid);
          visualize_edge(v_src.p, v_dest.p, current_f);
      }
  }
    
  popMatrix();
}

void visualize_edge(PVector source, PVector dest, Face f){
  PVector face_normal = f.N.copy();
  PVector direction = PVector.sub(dest, source);
  float scale = PVector.dist(dest, source)/20;
  PVector offset = face_normal.cross(direction).normalize().setMag(scale);
  PVector p1 = PVector.add(source, PVector.mult(direction, 0.4));
  PVector p2 = PVector.lerp(p1, dest, 0.15);
  PVector p3 = PVector.lerp(p1, dest, 0.3);
  //drawSphere(source, scale, color(255,0,0));
  //drawSphere(dest, scale, color(0,255,0));
  drawSphere(p1.add(offset), scale*0.9, color(0,0,255));
  drawSphere(p2.add(offset), scale*1.1, color(0,0,255));
  drawSphere(p3.add(offset), scale*1.3, color(0,0,255));
  
}

void drawSphere(PVector position, float r, color c){
  translate(position.x,  position.y, position.z);
  fill(c);
  noStroke();
  sphere(r);
  translate(-position.x,  -position.y, -position.z);
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
    if (keyCode == UP) {         // zoom in
      camera_distance *= 0.9;
    }
    else if (keyCode == DOWN) {  // zoom out
      camera_distance /= 0.9;
    }
    return;
  }
  
  if (key == 'R') {
    rot_mat.reset();
    camera_distance = camera_default;
  }
  else if (key == '1') {
    read_mesh ("octa.ply");
  }
  else if (key == '2') {
    read_mesh ("cube.ply");
  }
  else if (key == '3') {
    read_mesh ("icos.ply");
  }
  else if (key == '4') {
    read_mesh ("dodeca.ply");
  }
  else if (key == '5') {
    read_mesh ("star.ply");
  }
  else if (key == '6') {
    read_mesh ("torus.ply");
  }
  else if (key == '7') {      
    read_mesh ("s.ply");
  }
  else if (key == 'f') {      
    per_vertex_normal = !per_vertex_normal;
  }
  else if (key == 'e') {      
    display_edge = !display_edge;
  }
  else if (key == 'w') {      
    random_color_flag = !random_color_flag;
  }
  else if (key == 'v') {      
    visualize_edge = !visualize_edge;
  }
  else if (key == 'n') { 
    if(current_mesh != null) current_eid = current_mesh.edges.get(current_eid).next;
  }
  else if (key == 'p') {      
    if(current_mesh != null) current_eid = current_mesh.edges.get(current_eid).prev;
  }
  else if (key == 'o') {      
    if(current_mesh != null) current_eid = current_mesh.edges.get(current_eid).opposite;
  }
  else if (key == 's') {      
    if(current_mesh != null){
      current_eid = current_mesh.edges.get(current_eid).opposite;
      current_eid = current_mesh.edges.get(current_eid).next;
    }
  }
  else if (key == 'd') {      
    current_mesh = current_mesh.dual();
  }
  else if (key == 'g') {      
    
  }
  else if (key == 'c') {      
    
  }
  else if (key == 'r') {      
    
  }
  else if (key == 'l') {      
    
  }
  else if (key == 't') {      
    
  }
  

}
