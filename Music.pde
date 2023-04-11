import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;



Minim minim;
AudioPlayer song;
FFT fft;

// Variables to differenciate the "zones" of the spectrum
// For example, for the bass, you have only the first 3% of the total spectrum
float specLow = 0.03; // 3%
float specMid = 0.125;  // 12.5%
float specHi = 0.20;   // 20%

// Values for the scores of each zone
float scoreLow = 0;
float scoreMid = 0;
float scoreHi = 0;

// Previous values
float oldScoreLow = scoreLow;
float oldScoreMid = scoreMid;
float oldScoreHi = scoreHi;

float scoreDecreaseRate = 25;
Cube cube;

void setup() {
  fullScreen(P3D);

  minim = new Minim(this);

  //Load the song
  song = minim.loadFile("song.mp3");

  //Create the fft object of the song
  fft = new FFT(song.bufferSize(), song.sampleRate());
  background(0);

  cube = new Cube();

  //Play the song
  song.play(0);
}

void draw() {

  fft.forward(song.mix);

  oldScoreLow = scoreLow;
  oldScoreMid = scoreMid;
  oldScoreHi = scoreHi;

  // Reinitialise the values
  scoreLow = 0;
  scoreMid = 0;
  scoreHi = 0;

  // Caculate the new scores
  for (int i = 0; i < fft.specSize()*specLow; i++)
  {
    scoreLow += fft.getBand(i);
  }

  for (int i = (int)(fft.specSize()*specLow); i < fft.specSize()*specMid; i++)
  {
    scoreMid += fft.getBand(i);
  }

  for (int i = (int)(fft.specSize()*specMid); i < fft.specSize()*specHi; i++)
  {
    scoreHi += fft.getBand(i);
  }

  // To slow the descent
  if (oldScoreLow > scoreLow) {
    scoreLow = oldScoreLow - scoreDecreaseRate;
  }

  if (oldScoreMid > scoreMid) {
    scoreMid = oldScoreMid - scoreDecreaseRate;
  }

  if (oldScoreHi > scoreHi) {
    scoreHi = oldScoreHi - scoreDecreaseRate;
  }

  float globalScore = 0.66*scoreLow + 0.8*scoreMid + 1*scoreHi;

  background(0.05 * scoreLow, 0.05 * scoreMid, 0.05 * scoreHi);

  float previousBandValue = fft.getBand(0);

  //Z distance
  float dist = -25;

  //Height Multiplier
  float heightMult = 1.5;

  //Edge frequency lines
  for (int i = 1; i < fft.specSize(); i++)
  {
    //Value for each frequency bannd
    float bandValue = fft.getBand(i)*(1 + (i/50));

    stroke(scoreLow / 3, scoreMid / 3, scoreHi / 3);
    strokeWeight(globalScore/50);

    //bottom left
    line(0, height - (previousBandValue * heightMult), dist * (i - 1), 0, height - (bandValue * heightMult), dist * i);
    line((previousBandValue * heightMult), height, dist * (i - 1), (bandValue * heightMult), height, dist * i);
    line(0, height - (previousBandValue * heightMult), dist * (i - 1), (bandValue * heightMult), height, dist * i);

    //top right
    line(0, (previousBandValue * heightMult), dist * (i - 1), 0, (bandValue * heightMult), dist * i);
    line((previousBandValue * heightMult), 0, dist * (i - 1), (bandValue * heightMult), 0, dist * i);
    line(0, (previousBandValue * heightMult), dist * (i - 1), (bandValue * heightMult), 0, dist * i);

    //bottom left
    line(width, height - (previousBandValue * heightMult), dist * (i - 1), width, height - (bandValue * heightMult), dist * i);
    line(width - (previousBandValue * heightMult), height, dist * (i - 1), width - (bandValue * heightMult), height, dist * i);
    line(width, height - (previousBandValue * heightMult), dist * (i - 1), width - (bandValue * heightMult), height, dist * i);

    //top right
    line(width, (previousBandValue * heightMult), dist * (i - 1), width, (bandValue * heightMult), dist * i);
    line(width - (previousBandValue * heightMult), 0, dist*(i - 1), width-(bandValue * heightMult), 0, dist*  i);
    line(width, (previousBandValue * heightMult), dist * (i - 1), width - (bandValue * heightMult), 0, dist * i);

    previousBandValue = bandValue;
  }
  
  // Show the cube
  cube.show(scoreLow, scoreMid, scoreHi, globalScore);
}


class Cube {

  float rotX, rotY, rotZ;
  float sumRotX, sumRotY, sumRotZ;

  Cube() {

  }

  void show(float low, float mid, float high, float intensity) {
    rotX = random(0, 0.1);
    rotY = random(0, 0.1);
    rotZ = random(0, 0.1);

    sumRotX += (intensity / 2.5) * (rotX/200);
    sumRotY += (intensity / 2.5) * (rotY/200);
    sumRotZ += (intensity / 2.5) * (rotZ/200);


    // Draw the cube
    pushMatrix();
    translate(width/2, height/2, 300);

    // Apply the rotation
    rotateX(sumRotX);
    rotateY(sumRotY);
    rotateZ(sumRotZ);


    fill(low, mid, high);
    stroke(0);
    strokeWeight(2);
    box(100+(intensity/3));
    popMatrix();
  }
}
