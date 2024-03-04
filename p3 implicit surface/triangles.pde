// Triangle Mesh

float h = 0.00001;

ArrayList<Vertex> verts;
ArrayList<Triangle> triangles;

class Vertex {
  PVector pos;     // position
  PVector normal;  // surface normal
  float r,g,b;     // color

  Vertex (float x, float y, float z) {
    pos = new PVector (x, y, z);
  }
}

class Triangle {
  int v1, v2, v3;
  
  Triangle (int i1, int i2, int i3) {
    v1 = i1;
    v2 = i2;
    v3 = i3;
  }
}

// initialize our list of triangles
void init_triangles()
{
  verts = new ArrayList<Vertex>();
  triangles = new ArrayList<Triangle>();
}

// create a new triangle with the given vertex indices
void add_triangle (int i1, int i2, int i3)
{
  Triangle tri = new Triangle (i1, i2, i3);
  triangles.add (tri);
}

// add a vertex to the vertex list
int add_vertex (PVector p)
{
  int index = verts.size();
  Vertex v = new Vertex (p.x, p.y, p.z);
  verts.add (v);
  return (index);
}

// draw the triangles of the surface
void draw_surface()
{
  for (int i = 0; i < triangles.size(); i++) {
    Triangle t = triangles.get(i);
    Vertex v1 = verts.get(t.v1);
    Vertex v2 = verts.get(t.v2);
    Vertex v3 = verts.get(t.v3);
    beginShape();
    // add "normal" command before each vertex to use per-vertex (smooth) normals
    if(normal_flag){
      float dx1 = (implicit_func.getValue (v1.pos.x + h, v1.pos.y, v1.pos.z) - implicit_func.getValue (v1.pos.x - h, v1.pos.y, v1.pos.z)) / (2*h);
      float dy1 = (implicit_func.getValue (v1.pos.x, v1.pos.y + h, v1.pos.z) - implicit_func.getValue (v1.pos.x, v1.pos.y - h, v1.pos.z)) / (2*h);
      float dz1 = (implicit_func.getValue (v1.pos.x, v1.pos.y, v1.pos.z + h) - implicit_func.getValue (v1.pos.x, v1.pos.y, v1.pos.z - h)) / (2*h);
      v1.normal = new PVector(dx1, dy1, dz1);
      normal(v1.normal.x, v1.normal.y, v1.normal.z);
      vertex (v1.pos.x, v1.pos.y, v1.pos.z);
      
      float dx2 = (implicit_func.getValue(v2.pos.x + h, v2.pos.y, v2.pos.z) - implicit_func.getValue(v2.pos.x - h, v2.pos.y, v2.pos.z)) / (2 * h);
      float dy2 = (implicit_func.getValue(v2.pos.x, v2.pos.y + h, v2.pos.z) - implicit_func.getValue(v2.pos.x, v2.pos.y - h, v2.pos.z)) / (2 * h);
      float dz2 = (implicit_func.getValue(v2.pos.x, v2.pos.y, v2.pos.z + h) - implicit_func.getValue(v2.pos.x, v2.pos.y, v2.pos.z - h)) / (2 * h);
      v2.normal = new PVector(dx2, dy2, dz2);
      normal(v2.normal.x, v2.normal.y, v2.normal.z);
      vertex(v2.pos.x, v2.pos.y, v2.pos.z);
      
      float dx3 = (implicit_func.getValue(v3.pos.x + h, v3.pos.y, v3.pos.z) - implicit_func.getValue(v3.pos.x - h, v3.pos.y, v3.pos.z)) / (2 * h);
      float dy3 = (implicit_func.getValue(v3.pos.x, v3.pos.y + h, v3.pos.z) - implicit_func.getValue(v3.pos.x, v3.pos.y - h, v3.pos.z)) / (2 * h);
      float dz3= (implicit_func.getValue(v3.pos.x, v3.pos.y, v3.pos.z + h) - implicit_func.getValue(v3.pos.x, v3.pos.y, v3.pos.z - h)) / (2 * h);
      v3.normal = new PVector(dx3, dy3, dz3);
      normal(v3.normal.x, v3.normal.y, v3.normal.z);
      vertex(v3.pos.x, v3.pos.y, v3.pos.z);
    }else{
      vertex (v1.pos.x, v1.pos.y, v1.pos.z);
      vertex (v2.pos.x, v2.pos.y, v2.pos.z);
      vertex (v3.pos.x, v3.pos.y, v3.pos.z); 
    }
    endShape(CLOSE);
  }
}

// write triangles to a text file
void write_triangles(String filename)
{
  PrintWriter out = createWriter (filename);

  for (int i = 0; i < triangles.size(); i++) {
    Triangle t = triangles.get(i);
    Vertex v1 = verts.get(t.v1);
    Vertex v2 = verts.get(t.v2);
    Vertex v3 = verts.get(t.v3);
    
    out.println();
    out.println ("begin");
    out.println ("vertex " + v1.pos.x + " " + v1.pos.y + " " + v1.pos.z);
    out.println ("vertex " + v2.pos.x + " " + v2.pos.y + " " + v2.pos.z);
    out.println ("vertex " + v3.pos.x + " " + v3.pos.y + " " + v3.pos.z);
    out.println ("end");
  }
}
