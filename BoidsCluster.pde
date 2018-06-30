// ボイドのクラスタに関するクラス
// １）コンストラクタの引数に, 特定のボイド配列を指定
// ２）countClusterで, クラスタ構造を解析（クラスタの数を得る）
// ３）種々のgetXXXメソッドで, 関連情報（重心・距離・要素数）を取得
class BoidsCluster {

  Boid[] b;             //ボイドの配列
  Pos[] cluster_pos;    //クラスターの重心位置
  int[] cluster_size;   //クラスターの規模（内包するボイドの数）
  float[] cluster_dis;  //クラスターの最大距離（重心位置からの最大距離）
  int[] cgid;           //ボイドのグループID（-1, 0,1,...）, -1のときグループを持たない
  int pop;              //ボイドの数

  float[] cluster_strength;   //クラスターの強さ（内包するボイドの数と大きさによる）

  //コンストラクタ
  BoidsCluster(Boid[] b) {
    this.b = b;
    this.pop = b.length;
    this.cgid = new int[pop];

    resetClusterID();
  }

  //ボイドのグループIDを全て-1に初期化
  void resetClusterID() {
    for (int i=0; i<pop; i++) {
      cgid[i] = -1;
    }
  }

  //クラスターの重心を取得する. 
  Pos getClusterPos(int g) {
    return cluster_pos[g];
  }

  //クラスターのサイズ（重心からの最大距離）を取得する. 
  float getClusterDistance(int g) {
    return cluster_dis[g];
  }

  //クラスターの規模（内包するボイドの数）を取得する. 
  int getClusterSize(int g) {
    return cluster_size[g];
  }

  //i番目のボイドのクラスタIDを取得する. 
  //クラスタに属していない場合, -1を返す. 
  int getClusterID(int i) {
    return cgid[i];
  }

  //クラスターの数を計算する
  //thg以上のつながりを保持するグループをクラスターと定義する. 
  int countCluster(int thg) {

    int pop = b.length;

    //直接の知り合い
    boolean[][] neighborhood = new boolean[pop][pop];
    //知り合いの知り合いの...
    boolean[][] neighborhoodall = new boolean[pop][pop];

    //配列の全要素をfalseに初期化
    for (int i=0; i<pop; i++) {
      for (int j=0; j<pop; j++) {
        neighborhood[i][j] = false;		
        neighborhoodall[i][j] = false;
      }
    }

    //直接の知り合いに対してtrueに
    for (int i=0; i<pop; i++) {
      for (int j=0; j<pop; j++) {
        if (j!=i && b[i].isVisible(b[j])) {
          neighborhood[i][j] = true;		
          neighborhoodall[i][j] = true;
        }
      }
    }

    //trueを間接的な知り合いに対しても伝播させる. 
    while (true) {

      boolean escape = true;

      for (int i=0; i<pop; i++) {
        for (int j=0; j<pop; j++) {

          if (neighborhoodall[i][j]) {
            for (int k=0; k<pop; k++) {
              if (neighborhood[j][k] && !neighborhoodall[i][k]) {
                neighborhoodall[i][k] = true;
                escape = false;
              }
            }
          }
        }
      }
      if (escape) break;
    }  


    int id = -1;
    boolean[] belonging = new boolean[pop];
    int[] groupsize = new int[pop];
    int[] groupsize2 = new int[pop];

    float[] groupstrength = new float[pop];
    float[] groupstrength2 = new float[pop];

    int group = 0;

    for (int i=0; i<pop; i++) {
      belonging[i] = false;
      groupsize[i] = 0;
      groupsize2[i] = 0;

      groupstrength[i] = 0;
      groupstrength2[i] = 0;
    }

    //グループID（0,1,...）を振る作業
    for (int i=0; i<pop; i++) {

      if (belonging[i] == false) {
        id++;
        belonging[i] = true;

        for (int j=0; j<pop; j++) {
          if (neighborhoodall[i][j]) {
            belonging[j] = true;
            groupsize[id]++;

            groupstrength[id] += b[j].body_size / 10;
          }
        }
        if (groupsize[id]>=thg) {
          group++;
          groupsize2[group-1] = groupsize[id];

          groupstrength2[group-1] = groupstrength[id];

          cgid[i] = group-1;
          for (int j2=i+1; j2<pop; j2++) {
            if (neighborhoodall[i][j2]) cgid[j2] = group-1;
          }
        }
      }
    }

    cluster_pos = new Pos[group];
    cluster_size = new int[group];
    cluster_strength = new float[group];
    cluster_dis = new float[group];


    for (int g=0; g<group; g++) {
      cluster_size[g] = groupsize2[g];
      cluster_strength[g] = groupstrength2[g];

      float sumx = 0; 
      float sumy = 0; 
      float count = 0;

      for (int i=0; i<pop; i++) {
        if (cgid[i] == g) {            
          sumx += b[i].pos.x;
          sumy += b[i].pos.y;
          count ++;
        }
      }
      cluster_pos[g] = new Pos(sumx/count, sumy/count);

      float max = 0;

      for (int i=0; i<pop; i++) {
        if (cgid[i] == g) {
          float tmp = dist(
            cluster_pos[g].x, cluster_pos[g].y, 
            b[i].pos.x, b[i].pos.y);

          if (tmp>max) {
            max = tmp;
          }
        }
      }

      cluster_dis[g] = max;
    }

    return group;
  }
}
