import java.util.*;

class Scene {
  
  int fov;
  String name;
  ArrayList<Triangle> triangles;
  color background_color;
  ArrayList<Light> lights;
  MatrixStack stack;
  ArrayList<Object> objects;
  
  Scene() {
    this.triangles = new ArrayList<Triangle>();
    this.stack = new MatrixStack();
    this.lights = new ArrayList<Light>();
    this.objects = new ArrayList<Object>();
  }
  
  void addObject(Object o){
    this.objects.add(o);
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
    if(other.N != null)
      this.N = other.N.copy();
    for(int i = 0; i < other.vertices.size(); i++){
      this.vertices.add(other.vertices.get(i).copy()); 
    }
  }
}

class Ray {
  PVector origin;      // 3D point
  PVector direction;   // Direction vector
  String type;
  
  // Constructor
  Ray(PVector origin, PVector direction, String type) {
    this.origin = origin.copy();
    this.direction = direction.copy();
    this.type = type;
  }
  
  String toString(){
    return this.type + " Origin: " + this.origin + " Direction: " + this.direction;
  }
  
  // Other methods and functionalities can be added as needed
}

class Light{
  PVector position;
  color light_color;
  
  Light(PVector p, color c){
    this.position = p.copy();
    this.light_color = c;
  }
}


// An object that encapsulate information about a ray & triangle intersection, 
class RayTriangleIntersection{
  float t;
  Triangle triangle;
  RayTriangleIntersection(float t, Triangle tri){
    this.t = t;
    this.triangle = new Triangle(tri);
  }
  
}
