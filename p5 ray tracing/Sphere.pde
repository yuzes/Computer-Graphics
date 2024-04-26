class Sphere extends Object {
  PVector center;
  float radius;
  color surface_color;
  
  Sphere(PVector c, float r, color surface_color){
    this.center = c;
    this.radius = r;
    this.bbox = new AABB(c.copy().add(new PVector(r,r,r)), c.copy().sub(new PVector(r,r,r)), color(1,1,1));
    this.surface_color = surface_color;  
}
  
  AABB getBbox(){
    return this.bbox;
  }
  
  @Override
  String toString() {
    return "Sphere " + center + " " + radius;
  }
  
  @Override
  IntersectionResult intersectRay(Ray r){
    PVector oc = r.origin.copy().sub(this.center);
    float A = r.direction.dot(r.direction);
    float B = 2 * r.direction.dot(oc);
    float C = oc.dot(oc) - this.radius * this.radius;
    float discriminant = B * B - 4 * A * C;
    if(discriminant < 0) return null;
    float t1 = (-B - sqrt(discriminant)) / (2 * A);
    float t2 = (-B + sqrt(discriminant)) / (2 * A);
    float t = min(t1, t2);
    if(t < 0) return null;
    PVector p = r.direction.copy().mult(t).add(r.origin);
    return new IntersectionResult(t, this.surface_color, p.copy().sub(this.center).normalize(), p);
  }
}
