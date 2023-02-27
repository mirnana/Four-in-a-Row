import ddf.minim.*;

// specifications
int BOARDWIDTH=7, BOARDHEIGHT=6;
int DIFFICULTY=2;
int SPACESIZE=50;
int FPS=30;
int XMARGIN=(640-BOARDWIDTH*SPACESIZE)/2, YMARGIN=(480-BOARDHEIGHT*SPACESIZE)/2;
int XREDPILE=int(SPACESIZE / 2); int YREDPILE=480 - int(3 * SPACESIZE / 2);
int XYELLOWPILE=640 - int(3 * SPACESIZE / 2); int YYELLOWPILE=480 - int(3 * SPACESIZE / 2);
boolean MULTIPLAYER = false;

// variables
Minim minim;
AudioPlayer backgroundMusic;
PImage backg, red, yellow, boardim, arrow, computer, human, tie, mainmenu, rules, redWon, yellowWon;
PFont orbitron;
int[][] board = new int[BOARDHEIGHT][BOARDWIDTH]; // human: 1, computer: -1

int column_g;
int xcor, ycor; // coordinates of the currently active tile
int step;
float speed, dropSpeed;

int beginning, end;
int turn; // human: 1, computer: -1, second human (only with multiplayer mode): 0
int pressed;
int gameScreen; // mainMenu: 0, game: 1, endGame: 2, rules: 3
boolean showHelp, isFirstGame;
boolean draggingToken, humanMove;
int tokenx, tokeny;
boolean mouseR;
int winner;
boolean win;

int r, t; // r: rules, t==0: dark theme, t==1; light theme

void setup(){
  size(640, 480);
  frameRate(FPS);
  
  minim = new Minim(this);
  backgroundMusic = minim.loadFile("Sweet_Sun.mp3");
  backgroundMusic.loop();
  
  backg=loadImage("background.png");
  backg.resize(640, 480);
  red=loadImage("red.png");
  red.resize(SPACESIZE, SPACESIZE);
  yellow=loadImage("yellow.png");
  yellow.resize(SPACESIZE, SPACESIZE);
  boardim=loadImage("boardim.png");
  boardim.resize(SPACESIZE, SPACESIZE);
  
  arrow=loadImage("arrow.png");
  arrow.resize(int(SPACESIZE*3.75),int(1.5*SPACESIZE));
  computer=loadImage("computer.png");
  human=loadImage("human.png");
  tie=loadImage("tie.png");
  redWon = loadImage("redWon.png");
  yellowWon = loadImage("yellowWon.png");
  
  mainmenu=loadImage("mainmenu.png");
  mainmenu.resize(640, 480);
  rules=loadImage("rules.png");
  rules.resize(640, 480);
  
  orbitron=createFont("orbitron-light.otf", 25);
  
  isFirstGame=true;
  beginning=1;
  end=0;
  
  pressed=0;
  gameScreen=0;
  
  draggingToken=false;
  humanMove=false;
  mouseR=false;
  
  r=0;
  
  win=false;
}

