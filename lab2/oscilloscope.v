module oscilloscope(
CLOCK_50,
signal,
oVGA_CLK,
oVS,
oHS,
oBLANK_n,
b_data,
g_data,
r_data
                		  );

input CLOCK_50;
input [15:0] signal;
output oVGA_CLK;
output oVS;
output oHS;
output oBLANK_n;
output reg [7:0] b_data;
output reg [7:0] g_data;  
output reg [7:0] r_data;                     


//Variable and parameters declaration
//**************************************************************

wire cBLANK_n,cHS,cVS;  //use them in your code instead of using the output ports, at the end they will be assigned them to the corresponding output ports

// Variables for VGA Clock 
reg  vga_clk_reg;                   
wire iVGA_CLK;

//Variables for (x,y) coordinates VGA
wire [10:0] CX;
wire [9:0] CY;

//Oscilloscope parameters
	//Horizontal
	parameter DivX=10.0;  			// number of horizontal division
	parameter Ttotal=0.000025;   		// total time represented in the screen
	parameter pixelsH=640.0;  		// number of horizontal pixels
	parameter IncPixX=Ttotal/(pixelsH-1);			// time between two consecutive pixels
	//Amplitude
	parameter DivY=8.0;  			// number of vertical divisions
	parameter Atotal=8.0;			// total volts represented in the screen
	parameter pixelsV=480.0;  		// number of vertical pixels	
	parameter IncPixY=Atotal/(pixelsV-1.0);	// volts between two consecutive pixels

// Sinusoidal wave amplitude (Section 6)
parameter Amp=3.0;				// maximum amplitude of sinusoidal wave [-Amp, Amp]
parameter integer Apixels=Amp/IncPixY;		// number of pixels to represent the maximum amplitude	

//Vector to store the input signal (Section 6.1)
parameter integer nc=1						
reg [15:0] capturedVals [(nc*256)-1:0]; 		// vector with values of input signal
integer i=0;					// index of the vector

//Read the signal values from the vector (Section 6.2)
integer j=0; 					// read the correct element of the vector
parameter integer nf=2; 			//Vector points between two consecutive pixels 

//Value of the current pixel (Section 6.2 and 6.3)
reg [9:0] ValforVGA; 
reg [9:0] oldValforVGA; 


// Code starts here
//*******************************************************************

// 25 MHz clock for the VGA clock

always @(posedge CLOCK_50)
begin
	vga_clk_reg = ~vga_clk_reg;
end

assign iVGA_CLK = vga_clk_reg;

assign oVGA_CLK = ~iVGA_CLK;


// instance VGA controller

VGA_Controller VGA_ins( .reset(1'b0),
                        .vga_clk(iVGA_CLOCK),
                       	.BLANK_n(cBLANK_n),
								.HS(cHS),
                       	.VS(cVS),
								.CoorX(CX),
								.CoorY(CY)
					    );
						

// Store input signal in a vector (Section 6.1)			

always@(posedge CLOCK_50)
begin
           
	 capturedVals[i]<=signal;
	 
	 if(i=255)
	 	i<=0;
	 else	    
		i<=i+1;

end


// Read the correct point of the signal stored in the vector and calculate the pixel associated given the amplitude and the parameters of the oscilloscope (Section 6.2)

always@(negedge iVGA_CLK)
begin
	if (cBLANK_n)
		ValforVGA <= Apixels((capturedVals[j]-32768)/32768)+239  ;
		
		if (j==254)
		    j<=0;
		else
		    j<=j+2;
	else
		j<=0;
		ValforVGA<=0;
		oldValforVGA<=0;
	
end				

// Calculate the RGB values

always@(negedge iVGA_CLK)
begin 
     oldValforVGA<=ValforVGA;
	//display the vertical guide lines
	 if (CX==63||CX==127||CX==191||CX==319||CX==383||CX==447||CX==511||CX==575)
		begin
		b_data<=8'd255;
		g_data<=8'd255;
		r_data<=8'd255;
		end
	//display the horizontal guide lines
	else if (CY==59||CY==119||CY==179||CY==239||CY==299||CY==359||CY==419)
		begin
        b_data<=8'd255;
		g_data<=8'd255;
		r_data<=8'd255;
		end
		
	else if (()&&())
	    begin
	    b_data<=8'd255;
		g_data<=8'd255;
		r_data<=8'd255;
	    end
	    
	else if (()&&())
	    begin
	    b_data<=8'd255;
		g_data<=8'd255;
		r_data<=8'd255;
	    end
	    
    else if (CX==ValforVGA)
	    begin
	    b_data<=8'd255;
		g_data<=8'd255;
		r_data<=8'd255;
	    end
	    
	//Everything else is black
	else
		begin
		b_data<=8'b0;
		g_data<=8'b0;
		r_data<=8'b0;
		end
end


//Assign the internal signals to the output ports

reg [4:0] delay_bus;
reg [4:0] delay_busv;
reg [4:0] delay_bush;

always@(posedge iVGA_CLK)
begin

	delay_bus <= {delay_bus[3:0],cBLANK_n};
	delay_bush <= {delay_bush[3:0],cHS};
	delay_busv <= {delay_busv[3:0],cVS};

end

assign oBLANK_n = delay_bus[1];
assign oHS = delay_bush[1];
assign oVS = delay_busv[1];


endmodule
