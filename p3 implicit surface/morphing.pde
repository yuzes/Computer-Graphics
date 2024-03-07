float morphing_t = 1;


ImplicitInterface morphing = (x, y, z) -> {
   float dx = 1.2;
   float blobbyness = 0.4;
   PVector Q = new PVector(   x, y, z);
   PVector P1 = new PVector( dx, 0, 0);
   PVector P2 = new PVector(-dx, 0, 0);
   float distance1 = distance_lineSegment(P1, P2, Q);
   
   PVector P3 = new PVector(0,  dx, 0);
   PVector P4 = new PVector(0, -dx, 0);
   float distance2 = distance_lineSegment(P3, P4, Q);
   
   PVector P5 = new PVector(0, 0,  dx);
   PVector P6 = new PVector(0, 0, -dx);
   float distance3 = distance_lineSegment(P5, P6, Q);
   float d_line = blobby_filter(distance1, blobbyness) + blobby_filter(distance2, blobbyness) + blobby_filter(distance3, blobbyness);
   
   float d_sphere = blobby_filter(sqrt (x*x + y*y + z*z), 2);
   return morphing_t * d_line + (1 - morphing_t) * d_sphere;
};

ImplicitInterface my_implicit_surface = (x, y, z) -> {
   return 0;
};
