//////////////////////////////////////////////////////////////////////////////////
// Engineer: Robert Wu
// Create Date: 07/11/2019
// Project Name: VGA
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

module vga_display(
    input clk_25m,
	input rst,
    input [159:0] data,
    output h_sync_s,
    output v_sync_s,
    output reg [3:0] R,
    output reg [3:0] G,
    output reg [3:0] B
    );

	//parameter definition
	parameter H_FRONT = 16;                               //Horizontal front porch
	parameter H_SYNC = 96;                                //Horizontal sync pulse
	parameter H_BACK = 48;                                //Horizontal back porch
	parameter H_ACT = 640;                                //Horizontal activate pixels 
    parameter H_TOTAL = H_FRONT+H_SYNC+H_BACK+H_ACT;      //Horizontal total pixels

	parameter V_FRONT = 10;                               //Vertical front porch
	parameter V_SYNC = 2;                                 //Vertical sync pulse
	parameter V_BACK = 33;                                //Vertical back porch
	parameter V_ACT = 480;                                //Vertical activate pixels
	parameter V_TOTAL = V_FRONT+V_SYNC+V_BACK+V_ACT;      //Vertical total pixels

    parameter TEXT_X1 = 88;
    parameter TEXT_Y1 = 170;
    parameter TEXT_X2 = 216;
    parameter TEXT_Y2 = 330;
    parameter TEXT_XL = (TEXT_X2 - TEXT_X1);
    parameter TEXT_YL = (TEXT_Y2 - TEXT_Y1);

	wire [9:0] h_count;
	wire [9:0] v_count;

	wire ena_h;
	wire ena_v; 
	wire ena;

	VGA_control VGA_controller(
        .clk_25m(clk_25m), 
        .rst(rst), 
        .h_count(h_count), 
        .v_count(v_count)
    );

    assign ena_h = ((h_count >= H_SYNC + H_BACK) && (h_count < H_TOTAL - H_FRONT)) ? 1 : 0;
    assign ena_v = ((v_count >= V_SYNC + V_BACK) && (v_count < V_TOTAL - V_FRONT)) ? 1 : 0; 
    assign ena = (ena_h && ena_v) ? 1 : 0;

    assign h_sync_s = (h_count < H_SYNC) ? 0 : 1;      //VGA hontal sync signal
    assign v_sync_s = (v_count < V_SYNC) ? 0 : 1;     //VGA vical sync signal

    //determine the position of the text
    wire [10:0] text_h;
    wire [10:0] text_v;

    assign text_h = ((h_count >= H_SYNC + H_BACK + TEXT_X1) && (h_count < H_SYNC + H_BACK + TEXT_X2)) ? 
                     (h_count - H_SYNC - H_BACK - TEXT_X1) : TEXT_XL; 
    assign text_v = ((v_count >= V_SYNC + V_BACK + TEXT_Y1) && (v_count < V_SYNC + V_BACK + TEXT_Y2)) ? 
                     (v_count - V_SYNC - V_BACK - TEXT_Y1) : TEXT_YL;
    
    wire [5:0] dcnt;
    assign dcnt = ((h_count >= H_SYNC + H_BACK + TEXT_X1) && (h_count < H_SYNC + H_BACK + TEXT_X2) 
                   && (v_count >= V_SYNC + V_BACK + TEXT_Y1) && (v_count < V_SYNC + V_BACK + TEXT_Y2)) ?
                  ((((v_count - V_SYNC - V_BACK - TEXT_Y1) >> 5) << 3) + ((h_count - H_SYNC - H_BACK - TEXT_X1) >> 4)): 0;

    wire [2:0] h_index; 
    wire[3:0] v_index;

    assign h_index = ((h_count >= H_SYNC + H_BACK + TEXT_X1) && (h_count < H_SYNC + H_BACK + TEXT_X2)) ? 
                     (((h_count - H_SYNC - H_BACK - TEXT_X1) & 4'b1111) >> 1) : 0;
    assign v_index = ((v_count >= V_SYNC + V_BACK + TEXT_Y1) && (v_count < V_SYNC + V_BACK + TEXT_Y2)) ? 
                     (((v_count - V_SYNC - V_BACK - TEXT_Y1) & 5'b11111) >> 1) : 0;


    //extract the char matrix
    wire point;
    VGA_char vga_char(
        .rst(rst),
        .h_index(h_index), 
        .v_index(v_index), 
        .a_index(data[((((dcnt >> 'd3) + 'd1) << 'd5) - (((dcnt & 'b111) << 'd2) + 1)) -: 4]), 
        .point(point)
    );

    //determine the RGB
    always @(*)
    begin
        if(ena) begin
            if (text_h < TEXT_XL && text_v < TEXT_YL) begin
                if(point) begin
                    R <= 4'hf; 
                    G <= 4'hf; 
                    B <= 4'hf;
                end
                else begin
                    R <= 0; 
                    G <= 0; 
                    B <= 0;
                end
            end
            else begin
                R <= 0; 
                G <= 0; 
                B <= 0;
            end
        end
        else begin
            R <= 2;
            G <= 2; //消隐区设置RBG，亮度调整，越低越亮
            B <= 2;
        end
    end

endmodule
