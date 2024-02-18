class BVH extends Object{
  BVHNode root;
  
  BVH(ArrayList<Object> objects) {
    this.root = new BVHNode(objects, 0, objects.size() - 1);
    this.bbox = this.root.bbox;
  }
  
  IntersectionResult intersectRay(Ray r){
    return this.root.intersectRay(r); 
  }
}

class BVHNode extends Object{
  BVHNode left;
  BVHNode right;
  ArrayList<Object> objects;
  boolean isLeaf;
  int start, end; // the range of object that this BVHNode cover
  
  BVHNode(ArrayList<Object> objs, int start, int end){
    this.objects = objs;
    this.start = start;
    this.end = end;
    PVector min = new PVector(Float.MAX_VALUE, Float.MAX_VALUE, Float.MAX_VALUE);
    PVector max = min.copy().mult(-1);
    for(int i = start; i <= end; i++){
      Object obj = this.objects.get(i);
      min.x = min(min.x, obj.bbox.min.x);
      min.y = min(min.y, obj.bbox.min.y);
      min.z = min(min.z, obj.bbox.min.z);
      
      max.x = max(max.x, obj.bbox.max.x);
      max.y = max(max.y, obj.bbox.max.y);
      max.z = max(max.z, obj.bbox.max.z);
    }
    this.bbox = new AABB(min,  max, color(1,1,1));
    if(end - start <= 2) {
      return;
    }
    int axis = 0; // x by default
    PVector dist = max.copy().sub(min);
    if(dist.y > dist.x) axis = 1;
    if(dist.z > dist.array()[axis]) axis = 2;
    float splitPos = min.array()[axis] + dist.array()[axis] * 0.5f;
    int i = this.start;
    int j = this.end;
    while (i < j){
        if (this.objects.get(i).center.array()[axis] < splitPos){
          i++;
        }else{
          Collections.swap(this.objects, i, j);
          j--;
        }
    }
    println("Construct new BVHNode start = " + start + " i = " + i + " j = " + j + " end = " + end);
    this.left = new BVHNode(this.objects, start, i - 1);
    this.right = new BVHNode(this.objects, i, end);
  }
  
  IntersectionResult intersectRay(Ray r){
    return intersectRayHelper(r, this);
  }
  
  IntersectionResult intersectRayHelper(Ray r, BVHNode node){
    //if intersect left return left
    //if intersect right return right
    //else return bbox
    if(node == null) return null;
    IntersectionResult ir = this.bbox.intersectRay(r);
    if(ir == null) return null;
    if(node.left == null && node.right == null){
      return ir;
    }
    if(node.left != null) return intersectRayHelper(r, node.left);
    return intersectRayHelper(r, node.right);
  }

}
