class Material {
  color kd; // diffuse coefficient
  color ks; // specular coefficient
  int spec_pow;
  float k_refl;
  float gloss_radius;
  
  Material() {
    this.gloss_radius = 0;
  }
  
  Material(color kd) {
    this.kd = kd;
    this.gloss_radius = 0;
  }
}


String colorStr(color c){
  int r = (c >> 16) & 0xFF;
  int g = (c >> 8) & 0xFF;
  int b = c & 0xFF; 
  return r + " " + g + " " + b;
}

color color_add(color c1, color c2) {

  int r1 = (c1 >> 16) & 0xFF;
  int g1 = (c1 >> 8) & 0xFF;
  int b1 = c1 & 0xFF;

  int r2 = (c2 >> 16) & 0xFF;
  int g2 = (c2 >> 8) & 0xFF;
  int b2 = c2 & 0xFF;

  int r = min(r1 + r2, 255);
  int g = min(g1 + g2, 255);
  int b = min(b1 + b2, 255);


  return color(r, g, b);
}

color color_mult(color c, float f) {
  // Extract RGB components from the color
  int r = (c >> 16) & 0xFF;
  int g = (c >> 8) & 0xFF;
  int b = c & 0xFF;

  // Multiply each component by the scalar and clamp to 0-255
  r = int(r * f); // Clamp to 255 to avoid overflow
  g = int(g * f);
  b = int(b * f);

  // Create the new color with adjusted components
  return color(r, g, b);
}
