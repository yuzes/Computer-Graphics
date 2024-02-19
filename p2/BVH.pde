class BVH extends Object{
  BVHNode root;
  
  BVH(ArrayList<Object> objects) {
    this.root = new BVHNode(objects, 0, objects.size() - 1, 0);
    this.bbox = this.root.bbox;
  }
  
  IntersectionResult intersectRay(Ray r){
    return this.root.intersectRayHelper(r, this.root);
  }
}

class BVHNode extends Object{
  BVHNode left;
  BVHNode right;
  ArrayList<Object> objects;
  boolean isLeaf;
  int start, end; // the range of object that this BVHNode cover
  int depth;
  
  BVHNode(ArrayList<Object> objs, int start, int end, int depth){
    this.objects = objs;
    this.start = start;
    this.end = end;
    this.depth = depth;
    PVector min = new PVector(Float.MAX_VALUE, Float.MAX_VALUE, Float.MAX_VALUE);
    PVector max = min.copy().mult(-1);
    for(int i = start; i <= end; i++){
      Object obj = this.objects.get(i);
      //println("Object[" + i + "]" + " type: " + className + " bbox: min = " + obj.bbox.min + " max = " + obj.bbox.max);
      PVector objMin = obj.bbox.min.copy();
      PVector objMax = obj.bbox.max.copy();
      min.x = min(min.x, objMin.x);
      min.y = min(min.y, objMin.y);
      min.z = min(min.z, objMin.z);
      
      max.x = max(max.x, objMax.x);
      max.y = max(max.y, objMax.y);
      max.z = max(max.z, objMax.z);
    }
    //println("Current BVH has node min = " + min + " max = " + max + " contains: object[" + start + "] to " + "object[" + end + "]" + " depth = " + depth);
    this.bbox = new AABB(min,  max, color(random(0.5,1),random(0.5,1),1));
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
        if (this.objects.get(i).center.copy().array()[axis] < splitPos){
          i++;
        }else{
          Collections.swap(this.objects, i, j);
          j--;
        }
    }
    if(i == end || j == start) return;
    this.left = new BVHNode(this.objects, this.start, i, depth + 1);
    this.right = new BVHNode(this.objects, i+1, this.end, depth + 1);
  }
  
  IntersectionResult intersectRay(Ray r){
    return intersectRayHelper(r, this);
  }
  
  IntersectionResult intersectRayHelper(Ray r, BVHNode node){
    //if intersect left return left
    //if intersect right return right
    //else return bbox
    if(node == null) return null;
    IntersectionResult ir = node.bbox.intersectRay(r);
    if(ir == null) return null;
    if(node.left == null && node.right == null){
      //if(debug_flag){
      //  println("[Depth" + node.depth + "] Debug intersectRayHelper");
      //  println("\tbbox min: " + node.bbox.min + "bbox max: " + node.bbox.max);
      //  println("\tNode contains object from " + node.start + " to " + node.end );
      //}
      IntersectionResult objIr = castRay(r, node.objects, node.start, node.end);
      return objIr;
    }
    IntersectionResult left_ir = intersectRayHelper(r, node.left);
    IntersectionResult right_ir = intersectRayHelper(r, node.right);
    if(right_ir == null){
      return left_ir; 
    }else if(left_ir == null){
      return right_ir; 
    }
    // both left and right has some result
    if(left_ir.t < right_ir.t) return left_ir;
    return right_ir;
  }

}
