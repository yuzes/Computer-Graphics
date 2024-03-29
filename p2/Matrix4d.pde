import java.util.*;

class MatrixStack{
  Stack<Matrix> mStack;
  
  MatrixStack(){
    this.mStack = new Stack<Matrix>();
    this.mStack.push(new Matrix(4, 4));
  }
  
  void push(){
    this.mStack.push(this.mStack.peek());
  }
  
  Matrix pop(){
    return mStack.pop();
  }
  
  Matrix peek(){
    return mStack.peek(); 
  }
  
  void translate(float tx, float ty, float tz){
    float[][] T = {    {1.0f,  0,  0,  tx},
                       {0,  1.0f,  0,  ty},
                       {0,     0,1.0f, tz},
                       {0,    0,0,   1.0f}};
    Matrix C = this.mStack.pop();
    Matrix C_new = C.mult(new Matrix(T));
    this.mStack.push(C_new);
  }
  
  void scale(float sx, float sy, float sz){
    float[][] S = {    {sx,0,0,0},
                       {0,sy,0,0},
                       {0,0,sz,0},
                       {0,0,0,1.0f}};
    Matrix C = this.mStack.pop();
    Matrix C_new = C.mult(new Matrix(S));
    this.mStack.push(C_new);
  }
  
  //theta is degree
  void rotate(float theta, PVector axis){
    float[] sin = {sin(radians(theta*axis.x)), sin(radians(theta*axis.y)), sin(radians(theta*axis.z))};
    float[] cos = {cos(radians(theta*axis.x)), cos(radians(theta*axis.y)), cos(radians(theta*axis.z))};
    Matrix Rx = new Matrix(new float[][] {
                            {1.0f, 0, 0, 0},
                            {0, cos[0], -sin[0], 0},
                            {0, sin[0], cos[0], 0},
                            {0, 0, 0, 1.0f}
                          });

    Matrix Ry = new Matrix(new float[][] {
                            {cos[1], 0, sin[1], 0},
                            {0, 1.0f, 0, 0},
                            {-sin[1], 0, cos[1], 0},
                            {0, 0, 0, 1.0f}
                          });

    Matrix Rz = new Matrix(new float[][] {
                            {cos[2], -sin[2], 0, 0},
                            {sin[2], cos[2], 0, 0},
                            {0, 0, 1.0f, 0},
                            {0, 0, 0, 1.0f}
                          });
    Matrix C = this.mStack.pop();
    Matrix C_new = C.mult(Rx).mult(Ry).mult(Rz);
    this.mStack.push(C_new);
  }
  
}

class Matrix{
  float[][] matrix;
  
  //Create an dentity matrix
  Matrix(int m, int n){
    this.matrix = new float[m][n];
    for (int i = 0; i < m; i++) {
      for (int j = 0; j < n; j++) {
        if (i == j) {
          matrix[i][j] = 1.0;
        } else {
          matrix[i][j] = 0.0;
        }
      }
    }
  }
  
  // Create a matrix based on give 1d array
  Matrix(float[] m){
    if(m.length != 16) {
      throw new IllegalArgumentException("Float array length must be exactly 16");
    }
    this.matrix = new float[4][4];
    int index = 0;
    for(int i = 0; i < 4; i++){
      for(int j = 0; j < 4; j++){
        this.matrix[i][j] = m[index++];
      }
    }
  }
  
  Matrix invert(){
    if(this.matrix.length != 4 || this.matrix[0].length != 4) {
      throw new IllegalArgumentException("matrix should be 4x4");
    }
    PMatrix3D matrix3D = new PMatrix3D();
    float[] matrixArray = this.toArray();
    matrix3D.set(matrixArray);
    matrix3D.invert();
    return new Matrix(matrix3D.get(null));
  }
  
  float[] toArray() {
    float[] out = new float[this.matrix.length * this.matrix[0].length];
    int index = 0;
    for(int i = 0; i < this.matrix.length; i++){
      for(int j = 0; j < this.matrix[0].length; j++){
        out[index++] = this.matrix[i][j]; 
      }
    }
    return out;
  }
  
  //Create a matrix based on given 2d array
  Matrix(float[][] m){
    this.matrix = new float[m.length][m[0].length];
    for (int i = 0; i < m.length; i++) {
      for (int j = 0; j < m[0].length; j++) {
        matrix[i][j] = m[i][j];
      }
    }
  }
  
  //return matrix[r][c]
  float get(int r, int c){
    if(r < 0 || r > this.matrix.length || c < 0 || c > this.matrix[0].length){
      System.err.println("index out of bound (" + r + "," + c + ")"); 
    }
    return this.matrix[r][c];
  }
  
  // apply this transformation matrix to v
  PVector apply(PVector v, boolean isDirection){
    float w = isDirection ? 0 : 1;
    Matrix v_matrix = new Matrix(new float[][] {{v.x},{v.y},{v.z},{w}});
    Matrix result = this.mult(v_matrix);
    return new PVector(result.get(0,0), result.get(1,0), result.get(2,0));
  }
  
  Matrix mult(Matrix other){
    float[][] mat1 = this.matrix;
    float[][] mat2 = other.matrix;
    if(mat1[0].length != mat2.length) {
      println("Invaid dimension: mat1 should be m x n and mat2 should be n x k");
      return null;
    }
    int m = mat1.length;
    int n = mat2.length;
    int p = mat2[0].length;
    float[][] result = new float[n][p];
    for(int i = 0; i < m; i++){
      for(int j = 0; j < p; j++){
        for(int k = 0; k < n; k++){
          result[i][j] += mat1[i][k] * mat2[k][j];
        }
      }
    }
    return new Matrix(result);
  }
  
  String toString(){
    StringBuilder builder = new StringBuilder();
      for (int i = 0; i < matrix.length; i++) {
          for (int j = 0; j < matrix[i].length; j++) {
              builder.append(String.format("%.4f", matrix[i][j]));
              if (j < matrix[i].length - 1) {
                  builder.append(", ");
              }
          }
          if (i < matrix.length - 1) {
              builder.append("\n");
          }
      }
      builder.append("\n");
      return builder.toString();
  }
}
