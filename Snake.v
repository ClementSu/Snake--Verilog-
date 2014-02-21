`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Clement Su and Oliver Baverstam 
// 
// Create Date:    16:48:09 04/06/2013 
// Design Name: 
// Module Name:    Snake 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Snake(input up, input down, input left, input right, input reset, input clk,
output reg B, output reg R, output VS, output HS, output reg G, output [3:0] AN, output [6:0] seven,
input speed1, input speed2, input level1, input level2);
wire [10:0] hcount, vcount;	// coordinates for the current pixel
wire blank;	// signal to indicate the current coordinate is blank
wire snakehead;	// the snakehead controls the movement of the rest of the snake
reg obstacle1, obstacle2, obstacle3, obstacle4;
wire [15:0] BCDcode; //wire from BCD converter
wire [3:0] smallbin; //wire from smallbin
wire [15:0] scorewire;
wire clk1khz; //wire from 1khz clock
reg snakesegment1, snakesegment2, snakesegment3, snakesegment4, snakesegment5, snakesegment6,
snakesegment7, snakesegment8, snakesegment9, snakesegment10, snakesegment11, snakesegment12,
snakesegment13, snakesegment14, snakesegment15, snakesegment16, snakesegment17, snakesegment18, 
snakesegment19, snakesegment20, snakesegment21, snakesegment22, snakesegment23, snakesegment24,
snakesegment25;
reg letter1, letter2, letter3, letter4, letter5, letter6, letter7, letter8, letter9, letter10, letter11, 
letter12, letter13, letter14, letter15, letter16, letter17, letter18, letter19,letter20, letter21,
letter22, letter23, letter24;
//these letters spell out "LOSER" if the user loses
reg [15:0] score;
//create food variable for snake
reg [10:0] foodx, foody; 
//640 width in binary is 10'b1010000000
//480 height in binary is 9'b111100000
reg [15:0]foodxcount, foodycount;
reg [3:0] speed;
reg [1:0] level;
reg [10:0] x, y, x1, y1, x2, y2, x3, y3, x4, y4, x5, y5, x6, y6, x7, y7, x8, y8, x9, y9, 
x10, y10, x11, y11, x12, y12, x13, y13, x14, y14, x15, y15, x16, y16, x17, y17, x18, y18,
x19, y19, x20, y20, x21, y21, x22, y22, x23, y23, x24, y24, x25, y25;
//coordinates of the snakehead and snake follower segments
reg slow_clk; // clock for position update
reg [4:0] state, next_state;
reg d_up, d_down, d_left, d_right; //{right, left, down, up};
reg lose; 

parameter S_IDLE = 0; // 0000 - no button pushed
parameter S_UP = 1; // 0001 - the first button pushed
parameter S_DOWN = 2; // 0010 - the second button pushed
parameter S_LEFT = 4; // 0100 - and so on
parameter S_RIGHT = 8; // 1000 - and so on

 	/////////////////////////////////////////////////////
	// Begin clock division
	parameter N = 2;	// parameter for clock division
	reg clk_25Mhz;
	reg [N-1:0] count;
	always @ (posedge clk) begin
		count <= count + 1'b1;
		clk_25Mhz <= count[N-1];
	end
	// End clock division
	/////////////////////////////////////////////////////
	
//convert snake score
assign scorewire = score;
clk1khz clock(clk, clk1khz);
BCD bro(scorewire,BCDcode);
sevenalternate brah(BCDcode, smallbin, AN, clk1khz);
binarytoseven broo(smallbin, seven);
/////////////////////////////

initial begin
lose=1'b0;
score=16'b0;
foodx = 9'd400; //food x-coordinate
foody = 8'd400; //food y-coordinate
foodxcount = 9'd400;
foodycount = 8'd400;	 //random coordinate generators
// initial position of the snake
x = 11'd100; y = 11'd100;
x1 = 11'd80; y1 = 11'd100;
x2 = 11'd60; y2 = 11'd100;
x3 = 11'd40; y3 = 11'd100;
x4 = 11'd20; y4 = 11'd100;
x5 = 11'd0; y5 = 11'd100;
x6 = 11'd0; y6 = 11'd80;
x7 = 11'd0; y7 = 11'd60;
x8 = 11'd0; y8 = 11'd40;
x9 = 11'd0; y9 = 11'd20;
x10 = 11'd0; y10 = 11'd0;
x11 = 11'd20; y11 = 11'd0;
x12 = 11'd40; y12 = 11'd0;
x13 = 11'd60; y13 = 11'd0;
x14 = 11'd80; y14 = 11'd0;
x15 = 11'd100; y15 = 11'd0;
x16 = 11'd120; y16 = 11'd0;
x17 = 11'd140; y17 = 11'd0;
x18 = 11'd160; y18 = 11'd0;
x19 = 11'd180; y19 = 11'd0;
x20 = 11'd200; y20 = 11'd0;
x21 = 11'd220; y21 = 11'd0;
x22 = 11'd240; y22 = 11'd0;
x23 = 11'd260; y23 = 11'd0;
x24 = 11'd280; y24 = 11'd0;
x25 = 11'd300; y25 = 11'd0;
// snake is initially still
d_up =0; d_down=0; d_left=0; d_right =0;
end

///////////////////////////////////////////
// slow clock for position update - optional
reg [25:0] slow_count;

always @ (posedge clk) begin
slow_count = slow_count + 1'b1;

speed = {speed1,speed2};

if (speed == 1'd0) begin
slow_clk = slow_count[24];
end
else if (speed == 1'd1) begin
slow_clk = slow_count[23];
end
else if (speed == 2'd2) begin 
slow_clk = slow_count[22];
end
else if (speed == 2'd3) begin
slow_clk = slow_count[21];
end
else begin
slow_clk = slow_count[24];
end

level = {level1,level2};

end
/////////////////////////////////////////

always @ (posedge clk)begin

if (reset == 1'b1) begin //global reset
d_up =0; d_down=0; d_left=0; d_right =0;
foodx = foodxcount;
foody = foodycount;
score = 1'b0;
lose=1'b0;
state = next_state;
end
else if (lose==1'b1)begin //if lose condition is true
d_up =0; d_down=0; d_left=0; d_right =0;
x = x;
y = y;
state=next_state;
	letter1 = ~blank & (hcount >=210 & hcount <= 220 &vcount >= 180 & vcount <= 280);
	letter2 = ~blank & (hcount >=210 & hcount <= 240 &vcount >= 270 & vcount <= 280);
	
	letter3 = ~blank & (hcount >=250 & hcount <= 280 &vcount >= 180 & vcount <= 190);
	letter4 = ~blank & (hcount >=270 & hcount <= 280 &vcount >= 180 & vcount <= 280);
	letter5 = ~blank & (hcount >=250 & hcount <= 280 &vcount >= 270 & vcount <= 280);
	letter6 = ~blank & (hcount >=250 & hcount <= 260 &vcount >= 180 & vcount <= 280);
	
	letter7 = ~blank & (hcount >=290 & hcount <= 320 &vcount >= 180 & vcount <= 190);
	letter8 = ~blank & (hcount >=290 & hcount <= 300 &vcount >= 180 & vcount <= 230);
	letter9 = ~blank & (hcount >=290 & hcount <= 320 &vcount >= 225 & vcount <= 235);
	letter10 = ~blank & (hcount >=310 & hcount <= 320 &vcount >= 230 & vcount <= 280);
	letter11 = ~blank & (hcount >=290 & hcount <= 320 &vcount >= 270 & vcount <= 280);
	
	letter12 = ~blank & (hcount >=330 & hcount <= 360 &vcount >= 180 & vcount <= 190);
	letter13 = ~blank & (hcount >=330 & hcount <= 340 &vcount >= 180 & vcount <= 280);
	letter14 = ~blank & (hcount >=330 & hcount <= 360 &vcount >= 225 & vcount <= 235);
	letter15 = ~blank & (hcount >=330 & hcount <= 360 &vcount >= 270 & vcount <= 280);
	
	letter16 = ~blank & (hcount >=370 & hcount <= 425 &vcount >= 180 & vcount <= 190);
	letter17 = ~blank & (hcount >=415 & hcount <= 425 &vcount >= 180 & vcount <= 230);
	letter18 = ~blank & (hcount >=370 & hcount <= 425 &vcount >= 225 & vcount <= 235);
	letter19 = ~blank & (hcount >=370 & hcount <= 380 &vcount >= 180 & vcount <= 280);
	
	
	letter20 = ~blank & (hcount >=380 & hcount <= 390  &vcount >= 235  & vcount <= 245);
	letter21 = ~blank & (hcount >=390 & hcount <= 400  &vcount >= 245  & vcount <= 255);
	letter22 = ~blank & (hcount >=400 & hcount <= 410  &vcount >= 255  & vcount <= 265);
	letter23 = ~blank & (hcount >=410 & hcount <= 420  &vcount >= 265  & vcount <= 275);
	letter24 = ~blank & (hcount >=415 & hcount <= 425  &vcount >= 270  & vcount <= 280);
end
else begin

foodxcount = (foodxcount + 5'd20)%10'd600;
foodycount = (foodycount + 5'd20)%9'd420;

if (up==1'b1 && d_down == 1'b0) begin
d_up =1; d_down=0; d_left=0; d_right =0; 
state = next_state;
end
else if (down==1'b1 && d_up== 1'b0) begin
d_up =0; d_down=1; d_left=0; d_right =0;
state = next_state;
end
else if (left==1'b1 && d_right==1'b0) begin
d_up =0; d_down=0; d_left=1; d_right =0;
state = next_state;
end
else if (right==1'b1 && d_left==1'b0) begin
d_up =0; d_down=0; d_left=0; d_right =1;
state = next_state;
end
else state=state;
end

	if (score > 1'b0)
	snakesegment1 = ~blank & (hcount >=x1+1 & hcount <= x1 + 19 &vcount >= y1+1 & vcount <= y1+19);
	if (score > 1'b1)
	snakesegment2 = ~blank & (hcount >=x2+1 & hcount <= x2 + 19 &vcount >= y2+1 & vcount <= y2+19);
	if (score > 2'b10)
	snakesegment3 = ~blank & (hcount >=x3+1 & hcount <= x3 + 19 &vcount >= y3+1 & vcount <= y3+19);
	if (score > 2'b11)
	snakesegment4 = ~blank & (hcount >=x4+1 & hcount <= x4 + 19 &vcount >= y4+1 & vcount <= y4+19);
	if (score > 3'b100)
	snakesegment5 = ~blank & (hcount >=x5+1 & hcount <= x5 + 19 &vcount >= y5+1 & vcount <= y5+19);
	if (score > 3'b101)
	snakesegment6 = ~blank & (hcount >=x6+1 & hcount <= x6 + 19 &vcount >= y6+1 & vcount <= y6+19);
	if (score > 3'b110)
	snakesegment7 = ~blank & (hcount >=x7+1 & hcount <= x7 + 19 &vcount >= y7+1 & vcount <= y7+19);
	if (score > 3'b111)
	snakesegment8 = ~blank & (hcount >=x8+1 & hcount <= x8 + 19 &vcount >= y8+1 & vcount <= y8+19);
	if (score > 4'b1000)
	snakesegment9 = ~blank & (hcount >=x9+1 & hcount <= x9 + 19 &vcount >= y9+1 & vcount <= y9+19);
	if (score > 4'b1001)
	snakesegment10 = ~blank & (hcount >=x10+1 & hcount <= x10 + 19 &vcount >= y10+1 & vcount <= y10+19);
	if (score > 4'b1010)
	snakesegment11 = ~blank & (hcount >=x11+1 & hcount <= x11 + 19 &vcount >= y11+1 & vcount <= y11+19);
	if (score > 4'b1011)
	snakesegment12 = ~blank & (hcount >=x12+1 & hcount <= x12 + 19 &vcount >= y12+1 & vcount <= y12+19);
	if (score > 4'b1100)
	snakesegment13 = ~blank & (hcount >=x13+1 & hcount <= x13 + 19 &vcount >= y13+1 & vcount <= y13+19);
	if (score > 4'b1101)
	snakesegment14 = ~blank & (hcount >=x14+1 & hcount <= x14 + 19 &vcount >= y14+1 & vcount <= y14+19);
	if (score > 4'b1110)
	snakesegment15 = ~blank & (hcount >=x15+1 & hcount <= x15 + 19 &vcount >= y15+1 & vcount <= y15+19);
	if (score > 4'b1111)
	snakesegment16 = ~blank & (hcount >=x16+1 & hcount <= x16 + 19 &vcount >= y16+1 & vcount <= y16+19);
	if (score > 5'b10000)
	snakesegment17 = ~blank & (hcount >=x17+1 & hcount <= x17 + 19 &vcount >= y17+1 & vcount <= y17+19);
	if (score > 5'b10001)
	snakesegment18 = ~blank & (hcount >=x18+1 & hcount <= x18 + 19 &vcount >= y18+1 & vcount <= y18+19);
	if (score > 5'b10010)
	snakesegment19 = ~blank & (hcount >=x19+1 & hcount <= x19 + 19 &vcount >= y19+1 & vcount <= y19+19);
	if (score > 5'b10011)
	snakesegment20 = ~blank & (hcount >=x20+1 & hcount <= x20 + 19 &vcount >= y20+1 & vcount <= y20+19);
	if (score > 5'b10100)
	snakesegment21 = ~blank & (hcount >=x21+1 & hcount <= x21 + 19 &vcount >= y21+1 & vcount <= y21+19);
	if (score > 5'b10101)
	snakesegment22 = ~blank & (hcount >=x22+1 & hcount <= x22 + 19 &vcount >= y22+1 & vcount <= y22+19);
	if (score > 5'b10110)
	snakesegment23 = ~blank & (hcount >=x23+1 & hcount <= x23 + 19 &vcount >= y23+1 & vcount <= y23+19);
	if (score > 5'b10111)
	snakesegment24 = ~blank & (hcount >=x24+1 & hcount <= x24 + 19 &vcount >= y24+1 & vcount <= y24+19);
	if (score > 5'b11000)
	snakesegment25 = ~blank & (hcount >=x25+1 & hcount <= x25 + 19 &vcount >= y25+1 & vcount <= y25+19);

	
	

	if (level == 2'd1)
	begin
	obstacle1= ~blank & (hcount >= 1 & hcount <= 639 & vcount >= 1 & vcount <= 19);
	obstacle2= ~blank & (hcount >= 1 & hcount <= 639 & vcount >= 461 & vcount <= 479);
	obstacle3= ~blank & (hcount >= 1 & hcount <= 19 & vcount >= 1 & vcount <= 479);
	obstacle4= ~blank & (hcount >= 621 & hcount <= 639 & vcount >= 1 & vcount <= 479);
	end
	

	else if (level == 2'd2)
	begin
	obstacle1= ~blank & (hcount >= 221 & hcount <= 419 & vcount >= 61 & vcount <= 79);
	obstacle2= ~blank & (hcount >= 521 & hcount <= 539 & vcount >= 161 & vcount <= 319);
	obstacle3= ~blank & (hcount >= 221 & hcount <= 419 & vcount >= 401 & vcount <= 419);
	obstacle4= ~blank & (hcount >= 101 & hcount <= 119 & vcount >= 161 & vcount <= 319);
	end
	
	else if (level == 2'd3)
	begin
	obstacle1= ~blank & (hcount >= 161 & hcount <= 479 & vcount >= 81 & vcount <= 99);
	obstacle2= ~blank & (hcount >= 161 & hcount <= 479 & vcount >= 181 & vcount <= 199);
	obstacle3= ~blank & (hcount >= 161 & hcount <= 479 & vcount >= 281 & vcount <= 299);
	obstacle4= ~blank & (hcount >= 161 & hcount <= 479 & vcount >= 381 & vcount <= 399);
	end
	
	
	
// Define game over conditions
		if((snakehead && snakesegment2) || (snakehead && snakesegment3) || (snakehead && snakesegment4) ||
(snakehead && snakesegment5) || (snakehead && snakesegment6) || (snakehead && snakesegment7) || 
(snakehead && snakesegment8) || (snakehead && snakesegment9) || (snakehead && snakesegment10) ||
(snakehead && snakesegment11) || (snakehead && snakesegment12) || (snakehead && snakesegment13) ||
(snakehead && snakesegment14) || (snakehead && snakesegment15) || (snakehead && snakesegment16) || 
(snakehead && snakesegment17) || (snakehead && snakesegment18) || (snakehead && snakesegment19) || 
(snakehead && snakesegment20) || (snakehead && snakesegment21) || (snakehead && snakesegment22) || 
(snakehead && snakesegment23) || (snakehead && snakesegment24) || (snakehead && snakesegment25) ||
(snakehead && obstacle1) || (snakehead && obstacle2) || (snakehead && obstacle3) || 
(snakehead && obstacle4)) begin
		lose=1'b1;
		end

// Define the conditions of eating
			if (snakehead && food) begin	// if you are within the valid region
			score=score+1'd1;
			foodx = foodxcount;
			foody = foodycount;
			end
			
			if ((food && obstacle1) || (food && obstacle2) || (food && obstacle3) || (food && obstacle4) ||
(food && snakesegment1) || (food && snakesegment2) || (food && snakesegment3) || (food && snakesegment4) ||
(food && snakesegment5) || (food && snakesegment6) || (food && snakesegment7) || (food && snakesegment8) ||
(food && snakesegment9) || (food && snakesegment10) || (food && snakesegment11) || (food && snakesegment12) ||
(food && snakesegment13) || (food && snakesegment14) || (food && snakesegment15) || (food && snakesegment16) ||
(food && snakesegment17) || (food && snakesegment18) || (food && snakesegment19) || (food && snakesegment20) ||
(food && snakesegment21) || (food && snakesegment22) || (food && snakesegment23) || (food && snakesegment24) ||
(food && snakesegment25)) begin
			foodx = foodxcount;
			foody = foodycount;
			end
			

if (food) begin	// if you are within the valid region
			B = 1'b1;
			end
		else	begin// if you are outside the valid region
			B = 0;
			end
			
		if (snakehead ||snakesegment1|| snakesegment2|| snakesegment3|| snakesegment4|| snakesegment5|| snakesegment6||
	   snakesegment7|| snakesegment8|| snakesegment9|| snakesegment10|| snakesegment11|| 
	   snakesegment12|| snakesegment13|| snakesegment14||snakesegment15||
	 snakesegment16||snakesegment17||snakesegment18||snakesegment19||snakesegment20||
	 snakesegment21|| snakesegment22||snakesegment23||snakesegment24||snakesegment25) begin
			G = 1'b1;
			end
		else begin// if you are outside the valid region
			G = 0;
			end
			
		if (obstacle1|| obstacle2|| obstacle3|| obstacle4||
		letter1|| letter2|| letter3|| letter4|| letter5|| letter6|| letter7|| letter8|| letter9|| letter10||
		letter11|| letter12|| letter13|| letter14|| letter15|| letter16|| letter17|| letter18|| 
	letter19|| letter20|| letter21|| letter22 || letter23 ||letter24) begin
			R = 1'b1;
			end
		else begin// if you are outside the valid region
			R = 0;
			end
end



always @(posedge slow_clk) begin

if (reset == 1'b1) begin //global reset; reset initial starting positions of the snake
x25 = 300; y25 = 0; x24 = 280; y24 = 0; x23 = 260; y23 = 0; x22 = 240; y22 = 0; x21 = 220;
y21 = 0; x20 = 200; y20 = 0; x19 = 180; y19 = 0; x18 = 160; y18 = 0; x17 = 140; y17 = 0; 
x16 = 120; y16 = 0; x15 = 100; y15 = 0; x14 = 80; y14 = 0; x13 = 60; y13 = 0; x12 = 40;
y12 = 0; x11 = 20; y11 = 0; x10 = 0; y10 = 0; x9 = 0; y9 = 20; x8 = 0; y8 = 40; x7 = 0;
y7 = 60; x6 = 00; y6 = 80; x5 = 00; y5 = 100; x4 = 20; y4 = 100; x3 = 40; y3 = 100; x2 = 60;
y2 = 100; x1 = 80; y1 = 100; x = 100; y = 100;
end

case (x)  //control snake going left to right
10'd640:begin x = 5'd00000; //at 660 reset to 0
end
-10'd20:begin x = 10'd640; // at negative 20, jump to 640
end
endcase

case (y) //control snake going up and down
10'd460: begin y= 5'd0; // at y= 460 reset to 0
end
-10'd20: begin y=10'd460; // at y=-5 jump to y=450
end
endcase

case (state) // The following case statements control the movement of the snake
S_IDLE: begin 
end //If idle, nothing happens
S_UP: begin
//Since the snake is not idle, follower segments inherit the previous segments' coordinates
x25 = x24; y25 = y24; x24 = x23; y24 = y23; x23 = x22; y23 = y22; x22 = x21; y22 = y21; x21 = x20; 
y21 = y20; x20 = x19; y20 = y19; x19 = x18; y19 = y18; x18 = x17; y18 = y17; x17 = x16; y17 = y16;
x16 = x15; y16 = y15; x15 = x14; y15 = y14; x14 = x13; y14 = y13; x13 = x12; y13 = y12; x12 = x11;
y12 = y11; x11 = x10; y11 = y10; x10 = x9; y10 = y9; x9 = x8; y9 = y8; x8 = x7; y8 = y7; x7 = x6; 
y7 = y6; x6 = x5; y6 = y5; x5 = x4; y5 = y4; x4 = x3; y4 = y3; x3 = x2; y3 = y2; x2 = x1; y2 = y1; 
x1 = x; y1 = y;
y = y - 11'd20; // move snakehead up
end
S_DOWN: begin
//Since the snake is not idle, follower segments inherit the previous segments' coordinates
x25 = x24; y25 = y24; x24 = x23; y24 = y23; x23 = x22; y23 = y22; x22 = x21; y22 = y21; x21 = x20; 
y21 = y20; x20 = x19; y20 = y19; x19 = x18; y19 = y18; x18 = x17; y18 = y17; x17 = x16; y17 = y16;
x16 = x15; y16 = y15; x15 = x14; y15 = y14; x14 = x13; y14 = y13; x13 = x12; y13 = y12; x12 = x11;
y12 = y11; x11 = x10; y11 = y10; x10 = x9; y10 = y9; x9 = x8; y9 = y8; x8 = x7; y8 = y7; x7 = x6; 
y7 = y6; x6 = x5; y6 = y5; x5 = x4; y5 = y4; x4 = x3; y4 = y3; x3 = x2; y3 = y2; x2 = x1; y2 = y1; 
x1 = x; y1 = y;
y = y + 11'd20; // move snakehead down
end
S_LEFT: begin
//Since the snake is not idle, follower segments inherit the previous segments' coordinates
x25 = x24; y25 = y24; x24 = x23; y24 = y23; x23 = x22; y23 = y22; x22 = x21; y22 = y21; x21 = x20; 
y21 = y20; x20 = x19; y20 = y19; x19 = x18; y19 = y18; x18 = x17; y18 = y17; x17 = x16; y17 = y16;
x16 = x15; y16 = y15; x15 = x14; y15 = y14; x14 = x13; y14 = y13; x13 = x12; y13 = y12; x12 = x11;
y12 = y11; x11 = x10; y11 = y10; x10 = x9; y10 = y9; x9 = x8; y9 = y8; x8 = x7; y8 = y7; x7 = x6; 
y7 = y6; x6 = x5; y6 = y5; x5 = x4; y5 = y4; x4 = x3; y4 = y3; x3 = x2; y3 = y2; x2 = x1; y2 = y1; 
x1 = x; y1 = y;
x = x - 11'd20; // move snakehead left
end
S_RIGHT: begin
//Since the snake is not idle, follower segments inherit the previous segments' coordinates
x25 = x24; y25 = y24; x24 = x23; y24 = y23; x23 = x22; y23 = y22; x22 = x21; y22 = y21; x21 = x20; 
y21 = y20; x20 = x19; y20 = y19; x19 = x18; y19 = y18; x18 = x17; y18 = y17; x17 = x16; y17 = y16;
x16 = x15; y16 = y15; x15 = x14; y15 = y14; x14 = x13; y14 = y13; x13 = x12; y13 = y12; x12 = x11;
y12 = y11; x11 = x10; y11 = y10; x10 = x9; y10 = y9; x9 = x8; y9 = y8; x8 = x7; y8 = y7; x7 = x6; 
y7 = y6; x6 = x5; y6 = y5; x5 = x4; y5 = y4; x4 = x3; y4 = y3; x3 = x2; y3 = y2; x2 = x1; y2 = y1; 
x1 = x; y1 = y;
x = x + 11'd20; // move snakehead right
end
endcase
next_state = {d_right , d_left, d_down, d_up};
end

	
		vga_controller_640_60 vc(
		.pixel_clk(clk_25Mhz), 
		.HS(HS), 
		.VS(VS), 
		.hcounter(hcount), 
		.vcounter(vcount), 
		.blank(blank));
		
	
	assign snakehead = ~blank & (hcount >= x & hcount <= x+20 & vcount >= y & vcount <= y+20);
	assign food= ~blank & (hcount >=foodx + 5 & hcount <= foodx + 15 &vcount >= foody + 5 & vcount <= foody + 15);
	
	endmodule



module BCD (input [15:0] binary, output reg [15:0] BCDcode);
	
	reg [3:0] Thousands;
	reg [3:0] Hundreds;
	reg [3:0] Tens;
	reg [3:0] Ones;
		
integer i;
always @ (binary)
begin

	Thousands = 4'd0;
	Hundreds = 4'd0;
	Tens = 4'd0;
	Ones = 4'd0;
	
	for (i=10; i>=0; i = i-1)
	begin
	
	
		if (Thousands >= 5)
			Thousands = Thousands +3;
		if (Hundreds >= 5)
			Hundreds = Hundreds + 3;
		if (Tens >= 5)
			Tens = Tens + 3;
		if (Ones >= 5)
			Ones = Ones + 3;
			
			Thousands = Thousands << 1;
			Thousands[0] = Hundreds[3];
			Hundreds = Hundreds << 1;
			Hundreds[0] = Tens[3];
			Tens = Tens << 1;
			Tens[0] = Ones[3];
			Ones = Ones << 1;
			Ones[0] = binary[i];
		end
		BCDcode = {Thousands, Hundreds, Tens, Ones};
	end
endmodule

module binarytoseven(bin, seven);
	input [3:0] bin; 
	output reg [6:0] seven;
	
	initial
		seven=1'b0;
		
	always @ (*)
		case (bin)
		4'b0000: seven= 7'b1000000;
		4'b0001: seven= 7'b1111001;
		4'b0010: seven= 7'b0100100;
		4'b0011: seven= 7'b0110000;
		4'b0100: seven= 7'b0011001;
		4'b0101: seven= 7'b0010010;
		4'b0110: seven= 7'b0000010;
		4'b0111: seven= 7'b1111000;
		4'b1000: seven= 7'b0000000;
		4'b1001: seven= 7'b0010000;
		4'b1010: seven= 7'b0001000;
		4'b1011: seven= 7'b0000011;
		4'b1100: seven= 7'b1000110;
		4'b1101: seven= 7'b0100001;
		4'b1110: seven= 7'b0000110;
		4'b1111: seven= 7'b0001110;
		default: seven= 7'b1111111;
		endcase

endmodule
	
	
module sevenalternate(bigbin, smallbin, AN, clk1khz);

input [15:0] bigbin;
output reg [3:0] smallbin;
output reg [3:0] AN;
input clk1khz; 
reg [1:0] count; 

initial begin
	AN= 0;
	smallbin=0;
	count=1'b0;
	end
	
always @(posedge clk1khz) begin
				

	case (count)
	2'b00: begin 
		AN=4'b1110;
		smallbin = bigbin[3:0];
		
	end
		
	2'b01: begin 
			AN=4'b1101;
			smallbin=bigbin[7:4];
			end
	
	2'b10: begin 
			AN=4'b1011;
			smallbin=bigbin[11:8];
			end
			
	2'b11: begin 
			AN=4'b0111;
			smallbin=bigbin[15:12];
			end
		default: begin
		
			AN=4'b1111;
			smallbin=0;
			end
		endcase
		count= count+1'b1;
		
end

endmodule

module clk1khz(clk, oclk);
input clk;

output reg oclk;
reg [15:0] count; // 65535

initial 
	count=1'b0;
always @ (posedge clk) begin
 count<=count+ 1'b1;
 if (count >= 16'b1100001101010000) //50k0
	oclk<=1'b1;
 else
	oclk<=1'b0;
 end
 
endmodule



module vga_controller_640_60 (pixel_clk,HS,VS,hcounter,vcounter,blank);

	input pixel_clk;	// pixel clock
	output reg HS, VS;
	output reg blank;	// sync controls, blank indicator
	output reg [10:0] hcounter, vcounter;	// pixel coordinates

	parameter HMAX = 800; 	// maximum value for the horizontal pixel counter
	parameter VMAX = 525; 	// maximum value for the vertical pixel counter
	parameter HLINES = 640;	// total number of visible columns
	parameter HFP = 648; 	// value for the horizontal counter where front porch ends
	parameter HSP = 744; 	// value for the horizontal counter where the synch pulse ends
	parameter VLINES = 480;	// total number of visible lines
	parameter VFP = 482; 	// value for the vertical counter where the frone proch ends
	parameter VSP = 484; 	// value for the vertical counter where the synch pulse ends
	parameter SPP = 0;		// value for the porch synchronization pulse

	wire video_enable;	// valid region indicator
	
	// create a "blank" indicator
	always@(posedge pixel_clk)begin
		blank <= ~video_enable; 
	end
	
	// Create a horizontal beam trace (horizontal time):
	always@(posedge pixel_clk)begin
		if(hcounter == HMAX) hcounter <= 0;
		else hcounter <= hcounter + 1'b1;
	end
	
	// Create a vertical beam trace (vertical time):
	always@(posedge pixel_clk)begin
		if(hcounter == HMAX) begin
			if(vcounter == VMAX) vcounter <= 0;
			else vcounter <= vcounter + 1'b1; 
		end
	end
	
	// Check if between horizontal porches,
	// if not send horizontal porch synchronization pulse
	always@(posedge pixel_clk)begin
		if(hcounter >= HFP && hcounter < HSP) HS <= SPP;
		else HS <= ~SPP; 
	end
	
	// Check if between vertical porches,
	// if not send vertical porch synchronization pulse
	always@(posedge pixel_clk)begin
		if(vcounter >= VFP && vcounter < VSP) VS <= SPP;
		else VS <= ~SPP; 
	end
	
	
	// create a video enabled region
	assign video_enable = (hcounter < HLINES && vcounter < VLINES) ? 1'b1 : 1'b0;

endmodule
