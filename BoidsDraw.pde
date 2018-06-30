/** BoidsDrawクラス（ボイドの描画に関するクラス）**/
class BoidsDraw {

  Boid[] b; //ボイドの配列
  BoidsCluster bc;
  int pop;  //ボイドの総数（コンストラクタで指定）

  //int body_size = 10;  //ボイドのからだのサイズ（円の直径）
  int trace_width = 1;  //ボイドの軌跡の線幅

  PGraphics pg_body;  //ボイドの描画レイヤ
  PGraphics pg_trace; //移動軌跡の描画レイヤ
  PGraphics pg_connect; // 接続の可視化レイヤ
  PGraphics pg_cluster; // クラスタレイヤ
  PGraphics pg_ui; // UIレイヤ

  boolean MODE_RULE0 = false; //ルール0の適用の有無
  boolean MODE_RULE1 = false; //ルール1の適用の有無
  boolean MODE_RULE2 = false; //ルール2の適用の有無
  boolean MODE_RULE3 = false; //ルール3の適用の有無
  boolean MODE_RULE4 = false; //ルール4の適用の有無
  boolean MODE_RULE5 = false; //ルール5の適用の有無
  boolean MODE_RULE6 = false; //ルール6の適用の有無
  //マウスを押した際の作用（true：引力, false：斥力）
  boolean MODE_ATTRACT = true;

  float c1 = 0.1; 	//ルール1の係数
  float c2 = 5.0; 	//ルール2の係数
  float c3 = 0.05;	//ルール3の係数

  /** コンストラクタ **/
  //引数（p：ボイドの総数, w：画面の幅, h：画面の高さ）
  BoidsDraw(int p, int w, int h) {

    this.pop = p; //個体数をフィールドに代入

    //ボイドの配列を初期化
    b = new Boid[pop];

    //ボイドをpop分だけ生成したのち, 初期化
    //（位置と速度をランダムに与える）
    for (int i=0; i<pop; i++) {
      b[i] = new Boid();
    }

    //描画用のレイヤの生成
    pg_body = createGraphics(w, h, JAVA2D);
    pg_trace = createGraphics(w, h, JAVA2D);
    pg_connect = createGraphics(w, h, JAVA2D);
    pg_cluster = createGraphics(w, h, JAVA2D);
    pg_ui = createGraphics(w, h, JAVA2D);
  }

  /** メソッド **/

  //初期化（位置と速度をシャッフル）
  void init() {
    for (int i=0; i<pop; i++) {
      b[i].init();
    }
  }

  //位置の更新
  void updCondition() {

    //ボイドのルールの適用
    if (MODE_RULE0) applyRule0();
    if (MODE_RULE1) applyRule1();
    if (MODE_RULE2)	applyRule2();
    if (MODE_RULE3)	applyRule3();
    if (MODE_RULE4) applyRule4();
    if (MODE_RULE5) applyRule5();
    if (MODE_RULE6) applyRule6();

    //マウスが押されたときの作用
    if (mousePressed) {
      if (MODE_ATTRACT) {
        ruleAttractor(); //引力の発生
      } else {
        ruleSeparator(); //斥力の発生
      }
    }		

    //全てのボイドの位置を更新します. 
    for (int i=0; i<pop; i++) {
      b[i].upd();
    }
  }

  //ボイドをレイヤに描画（本画面に出力されないことに注意）
  void drawBoidsLayer(BoidsCluster bc) {
    this.bc = bc;

    drawBodyLayer();	//ボイドレイヤの描画
    drawTraceLayer(); 	//トレース・レイヤの描画
    drawConnectLayer(); //コネクトレイヤの描画
    drawClusterLayer(bc); //クラスタレイヤの描画

    drawUI();
  }


  //　ボイドレイヤの描画（ボイドの本体）
  void drawBodyLayer() {

    pg_body.beginDraw();//描画の開始

    //描画ここから---------------------------
    pg_body.clear();	//画面をクリア
    pg_body.noStroke(); //線を描かない
    pg_body.strokeWeight(3);

    for (int i=0; i<pop; i++) {
      //色の設定
      pg_body.fill(b[i].color_body);

      if (b[i].cancer) {
        pg_body.stroke(200, 0, 250);
      }

      //i番目のボイドのx座標・y座標
      float ix = b[i].pos.x; 
      float iy = b[i].pos.y; 
      //円の描画
      pg_body.ellipse(ix, iy, b[i].body_size, b[i].body_size);

      pg_body.noStroke();
    }
    //描画ここまで---------------------------

    // CUPPLE
    pg_body.endDraw(); //描画の終了
    for (int i = 0; i < pop; i++) {
      if (b[i].cupple) {
        float aveX = (b[i].pos.x + b[b[i].pare].pos.x) / 2;
        float aveY = (b[i].pos.y + b[b[i].pare].pos.y) / 2;

        float control = dist(b[i].pos.x, b[i].pos.y, aveX, aveY) * 0.5;

        if (dist(b[i].pos.x, b[i].pos.y, b[b[i].pare].pos.x, b[b[i].pare].pos.y) > 40) {
          b[i].vel.x += (aveX - b[i].pos.x) / control;
          b[i].vel.y += (aveY - b[i].pos.y) / control;
        } else if (dist(b[i].pos.x, b[i].pos.y, b[b[i].pare].pos.x, b[b[i].pare].pos.y) < 20) {
          b[i].vel.x -= (aveX - b[i].pos.x) / (control * 2);
          b[i].vel.y -= (aveY - b[i].pos.y) / (control * 2);
        }
      }
    }
  }


