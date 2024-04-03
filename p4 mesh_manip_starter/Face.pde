class Face{
  int id;  // index of this Face in array
  int eid; // on of the face's edge id
  PVector N; // surface normal
  PVector center;
  int num_vert; // number of vertices
  color c;

  String toString(){
    return "Face " + this.id + " With Edge: " + this.eid + " Num Verts: " + this.num_vert; 
  }
}
