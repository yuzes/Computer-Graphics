float x_min = 0;
float x_max = 1;
float k_1 = 1;
float k_2 = 1;

ImplicitInterface implicit_line = (x, y, z) -> {
   float dx = 1.2;
   PVector Q = new PVector(x, y, z);
   PVector P1 = new PVector(dx, 0, 0);
   PVector P2 = new PVector(-dx, 0, 0);
   float distance = distance_lineSegment(P1, P2, Q);
   return blobby_filter(distance, 1.05);
};

ImplicitInterface implicit_square = (x, y, z) -> {
   float size = 1;
   float dx = size;
   float dy = size;
   float blobby = 0.8;
   PVector Q = new PVector(x, y, z);
   PVector P1 = new PVector(dx, dy, 0);
   PVector P2 = new PVector(-dx, dy, 0);
   PVector P3 = new PVector(dx, -dy, 0);
   PVector P4 = new PVector(-dx, -dy, 0);
   
   float d1 = distance_lineSegment(P1, P2, Q);
   float d2 = distance_lineSegment(P2, P4, Q);
   float d3 = distance_lineSegment(P4, P3, Q);
   float d4 = distance_lineSegment(P3, P1, Q);
   return blobby_filter(d1, blobby) + blobby_filter(d2, blobby) + blobby_filter(d3, blobby) + blobby_filter(d4, blobby);
};

ImplicitInterface implicit_line_offset = (x, y, z) -> {
   float dx = 1.5;
   PVector Q = new PVector(x, y, z);
   PVector P1 = new PVector(dx, 0.5, 0);
   PVector P2 = new PVector(-dx, 0.5, 0);
   float distance = distance_lineSegment(P1, P2, Q);
   return blobby_filter(distance, 0.8);
};

ImplicitInterface implicit_line_twist = (x, y, z) -> {
   float dx = 1.5;
   PVector Q = twist(x, y, z, 7.0);
   PVector P1 = new PVector(dx, 0.5, 0);
   PVector P2 = new PVector(-dx, 0.5, 0);
   float distance = distance_lineSegment(P1, P2, Q);
   return blobby_filter(distance, 2);
};

ImplicitInterface implicit_line_taper = (x, y, z) -> {
   float dx = 1.5;
   PVector Q = taper(x, y, z);
   PVector P1 = new PVector(dx, 0, 0);
   PVector P2 = new PVector(-dx, 0, 0);
   float distance = distance_lineSegment(P1, P2, Q);
   return blobby_filter(distance, 2);
};

ImplicitInterface implicit_line_twist_taper = (x, y, z) -> {
   float dx = 1.5;
   PVector Q = taper(x, y, z);
   Q = twist(Q.x, Q.y, Q.z, 10.0);
   PVector P1 = new PVector(dx, 0.5, 0);
   PVector P2 = new PVector(-dx, 0.5, 0);
   float distance = distance_lineSegment(P1, P2, Q);
   return blobby_filter(distance, 2);
};

PVector taper(float x, float y, float z){
  return new PVector(x, y/k(x), z/k(x));
}

float t(float x){
  if(x < x_min) return 0;
  if(x > x_max) return 1;
  return (x - x_min)/(x_max - x_min);
}

float k(float x){
  return (1-t(x)) * k_1 + t(x) * k_2;
}

PVector twist(float x, float y, float z, float density){
  PVector result = new PVector(0, 0, 0);
  float cos = cos(x*density);
  float sin = sin(x*density);
  result.x = x;
  result.y = 2*(y * cos - z * sin);
  result.z = 2*(y * sin + z * cos);
  return result;
}

float distance_lineSegment(PVector P1, PVector P2, PVector Q){
  PVector v = PVector.sub(P2, P1);
  PVector w = PVector.sub(Q, P1);
  
  float c1 = w.dot(v);
  if (c1 <= 0) {
      return PVector.dist(Q, P1);
  }
  
  float c2 = v.dot(v);
  if (c2 <= c1) {
      return PVector.dist(Q, P2);
  }
  
  float b = c1 / c2;
  PVector Pb = PVector.add(P1, PVector.mult(v, b));
  return PVector.dist(Q, Pb);
}