  //　トレースレイヤの描画（ボイドの軌跡）
  void drawTraceLayer() {

    pg_trace.beginDraw(); //描画の開始

    //描画ここから---------------------------

    for (int i=0; i<pop; i++) {
      pg_trace.strokeWeight((float)b[i].body_size / 6); //軌跡の線の幅の設定
      //線の色の設定
      pg_trace.stroke(b[i].color_trace);

      //i番目のボイドのx座標・y座標
      float ix0 = b[i].pos.x; 	
      float iy0 = b[i].pos.y; 			
      //i番目のボイドの1フレーム前のx座標・y座標
      float ix1 = b[i].pos1.x; 	
      float iy1 = b[i].pos1.y; 		

      //1フレーム前の位置と線を結ぶ	     		
      pg_trace.line(ix0, iy0, ix1, iy1);
    }
    //描画ここまで---------------------------

    pg_trace.endDraw(); //描画の終了
  }

  // コネクトレイヤの描画
  void drawConnectLayer() {
    pg_connect.beginDraw();
    pg_connect.clear();

    for (int i = 0; i < pop; i++) {
      for (int j = i + 1; j < pop; j++) {
        pg_connect.strokeWeight((float)(b[i].body_size + b[j].body_size) / 14 - 0.3);
        if (b[i].isVisible(b[j])) {
          if (b[i].cancer || b[j].cancer) {
            pg_connect.stroke(200, 0, 250);
          } else if (b[i].pare == j) {
            pg_connect.stroke(b[i].color_body);
          } else {
            pg_connect.stroke(255);
          }
          pg_connect.line(b[i].pos.x, b[i].pos.y, b[j].pos.x, b[j].pos.y);
        }
      }
    }
    pg_connect.endDraw();
  }

  // クラスタ
  void drawClusterLayer(BoidsCluster bc) {
    pg_cluster.beginDraw();
    pg_cluster.clear();

    pg_cluster.noStroke();
    pg_cluster.fill(200, 100, 0, 100);

    int sum_g = bc.countCluster(pop / 12);

    for (int g = 0; g < sum_g; g++) {
      Pos cp = bc.getClusterPos(g);  // 重心の位置
      float cd = bc.getClusterDistance(g);  // 重心からの距離
      int cs = bc.getClusterSize(g);  // クラスタの規模(内包するボイドの数)

      float control = (float)(sqrt(cs)) / (float)(sqrt(pop));

      pg_cluster.fill(255 * control, 191 - 191 * control, 0, 130);
      pg_cluster.ellipse(cp.x, cp.y, cd * 2, cd * 2);
    }
    pg_cluster.endDraw();
  }

  void drawUI() {
    pg_ui.beginDraw();
    pg_ui.clear();

    rectMode(CENTER);

    float scale = (width - 80) * 2 / 29;
    float size = scale / 2;

    pg_ui.noStroke();
    pg_ui.fill(100, 100, 100, 130);
    if (MODE_RULE0) {
      pg_ui.fill(255, 127, 0, 150);
    }
    pg_ui.rect(40 + scale * 9.5, height - size / 2, size, size / 2);
    pg_ui.fill(100, 100, 100, 130);
    // -------------------------------------------------------------
    if (MODE_RULE1) {
      pg_ui.fill(255, 127, 0, 150);
    }
    pg_ui.rect(40 + scale * 0.5, height - size / 2, size, size / 2);
    pg_ui.fill(100, 100, 100, 130);
    // -------------------------------------------------------------
    if (MODE_RULE2) {
      pg_ui.fill(255, 127, 0, 150);
    }
    pg_ui.rect(40 + scale * 1.5, height - size / 2, size, size / 2);
    pg_ui.fill(100, 100, 100, 130);
    // -------------------------------------------------------------
    if (MODE_RULE3) {
      pg_ui.fill(255, 127, 0, 150);
    }
    pg_ui.rect(40 + scale * 2.5, height - size / 2, size, size / 2);
    pg_ui.fill(100, 100, 100, 130);
    // -------------------------------------------------------------
    if (MODE_RULE4) {
      pg_ui.fill(255, 127, 0, 150);
    }
    pg_ui.rect(40 + scale * 3.5, height - size / 2, size, size / 2);
    pg_ui.fill(100, 100, 100, 130);
    // -------------------------------------------------------------
    if (MODE_RULE5) {
      pg_ui.fill(255, 127, 0, 150);
    }
    pg_ui.rect(40 + scale * 4.5, height - size / 2, size, size / 2);
    pg_ui.fill(100, 100, 100, 130);
    // -------------------------------------------------------------
    if (MODE_RULE6) {
      pg_ui.fill(255, 127, 0, 150);
    }
    pg_ui.rect(40 + scale * 5.5, height - size / 2, size, size / 2);
    pg_ui.fill(100, 100, 100, 130);

    pg_ui.endDraw();
  }

