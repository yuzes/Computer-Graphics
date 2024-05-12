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
    PVector speed;
    Object() {
        this.inverseTransformation = new Matrix(4, 4);
        this.transformation = new Matrix(4,4);
        this.speed = new PVector(0,0,0);
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
  Material material;
  
  Instance(Object obj) {
    this(obj, new Matrix(4,4), new Matrix(4,4), new Material());
  }
  
  Instance(Object obj, Matrix trans, Matrix inv, Material m){
    this.obj = obj;
    this.transformation = trans;
    this.inverseTransformation = inv;
    this.material = m;
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
    PVector d = r.direction;
    float t_wspace = (PVector.sub(hit_wspace, r.origin).dot(d)) / (d.dot(d));
    if(N_wspace.z < 0) N_wspace.mult(-1);
    return new IntersectionResult(t_wspace, this.material, N_wspace.normalize(), hit_wspace);
  }
}
