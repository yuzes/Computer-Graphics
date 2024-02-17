class Ray {
  PVector origin;      // 3D point
  PVector direction;   // Direction vector
  String type;
  
  // Constructor
  Ray(PVector origin, PVector direction, String type) {
    this.origin = origin.copy();
    this.direction = direction.copy();
    this.type = type;
    if(type == "EYE") this.direction.normalize();
  }
  
  String toString(){
    return this.type + " Origin: " + this.origin + " Direction: " + this.direction;
  }
  
  // Other methods and functionalities can be added as needed
  // Apply transformation matrix to ray
  Ray transform(Matrix m){
    PVector new_origin = m.apply(this.origin, false);
    PVector new_direction = m.apply(this.direction, true);
    if(this.type == "EYE") new_direction.normalize();
    return new Ray(new_origin, new_direction, this.type);
  }
}
