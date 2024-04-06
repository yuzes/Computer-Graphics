// Read polygon mesh from .ply file
//
// You should modify this routine to store all of the mesh data
// into a mesh data structure instead of printing it to the screen.
class Mesh {
  ArrayList<Edge> edges;
  ArrayList<Face> faces;
  ArrayList<Vertex> vertices;
  boolean random_color;
  
  
  public Mesh() {
    this.edges = new ArrayList<Edge>();
    this.faces = new ArrayList<Face>();
    this.vertices = new ArrayList<Vertex>();
  }
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
      e = edge_next(e);
      PVector v2 = this.vertices.get(e.vid).p;
      e = edge_next(e);
      // need only 3 verts to determine face normal
      PVector v3 = this.vertices.get(e.vid).p;
      PVector A = v2.copy().sub(v1);
      PVector B = v3.copy().sub(v1);
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
        // println("Set normals: " + e.toString());
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
  
  void midpoint_subdivision() {
    println("midpoint subdivision start, original faces: " + this.faces.size());
    //map from edge id to the new vertex to be create on that edge
    HashMap<Integer, PVector> new_verts =  this.get_new_verts();
    // split all edges based on new_verts, add new edges to this.edges tail
    for(Integer k : new_verts.keySet()){
      int i = k.intValue();
      this.splitEdge(i, new_verts.get(i));
    }
    // divide all faces
    int original_faces = this.faces.size();
    for(int i = 0; i < original_faces; i++){
      divideFace(this.faces.get(i));
    }
    
    for(Vertex v : this.vertices) {
      float mag = v.p.mag();
      v.p = v.p.copy().div(mag);
    }
    
    this.setNormals();
    this.setCenters();
    println("midpoint subdivision finish , current faces: " + this.faces.size());
  }
  
  HashMap<Integer, PVector> get_new_verts() {
    HashMap<Integer, PVector> new_verts = new HashMap<Integer, PVector>();
    for(int i = 0; i < this.edges.size(); i++){
      Edge e = this.edges.get(i);
      if(e.id < edge_opposite(e).id) {
        PVector v1 = this.vertices.get(e.vid).p.copy();
        PVector v2 = this.vertices.get(edge_next(e).vid).p.copy();
        v1 = v1.mult(0.5);
        v2 = v2.mult(0.5);
        PVector new_vert = v1.add(v2);
        new_verts.put(e.id, new_vert);
      }
    }
    return new_verts;
  }
  
  
  
