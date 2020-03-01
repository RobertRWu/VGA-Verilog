//////////////////////////////////////////////////////////////////////////////////
// Engineer: Robert Wu
// Create Date: 07/11/2019
// Project Name: VGA
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

module VGA_control(
    input clk_25m,
    input rst,
    output reg [9:0] h_count,
    output reg [9:0] v_count
    );
	
	parameter H_FRONT = 16;                               //Horizontal front porch
    parameter H_SYNC = 96;                               //Horizontal sync pulse
    parameter H_BACK = 48;                                //Horizontal back porch
    parameter H_ACT = 640;                                //Horizontal activate pixels 
    parameter H_TOTAL = H_FRONT+H_SYNC+H_BACK+H_ACT;      //Horizontal total pixels
    
    parameter V_FRONT = 11;                                //Vertical front porch
    parameter V_SYNC = 2;                                 //Vertical sync pulse
    parameter V_BACK = 31;                                //Vertical back porch
    parameter V_ACT = 480;                                //Vertical activate pixels
    parameter V_TOTAL = V_FRONT+V_SYNC+V_BACK+V_ACT;      //Vertical total pixels

	
	//horizontal
    always @(posedge clk_25m or posedge rst)
    begin
        if(rst)
            h_count <= 0;
        else begin
            if(h_count < H_TOTAL - 1)
                h_count <= h_count + 1;
            else
                h_count <= 0;
        end
    end

    //vertical
    always @(posedge clk_25m or posedge rst)
    begin
        if(rst)
            v_count <= 0;
        else if(h_count == H_TOTAL - 1) begin
            if(v_count < V_TOTAL - 1)
                v_count <= v_count + 1;
            else
                v_count <= 0;
        end
    end
	
endmodule
