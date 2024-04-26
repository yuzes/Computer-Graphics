interface Renderable {
    // return information about the intersection between Ray r and this object
    // include distance t from ray's origin, color and surface normal of hit point
    IntersectionResult intersectRay(Ray r);
}

interface Transformable {
    void applyTransformation();
}

class Object implements Renderable{
    //Matrix invTransformation;
    AABB bbox;
    PVector center;
    Matrix inverseTransformation;
    Matrix transformation;
    Object() {
        this.inverseTransformation = new Matrix(4, 4);
        this.transformation = new Matrix(4,4);
    }
    
    AABB getBbox(){
      return null; 
    }
    
    IntersectionResult intersectRay(Ray r){
      return null; 
    }
    
    String toString() {
      return null;
    }
}

class Instance extends Object{
  Object obj;
  Matrix inverseTransformation;
  Matrix transformation;
  color surface_color;
  
  Instance(Object obj) {
    this(obj, new Matrix(4,4), new Matrix(4,4), color(1,1,1));
  }
  
  Instance(Object obj, Matrix trans, Matrix inv, color c){
    this.obj = obj;
    this.transformation = trans;
    this.inverseTransformation = inv;
    this.surface_color = c;
  }
  
  @Override
  IntersectionResult intersectRay(Ray r){
    Ray r_trans = r.transform(this.inverseTransformation);
    IntersectionResult ir = this.obj.intersectRay(r_trans);
    if(ir == null) return null;
    PVector hit_rspace = r_trans.direction.copy().mult(ir.t).add(r_trans.origin);
    PVector hit_wspace = transformation.apply(hit_rspace, false);
    if(hit_wspace.z > -1.0) return null;
    PVector N_wspace = transformation.apply(ir.N.copy(), true);
    if(debug_flag){
      println("Hit point in vector space: " + hit_rspace);
      println("Hit point in world space: " + hit_wspace);
      println("Surface Normal in vector space: " + ir.N);
      println("Surface Normal in world space: " + N_wspace);
    }
    PVector d = r.direction;
    float t_wspace = (PVector.sub(hit_wspace, r.origin).dot(d)) / (d.dot(d));
    if(N_wspace.z < 0) N_wspace.mult(-1);
    return new IntersectionResult(t_wspace, this.surface_color, N_wspace.normalize(), hit_wspace);
  }
}