  void splitEdge(int eid, PVector vert_pos){
    Edge e = this.edges.get(eid);
    Edge e_opp = edge_opposite(e);
    Edge e0 = new Edge();
    Edge e1 = new Edge();
    Vertex v0 = new Vertex();
    
    e0.id = this.edges.size();
    e1.id = e0.id + 1;
    
    // setup new vertex
    v0.p = vert_pos.copy(); 
    v0.id = this.vertices.size();
    v0.eid = e0.id;
    this.vertices.add(v0);
    
    // setup new Edges
    e0.vid = v0.id;
    e0.fid = e.fid;
    e0.next = e.next;
    e0.prev = e.id;
    e0.opposite = e.opposite;
    
    e1.vid = v0.id;
    e1.fid = e_opp.fid;
    e1.next = e_opp.next;
    e1.prev = e.opposite;
    e1.opposite = e.id;
    this.edges.add(e0);
    this.edges.add(e1);
    
    this.edges.get(e.next).prev = e0.id;
    this.edges.get(e_opp.next).prev = e1.id;
    e.next = e0.id;
    e_opp.next = e1.id;
    e_opp.opposite = e0.id;
    e.opposite = e1.id;
    
    // update face verts
  }
  
  
  // with all split edges, divide each face into 4 faces
  void divideFace(Face f){
    Edge e = this.edges.get(f.eid);
    Edge e1 = this.edges.get(e.next);
    if(e.id != edge_next(edge_next(e)).next) {
      do{
        Edge e2 = edge_next(e1);
        Edge e3 = edge_next(e2);
        Edge e_new = new Edge();
        Edge e_new_opp = new Edge();
        
        e_new.id = this.edges.size();
        e_new_opp.id = e_new.id + 1;
        
        Face f_new = new Face();
        f_new.id = this.faces.size();
        f_new.eid = e1.id;
        f_new.num_vert = 3;
        
        e_new_opp.opposite = e_new.id;
        e_new_opp.vid = e3.vid;
        e_new_opp.fid = f_new.id;
        e_new_opp.prev = e2.id;
        e_new_opp.next = e1.id;
        
        e_new.opposite = e_new_opp.id;
        e_new.vid = e1.vid;
        e_new.fid = f.id;
        e_new.prev = e1.prev;
        e_new.next = e2.next;
        
        
        
        this.edges.add(e_new);
        this.edges.add(e_new_opp);
        this.faces.add(f_new);
        
        // delete old connections
        edge_prev(e1).next = e_new.id;
        e3.prev = e_new.id;
        e1.prev = e_new_opp.id;
        e2.next = e_new_opp.id;
        e1.fid = f_new.id;
        e2.fid = f_new.id;
        f.eid = e_new.id;
        e1 = e3;
      }while(e.id != edge_next(edge_next(e)).next);
    }
    
  }
  
  
  void catmull_clark_subdivision() {
    println("CC subdivision start, original faces: " + this.faces.size());
    //map from edge id to the new vertex to be create on that edge
    HashMap<Integer, PVector> new_edge_verts =  this.get_edge_verts();
    // split all edges based on new_verts, add new edges to this.edges tail
    update_vertices(new_edge_verts);
    for(Integer k : new_edge_verts.keySet()){
      int eid = k.intValue();
      this.splitEdge(eid, new_edge_verts.get(eid));
    }
    int face_size = this.faces.size();
    for(int i = 0; i < face_size; i++) {
      divide_surface_cc(this.faces.get(i)); 
    }
    this.setNormals();
    this.setCenters();
    println("CC subdivision finish , current faces: " + this.faces.size());
  }
  
  void update_vertices(HashMap<Integer, PVector> new_edge_verts) {
    for(int i = 0; i < this.vertices.size(); i++){
      Vertex v = this.vertices.get(i);
      PVector face_avg = new PVector(0,0,0);
      PVector edge_avg = new PVector(0,0,0);
      Edge e_start = this.edges.get(v.eid);
      Edge current_e = e_start;
      int n = 0;
      do {
        // do things on next_e
        PVector em;
        if(new_edge_verts.containsKey(current_e.id)){
          em = new_edge_verts.get(current_e.id); 
        }else{
          em = new_edge_verts.get(edge_opposite(current_e).id);
        }
        edge_avg.add(em);
        face_avg.add(this.faces.get(current_e.fid).center.copy());
        current_e = edge_unswing(current_e);
        n += 1;
      } while(current_e.id != e_start.id);
      edge_avg.div(n);
      face_avg.div(n).mult(2);
      PVector v_old = v.p.copy().mult(n - 3);
      v.p = edge_avg.add(face_avg).add(v_old).div(n).copy();
    }
    
    
  }
  
  HashMap<Integer, PVector> get_edge_verts() {
    HashMap<Integer, PVector> new_verts = new HashMap<Integer, PVector>();
    for(int i = 0; i < this.edges.size(); i++){
      Edge e = this.edges.get(i);
      if(e.id < edge_opposite(e).id) {
        PVector v1 = this.vertices.get(e.vid).p.copy();
        PVector v2 = this.vertices.get(edge_next(e).vid).p.copy();
        PVector ec = PVector.add(v1,v2).copy().mult(0.5);
        PVector fp1 = this.faces.get(e.fid).center;
        PVector fp2 = this.faces.get(edge_opposite(e).fid).center;
        PVector fpc = PVector.add(fp1, fp2).copy().mult(0.5);
        PVector ep = PVector.add(ec, fpc).copy().mult(0.5);
        new_verts.put(e.id, ep);
      }
    }
    return new_verts;
  }
  
