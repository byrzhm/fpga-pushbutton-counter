module bcd_counter #(
    parameter DECIMAL_NUM = 6,
    parameter BCD_WIDTH   = DECIMAL_NUM * 4
) (
    output [BCD_WIDTH-1:0] count_value,
    input clk,
    input rst,
    input ce
);
  wire [3:0] cnt_val[0:DECIMAL_NUM-1];
  wire [3:0] cnt_val_next[0:DECIMAL_NUM-1];
  wire [DECIMAL_NUM-1:0] cnt_rst;
  wire [DECIMAL_NUM-1:0] cnt_ce;

  REGISTER_R_CE #(
      .N(4),
      .INIT(4'd0)
  ) cnt0 (
      .q  (cnt_val[0]),
      .d  (cnt_val_next[0]),
      .clk(clk),
      .rst(cnt_rst[0]),
      .ce (cnt_ce[0])
  );

  assign count_value[0+:4] = cnt_val[0];
  assign cnt_val_next[0] = cnt_val[0] + 4'd1;
  assign cnt_rst[0] = (cnt_val[0] == 4'd9) & ce | rst;
  assign cnt_ce[0] = ce;

  genvar i;
  generate
    for (i = 1; i < DECIMAL_NUM; i = i + 1) begin : bcd_cnt_gen
      REGISTER_R_CE #(
          .N(4),
          .INIT(4'd0)
      ) cnt0 (
          .q  (cnt_val[i]),
          .d  (cnt_val_next[i]),
          .clk(clk),
          .rst(cnt_rst[i]),
          .ce (cnt_ce[i])
      );

      assign count_value[4*i+:4] = cnt_val[i];
      assign cnt_val_next[i] = cnt_val[i] + 4'd1;
      assign cnt_ce[i] = (cnt_val[i-1] == 4'd9) & cnt_ce[i-1];
      assign cnt_rst[i] = (cnt_val[i] == 4'd9) & cnt_ce[i] | rst;
    end
  endgenerate

endmodule
