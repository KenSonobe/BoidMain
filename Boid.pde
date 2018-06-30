/** Boidクラス（ボイドの個体の状態を定義するクラス）**/
class Boid {

  /** Boidクラスのフィールド **/
  Pos pos;  //ボイドの位置（Posは位置を扱うためのクラス）
  Pos pos1; //1フレーム前のボイドの位置
  Vel vel;  //ボイドの速度（Velは速度を扱うためのクラス）

  float body_size = 10; //Boidの大きさ
  float vision_space = 60; //視界の限界距離（ボイドが見渡せる範囲）
  float neighbor_space = 30; //接触の限界距離（ボイド同士が衝突する距離）
  float meet_space = 10;
  float eat_space = 150;
  float vmax = 10.0; //速度の最大値（初期値を20とする）

  color color_trace = color(255, 255, 255, 100); //ボイドの線の色（初期値を白とする）
  color color_body = color(255); //ボイド本体の色（初期値を白とする）

  int meet[] = new int[pop];
  boolean cupple = false;
  int pare = -1;

  boolean cancer;
  float count_sick;

  /** コンストラクタ **/
  Boid() {
    init(); //初期化処理
  }

  /** メソッド **/

  /* ボイドの状態を初期化 */
  void init() {
    //ボイドの位置をWINDOW上にランダムに配置する. 
    pos = new Pos(random(width), random(height));
    //pos1にはposと同じ座標を入れておく. 
    pos1 = new Pos(pos.x, pos.y);
    //ボイドの速度（pixel/frame）をランダムに初期化
    //（X方向・Y方向とも最大5ピクセル/フレーム）
    vel = new Vel(random(-10, 10), random(-10, 10));

    this.cupple = false;
    this.pare = -1;
    this.color_trace = color(255, 255, 255, 100);
    this.color_body = color(255);
    this.neighbor_space = 30;
    this.setMaxSpeed(20);

    for (int i = 0; i < pop; i++) {
      meet[i] = 0;
    }

    this.body_size = 10; //Boidの大きさ
    this.vision_space = 60; //視界の限界距離（ボイドが見渡せる範囲）
    this.neighbor_space = 30; //接触の限界距離（ボイド同士が衝突する距離）
    this.meet_space = 10;
    this.eat_space = 150;

    this.cancer = false;
    this.count_sick = 0;
  }

  /* ボイドの状態を更新する */
  // (A）現在の速度に応じて, 位置を更新する. 
  // (B) ボイドがウィンドウをはみだした場合, 速度成分を反転させる. 
  // (C) 速度が上限を越える場合, 
  void upd() {
    //pos1を現在の位置に更新する. 
    pos1.setPosition(pos.x, pos.y);

    //(A) 位置を現在の速度に従って更新する. 
    pos.updPosition(vel);

    //(B) ウィンドウの外に出た場合, 対応する速度成分を反転させる！！
    if (pos.x<0 && vel.x<0) vel.x *= -1.0;
    if (pos.x>width && vel.x>0) vel.x *= -1.0;
    if (pos.y<0 && vel.y<0) vel.y *= -1.0;
    if (pos.y>height && vel.y>0) vel.y *= -1.0;  

    //(C) 速度を最小値と最大値の間に制限する. 
    vel.x = constrain(vel.x, -vmax, vmax);
    vel.y = constrain(vel.y, -vmax, vmax);
  }

  /* 速度ベクトルの加算 */
  //引数１）v <Velocityクラス>：加算する速度ベクトル
  void addVelocity(Vel v) {
    vel.setVelocity(vel.x+v.x, vel.y+v.y);
  }

  /* 最大速度の設定 */
  void setMaxSpeed(float max) {
    this.vmax = max;
  }

  /*　視界範囲の設定（単位はピクセル） */
  void setVisionSpace(float vs) {
    this.vision_space = vs;
  }

  /* 別のボイド個体（bi2）との距離を返す */
  float getDistance(Boid bi2) {
    return this.pos.getDistance(bi2.pos);
  }

  /* 別のボイド個体（bi2）が視界内にあるかの判定 */
  boolean isVisible(Boid bi2) {
    return pos.isInsideCircle(bi2.pos, vision_space);
  }

  /* 別のボイド個体（bi2）と接触領域にあるかの判定 */
  boolean isNeighbor(Boid bi2) {
    return pos.isInsideCircle(bi2.pos, neighbor_space);
  }

  boolean isMeet(Boid bi2) {
    return pos.isInsideCircle(bi2.pos, meet_space);
  }

  boolean isEat(Boid bi2) {
    return pos.isInsideCircle(bi2.pos, eat_space);
  }

  /* トレース用の色を設定します */
  void setColorTrace(color c) {
    color_trace = c;
  }

  /* ボイドの色を設定します */
  void setColorBody(color c) {
    color_body = c;
  }
}

/** Velocityクラス （速度に関するクラス）**/
class Vel {
  /** フィールド **/
  //速度のx成分・y成分
  float x;  
  float y;

  /** コンストラクタ **/
  Vel(float x, float y) {
    this.x = x; 
    this.y = y;
  }

  /** メソッド **/
  //XY座標を, 引数で指定された位置にセットする. 
  void setVelocity(float x, float y) {
    this.x = x; 
    this.y = y;
  }
}

/** Posクラス（位置に関するクラス）**/
class Pos {

  /** フィールド **/
  //x座標・Y座標
  float x; 
  float y;

  /** コンストラクタ **/
  Pos(float x, float y) {
    this.setPosition(x, y);
  }

  /** メソッド **/
  //XY座標を, 引数で指定された位置にセットする. 
  void setPosition(float x, float y) {
    this.x = x; 
    this.y = y;
  }

  //速度に応じて位置を更新する. 
  void updPosition(Vel v) {
    this.x += v.x;
    this.y += v.y;
  }

  //別の位置（p）との距離を返す. 
  float getDistance(Pos p) {
    return dist(this.x, this.y, p.x, p.y);
  }

  //近傍判定：
  //別の位置（p）との距離がdmax未満のときにtrue, 
  //別の位置（p）との距離がdmax未満のときにfalseを返す. 
  boolean isInsideCircle(Pos p, float dmax) {

    float d = this.getDistance(p);

    if (d<dmax) {
      return true;
    } else {
      return false;
    }
  }
}