  //ボイドレイヤを本画面に出力
  void showBody() {
    image(pg_body, 0, 0);
  }

  //トレースレイヤを本画面に出力
  void showTrace() {
    image(pg_trace, 0, 0);
  }

  //トレースレイヤを消去
  void clearTrace() {
    pg_trace.beginDraw();
    pg_trace.clear();
    pg_trace.endDraw();
  }

  void applyRule0() {
    for (int i = 0; i < pop; i++) {
      for (int j = i + 1; j < pop; j++) {
        float dis = dist(b[i].pos.x, b[i].pos.y, b[j].pos.x, b[j].pos.y);

        if (dis < 5) {
          b[i].vel.x = 0;
          b[i].vel.y = 0;
          b[j].vel.x = 0;
          b[j].vel.y = 0;
        }
      }
    }
  }

  //ルール1（結合ルール）をここに書きましょう。
  void applyRule1() {
    int count;
    float sumX, sumY;
    float aveX, aveY;
    float control;
    for (int i = 0; i < pop; i++) {
      count = 0;
      sumX = 0;
      sumY = 0;
      for (int j = 0; j < pop; j++) {
        if (j != i && b[i].isVisible(b[j]) && b[i].pare != j && (b[i].body_size < b[j].body_size + 5 && b[i].body_size > b[j].body_size - 5)) {
          sumX += b[j].pos.x;
          sumY += b[j].pos.y;
          count++;
        }
      }
      if (count > 0) {
        aveX = sumX / count;
        aveY = sumY / count;

        control = dist(b[i].pos.x, b[i].pos.y, aveX, aveY) * 0.3;

        b[i].vel.x += (aveX - b[i].pos.x) / control;
        b[i].vel.y += (aveY - b[i].pos.y) / control;
      }
    }
  }	
  //ルール2（分離ルール）をここに書きましょう。
  void applyRule2() {
    float d;
    for (int i = 0; i < pop; i++) {
      for (int j = 0; j < pop; j++) {
        if (j != i && b[i].isNeighbor(b[j]) && b[i].pare != j) {
          d = dist(b[i].pos.x, b[i].pos.y, b[j].pos.x, b[j].pos.y);
          b[i].vel.x -= (b[j].pos.x - b[i].pos.x) * c2 / d;
          b[i].vel.y -= (b[j].pos.y - b[i].pos.y) * c2 / d;
        }
      }
    }
  }
  //ルール3（整列ルール）をここに書きましょう. 
  void applyRule3() {
    int count;
    float sumX, sumY;
    float aveX, aveY;
    for (int i = 0; i < pop; i++) {
      count = 0;
      sumX = 0;
      sumY = 0;
      for (int j = 0; j < pop; j++) {
        if (b[i].isVisible(b[j]) && b[i].pare != j && b[i].body_size <= b[j].body_size + 5) {
          sumX += b[j].vel.x * (b[j].body_size * b[j].body_size * b[j].body_size);
          sumY += b[j].vel.y * (b[j].body_size * b[j].body_size * b[j].body_size);
          count += b[j].body_size * b[j].body_size * b[j].body_size;
        }
      }
      if (count > 0) {
        aveX = sumX / count;
        aveY = sumY / count;

        b[i].vel.x = aveX * c3 + b[i].vel.x * (1 - c3);
        b[i].vel.y = aveY * c3 + b[i].vel.y * (1 - c3);
      }
    }
  }