  // refer cc.jpg for visualization of this function
  void divide_surface_cc(Face f){
    Vertex f_center = new Vertex();
    f_center.p = f.center.copy();
    f_center.id = this.vertices.size();
    this.vertices.add(f_center);
    Edge e = this.edges.get(f.eid);
    ArrayList<Face> temp_faces = new ArrayList<Face>(f.num_vert);
    int vn = f.num_vert;
    for(int i = 0; i < vn; i++){
      // num_vert == 0 indicate this face is not initialize
      if(f.num_vert == 0){
        f.id = this.faces.size();
        f.eid = e.id;
        this.faces.add(f);
      }
      f.num_vert = 4;
      Edge e0 = edge_next(e);
      Edge e2 = edge_next(e0);
      Edge ep = edge_prev(e);
      // initialize two edges that connect face center
      
      Edge ef = new Edge();
      Edge fep = new Edge();
      
      ef.id = this.edges.size();
      fep.id = ef.id + 1;
      f_center.eid = fep.id;
      
      //setup ef
      ef.vid = e0.vid;
      //ef.opposite = next mesh.fep
      ef.next = fep.id;
      ef.prev = e.id;
      ef.fid = f.id;
      
      //setup fep
      fep.vid = f_center.id;
      // fep.opposite = prev mesh.ef
      fep.next = ep.id;
      fep.prev = ef.id;
      fep.fid = f.id;
      
      e.next = ef.id;
      ep.prev = fep.id;
      e.fid = f.id;
      ep.fid = f.id;
      
      temp_faces.add(f);
      this.edges.add(ef);
      this.edges.add(fep);
      
      e = e2;
      f = new Face();
    }
    int n = temp_faces.size();
    for(int i = 0; i < temp_faces.size(); i++) {
      Face current_f = temp_faces.get(i);
      Face next_f = temp_faces.get(((i+1) % n + n) % n);
      Face prev_f = temp_faces.get(((i-1) % n + n) % n);
      Edge c_e = this.edges.get(current_f.eid);
      Edge n_e = this.edges.get(next_f.eid);
      Edge p_e = this.edges.get(prev_f.eid);
      Edge ef = edge_next(c_e);
      Edge ep = edge_prev(c_e);
      Edge fep = edge_prev(ep);
      Edge n_ep = edge_prev(n_e);
      Edge n_fep = edge_prev(n_ep);
      ef.opposite = n_fep.id;
      fep.opposite = edge_next(p_e).id;
      
      Edge e0 = edge_next(n_fep);
      e0.prev = n_fep.id;
      p_e.next = fep.opposite;
    }
  }
  
  void add_noise(){
    for(Vertex v : this.vertices){
      Edge e = this.edges.get(v.eid);
      Face f = this.faces.get(e.fid);
      v.p.add(f.N.copy().mult(random(-0.1,0.1)));
    }
  }
  
  void taubin_smoothing(int iter, float lambda, float mu) {
    for(int it = 0; it < iter; it++){
      shrink_inflate(lambda);
      shrink_inflate(mu);
    }
  }
  
  void shrink_inflate(float k){
    ArrayList<Vertex> temp_vertices = new ArrayList<Vertex>(this.vertices.size());
    for(int i = 0; i < this.vertices.size(); i++){
      Vertex v = this.vertices.get(i);
      ArrayList<Vertex> neighbors = new ArrayList<Vertex>();
      Edge e = this.edges.get(v.eid);
      Edge current_e = e;
      do{
        neighbors.add(this.vertices.get(edge_next(current_e).vid));
        current_e = edge_swing(current_e);
      }while(current_e.id != e.id);
      
      PVector vcent_p = new PVector(0,0,0);
      for(Vertex n : neighbors) vcent_p.add(n.p);
      vcent_p.div(neighbors.size());
      PVector dvp = vcent_p.sub(v.p);
      Vertex newV = v.copy();
      newV.p = v.p.copy().add(dvp.mult(k));
      temp_vertices.add(newV);
    }
    for(int i = 0; i < this.vertices.size(); i++){
      this.vertices.get(i).p = temp_vertices.get(i).p;
    }  
  }
  
  void laplacian_smoothing(int iter, float lambda){
    for(int it = 0; it < iter; it++){
      shrink_inflate(lambda);
    }
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
