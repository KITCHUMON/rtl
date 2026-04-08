`timescale 1ns/1ps
module OR ( input A,
           input B,
           output Y);
  always @(*) begin
    Y= A|B;
  end
endmodule
  
