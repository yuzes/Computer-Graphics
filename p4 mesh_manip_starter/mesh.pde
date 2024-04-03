// Read polygon mesh from .ply file
//
// You should modify this routine to store all of the mesh data
// into a mesh data structure instead of printing it to the screen.
class Mesh {
  ArrayList<Edge> edges;
  ArrayList<Face> faces;
  ArrayList<Vertex> vertices;
  
  ArrayList<Integer> originalFaceVerts;
  ArrayList<Integer> originalFaceEdges;
  
  boolean random_color;
  
  

  public Mesh(PVector[] vert_coordinates, ArrayList<int[]> face_indices) {
      this.vertices = new ArrayList<>(vert_coordinates.length);
      this.faces = new ArrayList<>(face_indices.size());
      this.random_color = false;
      int numEdges = 0;
      for(int i = 0; i < vert_coordinates.length; i++){
        this.vertices.add(null);
      }
      for(int[] f : face_indices){
        numEdges += f.length;
        this.faces.add(null);
      }
      this.edges = new ArrayList<>(numEdges);
      for(int i = 0; i < numEdges; i++) this.edges.add(null);
      HashMap<IntPair, Edge> edgeTable = new HashMap<IntPair, Edge>();
      int e_start = 0;
      for(int fid = 0; fid < face_indices.size(); fid++){
        int[] face_verts = face_indices.get(fid);
        int verts_per_face = face_verts.length;
        for(int j = 0; j < verts_per_face; j++){
          Edge current_edge = new Edge();
          current_edge.id = e_start + j;
          int v_src = face_verts[j];
          int v_dest = face_verts[(j+1) % verts_per_face];
          IntPair k = new IntPair(v_dest, v_src);
          Edge opp = edgeTable.get(k);
          if(opp == null){
            k = new IntPair(v_src, v_dest);
            edgeTable.put(k, current_edge);
          } else{
            current_edge.opposite = opp.id;
            opp.opposite = current_edge.id;
          }
          current_edge.vid = v_src;
          if(this.vertices.get(v_src) == null) {
            Vertex current_v = new Vertex();
            current_v.id = v_src;
            current_v.p = vert_coordinates[current_v.id].copy();
            current_v.eid = current_edge.id;
            this.vertices.set(v_src, current_v);
          }
          current_edge.fid = fid;
          current_edge.next = e_start + (j+1) % verts_per_face;
          current_edge.prev = e_start + (j + verts_per_face - 1) % verts_per_face;
          this.edges.set(current_edge.id, current_edge);
        }
        Face current_face = new Face();
        current_face.id = fid;
        current_face.eid = e_start;
        current_face.num_vert = verts_per_face;
        current_face.c = color((int)random(256), (int)random(256), (int)random(256));
        this.faces.set(fid, current_face);
        e_start += verts_per_face;
      }
      setNormals();
      setCenters();
  }
  
  void setCenters(){
    for(Face f : this.faces){
      PVector center = new PVector(0,0.0);
      Edge e = this.edges.get(f.eid);
      for(int i = 0; i < f.num_vert; i++){
        PVector v = this.vertices.get(e.vid).p;
        center.add(v);
        e = edge_next(e);
      }
      center.div(f.num_vert);
      f.center = center.copy();
    }
  }
  
  void setNormals(){
    // set face normal
    for(Face f : this.faces){
      Edge e = this.edges.get(f.eid);
      PVector v1 = this.vertices.get(e.vid).p;
      e = this.edges.get(e.next);
      PVector v2 = this.vertices.get(e.vid).p;
      e = this.edges.get(e.next);
      // need only 3 verts to determine face normal
      PVector v3 = this.vertices.get(e.vid).p;
      PVector A = PVector.sub(v2, v1);
      PVector B = PVector.sub(v3, v1);
      f.N = A.cross(B).normalize();
    }
    
    //set vertex normal
    for(Vertex v : this.vertices){
      ArrayList<PVector> normals = new ArrayList<PVector>();
      Edge e = this.edges.get(v.eid);
      Edge next_e = e;
      do {
        normals.add(this.faces.get(next_e.fid).N);
        next_e = this.edge_swing(next_e);
      }while(e.id != next_e.id);
      PVector result = new PVector(0,0,0);
      for(int i = 0; i < normals.size(); i++) result.add(normals.get(i).copy());
      v.N = result.normalize();
    }
    
  }
  
  Edge edge_next(Edge e){
    return this.edges.get(e.next);
  }
  
  Edge edge_prev(Edge e){
    return this.edges.get(e.prev);
  }
  
  Edge edge_opposite(Edge e){
    return this.edges.get(e.opposite);
  }
  
  Edge edge_swing(Edge e){
    return edge_next(edge_opposite(e));
  }
  
  Edge edge_unswing(Edge e){
    return edge_opposite(edge_prev(e)); 
  }
  
  Mesh dual() {
    PVector[] vert_coordinates = new PVector[this.faces.size()];
    ArrayList<int[]> face_indices = new ArrayList<int[]>(this.vertices.size());
    for(Vertex v : this.vertices) {
      Edge e = this.edges.get(v.eid);
      Edge prev_e = e;
      ArrayList<Integer> newFace_list = new ArrayList<>();
      do {
        Face f = this.faces.get(prev_e.fid);
        PVector f_center = f.center.copy();
        vert_coordinates[f.id] = f_center;
        prev_e = edge_unswing(prev_e);
        newFace_list.add(f.id);
      }while(e.id != prev_e.id);
      int[] newFace = new int[newFace_list.size()];
      for(int i = 0; i < newFace.length; i++) newFace[i] = newFace_list.get(i);
      face_indices.add(newFace);
    }
    return new Mesh(vert_coordinates, face_indices); 
  }
}


void read_mesh (String filename)
{
  String[] words;
  
  String lines[] = loadStrings(filename);
  
  words = split (lines[0], " ");
  int num_vertices = int(words[1]);
  println ("number of vertices = " + num_vertices);
  
  words = split (lines[1], " ");
  int num_faces = int(words[1]);
  println ("number of faces = " + num_faces);
  
  // read in the vertices
  PVector[] vert_coordinates = new PVector[num_vertices];
  for (int i = 0; i < num_vertices; i++) {
    words = split (lines[i+2], " ");
    float x = float(words[0]);
    float y = float(words[1]);
    float z = float(words[2]);
    println ("vertex = " + x + " " + y + " " + z);
    vert_coordinates[i] = new PVector(x, y, z);
  }
  
  // read in the faces
  ArrayList<int[]> face_indices = new ArrayList<int[]>();
  for (int i = 0; i < num_faces; i++) {
    
    int j = i + num_vertices + 2;
    words = split (lines[j], " ");
    // get the number of vertices for this face
    int nverts = int(words[0]);
    println("Number of verts: " + nverts);
    int[] current_face = new int[nverts];
    // get all of the vertex indices
    print ("face = ");
    for (int k = 1; k <= nverts; k++) {
      int index = int(words[k]);
      current_face[k-1] = index;
      print (index + " ");
    }
    face_indices.add(current_face);
    println();

  }
  
  current_mesh = new Mesh(vert_coordinates, face_indices);

}