void draw(){
  if (gameScreen==0){
    background(mainmenu);
    
    rectMode(CENTER);
    stroke(185, 59, 50, 50);
    if (overRect(70, 105, 160, 100))
      fill(185, 59, 50);
    else
      fill(185, 59, 50, 50);
    rect(150, 155, 160, 100);
    if (overRect(240, 105, 160, 100))
      fill(185, 59, 50);
    else
      fill(185, 59, 50, 50);
    rect(320, 155, 160, 100);
    if (overRect(410, 105, 160, 100))
      fill(185, 59, 50);
    else
      fill(185, 59, 50, 50);
    rect(490, 155, 160, 100);
    textFont(orbitron);
    fill(0, 0, 0);
    textAlign(CENTER, CENTER);
    text("PLAY", 150, 155);
    text("RULES", 320, 155);
    text("QUIT", 490, 155);
    
    stroke(206, 66, 56);
    if (overRect(195, 225, 250, 35))
      fill(185, 59, 50);
    else {
      if(MULTIPLAYER) fill(160, 52, 44);
      else fill(206, 66, 56);
    }
    rect(320, 242, 250, 35);
    if (overRect(195, 313, 250, 35))
      fill(185, 59, 50);
    else {
      if(!MULTIPLAYER && DIFFICULTY == 1) fill(160, 52, 44);
      else fill(206, 66, 56);
    }
    rect(320, 330, 250, 35);
    if (overRect(195, 358, 250, 35))
      fill(185, 59, 50);
    else {
      if(!MULTIPLAYER && DIFFICULTY == 2) fill(160, 52, 44);
      else fill(206, 66, 56);
    }
    rect(320, 375, 250, 35);
    if (overRect(195, 403, 250, 35))
      fill(185, 59, 50);
    else {
      if(!MULTIPLAYER && DIFFICULTY == 3) fill(160, 52, 44);
      else fill(206, 66, 56);
    }
    rect(320, 420, 250, 35);
    textFont(orbitron);
    fill(0, 0, 0);
    text("Multiplayer", 320, 242);
    text("Easy", 320, 330);
    text("Medium", 320, 375);
    text("Hard", 320, 420);
    
    fill(0,0,0,0);
    if (overCircle(40, 423, 62)) 
      stroke(255);
    else 
      noStroke();
    ellipse(40, 423, 62, 62);
    if (overCircle(108, 423, 62)) 
      stroke(0);
    else 
      noStroke();
    ellipse(108, 423, 62, 62);

    if (mousePressed){
      if (overRect(195, 225, 250, 35))
        MULTIPLAYER = true;
      if (overRect(195, 313, 250, 35)) {
        DIFFICULTY=1;
        MULTIPLAYER = false;
      }
      else if (overRect(195, 358, 250, 35)) {
        DIFFICULTY=2;
        MULTIPLAYER = false;
      }
      else if (overRect(195, 403, 250, 35)) {
        DIFFICULTY=3;
        MULTIPLAYER = false;
      }
      else if (overRect(70, 105, 160, 100)) {
        backgroundMusic.pause();
        gameScreen=1;
      }
      else if (overRect(240, 105, 160, 100))
        gameScreen=3;
      else if (overRect(410, 105, 160, 100))
        exit();
      else if (overCircle(40, 423, 62)){
        darkTheme(); t=0;
      }
      else if (overCircle(108, 423, 62)){
        lightTheme(); t=1;
      }
    }
  }
  
  if (gameScreen==1 || gameScreen==2){
    background(backg);
    drawTile(xcor,ycor,turn);
    drawBoard(board);
    
    if (showHelp)
      image(arrow, int(SPACESIZE / 2)+SPACESIZE, 470 - int(3 * SPACESIZE / 2));
  }
  
  if (gameScreen==1){
    rectMode(CENTER);
    stroke(185, 59, 50);
    if (overRect(540, 0, 100, 50))
      fill(185, 59, 50);
    else
      fill(206, 66, 56);
    rect(590, 25, 100, 50);
    textFont(orbitron);
    fill(0, 0, 0);
    textAlign(CENTER, CENTER);
    text("EXIT", 590, 25);
    
    if (mousePressed && overRect(540, 0, 100, 50)) {
      beginning = 1;
      gameScreen = 0;
      backgroundMusic.loop();
    }
    
    if (beginning==1){
      if (isFirstGame){
        if (MULTIPLAYER) turn = 0;
        else turn=-1; // computer: -1
        showHelp=true;
      }
      else{
        if (round(random(0,1))==0)
          if (MULTIPLAYER) turn = 0;
          else turn=-1;
        else
          turn=1;
        showHelp=false;
      }
    
      getNewBoard();
      step=0;
      if(turn==1){
        xcor=XREDPILE;
        ycor=YREDPILE;
      }
      else{
        xcor=XYELLOWPILE;
        ycor=YYELLOWPILE;
      }
      beginning=0;
    }
    
    if(turn==1 || turn==0){ // human
      humanMove=true;
      
      textFont(orbitron);
      if(t==0) fill(246, 27, 31);
      else fill(80, 7, 45);
      if(MULTIPLAYER) {
        if (turn == 0) text("Right players' turn!", 320, 40);
        else if (turn == 1) text("Left players' turn!", 320, 40);
      }
      else text("Your turn!", 320, 40);
      
      if (step==0){
          boolean redTurn = mouseX>XREDPILE 
                            && mouseX<XREDPILE+SPACESIZE 
                            && mouseY>YREDPILE 
                            && mouseY<YREDPILE+SPACESIZE
                            && turn == 1;
          boolean yellowTurn = mouseX>XYELLOWPILE 
                            && mouseX<XYELLOWPILE+SPACESIZE 
                            && mouseY>YYELLOWPILE 
                            && mouseY<YYELLOWPILE+SPACESIZE
                            && turn == 0
                            && MULTIPLAYER;
          if (mousePressed && draggingToken==false && (redTurn || yellowTurn)){
          // start of dragging on red token pile
            draggingToken=true;
            xcor=mouseX-SPACESIZE/2;
            ycor=mouseY-SPACESIZE/2;
           }
          if (mouseR){
            column_g=(int)((xcor+SPACESIZE/2-XMARGIN)/SPACESIZE);
            if (isValidMove(board, column_g)){
              dropSpeed=1.0;
              step=1;
            }
          }
      }
      else if (step==1){
        draggingToken=false;
        mouseR=false;  
      
        int row=getLowestEmptySpace(board, column_g);
      
        if(int((ycor+int(dropSpeed)-YMARGIN) / SPACESIZE)<row){
          ycor+=int(dropSpeed);
          dropSpeed+=0.5;
        }
        else step=2;
      }
      else if (step==2){
        int p = turn;
        if(turn == 0) p = -1;
        
        makeMove(board, p, column_g);
        showHelp=false;
        
        if (isWinner(board, p)){
          winner=p;
          gameScreen=2; // RESTART
          win=true;
          backgroundMusic.loop();
        }
        if (turn == 1) {
          if (MULTIPLAYER) turn = 0;
          else turn=-1;
          humanMove=false;
          xcor = XYELLOWPILE;
          ycor = YYELLOWPILE;
        }
        else if (turn == 0) {
          turn = 1;
          humanMove=false;
          xcor = XREDPILE;
          ycor = YREDPILE;
        }
        step=0;
      }
    }
    else if (!MULTIPLAYER){ // computer
      textFont(orbitron);
      if(t==0) fill(246, 27, 31);
      else fill(80, 7, 45);
      text("Computer's turn!", 320, 40);
    
      if (step==0){
        column_g=getComputerMove(DIFFICULTY);
        dropSpeed=1.0;
        speed=1.0;
        xcor=XYELLOWPILE;
        ycor=YYELLOWPILE;
        step=1;
      }
      else if (step==1){  
        if (ycor>(YMARGIN - SPACESIZE)){
          speed+=0.1;
          ycor-=int(speed);
        }
        else step=2;
      }
      else if (step==2){
        if (xcor>(XMARGIN + column_g*SPACESIZE+10)){
          xcor-=int(speed);
          speed+=0.1;
        }
        else {
          xcor=XMARGIN + column_g*SPACESIZE; 
          step=3;
        }
      }
      else if (step==3){
        int row=getLowestEmptySpace(board, column_g);

        if (int((ycor+int(dropSpeed)-YMARGIN) / SPACESIZE)<row){
          ycor+=int(dropSpeed);
          dropSpeed+=0.5;
        }
        else step=4;
      }
      else if (step==4){
        makeMove(board, -1, column_g);
        if (isWinner(board, -1)){
          winner=-1;
          gameScreen=2; // RESTART
          win=true;
          backgroundMusic.loop();
        }
        turn=1;
        step=0;
        xcor=XREDPILE;
        ycor=YREDPILE;
      }
    }
  
    if (!win && isBoardFull(board)){
      winner=2;
      gameScreen=2; // RESTART
      backgroundMusic.loop();
    }
  }
  
  if(gameScreen==2){
     isFirstGame=false;
     imageMode(CENTER);
     if (winner==1) {
       if (MULTIPLAYER) image(redWon, 640/2, 480/2);
       else image(human, 640/2, 480/2);
     }
     else if (winner==-1) {
       if (MULTIPLAYER) image(yellowWon, 640/2, 480/2);
       else image(computer, 640/2, 480/2);
     }
     else
       image(tie, 640/2, 480/2);
     imageMode(CORNER);
     win=false;
  }
  
  if(gameScreen==3){
    background(rules);
    r++;
  }
}

