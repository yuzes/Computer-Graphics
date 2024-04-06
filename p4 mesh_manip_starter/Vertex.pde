class Vertex{
  PVector p; // coordinate of vertex
  PVector N; // Vertex Normal
  int id; // index 
  int eid; // one of edges with this vert as source
  
  String toString(){
    return "Vid = " + this.id + " " + this.p;
  }
  
  Vertex copy(){
    Vertex copy = new Vertex();
    copy.p = this.p.copy();
    copy.N = this.N.copy();
    copy.id = this.id;
    copy.eid = this.eid;
    return copy;
  }
  
}

class IntPair {
      int i, j;
      public IntPair(int i, int j) {
        this.i = i;
        this.j = j;
      }
      public boolean equals(Object other) {
        IntPair o = (IntPair)other;
        return o.i == i && o.j == j;
      }
      public int hashCode() {
        return 23*i + j;
      }
}
