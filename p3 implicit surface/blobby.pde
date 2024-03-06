float blobby_filter(float r, float b){
  return meatball(r, b);
}

float meatball(float r, float b){
  float b_r = r/b;
  float a = 2;
  if(r >= b) return 0;
  if(r < b / 3) {
    return a * (1 - 3 * b_r * b_r); 
  }
  return a * 1.5 * (1 - b_r) * (1 - b_r); 
}

float gaussian(float r, float b){
  return exp(-r *  r * b);
}
