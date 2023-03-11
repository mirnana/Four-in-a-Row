import ddf.minim.*;

// specifications
int BOARDWIDTH=7, BOARDHEIGHT=6;
int DIFFICULTY=2;
int SPACESIZE=50;
int FPS=30;
int XMARGIN=(640-BOARDWIDTH*SPACESIZE)/2, YMARGIN=(480-BOARDHEIGHT*SPACESIZE)/2;
int XLEFTPILE=int(SPACESIZE / 2); int YLEFTPILE=480 - int(3 * SPACESIZE / 2);
int XRIGHTPILE=640 - int(3 * SPACESIZE / 2); int YRIGHTPILE=480 - int(3 * SPACESIZE / 2);
boolean MULTIPLAYER = false;
boolean first=false;

// variables
Minim minim, minimTileFall;
AudioPlayer backgroundMusic, tileFall;
PImage backg, chosenTheme, leftPlayer, rightPlayer, boardim, arrow, computer, computer2, human, human2, tie, tie2, mainmenu, rules, leftPlayerWon, rightPlayerWon, mute, unmute, settings;
PFont orbitron;
int[][] board = new int[BOARDHEIGHT][BOARDWIDTH]; // human: 1, computer: -1

int[][][] historyBoard = new int[100][BOARDHEIGHT][BOARDWIDTH];
int move = 0;

int column_g;
int xcor, ycor; // coordinates of the currently active tile
int step;
float speed, dropSpeed;

int beginning, end;
int turn; // human: 1, computer: -1, second human (only with multiplayer mode): 0
int pressed;
int gameScreen; // mainMenu: 0, game: 1, endGame: 2, rules: 3, settings: 4
boolean showHelp, isFirstGame;
boolean draggingToken, humanMove;
int tokenx, tokeny;
boolean mouseR;
int winner;
boolean win;

int left_res=0, right_res=0;

int r, t; // r: rules, t==0: dark theme, t==1; light theme
boolean muted;

