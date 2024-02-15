interface Object{
  RayTriangleIntersection intersectRay(Ray r);
}

//
class Mesh implements Object{
  String name;
  ArrayList<Triangle> triangles;
  
  Mesh(String name){
    this.name = name;
    this.triangles = new ArrayList<Triangle>();
  }
  
  RayTriangleIntersection intersectRay(Ray r){
    return null;  
  }
}

class AABB implements Object{
  PVector min;
  PVector max;
  
  AABB(PVector min, PVector max){
    this.min= min;
    this.max = max;
  }
  
  RayTriangleIntersection intersectRay(Ray r){
    return null;  
  }
}

class MeshInstance {
  Mesh mesh;
  Matrix transformation;
}
