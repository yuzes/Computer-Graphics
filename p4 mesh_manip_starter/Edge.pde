class Edge{
  int id; // index of edge
  int opposite; // opposite edge
  int vid; // id of source vertex 
  int fid; // face on left for CCW traversal
  int prev;
  int next;
  
  String toString() {
    return prev + "->" + "[E" + id + " V" + vid + "]->" + next + " with F" + fid + "\n  [OP]" + opposite;
  }
}
