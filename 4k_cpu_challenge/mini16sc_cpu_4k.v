// SPDX-License-Identifier: BSD-2-Clause
// Copyright (c) 2024 miya All rights reserved.
module mini16sc_cpu
#(parameter WIDTH_I = 16, WIDTH_D = 16, DEPTH_I = 8, DEPTH_D = 8, DEPTH_REG = 5)
(
input clk,
input reset,
input soft_reset,
output wire [C-1:0] mem_i_r_addr,
input [A-1:0] mem_i_r_data,
output wire [D-1:0] mem_d_r_addr,
input [B-1:0] mem_d_r_data,
output wire [D-1:0] mem_d_w_addr,
output wire [B-1:0] mem_d_w_data,
output wire mem_d_we
);

localparam A = WIDTH_I, B = WIDTH_D, C = DEPTH_I, D = DEPTH_D, E = DEPTH_REG;
wire a = clk;
wire b = reset;
wire c = soft_reset;
wire [A-1:0] e = mem_i_r_data;
wire [B-1:0] g = mem_d_r_data;
reg [C-1:0] d;
reg [D-1:0] f, h;
reg [B-1:0] u0;
reg j;
assign mem_i_r_addr = d;
assign mem_d_r_addr = f;
assign mem_d_w_addr = h;
assign mem_d_w_data = u0;
assign mem_d_we = j;

localparam F = 1'b1, G = 1'b0, H = 1'd1, I = 1'd0, J = {B{1'b1}}, K = $clog2(B), L = 5, M = 3, N = 1'd1, O = 0, P = 1;

reg [A-1:0] k;
wire [L-1:0] l, m;
wire [10:0] n;
wire o;
wire [4:0] p;
reg q, x, s0, t0;
reg [C-1:0] r;
wire [B-1:0] v;
reg [E-1:0] w;
reg [B-1:0] s, t, u, y, z, a0, b0, c0, d0, e0, f0, g0, h0, e0a, j0, k0, l0, m0, n0, o0;
reg [B-1:0] p0 [0:M];
reg [B-1:0] q0 [0:(1<<E)-1];
reg [B-1:0] r0 [0:3];
integer i;

assign l = k[15:11];
assign m = k[10:6];
assign o = k[5];
assign p = k[4:0];
assign n = k[15:5];

always @*
begin
t = q0[l];
u = q0[m];
s0 = (u != I);
t0 = (u[B-1] == 1'b0);

case (p)
5'h2: w = O;
5'h16: w = P;
default: w = l;
endcase
if ((p[4] == F) || ((p == 5'h2) && (s0 == F)))
x = F;
else
x = G;

if ((p == 5'h3) || ((p == 5'h4) && (t != I)) || (p == 5'h18))
begin
q = F;
r = u;
end
else
begin
q = G;
r = I;
end

y = t;
if (o == F)
z = $signed(m);
else
z = u;

case (p)
5'h10: s = y + z;
5'h11: s = y - z;
5'h12: s = y & z;
5'h13: s = y | z;
5'h14: s = y ^ z;
5'h15: s = z;
5'h2: s = y;
5'h17: s = r0[z];
5'h18: s = d + N;
5'h19: s = g;
5'h16: s = n;
5'h1a:
begin
if (s0 == F)
s = {B{F}};
else
s = {B{G}};
end
5'h1b:
begin
if (t0 == F)
s = {B{F}};
else
s = {B{G}};
end
default: s = I;
endcase
end

always @(posedge a)
begin
if (x == 1'b1)
begin
q0[w] <= s;
end

if (b == F)
begin
d <= I;
end
else
begin
if (c == F)
begin
d <= I;
end
else
begin
if (q == F)
begin
d <= r;
end
else
begin
d <= d + H;
end
end
end

if (b == F)
k <= I;
else
k <= e;

if (p == 5'h19)
f <= u;
if (p == 5'h1)
h <= t;
if (p == 5'h1)
u0 <= z;
if (p == 5'h1)
j <= F;
else
j <= G;

if (p == 5'h5)
begin
n0 <= y;
o0 <= z;
end
p0[0] <= n0 * o0;
for (i = 0; i < M; i = i + 1)
begin: gen_p0
p0[i + 1] <= p0[i];
end
r0[3] <= p0[M];

if (p == 5'h7)
begin
b0 <= y;
c0 <= z;
end
d0 <= b0 << c0;
r0[0] <= d0;

if (p == 5'h6)
begin
f0 <= y;
g0 <= z;
end
h0 <= f0 >> g0;
r0[1] <= h0;

if (p == 5'h8)
begin
j0 <= y;
k0 <= z;
end
l0 <= $signed(j0) >>> k0;
r0[2] <= l0;
end
endmodule
