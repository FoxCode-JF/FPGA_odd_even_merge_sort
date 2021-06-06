module BatcherSort (
	input wire [31:0] in_flattenedData,
	output wire [31:0] out_flattenedData 
);

localparam NUM_ARRAY_WIDTH = 8;
localparam NUM_BIT_SIZE = 4;

reg [NUM_BIT_SIZE-1:0] out_intermediate[NUM_ARRAY_WIDTH-1:0];
wire [NUM_BIT_SIZE-1:0] out_sortedArray_stage1[NUM_ARRAY_WIDTH-1:0];
wire [NUM_BIT_SIZE-1:0] out_sortedArray_stage2[NUM_ARRAY_WIDTH-1:0];
wire [NUM_BIT_SIZE-1:0] out_sortedArray_stage3[NUM_ARRAY_WIDTH-1:0];
wire [NUM_BIT_SIZE-1:0] out_sortedArray_stage4[NUM_ARRAY_WIDTH-1:0];

reg [31:0] out_flattenedData_tmp;

integer i = 0;

always @* begin
	for (i = 0; i < NUM_ARRAY_WIDTH; i = i + 1) begin
		out_intermediate[i] = in_flattenedData[NUM_BIT_SIZE * i +: NUM_BIT_SIZE];
	end
end

sort4 sort1234(.in_flattenedData({out_intermediate[3], out_intermediate[2], out_intermediate[1], out_intermediate[0]}),
							 .out_flattenedData({out_sortedArray_stage1[3], out_sortedArray_stage1[2], out_sortedArray_stage1[1], out_sortedArray_stage1[0]}));
sort4 sort5678(.in_flattenedData({out_intermediate[7], out_intermediate[6], out_intermediate[5], out_intermediate[4]}),
							 .out_flattenedData({out_sortedArray_stage1[7], out_sortedArray_stage1[6], out_sortedArray_stage1[5], out_sortedArray_stage1[4]}));

sort2 sort15(.in_flattenedData({out_sortedArray_stage1[4], out_sortedArray_stage1[0]}),
						 .out_flattenedData({out_sortedArray_stage2[4], out_sortedArray_stage2[0]}));
sort2 sort26(.in_flattenedData ({out_sortedArray_stage1[5], out_sortedArray_stage1[1]}), 
						 .out_flattenedData({out_sortedArray_stage2[5], out_sortedArray_stage2[1]}));
sort2 sort37(.in_flattenedData({out_sortedArray_stage1[6], out_sortedArray_stage1[2]}),
						 .out_flattenedData({out_sortedArray_stage2[6], out_sortedArray_stage2[2]}));
sort2 sort48(.in_flattenedData ({out_sortedArray_stage1[7], out_sortedArray_stage1[3]}), 
						 .out_flattenedData({out_sortedArray_stage2[7], out_sortedArray_stage2[3]}));


sort2 sort35(.in_flattenedData({out_sortedArray_stage2[4], out_sortedArray_stage2[2]}),
						 .out_flattenedData({out_sortedArray_stage3[4], out_sortedArray_stage3[2]}));
sort2 sort46(.in_flattenedData ({out_sortedArray_stage2[5], out_sortedArray_stage2[3]}), 
						 .out_flattenedData({out_sortedArray_stage3[5], out_sortedArray_stage3[3]}));


sort2 sort23(.in_flattenedData({out_sortedArray_stage3[2], out_sortedArray_stage2[1]}),
						 .out_flattenedData({out_sortedArray_stage4[2], out_sortedArray_stage4[1]}));
sort2 sort45(.in_flattenedData ({out_sortedArray_stage3[4], out_sortedArray_stage3[3]}), 
						 .out_flattenedData({out_sortedArray_stage4[4], out_sortedArray_stage4[3]}));
sort2 sort67(.in_flattenedData ({out_sortedArray_stage2[6], out_sortedArray_stage3[5]}), 
						 .out_flattenedData({out_sortedArray_stage4[6], out_sortedArray_stage4[5]}));

assign out_flattenedData = {
			 out_sortedArray_stage2[7], out_sortedArray_stage4[6],
			 out_sortedArray_stage4[5], out_sortedArray_stage4[4],
			 out_sortedArray_stage4[3], out_sortedArray_stage4[2], 
			 out_sortedArray_stage4[1], out_sortedArray_stage2[0]};

