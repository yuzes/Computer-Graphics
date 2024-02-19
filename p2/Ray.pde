class Ray {
  PVector origin;      // 3D point
  PVector direction;   // Direction vector
  String type;
  
  // Constructor
  Ray(PVector origin, PVector direction, String type) {
    //if(type == "EYE") direction.normalize();
    this.origin = origin.copy();
    this.direction = direction.copy();
    this.type = type;
  }
  
  String toString(){
    return this.type + " Origin: " + this.origin + " Direction: " + this.direction;
  }
  
  // Other methods and functionalities can be added as needed
  // Apply transformation matrix to ray
  Ray transform(Matrix m){
    PVector new_origin = m.apply(this.origin, false);
    PVector new_direction = m.apply(this.direction, true);
    return new Ray(new_origin, new_direction.copy(), this.type);
  }
}