  void applyRule4() {
    for (int i = 0; i < pop; i++) {
      for (int j = 0; j < pop; j++) {
        if (j != i && b[i].pare != j && (bc.cgid[i] != bc.cgid[j] || (bc.cgid[i] == -1 && bc.cgid[j] == -1))) {
          float size_i;
          if (bc.cgid[i] != -1) {
            size_i = bc.cluster_strength[bc.cgid[i]];
          } else {
            size_i = b[i].body_size;
          }
          float size_j;
          if (bc.cgid[j] != -1) {
            size_j = bc.cluster_strength[bc.cgid[j]];
          } else {
            size_j = b[j].body_size;
          }


          if (size_i > size_j && b[i].isEat(b[j])) {
            b[i].body_size += (400 - (b[i].body_size * b[i].body_size)) / 400;
          } else if (b[i].body_size > 5 && b[j].isEat(b[i])) {
            b[i].body_size -= b[i].body_size * b[i].body_size / 400;
          }
          b[i].vision_space = (14 - b[i].body_size) * 3 + 60;
          //b[i].eat_space = b[i].body_size * 8;
        }
      }
    }
  }
  
  void applyRule5() {
    for (int i = 0; i < pop; i++) {
      if (random(0, 10) < 0.005) {
        b[i].cancer = true;
        b[i].count_sick = 20;
      }
      if (random(0, 10) < 0.008) {
        b[i].cancer = false;
        b[i].count_sick = 0;
      }
      for (int j = 0; j < pop; j++) {
        if (b[i].isVisible(b[j]) && i != j) {

          if (b[i].cancer) {
            float control;
            if (b[j].cancer) {
              control = dist(b[i].pos.x, b[i].pos.y, b[j].pos.x, b[j].pos.y) * 0.001;
            } else {
              control = dist(b[i].pos.x, b[i].pos.y, b[j].pos.x, b[j].pos.y) * 0.0005;
            }

            b[i].vel.x -= (float)(b[i].pos.x - b[j].pos.x) * control;
            b[i].vel.y -= (float)(b[i].pos.y - b[j].pos.y) * control;


            if (b[j].count_sick < 20) {
              b[j].count_sick += 1.7;
            }
            
          } else if (!b[i].cancer) {
            float control;
            if (b[j].cancer) {
              control = dist(b[i].pos.x, b[i].pos.y, b[j].pos.x, b[j].pos.y) * 0.0005;
            } else {
              control = dist(b[i].pos.x, b[i].pos.y, b[j].pos.x, b[j].pos.y) * 0.0007;
            }
            
            b[i].vel.x -= (float)(b[i].pos.x - b[j].pos.x) * control;
            b[i].vel.y -= (float)(b[i].pos.y - b[j].pos.y) * control;


            if (b[j].count_sick > 0) {
              b[j].count_sick--;
            }
          }
        }
      }

      if (b[i].count_sick > 10) {
        b[i].cancer = true;
        b[i].count_sick = 18;
      } else {
        b[i].cancer = false;
        b[i].count_sick = 3;
      }
    }
  }

  void applyRule6() {
    for (int i = 0; i < pop; i++) {
      for (int j = 0; j < pop; j++) {
        if (j != i && b[i].isMeet(b[j]) && !b[i].cupple && !b[j].cupple) {
          b[i].meet[j]++;
          b[j].meet[i]++;
          if (b[i].meet[j] > 10) {
            b[i].cupple = true;
            b[i].pare = j;
            b[j].cupple = true;
            b[j].pare = i;

            float red = random(100, 255);
            float green = random(100, 255);
            float blue = random(100, 255);
            b[i].color_trace = color(red, green, blue, 130);
            b[j].color_trace = b[i].color_trace;
            b[i].color_body = color(red, green, blue);
            b[j].color_body = b[i].color_body;
            b[i].neighbor_space = 35;
            b[j].neighbor_space = 35;
            b[i].setMaxSpeed(5);
            b[j].setMaxSpeed(5);
          }
        }
      }
    }
  }

  //マウスで押した点へと引き込まれるルールを書いてください. 
  void ruleAttractor() {
    for (int i=0; i<pop; i++) {
      //i番目のボイドの位置座標・速度
      Pos ipos = b[i].pos;

      //ここから適切な処理を追加してください.
      float control = dist(ipos.x, ipos.y, mouseX, mouseY) * 0.7;
      Vel avel = new Vel( (mouseX - ipos.x) / control, (mouseY - ipos.y) / control);

      b[i].vel.x += avel.x;
      b[i].vel.y += avel.y;
    }
  }

  //マウスで押した点から斥力が発生するようなルールを書いてください
  //ただし, 距離が100ピクセル未満となったときのみ斥力が発生するものとします. 
  void ruleSeparator() {
    for (int i=0; i<pop; i++) {
      //i番目のボイドの位置座標・速度
      Pos ipos = b[i].pos;

      //ここから適切な処理を追加してください.
      float control = dist(ipos.x, ipos.y, mouseX, mouseY) * 3;
      Vel avel = new Vel( (mouseX - ipos.x) / control, (mouseY - ipos.y) / control);

      b[i].vel.x -= avel.x;
      b[i].vel.y -= avel.y;
    }
  }
}
