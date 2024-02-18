import java.util.*;

class Scene {
  
  int fov;
  String name;
  ArrayList<Triangle> triangles;
  color background_color;
  ArrayList<Light> lights;
  MatrixStack stack;
  ArrayList<Object> objects;
  HashMap<String, Object> instances;
  
  Scene() {
    this.triangles = new ArrayList<Triangle>();
    this.stack = new MatrixStack();
    this.lights = new ArrayList<Light>();
    this.objects = new ArrayList<Object>();
    this.instances = new HashMap<>();
  }
  
  void addObject(Object o){
    this.objects.add(o);
  }
  
  Object removeTail(){
    return this.objects.remove(this.objects.size() - 1); 
  }
  
  void addTriangle(Triangle t){
    this.triangles.add(t);
  }
  
  void putInstance(String name, Object obj){
    this.instances.put(name, obj); 
  }
  
  Object getInstance(String name){
    return this.instances.get(name); 
  }
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
  PVector hitpoint;
  
  IntersectionResult(float t, color c, PVector N, PVector p){
    this.t = t;
    this.c = c;
    this.N = N;
    this.hitpoint = p;
  }
}