boolean overRect(int x, int y, int width, int height){
  if (mouseX>=x && mouseX<=x+width && mouseY>=y && mouseY<=y+height)
    return true;
  return false;
}

boolean overCircle(int x, int y, int diameter) {
  float disX = x - mouseX;
  float disY = y - mouseY;
  if (sqrt(sq(disX) + sq(disY)) < diameter/2 )
    return true;
  return false;
}

void mouseClicked(){
	if (gameScreen==2){
		beginning=1;
    gameScreen=0;
	}
  if (gameScreen==3 && r>5){
    gameScreen=0;
    r=0;
  }
}

void darkTheme(){
  backg=loadImage("background.png");
  backg.resize(640, 480);
  red=loadImage("red.png");
  red.resize(SPACESIZE, SPACESIZE);
  yellow=loadImage("yellow.png");
  yellow.resize(SPACESIZE, SPACESIZE);
  boardim=loadImage("boardim.png");
  boardim.resize(SPACESIZE, SPACESIZE);
}

void lightTheme(){
  backg=loadImage("backgroundl.png");
  backg.resize(640, 480);
  red=loadImage("greenl.png");
  red.resize(SPACESIZE, SPACESIZE);
  yellow=loadImage("violet.png");
  yellow.resize(SPACESIZE, SPACESIZE);
  boardim=loadImage("boardl.png");
  boardim.resize(SPACESIZE, SPACESIZE);
}

