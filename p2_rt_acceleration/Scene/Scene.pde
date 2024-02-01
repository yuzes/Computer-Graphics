class Scene {
  
  int fov;
  PVector light_position;
  color light_color;
  ArrayList<Triangle> triangles;
  color background_color;
  
  Scene() {
    this.triangles = new ArrayList<Triangle> ();
  }
  
  void addTriangle(Triangle t){
    this.triangles.add(t);
  }
}

class Triangle{
  ArrayList<PVector> vertices;
  color surface_c;
  Triangle(PVector v1, PVector v2, PVector v3) {
     this.vertices = new ArrayList<PVector> ();
     this.vertices.add(v1);
     this.vertices.add(v2);
     this.vertices.add(v3);
  }
  
  Triangle() {
    this.vertices = new ArrayList<PVector> ();
  }
}
