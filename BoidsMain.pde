import processing.pdf.*;
import java.util.Calendar;


// 画像保存=========================================================
void keyReleased() {
  if (key =='s'|| key == 'S') {
    saveFrame(timestamp()+"_##.png");
  }
}

String timestamp() {
  Calendar now = Calendar.getInstance();
  return String.format("%1$ty%1$tm%1$td_%1$tH%1$tM%1$tS", now);
}

boolean recordPDF = false;
// ================================================================

/* グローバル変数 */
BoidsDraw bdraw; //ボイド描画オブジェクト
int pop;   //ボイドの総数

boolean MODE_TRACE = false; //軌跡モード（初期時はFALSE）
boolean MODE_CONNECT = false;
boolean MODE_CLUSTER = false;

boolean showUI = true;

long count;
//boolean size;
int pust;
int num[];

//起動時の処理
void setup() {
  //ウィンドウを画面一杯に開く
  //Processing環境で「⌘+SHIFT+R」で実行するとフルスクリーンになります. 
  fullScreen();
  //size(displayWidth, displayHeight);
  background(0); //背景を黒とする. 
  frameRate(30);  //フレームレート
  ellipseMode(CENTER);

  pop = (int)(displayWidth / 18);

  count = 0;
  //size = false;
  pust = 0;
  num = new int[41];
  for (int i = 0; i <= 40; i++) {
    num[i] = 0;
  }

  //ボイド描画オブジェクトの生成
  bdraw = new BoidsDraw(pop, width, height);
}

//繰り返し行う処理
void draw() {

  //背景のクリア
  background(0); 

  //ボイドの状態（位置・速度）を更新
  bdraw.updCondition();

  BoidsCluster bc = new BoidsCluster(bdraw.b);
  //ボイドの描画（レイヤ）
  bdraw.drawBoidsLayer(bc);

  if (MODE_CLUSTER) {
    image(bdraw.pg_cluster, 0, 0);
  }

  //ボイドの描画（本画面）
  if (MODE_TRACE) {
    //トレースレイヤは, MODE_TRACEがTRUEのときのみ描画		
    //MODE_TRACEはSHIFTボタンによって反転
    bdraw.showTrace();
  }

  if (MODE_CONNECT) {
    image(bdraw.pg_connect, 0, 0);
  }

  bdraw.showBody();

  if (showUI) {
    image(bdraw.pg_ui, 0, 0);
  }
  //if (size) {
  //  if (count % 10 == 0 && (int)(count / 10) != 0) {
  //    //int s = (int)dist(0, 0, bdraw.b[0].vel.x, bdraw.b[0].vel.y);
  //    int s = (int)bdraw.b[0].vel.x;
  //    num[abs(s - pust)]++;
  //    //println((int)(count / 30) + ": " + (s - pust));
  //    //  int sum_g = bc.countCluster(pop / 12);
  //    //  int max = 0;
  //    //  for (int i = 0; i < sum_g; i++) {
  //    //    int cs = bc.cgid[i];
  //    //    if (cs > max) {
  //    //      max = cs;
  //    //    }
  //    //  }
  //    //  println((int)(count / 30) + ": " + (max + 1));
  //    //  pust = max;
  //    pust = s;
  //  }
  //  count++;
  //} else if (count > 0) {
  //  for (int i = 0; i <= 40; i++) {
  //    println(i + ": " + num[i]);
  //  }
  //}
}


//キーが押されたときの処理
void keyPressed() {
  //シフトが押されるたびにトレースモードが反転します。
  if (keyCode == SHIFT) {
    MODE_TRACE = !MODE_TRACE;
    bdraw.clearTrace();
  }
  //「i」が押されると, 全てのボイドの状態を初期化します。
  if (key == 'i' || key =='I') {
    bdraw.init();
  }
  //「a」が押されると, マウスを押した際に働く引力・斥力が切り替わります. 
  if (key == 'a' || key == 'A') {
    bdraw.MODE_ATTRACT = !bdraw.MODE_ATTRACT;
  }
  //「0」を押して, ルール1の適用の有無を切り替えます. 
  if (key == '0') {
    bdraw.MODE_RULE0 = !bdraw.MODE_RULE0;
  }
  //「1」を押して, ルール1の適用の有無を切り替えます. 
  if (key == '1') {
    bdraw.MODE_RULE1 = !bdraw.MODE_RULE1;
  }
  //「2」を押して, ルール2の適用の有無を切り替えます. 
  if (key == '2') {
    bdraw.MODE_RULE2 = !bdraw.MODE_RULE2;
  }
  //「3」を押して, ルール3の適用の有無を切り替えます. 
  if (key == '3') {
    bdraw.MODE_RULE3 = !bdraw.MODE_RULE3;
  }
  //「4」を押して, ルール3の適用の有無を切り替えます. 
  if (key == '4') {
    bdraw.MODE_RULE4 = !bdraw.MODE_RULE4;
  }
  if (key == '5') {
    bdraw.MODE_RULE5 = !bdraw.MODE_RULE5;
  }
  if (key == '6') {
    bdraw.MODE_RULE6 = !bdraw.MODE_RULE6;
  }

  //「c」を押して, コネクトの適用の有無を切り替えます. 
  if (key == 'c' || key == 'C') {
    MODE_CONNECT = !MODE_CONNECT;
  }
  //「d」を押して, クラスタの適用の有無を切り替えます. 
  if (key == 'd' || key == 'D') {
    MODE_CLUSTER = !MODE_CLUSTER;
  }
  if (key == 'h' || key =='H') {
    showUI = !showUI;
  }

  //if (key == 'p' || key =='P') {
  //  size = !size;
  //}

  if (keyCode == RIGHT) {
    float vs = bdraw.b[0].vision_space;
    for (int i = 0; i < pop; i++) {
      vs = bdraw.b[i].vision_space + 1;
      bdraw.b[i].setVisionSpace(vs);
    }
    //println("vision_space = " + vs);
  }
  if (keyCode == LEFT) {
    float vs = bdraw.b[0].vision_space;
    for (int i = 0; i < pop; i++) {
      vs = bdraw.b[i].vision_space - 1;
      bdraw.b[i].setVisionSpace(vs);
    }
    //println("vision_space = " + vs);
  }
}
