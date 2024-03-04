// Lambda expressions for implicit functions
//
// See the "a_sphere" lambda expression for an example of defining an implicit function

import java.lang.FunctionalInterface;

// this is a functional interface that will let us define an implicit function
@FunctionalInterface
interface ImplicitInterface {

  // abstract method that takes (x, y, z) and returns a float
  float getValue(float x, float y, float z);
}

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
   PVector c1 = new PVector(1, 0, 0);
   PVector c2 = new PVector(-1, 0, 0);
   float d1 = distance(new PVector(x, y, z), c1);
   float d2 = distance(new PVector(x, y, z), c2);
   float f1 = blob(d1);
   float f2 = blob(d2);
   return f1 + f2 - threshold;
};

float Gaussian(float d){
  return exp(-d * d);
}

float blob(float d){
  float d2 = 1 - d * d;
  float b = d2 * d2 * d2;
  return b;
}

float distance(PVector p1, PVector p2){
  float dx = p2.x - p1.x;
  float dy = p2.y - p1.y;
  float dz = p2.z - p1.z;
  return sqrt(dx * dx + dy * dy + dz * dz); 
}
