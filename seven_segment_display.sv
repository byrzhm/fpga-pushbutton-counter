module seven_segment_display #(
    parameter DECIMAL_NUM = 6,
    parameter BCD_WIDTH   = DECIMAL_NUM * 4,
    parameter SEG_WIDTH   = DECIMAL_NUM * 7
) (
    output reg [6:0] led_out,
    output reg [DECIMAL_NUM-1:0] led_sel,
    input [BCD_WIDTH-1:0] bcd_in,
    input clk
);

  wire [SEG_WIDTH-1:0] seg_out;
  genvar i;
  generate
    for (i = 0; i < DECIMAL_NUM; i = i + 1) begin : seven_segment_display_inst_gen
      seven_segment seven_segment_inst (
          .seg_out(seg_out[7*i+:7]),
          .seg_in (bcd_in[4*i+:4])
      );  // indexed part-select
    end
  endgenerate

  reg dri_clk = 0;
  reg [7:0] dri_cnt = 8'd0;
  always @(posedge clk) begin
    if (dri_cnt == 8'd99) begin
      dri_cnt <= 8'd0;
      dri_clk <= ~dri_clk;
    end else begin
      dri_cnt <= dri_cnt + 8'd1;
      dri_clk <= dri_clk;
    end
  end

  localparam COUNT_WIDTH = $clog2(DECIMAL_NUM);
  wire [COUNT_WIDTH-1:0] cnt_val, cnt_val_next;
  wire cnt_rst = (cnt_val == DECIMAL_NUM - 1);
  REGISTER_R #(
      .N(COUNT_WIDTH)
  ) cnt_to (
      .q  (cnt_val),
      .d  (cnt_val_next),
      .clk(dri_clk),
      .rst(cnt_rst)
  );
  assign cnt_val_next = cnt_val + 1;

  always_comb begin
    led_out = seg_out[7*cnt_val+:7];
    led_sel = ~(1 << cnt_val);
  end

endmodule
