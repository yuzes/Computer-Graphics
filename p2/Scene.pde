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


// Information about intersection of a ray with an object
// t: distance from origin, along the direction of ray
// c: color of hit point
// N: surface normal of hit point
class IntersectionResult{
  float t;
  color c;
  PVector N;
  
  IntersectionResult(float t, color c, PVector N){
    this.t = t;
    this.c = c;
    this.N = N;
  }
}
