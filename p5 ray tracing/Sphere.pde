class Sphere extends Object {
  PVector center;
  float radius;
  
  Sphere(PVector c, float r){
    this.center = c;
    this.radius = r;
    this.bbox = new AABB(c.add(new PVector(r,r,r)), c.sub(new PVector(r,r,r)), color(1,1,1));
  }
  
  AABB getBbox(){
    return this.bbox;
  }
  
  @Override
  IntersectionResult intersectRay(Ray r){
    
    return null;
  }
}
