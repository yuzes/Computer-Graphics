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
  float limb_blobbyness = 0.3;
  float dz = 0;
  PVector Q = new PVector(x*2, y*2, z*2);
  PVector center = new PVector(0,0,dz);
  PVector left_knee = new PVector(-1, -1,dz);
  PVector right_knee = new PVector(1, -1,dz);
  PVector left_heel = new PVector(-1, -2, dz);
  PVector right_heel = new PVector(1, -2, dz);
  PVector left_toe = new PVector(-1.3, -2, dz + 0.3);
  PVector right_toe = new PVector(1.3, -2, dz + 0.3);
  PVector neck = new PVector(0, 1.5, dz);
  PVector head_center = new PVector(0, 2.5, dz);
  PVector left_showder_joint = new PVector(-2, 1.5, dz);
  PVector right_showder_joint = new PVector(2, 1.5, dz);
  
  float body = distance_lineSegment(neck, center, Q);
  float left_thigh = distance_lineSegment(left_knee, center, Q);
  float right_thigh = distance_lineSegment(right_knee, center, Q);
  float left_leg = distance_lineSegment(left_heel, left_knee, Q);
  float right_leg = distance_lineSegment(right_heel, right_knee, Q);
  float left_foot = distance_lineSegment(left_toe, left_heel, Q);
  float right_foot = distance_lineSegment(right_toe, right_heel, Q);
  float head = distance(Q, head_center);
 
 
  float left_shoulder = distance_lineSegment(neck, left_showder_joint, Q);
  float right_shoulder = distance_lineSegment(neck, right_showder_joint, Q);
  
  
  PMatrix3D transformation = new PMatrix3D();
  transformation.scale(1.5, 2, 1.5);
  transformation.rotateX(radians(-45));
  transformation.translate(-2.8, -1.5, dz);
  PVector Qp = transformation.mult(Q, null);
  float mug = a_mug(Qp.x, Qp.y, Qp.z);
  
  PMatrix3D transformation2 = new PMatrix3D();
  transformation2.scale(1.5, 2, 1.5);
  transformation2.rotateX(radians(45));
  transformation2.translate(1.2, -1.5, dz);
  PVector Qh = transformation2.mult(Q, null);
  float helix = a_helix(Qh.x, Qh.y, Qh.z);
  return blobby_filter(left_thigh, limb_blobbyness)
        +blobby_filter(right_thigh, limb_blobbyness)
        +blobby_filter(left_leg, limb_blobbyness)
        +blobby_filter(right_leg, limb_blobbyness)
        +blobby_filter(left_foot, limb_blobbyness)
        +blobby_filter(right_foot, limb_blobbyness)
        +blobby_filter(body, limb_blobbyness)
        +blobby_filter(head, 1)
        +blobby_filter(left_shoulder, limb_blobbyness)
        +blobby_filter(right_shoulder, limb_blobbyness)
        +blobby_filter(mug, 0.5)
        +helix
        ;

};

float a_mug(float x, float y, float z) {
  PVector Q = new PVector(x, y, z);
  PVector out_bottom = new PVector(0, -0.5, 0);
  PVector out_top = new PVector(0,1,0);
  PVector inner_bottom = new PVector(0,-0.5, 0);
  PVector inner_top = new PVector(0, 2,0);
  
  float outer = distance_lineSegment(out_bottom, out_top, Q);
  float inner = distance_lineSegment(inner_bottom, inner_top, Q);
  
  return max(2 * threshold - blobby_filter(outer, 1) ,  blobby_filter(inner, 0.8));
}

float a_helix(float x, float y, float z){
   float dx = 1.5;
   PVector Q = twist(x, y, z, 7);
   PVector P1 = new PVector(dx, 0.5, 0);
   PVector P2 = new PVector(-dx, 0.5, 0);
   float distance = distance_lineSegment(P1, P2, Q);
   return blobby_filter(distance, 1); 
}
