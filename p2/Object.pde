interface Renderable {
    // return information about the intersection between Ray r and this object
    // include distance t from ray's origin, color and surface normal of hit point
    IntersectionResult intersectRay(Ray r);
}

interface Transformable {
    void applyTransformation();
}

class Object implements Renderable{
    Matrix invTransformation;
    
    Object() {
        this.invTransformation = new Matrix(4, 4);
    }
    
    IntersectionResult intersectRay(Ray r){
      return null; 
    }
}


class NamedObject{
  String name;
  ArrayList<Triangle> triangles;
  
  NamedObject(String name){
    this.name = name;
    this.triangles = new ArrayList<Triangle>();
  }
}

class NamedObjectInstance extends Object {
  NamedObject mesh;
  Matrix transformation;
  
  
  @Override
  IntersectionResult intersectRay(Ray r){
    float min_t = Float.MAX_VALUE;
    Triangle closest_triangle = null;
    for(Triangle tri : this.mesh.triangles) {
      float t = tri.rayTriangleIntersection(r);
      if(t <= 0 || t > min_t) {
        continue;
      }
      if(t < min_t){
        min_t = t;
        closest_triangle = tri;
      }
    }
    if(closest_triangle == null) return null;
    return new IntersectionResult(min_t, closest_triangle.surface_color, closest_triangle.N);
  }
}
