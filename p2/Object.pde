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
    
    Object() {
        //this.invTransformation = new Matrix(4, 4);
    }
    
    IntersectionResult intersectRay(Ray r){
      return null; 
    }
}

class Instance extends Object{
  Object obj;
  Matrix inverseTransformation;
  
  Instance(Object obj) {
    this(obj, new Matrix(4,4));
  }
  
  Instance(Object obj, Matrix inv){
    this.obj = obj;
    this.inverseTransformation = inv;
  }
  
  @Override
  IntersectionResult intersectRay(Ray r){
    Ray r_trans = r.transform(this.inverseTransformation);
    return this.obj.intersectRay(r_trans);
  }
}
