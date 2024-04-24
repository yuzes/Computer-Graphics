class Light{
  PVector position;
  color light_color;
  
  Light(PVector p, color c){
    this.position = p.copy();
    this.light_color = c;
  }
  
  Light(){}
}

class DiskLight extends Light {
  float radius;
  PVector direction;
  
  DiskLight(PVector center, float r, PVector direction, color c) {
    super(center, c);
    this.radius = r;
    this.direction = direction;
  }
}