void setup(){
  size(640, 480);
  frameRate(FPS);
  
  muted = false;
  minim = new Minim(this);
  backgroundMusic = minim.loadFile("Sweet_Sun.mp3");
  backgroundMusic.loop();
  
  backg=loadImage("background.png");
  backg.resize(640, 480);
  leftPlayer=loadImage("red.png");
  leftPlayer.resize(SPACESIZE, SPACESIZE);
  rightPlayer=loadImage("yellow.png");
  rightPlayer.resize(SPACESIZE, SPACESIZE);
  boardim=loadImage("boardim.png");
  boardim.resize(SPACESIZE, SPACESIZE);
  
  arrow=loadImage("arrow.png");
  arrow.resize(int(SPACESIZE*3.75),int(1.5*SPACESIZE));
  computer=loadImage("computer.png");
  computer2=loadImage("computer2.png");
  human=loadImage("human.png");
  human2=loadImage("human2.png");
  tie=loadImage("tie.png");
  tie2=loadImage("tie2.png");
  leftPlayerWon = loadImage("leftPlayerWon.png");
  rightPlayerWon = loadImage("rightPlayerWon.png");
  
  mainmenu=loadImage("mainmenu.png");
  mainmenu.resize(640, 480);
  rules=loadImage("rules.png");
  rules.resize(640, 480);
  settings=loadImage("settings.png");
  settings.resize(640, 480);
  
  mute = loadImage("mute.png");
  mute.resize(SPACESIZE, SPACESIZE);
  unmute = loadImage("unmute.png");
  unmute.resize(SPACESIZE, SPACESIZE);
  
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
    left_res=0;
    right_res=0;
    imageMode(CENTER);
    if(muted) image(unmute, 55, 55);
    else image(mute, 55, 55);
    imageMode(CORNER);
    
    rectMode(CENTER);
    stroke(185, 59, 50, 50);
    //PLAY
    if (overRect(17, 105, 135, 100)) 
      fill(185, 59, 50); // BOJA BEZ HOVERA
    else
      fill(185, 59, 50, 50); // BOJA S HOVEROM
    rect(85, 155, 135, 100); // POZICIJA RECT
    
    //RULES
    if (overRect(167, 105, 140, 100))
      fill(185, 59, 50); // BOJA BEZ HOVERA
    else
      fill(185, 59, 50, 50); // BOJA S HOVEROM
    rect(237, 155, 140, 100); // POZICIJA RECT
    
    //SETTINGS
    if (overRect(320, 105, 160, 100))
      fill(185, 59, 50); // BOJA BEZ HOVERA
    else
      fill(185, 59, 50, 50); // BOJA S HOVEROM
    rect(400, 155, 160, 100);// POZICIJA RECT
    
    //QUIT
    if (overRect(495, 105, 130, 100))
      fill(185, 59, 50); // BOJA BEZ HOVERA
    else
      fill(185, 59, 50, 50); // BOJA S HOVEROM
    rect(560, 155, 130, 100); // POZICIJA RECT
    
    textFont(orbitron);
    fill(0, 0, 0);
    textAlign(CENTER, CENTER);
    text("PLAY", 90, 155);
    text("RULES", 240, 155);
    text("SETTINGS", 400, 155);
    text("QUIT", 560, 155);
    
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
    fill(255,0,0);
    

    if (mousePressed){
      if (overRect(195, 225, 250, 35)) {
        MULTIPLAYER = true;
        beginning = 1; 
      }
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
      else if (overRect(17, 105, 135, 100)) { // PLAY PRIJELAZ 
        backgroundMusic.pause();
        gameScreen=1;
      }
      else if (overRect(167, 105, 140, 100)) // RULES PRIJELAZ
        gameScreen=3;
      else if(overRect(320, 105, 160, 100)) // SETTINGS PRIJELAZ
        gameScreen=4;
      else if (overRect(495, 105, 130, 100)) //QUIT PRIJELAZ
        exit();
      else if (overCircle(40, 423, 62)){
        darkTheme(); t=0;
      }
      else if (overCircle(108, 423, 62)){
        lightTheme(); t=1;
      }
    }
    if (t == 0)
      chosenTheme = loadImage("background.png");
    else
      chosenTheme = loadImage("backgroundl.png");
    // resize to 62
    chosenTheme.resize(62, 62);
    image(chosenTheme, 20, 280);

    stroke(255, 0, 0);
    noFill();
    rect(20 + 31, 280 + 31, 62, 62);

  } //end of main menu
  
  if (gameScreen==1 || gameScreen==2){
    background(backg);
    drawTile(xcor,ycor,turn);
    drawBoard(board);
    
    if (showHelp && !MULTIPLAYER)
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
    fill(206, 66, 56); 
    if (!MULTIPLAYER) {
      text("DIFFICULTY:", 90, 25);
      if(DIFFICULTY==1)
      text("EASY", 44, 55);
      else if(DIFFICULTY==2)
      text("MEDIUM", 60, 55);
      else 
      text("HARD", 46, 55);
      textSize(20);
      text("HUMAN", 70,200);
      text("COMPUTER",565,200);
      fill(206, 66, 56);
      rect(70,225, 40,25);
      rect(565,225, 40,25);
      textSize(25);
      fill(255,255,255);
      text(left_res,70,225);
      text(right_res,565,225);
    }
    else
    {   
      text("LEFT", 70,200);
      text("RIGHT",565,200);
      fill(206, 66, 56);
      rect(70,225, 40,25);
      rect(565,225, 40,25);

      fill(255,255,255);
      text(left_res,70,225);
      text(right_res,565,225);
    }
    
    if (beginning==1){
      if (isFirstGame){
        if (MULTIPLAYER) turn = 0;
        else turn=-1; // computer: -1
        showHelp=true;
      }
      else{
        if (round(random(0,1))==0) {
          if (MULTIPLAYER) turn = 0;
          else turn=-1;
        }
        else
          turn=1;
        showHelp=false;
      }
    
      getNewBoard();
      step=0;
      if(turn==1){
        xcor=XLEFTPILE;
        ycor=YLEFTPILE;
      }
      else {
        xcor=XRIGHTPILE;
        ycor=YRIGHTPILE;
      }
      beginning=0;
    }
    
    if (mousePressed && overRect(540, 0, 100, 50)) {
      beginning = 1;
      gameScreen = 0;
      backgroundMusic.loop();
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
          boolean leftPlayerTurn = mouseX>XLEFTPILE 
                            && mouseX<XLEFTPILE+SPACESIZE 
                            && mouseY>YLEFTPILE 
                            && mouseY<YLEFTPILE+SPACESIZE
                            && turn == 1;
          boolean rightPlayerTurn = mouseX>XRIGHTPILE 
                            && mouseX<XRIGHTPILE+SPACESIZE 
                            && mouseY>YRIGHTPILE 
                            && mouseY<YRIGHTPILE+SPACESIZE
                            && turn == 0
                            && MULTIPLAYER;
          
          if (move > 0)
          {
            // make clickable undo button
            rect(50, 100, 100, 50);
            // write text undo
            fill(200, 0, 0);
            text("UNDO", 50, 100);
          }
          // when hovering over undo button, change color
          if (mouseX > 0 && mouseX < 100 && mouseY > 75 && mouseY < 125 && move > 0){
            fill(150, 0, 0);
            rect(50, 100, 100, 50);
            fill(200, 0, 0);
            text("UNDO", 50, 100);
          }
          else if (move > 0)
          {
            fill(200, 0, 0);
            rect(50, 100, 100, 50);
            fill(255, 255, 255);
            text("UNDO", 50, 100);
          }
          
          // if undo button is clicked and move > 0, change color of undo button
          if (mousePressed && mouseX > 0 && mouseX < 100 && mouseY > 75 && mouseY < 125 && move > 0)
          {
            fill(255, 0, 0);
            rect(50, 100, 100, 50);
            fill(255, 255, 255);
            text("UNDO", 50, 100);
            // undo move
            undoMove();
          }

          
          if (mousePressed && draggingToken==false && (leftPlayerTurn || rightPlayerTurn)){
          // start of dragging on leftPlayer token pile
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
        column_g=(int)((xcor+SPACESIZE/2-XMARGIN)/SPACESIZE);
        xcor = XMARGIN + column_g * SPACESIZE;
        

        //if (move > 0)
        //  println(equal(board, historyBoard[move - 1]));
        println("move: " + move);
        if (move == 0)
        {
          copy(board, historyBoard[move]);
          move++;
        }
        else if (move > 0 && !equal(board, historyBoard[move - 1]))
        {
          copy(board, historyBoard[move]);
          move++;
          println(move);
        }
        
        
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
          first=true;
          gameScreen=2; // RESTART
          win=true;
          backgroundMusic.loop();
        }
        if (turn == 1) {
          if (MULTIPLAYER) turn = 0;
          else turn=-1;
          xcor = XRIGHTPILE;
          ycor = YRIGHTPILE;
        }
        else if (turn == 0) {
          turn = 1;
          xcor = XLEFTPILE;
          ycor = YLEFTPILE;
        }
        humanMove=false;
        step=0;
        playTileFall();
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
        xcor=XRIGHTPILE;
        ycor=YRIGHTPILE;
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
          first=true;
          gameScreen=2; // RESTART
          win=true;
          backgroundMusic.loop();
        }
        turn=1;
        step=0;
        xcor=XLEFTPILE;
        ycor=YLEFTPILE;
        
        playTileFall();
      }
    }
  
    if (!win && isBoardFull(board)){
      winner=2;
      first=true;
      gameScreen=2; // RESTART
      backgroundMusic.loop();
    }
  } // end of game
  
  if(gameScreen==2){
     isFirstGame=false;
   
     imageMode(CENTER);
     if (winner==1) {
         if (MULTIPLAYER){ 
            if(first == true)
           {
             left_res++;
             first=false;
           }
           image(leftPlayerWon, 640/2, 480/2);
             stroke(206, 66, 56);
             if (overRect(195, 280, 250, 35))
                fill(185, 59, 50);
             else {
              
              fill(255, 255, 255);
                   }
              rect(320, 297, 250, 35);
              if (overRect(195, 325, 250, 35))
                fill(185, 59, 50);
             else {
              
              fill(255, 255, 255);
                   }
              rect(320, 342, 250, 35);
              textFont(orbitron);
              fill(0, 0, 0);
               text("Play again", 320, 297);
               text("Main menu", 320, 342);
               if(mousePressed)
               {
                 if (overRect(195, 280, 250, 35))

                 {
                   beginning=1;
                   gameScreen=1;
                   backgroundMusic.pause();
                   
                 }
                 if (overRect(195, 325, 250, 35))
                 {
                   
                    gameScreen = 0;
                    beginning=1;

                 }
               }
         
       }
         else 
         {
           if(first == true)
           {
             left_res++;
             first=false;
           }
             image(human2, 640/2, 480/2);
                     stroke(206, 66, 56);
             if (overRect(195, 280, 250, 35))
                fill(185, 59, 50);
             else {
              
              fill(255, 255, 255);
                   }
              rect(320, 297, 250, 35);
              if (overRect(195, 325, 250, 35))
                fill(185, 59, 50);
             else {
              
              fill(255, 255, 255);
                   }
              rect(320, 342, 250, 35);
              textFont(orbitron);
              fill(0, 0, 0);
               text("Play again", 320, 297);
               text("Main menu", 320, 342);
               if(mousePressed)
               {
                 if (overRect(195, 280, 250, 35))

                 {
                   beginning=1;
                   gameScreen=1;
                   backgroundMusic.pause();
                   
                 }
                 if (overRect(195, 325, 250, 35))
                 {
                   
                    gameScreen = 0;
                    beginning=1;

                 }
               }
     }
     }
     else if (winner==-1) {
       if (MULTIPLAYER)
       {
         image(rightPlayerWon, 640/2, 480/2);
         if(first == true)
           {
             right_res++;
             first=false;
           }
             stroke(206, 66, 56);
             if (overRect(195, 280, 250, 35))
                fill(185, 59, 50);
             else {
              
              fill(255, 255, 255);
                   }
              rect(320, 297, 250, 35);
              if (overRect(195, 325, 250, 35))
                fill(185, 59, 50);
             else {
              
              fill(255, 255, 255);
                   }
              rect(320, 342, 250, 35);
              textFont(orbitron);
              fill(0, 0, 0);
               text("Play again", 320, 297);
               text("Main menu", 320, 342);
               if(mousePressed)
               {
                 if (overRect(195, 280, 250, 35))

                 {
                   beginning=1;
                   gameScreen=1;
                   backgroundMusic.pause();
                   
                 }
                 if (overRect(195, 325, 250, 35))
                 {
                   
                    gameScreen = 0;
                    beginning=1;

                 }
               }
         
     }
       else 
       {
         image(computer2, 640/2, 480/2);
         
         if(first == true)
           {
             right_res++;
             first=false;
           }
                     stroke(206, 66, 56);
             if (overRect(195, 280, 250, 35))
                fill(185, 59, 50);
             else {
              
              fill(255, 255, 255);
                   }
              rect(320, 297, 250, 35);
              if (overRect(195, 325, 250, 35))
                fill(185, 59, 50);
             else {
              
              fill(255, 255, 255);
                   }
              rect(320, 342, 250, 35);
              textFont(orbitron);
              fill(0, 0, 0);
               text("Play again", 320, 297);
               text("Main menu", 320, 342);
               if(mousePressed)
               {
                 if (overRect(195, 280, 250, 35))

                 {
                   beginning=1;
                   gameScreen=1;
                   backgroundMusic.pause();
                   
                 }
                 if (overRect(195, 325, 250, 35))
                 {
                   
                    gameScreen = 0;
                    beginning=1;

                 }
               }
         
       }
       
     }
     else
     {
       image(tie, 640/2, 480/2);
        stroke(206, 66, 56);
             if (overRect(195, 313, 250, 35))
                fill(185, 59, 50);
             else {
              
              fill(206, 66, 56);
                   }
              rect(320, 330, 250, 35);
              if (overRect(195, 358, 250, 35))
                fill(185, 59, 50);
             else {
              
              fill(206, 66, 56);
                   }
              rect(320, 375, 250, 35);
              textFont(orbitron);
              fill(0, 0, 0);
               text("Play again", 320, 330);
               text("Main menu", 320, 375);
               if(mousePressed)
               {
                 if(overRect(195, 313, 250, 35))
                 {
                   backgroundMusic.pause();
                   beginning=1;
                   gameScreen=1;
                   
                 }
                 if (overRect(195, 358, 250, 35))
                 {
                  
                    gameScreen = 0;
                    beginning=1;
                 }
               }
     }
     imageMode(CORNER);
     win=false;
  }
  
  if(gameScreen==3){
    background(rules);
    r++;
  }
  
  if(gameScreen==4){
    background(settings); 
    // EXIT
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
    fill(206, 66, 56);

    // show leftPlayer and rightPlayer and resize them to SPACESIZE
    imageMode(CENTER);
    image(leftPlayer, XLEFTPILE+SPACESIZE/2, YLEFTPILE+SPACESIZE/2, SPACESIZE, SPACESIZE);
    image(rightPlayer, XRIGHTPILE+SPACESIZE/2, YRIGHTPILE+SPACESIZE/2, SPACESIZE, SPACESIZE);

  
    // print location
    if( mousePressed)
      println(mouseX, mouseY);
    
    if (mousePressed && overRect(540, 0, 100, 50)) {
      beginning = 1;
      gameScreen = 0;
      backgroundMusic.loop();
    }
    // when clicked, print coordinates
    else if ( mousePressed && overCircle( 138, 252, 62 ))
    {
      // load "red.png" for leftPlayer
      leftPlayer = loadImage("red.png");
      leftPlayer.resize(SPACESIZE, SPACESIZE);
    }
    else if ( mousePressed && overCircle( 216, 252, 62 ))
    {
      // load "greenl.png" for leftPlayer
      leftPlayer = loadImage("greenl.png");
      leftPlayer.resize(SPACESIZE, SPACESIZE);
    }
    else if ( mousePressed && overCircle( 309, 252, 62 ))
    {
      // load "blue.png" for leftPlayer
      leftPlayer = loadImage("blue.png");
      leftPlayer.resize(SPACESIZE, SPACESIZE);
    }
    else if ( mousePressed && overCircle( 396, 252, 62 ))
    {
      // load "blue-green.png" for leftPlayer
      leftPlayer = loadImage("blue-green.png");
      leftPlayer.resize(SPACESIZE, SPACESIZE);
    }
    else if ( mousePressed && overCircle( 488, 252, 62 ))
    {
      // load "blue_special.png" for leftPlayer
      leftPlayer = loadImage("blue_special.png");
      leftPlayer.resize(SPACESIZE, SPACESIZE);
    }
    else if ( mousePressed && overCircle( 138, 381, 62 ))
    {
      // load "yellow.png" for rightPlayer
      rightPlayer = loadImage("yellow.png");
      rightPlayer.resize(SPACESIZE, SPACESIZE);
    }
    else if ( mousePressed && overCircle( 216, 381, 62 ))
    {
      // load "violet.png" for rightPlayer
      rightPlayer = loadImage("violet.png");
      rightPlayer.resize(SPACESIZE, SPACESIZE);
    }
    else if ( mousePressed && overCircle( 309, 381, 62 ))
    {
      // load "pink.png" for rightPlayer
      rightPlayer = loadImage("pink.png");
      rightPlayer.resize(SPACESIZE, SPACESIZE);
    }
    else if ( mousePressed && overCircle( 396, 381, 62 ))
    {
      // load "pink-blue.png" for rightPlayer
      rightPlayer = loadImage("pink-blue.png");
      rightPlayer.resize(SPACESIZE, SPACESIZE);
    }
    else if ( mousePressed && overCircle( 488, 381, 62 ))
    {
      // load "pink_special.png" for rightPlayer
      rightPlayer = loadImage("pink_special.png");
      rightPlayer.resize(SPACESIZE, SPACESIZE);
    }

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
/*	if (gameScreen==2 && MULTIPLAYER){
		beginning=1;
    gameScreen=0;
	} */
  if (gameScreen==3 && r>5){
    gameScreen=0;
    r=0;
  }
  if (gameScreen == 0 && overCircle(55,55,SPACESIZE)) {
    if(muted) {
      muted = false;
      backgroundMusic.unmute();
    }
    else {
      muted = true;
      backgroundMusic.mute();
    }
  }
}

