
module counter ( clock, in, latch, dec, zero );
  input [3:0] in;
  input clock, latch, dec;
  output zero;
  wire   \U4/DATA1_0 , \U4/DATA1_1 , \U4/DATA1_2 , \U4/DATA1_3 , \sub_42/A[0] ,
         \sub_42/A[1] , \sub_42/A[2] , n33, n34, n35, n36, n37, n38, n39, n40,
         n41, n42, n43, n44, n45, n46, n47, n48, n49, n50, n51, n56, n57, n58,
         n59;
  assign \U4/DATA1_0  = in[0];
  assign \U4/DATA1_1  = in[1];
  assign \U4/DATA1_2  = in[2];
  assign \U4/DATA1_3  = in[3];

  DFF_X1 \value_reg[0]  ( .D(n59), .CK(clock), .Q(\sub_42/A[0] ), .QN(n51) );
  DFF_X1 \value_reg[3]  ( .D(n58), .CK(clock), .QN(n42) );
  DFF_X1 \value_reg[2]  ( .D(n57), .CK(clock), .Q(\sub_42/A[2] ), .QN(n41) );
  DFF_X1 \value_reg[1]  ( .D(n56), .CK(clock), .Q(\sub_42/A[1] ) );
  OAI21_X1 U4 ( .B1(latch), .B2(n34), .A(n35), .ZN(n56) );
  NAND2_X1 U5 ( .A1(latch), .A2(\U4/DATA1_1 ), .ZN(n35) );
  AOI21_X1 U6 ( .B1(\sub_42/A[1] ), .B2(n36), .A(n37), .ZN(n34) );
  OAI21_X1 U7 ( .B1(latch), .B2(n38), .A(n39), .ZN(n57) );
  NAND2_X1 U8 ( .A1(\U4/DATA1_2 ), .A2(latch), .ZN(n39) );
  INV_X1 U9 ( .A(n40), .ZN(n38) );
  OAI22_X1 U10 ( .A1(n41), .A2(n37), .B1(n42), .B2(n43), .ZN(n40) );
  NOR2_X1 U11 ( .A1(n36), .A2(\sub_42/A[1] ), .ZN(n37) );
  OAI21_X1 U13 ( .B1(n42), .B2(n44), .A(n45), .ZN(n58) );
  NAND2_X1 U14 ( .A1(\U4/DATA1_3 ), .A2(latch), .ZN(n45) );
  NAND2_X1 U15 ( .A1(n43), .A2(n46), .ZN(n44) );
  NAND2_X1 U16 ( .A1(dec), .A2(n47), .ZN(n43) );
  INV_X1 U17 ( .A(n48), .ZN(n59) );
  AOI22_X1 U18 ( .A1(n49), .A2(n46), .B1(\U4/DATA1_0 ), .B2(latch), .ZN(n48)
         );
  INV_X1 U19 ( .A(latch), .ZN(n46) );
  OAI21_X1 U20 ( .B1(n50), .B2(n51), .A(n36), .ZN(n49) );
  NAND2_X1 U21 ( .A1(n50), .A2(n51), .ZN(n36) );
  AND2_X1 U23 ( .A1(dec), .A2(n33), .ZN(n50) );
  NAND2_X1 U24 ( .A1(n47), .A2(n42), .ZN(n33) );
  NOR3_X1 U26 ( .A1(\sub_42/A[1] ), .A2(\sub_42/A[2] ), .A3(\sub_42/A[0] ), 
        .ZN(n47) );
  INV_X4 U27 ( .A(n33), .ZN(zero) );
endmodule

