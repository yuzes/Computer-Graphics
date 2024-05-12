float EPS = 0.0001f;

class AABB extends Object{
  PVector min;
  PVector max;
  Material material;
  
  AABB(PVector min, PVector max, Material m){
    this.min= min;
    this.max = max;
    this.material = m;
    this.center = min.copy().add(max).mult(0.5);
  }
  
  @Override
  AABB getBbox(){
    return this; 
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
    //if (txmin < 0 && txmax < 0) return null; // ray behind object



    float t = txmin >= 0 ? txmin : txmax;
    if(t < 0) return null;
    PVector N = new PVector(0,0,0);
    PVector intersect = r.origin.copy().add(r.direction.copy().mult(t));
    if(Math.abs(intersect.z - min.z) < EPS){
      N.z = -1;
    }else if(Math.abs(intersect.z - max.z) < EPS){
      N.z = 1; 
    }else if(Math.abs(intersect.y - max.y) < EPS){
      N.y = 1; 
    }else if(Math.abs(intersect.y - min.y) < EPS){
      N.y = -1; 
    }else if(Math.abs(intersect.x - min.x) < EPS){
      N.x = -1; 
    }else if(Math.abs(intersect.x - max.x) < EPS){
      N.x = 1;
    }
    //if(debug_flag){
    //  println("DEBUG AABB");
    //  println(r.type + " Intersection result: t = " + t + " color = " + colorStr(this.surface_color) + " N = " + N);
    //  println("Min = " + min + " Max = " + max + " Intersection = " + intersect);
    //}
    return new IntersectionResult(t, this.material, N, r.direction.copy().mult(t).add(r.origin));  
  }
}
