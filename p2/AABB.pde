class AABB extends Object{
  PVector min;
  PVector max;
  color surface_color;
  
  AABB(PVector min, PVector max, color surface_color){
    this.min= min;
    this.max = max;
    this.surface_color = surface_color;
  }
  
  @Override
  IntersectionResult intersectRay(Ray r){
    float txmin, txmax, tymin, tymax, tzmin, tzmax;
    float invDx = 1.0 / r.direction.x;
    float invDy = 1.0 / r.direction.y;
    float invDz = 1.0 / r.direction.z;
    
    
    float tx1 = (this.min.x - r.origin.x) * invDx;
    float tx2 = (this.max.x - r.origin.x) * invDx;
    txmin = min(tx1, tx2);
    txmax = max(tx1, tx2);
    float ty1 = (this.min.y - r.origin.y) * invDy;
    float ty2 = (this.max.y - r.origin.y) * invDy;
    tymin = min(ty1, ty2);
    tymax = max(ty1, ty2);
    if ((txmin > tymax) || (tymin > txmax)) return null;
    
    txmin = max(txmin, tymin);
    txmax = min(txmax, tymax);
    float tz1 = (this.min.z - r.origin.z) * invDz;
    float tz2 = (this.max.z - r.origin.z) * invDz;
    tzmin = min(tz1, tz2);
    tzmax = max(tz1, tz2);
    if ((txmin > tzmax) || (tzmin > txmax)) return null;
    
    txmin = max(txmin, tzmin);
    txmax = min(txmax, tzmax);

    if (txmin < 0 && txmax < 0) return null; // ray behind object



    float t = txmin >= 0 ? txmin : txmax;
    PVector N = new PVector(0,0,0);
    PVector intersect = r.origin.copy().add(r.direction.copy().mult(t));
    if(intersect.z == max.z){
      N.z = 1; 
    }else if(intersect.y == min.y){
      N.y = -1; 
    }else if(intersect.y == max.y){
      N.y = 1; 
    }else if(intersect.x == min.x){
      N.x = -1; 
    }else if(intersect.x == max.x){
      N.x = 1;
    }
    return new IntersectionResult(t, this.surface_color, N);  
  }
}
