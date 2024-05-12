class Triangle extends Object{
  ArrayList<PVector> vertices;
  PVector N; // surface normal
  Material material;
  
  Triangle(PVector v1, PVector v2, PVector v3) {
     super();
     this.vertices = new ArrayList<PVector> ();
     this.vertices.add(v1);
     this.vertices.add(v2);
     this.vertices.add(v3);
     this.center = v1.copy().add(v2).add(v3).mult(0.33333f);
     this.material = new Material();
  }
  
  Triangle() {
    super();
    this.vertices = new ArrayList<PVector> ();
    this.material = new Material();
  }
  
  Triangle(Triangle other){
    this.vertices = new ArrayList<PVector>();
    if(other.N != null)
      this.N = other.N.copy();
    PVector bboxMin = new PVector(Float.MAX_VALUE, Float.MAX_VALUE, Float.MAX_VALUE);
    PVector bboxMax = bboxMin.copy().mult(-1);
    for(int i = 0; i < other.vertices.size(); i++){
      PVector v = other.vertices.get(i).copy();
      this.vertices.add(v);
      bboxMin.x = min(bboxMin.x, v.x);
      bboxMin.y = min(bboxMin.y, v.y);
      bboxMin.z = min(bboxMin.z, v.z);
      
      bboxMax.x = max(bboxMax.x, v.x);
      bboxMax.y = max(bboxMax.y, v.y);
      bboxMax.z = max(bboxMax.z, v.z);
    }
    this.bbox = new AABB(bboxMin.copy(), bboxMax.copy(), new Material(color(1,random(0,1),1)));
    PVector v1 = this.vertices.get(0);
    PVector v2 = this.vertices.get(1);
    PVector v3 = this.vertices.get(2);
    this.center = v1.copy().add(v2).add(v3).mult(0.33333f);
    this.material = other.material;
  }
  
  
  @Override
  IntersectionResult intersectRay(Ray r){
    float t = this.rayTriangleIntersection(r);
    if(t == 0.0) return null;
    PVector P = r.direction.copy().mult(t).add(r.origin);
    //if(debug_flag)
    //  println("\t\tIntersection point: " + P);
    //if(P.z > -1) return null;
    if (P.copy().dot(this.N) > 0 && r.type == "EYE") this.N.mult(-1);
    return new IntersectionResult(t, this.material, this.N.copy(), P.copy());
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
    //if(debug_flag) 
    //  println(t);
    if(t < 0.00001)
      return 0.0;
    PVector P = r.direction.copy().mult(t).add(r.origin);
    //if(P.z > -1) return 0.0;
    if(insideTriangle(A, B, C, this.N, P)){
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