void darkTheme(){
  backg=loadImage("background.png");
  backg.resize(640, 480);
  leftPlayer=loadImage("red.png");
  leftPlayer.resize(SPACESIZE, SPACESIZE);
  rightPlayer=loadImage("yellow.png");
  rightPlayer.resize(SPACESIZE, SPACESIZE);
  boardim=loadImage("boardim.png");
  boardim.resize(SPACESIZE, SPACESIZE);

}

void lightTheme(){
  backg=loadImage("backgroundl.png");
  backg.resize(640, 480);
  leftPlayer=loadImage("greenl.png");
  leftPlayer.resize(SPACESIZE, SPACESIZE);
  rightPlayer=loadImage("violet.png");
  rightPlayer.resize(SPACESIZE, SPACESIZE);
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
      if (currBoard[i][j]==1) image(leftPlayer, x, y);
      else if (currBoard[i][j]==-1) image(rightPlayer, x, y);
      image(boardim, x, y);
      y+=SPACESIZE;
    }
    y=YMARGIN;
    x+=SPACESIZE;
  }
  
  image(leftPlayer, XLEFTPILE, YLEFTPILE);
  image(rightPlayer, XRIGHTPILE, YRIGHTPILE);
}

void drawTile(int x, int y, int player){
  if (player==-1 || player==0) image(rightPlayer, x, y);
  else image(leftPlayer, x, y);
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

void playTileFall() {
  minimTileFall = new Minim(this);
  tileFall = minimTileFall.loadFile("plastic fall.mp3");
  tileFall.play();
}

long currentTime = 0;

void undoMove() {
  if (move > 0 && millis() - currentTime > 1000) {
    // board = lastBoard;
    for (int i = 0; i < BOARDHEIGHT; i++) {
      for (int j = 0; j < BOARDWIDTH; j++) {
        board[i][j] = historyBoard[move - 1][i][j];
        historyBoard[move - 1][i][j] = 0;
      }
    } 

    // remove last board from history of type int[][][]
    
    
    move--;

    // get current time in milliseconds
    currentTime = millis();

    if (MULTIPLAYER)
    {
      if (turn == 1)
      {
        turn = 0;
      }
      else
      {
        turn = 1;
      }
    }
  }
}

boolean equal(int[][] a, int[][] b)
{
  for (int i = 0; i < a.length; i++)
  {
    for (int j = 0; j < a[i].length; j++)
    {
      if (a[i][j] != b[i][j])
      {
        return false;
      }
    }
  }
  return true;
}

void copy(int[][] a, int[][] b)
{
  for (int i = 0; i < a.length; i++)
  {
    for (int j = 0; j < a[i].length; j++)
    {
      b[i][j] = a[i][j];
    }
  }
}