void makeMove(int[][] currBoard, int player, int column){
    int lowest=getLowestEmptySpace(currBoard, column);
    if (lowest != -1)
        currBoard[lowest][column]=player;
}

void drawBoard(int[][] currBoard){
  int x=XMARGIN, y=YMARGIN;
  for (int j=0 ; j<BOARDWIDTH ; ++j){
    for (int i=0 ; i<BOARDHEIGHT ; ++i){
      if (currBoard[i][j]==1) image(red, x, y);
      else if (currBoard[i][j]==-1) image(yellow, x, y);
      image(boardim, x, y);
      y+=SPACESIZE;
    }
    y=YMARGIN;
    x+=SPACESIZE;
  }
  
  image(red, XREDPILE, YREDPILE);
  image(yellow, XYELLOWPILE, YYELLOWPILE);
}

void drawTile(int x, int y, int player){
  if (player==-1 || player==0) image(yellow, x, y);
  else image(red, x, y);
}

void getNewBoard(){
  for (int j=0 ; j<BOARDWIDTH ; ++j){
    for (int i=0 ; i<BOARDHEIGHT ; ++i){
      board[i][j]=0;
    }
  }
}

void mouseDragged(){
  if (humanMove && draggingToken){
    xcor=mouseX-SPACESIZE/2;
    ycor=mouseY-SPACESIZE/2;
  }
}

void mouseReleased(){
  if (humanMove && draggingToken)
    mouseR=true;
}

int getComputerMove(int diff){
  int[] potentialMoves=getPotentialMoves(board, -1, diff);
  int bestMoveFitness=-1, i;
  for (i=0 ; i<BOARDWIDTH ; ++i){
    if (potentialMoves[i]>bestMoveFitness && isValidMove(board, i))
      bestMoveFitness=potentialMoves[i];
  }

  IntList bestMoves=new IntList();
  for (i=0 ; i<potentialMoves.length ; ++i)
    if (potentialMoves[i]==bestMoveFitness && isValidMove(board, i))
      bestMoves.append(i);
  int choice=round(random(bestMoves.size()-1));
  return bestMoves.array()[choice];
}

void deepCopy(int[][] board1, int[][] board2){
  int i, j;
  for (i=0 ; i<BOARDHEIGHT ; ++i)
    for (j=0 ; j<BOARDWIDTH ; ++j)
      board2[i][j]=board1[i][j];
}

