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
  color surface_color;
  PVector N; // surface normal
  
  Triangle(PVector v1, PVector v2, PVector v3) {
     this.vertices = new ArrayList<PVector> ();
     this.vertices.add(v1);
     this.vertices.add(v2);
     this.vertices.add(v3);
  }
  
  Triangle() {
    this.vertices = new ArrayList<PVector> ();
  }
  
  Triangle(Triangle other){
    this.surface_color = other.surface_color;
    this.vertices = new ArrayList<PVector>();
    for(int i = 0; i < other.vertices.size(); i++){
      this.vertices.add(other.vertices.get(i)); 
    }
  }
}

class Ray {
  PVector origin;      // 3D point
  PVector direction;   // Direction vector
  
  // Constructor
  Ray(float x, float y, float z, float dx, float dy, float dz) {
    origin = new PVector(x, y, z);
    direction = new PVector(dx, dy, dz);
  }
  
  // Other methods and functionalities can be added as needed
}
