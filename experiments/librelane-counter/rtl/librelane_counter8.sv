// Small synthesizable design used to study the LibreLane flow.
module librelane_counter8 (
  input  logic       clk_i,
  input  logic       rst_ni,
  input  logic       enable_i,
  output logic [7:0] count_o
);

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      count_o <= 8'h00;
    end else if (enable_i) begin
      count_o <= count_o + 8'h01;
    end
  end

endmodule

