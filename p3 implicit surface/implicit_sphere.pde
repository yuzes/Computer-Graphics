// Implicit function for a sphere at the origin.
//
// This may look like a function definition, but it is a lambda expression that we are
// storing in the variable "a_sphere" using =. Note the -> and the semi-colon after the last }
ImplicitInterface a_sphere = (x, y, z) -> {
  float d = sqrt (x*x + y*y + z*z);
  return d;
};

ImplicitInterface flat_sphere = (x, y, z) -> {
  float d = sqrt(x*x + y*y*10 + z*z); 
  return d;
};

ImplicitInterface blobby_sphere = (x, y, z) -> {
   float dx = 0.75;
   float dx2 = 0.7;
   float dy = 1.0;
   PVector P = new PVector(x, y, z);
   PVector c1 = new PVector(-dx, dy, 0);
   PVector c2 = new PVector(dx, dy, 0);
   PVector c3 = new PVector(-dx2, -dy, 0);
   PVector c4 = new PVector(dx2, -dy, 0);
   
   float d_p1 = blobby_pair(P, c1, c2, 0.94);
   float d_p2 = blobby_pair(P, c3, c4, 0.96);
   return d_p2 + d_p1;
};

ImplicitInterface ten_blobbys = (x, y, z) -> {
  PVector P = new PVector(x, y, z);
  float d_ps = 0.0;
  for(int i = 0; i < 10; i++){
    PVector c = lineSegments[i];
    float d = distance(P, c);
    d_ps += blobby_filter(d, 0.6);
  }
  return d_ps;
};

ImplicitInterface intersection_sphere = (x, y, z) -> {
  float dx = 0.5;
  PVector P = new PVector(x, y, z);
  PVector c1 = new PVector(-dx, 0, 0);
  PVector c2 = new PVector(dx, 0, 0);
  float d1 = distance(P, c1);
  float d2 = distance(P, c2);
  return min(blobby_filter(d1, 0.9),blobby_filter(d2, 0.9));
};

float blobby_pair(PVector P, PVector c1, PVector c2, float r){
   float d1 = distance(P, c1);
   float d2 = distance(P, c2);
   float d_p = blobby_filter(d1, r) + blobby_filter(d2, r);
   return d_p;
}

float distance(PVector p1, PVector p2){
  float dx = p2.x - p1.x;
  float dy = p2.y - p1.y;
  float dz = p2.z - p1.z;
  return sqrt(dx * dx + dy * dy + dz * dz); 
}