endmodule // BatcherSort

module comparator4 (
	input wire [3:0] A, B,   // compared 4-bit unsigned numbers
 	output reg gt, lt, eq
);

 // wire cmp_eq, cmp_lt, cmp_gt;
always @* begin
	if (A > B) begin
 		gt = 1;
 		eq = 0;
 		lt = 0;
 	end 
 	else if (A == B) begin
 		gt = 0;
 		eq = 1;
 		lt = 0;
 	end
 	else begin
 		gt = 0;
 		eq = 0;
 		lt = 1;
 	end

end
	
endmodule // comparator4

module sort2 (
	input wire [7:0] in_flattenedData, // flattened array of unsorted data
	output wire [7:0] out_flattenedData	
);

reg [3:0] in_notSortedArray[1:0];
reg [3:0] out_sortedArray[1:0];

always @* begin
	in_notSortedArray[0] = in_flattenedData[3:0];
	in_notSortedArray[1] = in_flattenedData[7:4];
end

wire gt12, eq12, lt12;
comparator4 cmp4_12(.A (in_notSortedArray[0]), .B (in_notSortedArray[1]), .gt(gt12), .eq(eq12), .lt(lt12));

always @(gt12, eq12, lt12, in_notSortedArray) begin
	if (gt12 == 1) begin
		out_sortedArray[0] = in_notSortedArray[1];
		out_sortedArray[1] = in_notSortedArray[0]; 
	end
	else begin
		out_sortedArray[0] = in_notSortedArray[0];
		out_sortedArray[1] = in_notSortedArray[1];
	end
	// out_flattenedData[7:0] <= {out_sortedArray[1], out_sortedArray[0]};
end
assign out_flattenedData[7:0] = {out_sortedArray[1], out_sortedArray[0]};

endmodule // sort2

module sort4 (
	input wire [15:0] in_flattenedData,
	output wire [15:0] out_flattenedData
);

localparam NUM_ARRAY_WIDTH = 4;
localparam NUM_BIT_SIZE = 4;

reg [NUM_BIT_SIZE-1:0] out_intermediate[NUM_ARRAY_WIDTH-1:0];
wire [NUM_BIT_SIZE-1:0] out_sortedArray_stage1[NUM_ARRAY_WIDTH-1:0];
wire [NUM_BIT_SIZE-1:0] out_sortedArray_stage2[NUM_ARRAY_WIDTH-1:0];
wire [NUM_BIT_SIZE-1:0] out_sortedArray_stage3[NUM_ARRAY_WIDTH-1:0];

integer i = 0;
always @* begin
	for (i = 0; i < NUM_ARRAY_WIDTH; i = i + 1) begin
		out_intermediate[i] = in_flattenedData[NUM_BIT_SIZE * i +: NUM_BIT_SIZE];
	end
end

sort2 sort12(.in_flattenedData ({out_intermediate[1], out_intermediate[0]}), .out_flattenedData({out_sortedArray_stage1[1], out_sortedArray_stage1[0]}));
sort2 sort34(.in_flattenedData ({out_intermediate[3], out_intermediate[2]}), .out_flattenedData({out_sortedArray_stage1[3], out_sortedArray_stage1[2]}));

sort2 sort13(.in_flattenedData ({out_sortedArray_stage1[2], out_sortedArray_stage1[0]}), .out_flattenedData({out_sortedArray_stage2[2], out_sortedArray_stage2[0]}));
sort2 sort24(.in_flattenedData ({out_sortedArray_stage1[3], out_sortedArray_stage1[1]}), .out_flattenedData({out_sortedArray_stage2[3], out_sortedArray_stage2[1]}));

sort2 sort23(.in_flattenedData ({out_sortedArray_stage2[2], out_sortedArray_stage2[1]}), .out_flattenedData({out_sortedArray_stage3[2], out_sortedArray_stage3[1]}));

assign out_flattenedData = {out_sortedArray_stage2[3], out_sortedArray_stage3[2], out_sortedArray_stage3[1], out_sortedArray_stage2[0]};

endmodule // sort4