int[] getPotentialMoves(int[][] currBoard, int player, int diff){
  int[] potentialMoves=new int[BOARDWIDTH];
  int i;
  for (i=0 ; i<BOARDWIDTH ; ++i)
    potentialMoves[i]=0;
    
  if (diff==0 || isBoardFull(currBoard)){
      return potentialMoves;
  }
  
  int enemy;
  if (player==1)
    enemy=-1;
  else
    enemy=1;
    
  for (int firstMove=0 ; firstMove<BOARDWIDTH ; ++firstMove){
    int[][] dupeBoard=new int[BOARDHEIGHT][BOARDWIDTH];
    deepCopy(board, dupeBoard);
    if (!isValidMove(dupeBoard, firstMove))
      continue;
    makeMove(dupeBoard, player, firstMove);
    if (isWinner(dupeBoard, player)){
      potentialMoves[firstMove]=1;
      break;
    }
    else{
      if (isBoardFull(dupeBoard))
        potentialMoves[firstMove]=0;
      else{
        for (int counterMove=0 ; counterMove<BOARDWIDTH ; ++counterMove){
          int[][] dupeBoard2=new int[BOARDHEIGHT][BOARDWIDTH];
          deepCopy(dupeBoard, dupeBoard2);
          if (!isValidMove(dupeBoard2, counterMove))
            continue;
          makeMove(dupeBoard2, enemy, counterMove);
          if (isWinner(dupeBoard2, enemy)){
            potentialMoves[firstMove]=-1;
            break;
          }
          else{
            int[] results=getPotentialMoves(dupeBoard2, player, diff-1);
            int sum=0;
            for (int j=0 ; j<BOARDWIDTH ; ++j)
              sum+=results[j];
            potentialMoves[firstMove]+=(sum/BOARDWIDTH)/BOARDWIDTH;
          }
        }
      }
    }
  }
  return potentialMoves;
}

int getLowestEmptySpace(int[][] currBoard, int column){
  // return the row number of the lowest empty row in the given column.
  for(int i=BOARDHEIGHT-1; i>=0 ; --i){
    if (currBoard[i][column]==0)
      return i;
  }
  return -1;
}

boolean isValidMove(int[][] currBoard, int column){
  if (column<0 || column>=BOARDWIDTH || currBoard[0][column]!=0)
    return false;
  return true;
}

boolean isBoardFull(int[][] currBoard){
  for(int j=0 ; j<BOARDWIDTH ; ++j){
      if(currBoard[0][j]==0) return false;
    }
  return true;
}

boolean isWinner(int[][] currBoard, int player){
  // check vertical spaces
  int i, j;
  for(i=0 ; i<(BOARDHEIGHT-3) ; ++i){
    for(j=0 ; j<BOARDWIDTH ; ++j){
      if (currBoard[i][j]==player && currBoard[i+1][j]==player && currBoard[i+2][j]==player && currBoard[i+3][j]==player)
        return true;
    }
  }
    
  // check horizontal spaces
  for(i=0 ; i<BOARDHEIGHT ; ++i){
    for(j=0 ; j<(BOARDWIDTH-3) ; ++j){
      if (currBoard[i][j]==player && currBoard[i][j+1]==player && currBoard[i][j+2]==player && currBoard[i][j+3]==player)
        return true;
     }
  }
  
  // check / diagonal spaces
  for(i=3 ; i<BOARDHEIGHT ; ++i){
    for(j=0 ; j<BOARDWIDTH-3 ; ++j){
      if (currBoard[i][j]==player && currBoard[i-1][j+1]==player && currBoard[i-2][j+2]==player && currBoard[i-3][j+3]==player)
        return true;
    }
  }
    
  // check \ diagonal spaces
  for(i=0 ; i<(BOARDHEIGHT-3) ; ++i){
    for(j=0 ; j<(BOARDWIDTH-3) ; ++j){
      if (currBoard[i][j]==player && currBoard[i+1][j+1]==player && currBoard[i+2][j+2]==player && currBoard[i+3][j+3]==player)
        return true;
    }
  }
  return false;
}
