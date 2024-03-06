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

ImplicitInterface implicit_torus = (x, y, z) -> {
  PVector Q = new PVector(x, y, z);
  float dist = distanceToTorus(Q, 0.8, 0.3);
  return blobby_filter(dist, 0.8);
};

ImplicitInterface blobby_tori = (x, y, z) -> {
  float blobbyness = 0.2;
  PVector Q = new PVector(x, y, z);
  PVector c = new PVector(-1.1,0,0);
  float result = 0.0;
  for(int i = 0; i < 3; i++){
    float dist = distanceToTorus(PVector.sub(Q,c), 0.5, 0.15);
    result += blobby_filter(dist, blobbyness);
    c.x += 1.1;
    PMatrix3D transformation = new PMatrix3D();
    transformation.rotateX(radians(45));
    Q = transformation.mult(Q, null);
  }
  return result;
};

float distanceToTorus(PVector Q, float R, float r) {
    float x = Q.x;
    float y = Q.y;
    float z = Q.z;

    float distance = 0;
    float torusEquation = (pow(x, 2) + pow(y, 2) + pow(z, 2) + pow(R, 2) - pow(r, 2));
    torusEquation = pow(torusEquation, 2) - 4 * pow(R, 2) * (pow(x, 2) + pow(y, 2));

    if (torusEquation > 0) {
        distance = sqrt(torusEquation); // Distance to the surface of the torus
    } else {
        distance = 0;
    }

    return distance;
}
