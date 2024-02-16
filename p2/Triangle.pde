class Triangle extends Object{
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
  
  @Override
  IntersectionResult intersectRay(Ray r){
    float t = this.rayTriangleIntersection(r);
    if(t == 0) return null;
    return new IntersectionResult(t, this.surface_color, this.N);
  }
  
  float rayTriangleIntersection(Ray r){
    //calculate plane of triangle and get a, b, c and d
    PVector A = this.vertices.get(0);
    PVector B = this.vertices.get(1);
    PVector C = this.vertices.get(2);
    PVector N = this.N; // a, b, c
    float a = N.x;
    float b = N.y;
    float c = N.z;
    float d = -(a * A.x + b * A.y + c * A.z);
    //calculate t and find intersection of ray and plane
    float plane = a * r.direction.x + b * r.direction.y + c * r.direction.z;
    if(plane == 0)
      return 0.0;
    float t = -(a*r.origin.x + b*r.origin.y + c*r.origin.z + d) / plane;
    if(t < 0.00001)
      return 0.0;
    PVector P = r.direction.copy().mult(t).add(r.origin);
    if(P.z > -1) return 0.0;
    if (P.dot(this.N) > 0 && r.type == "EYE") this.N.mult(-1);
    if(insideTriangle(A, B, C, this.N, P)){
      if(debug_flag){
        println("Hit point " + P + " inside triangle: " + colorStr(this.surface_color) + " Triangle Normal: " + this.N);
        println("O + t*d = " + r.origin + " + " + t + " * " + r.direction + " = " + r.origin.copy().add(r.direction.copy().mult(t)));
      }
      return t;
    }else {
      return 0.0;
    }
  }
  
  // return true if P is inside triangle ABC
  boolean insideTriangle(PVector A, PVector B, PVector C, PVector N, PVector P){
    boolean side1 = side(A, B, N, P);
    boolean side2 = side(B, C, N, P);
    boolean side3 = side(C, A, N, P);
    return side1 == side2 && side2 == side3;
  }
  
  
  // return whether OX cross OP has the same side as ON
  boolean side(PVector O, PVector X, PVector N, PVector P){
    PVector OX = X.copy().sub(O);
    PVector OP = P.copy().sub(O);
    PVector cross = OX.cross(OP);
    return N.dot(cross) > 0;
  }
}
