## Switches (A and B)
set_property -dict { PACKAGE_PIN J15 IOSTANDARD LVCMOS33 } [get_ports { A[0] }];    # IO_L24N_T3_RS0_15 Sch=A[0]
set_property -dict { PACKAGE_PIN L16 IOSTANDARD LVCMOS33 } [get_ports { A[1] }];    # IO_L3N_T0_DQS_EMCCLK_14 Sch=A[1]
set_property -dict { PACKAGE_PIN M13 IOSTANDARD LVCMOS33 } [get_ports { A[2] }];    # IO_L6N_T0_D08_VREF_14 Sch=A[2]
set_property -dict { PACKAGE_PIN R15 IOSTANDARD LVCMOS33 } [get_ports { A[3] }];    # IO_L13N_T2_MRCC_14 Sch=A[3]
set_property -dict { PACKAGE_PIN R17 IOSTANDARD LVCMOS33 } [get_ports { A[4] }];    # IO_L12N_T1_MRCC_14 Sch=A[4]
set_property -dict { PACKAGE_PIN T18 IOSTANDARD LVCMOS33 } [get_ports { A[5] }];    # IO_L7N_T1_D10_14 Sch=A[5]

set_property -dict { PACKAGE_PIN U18 IOSTANDARD LVCMOS33 } [get_ports { B[0] }];    # IO_L24N_T3_34 Sch=B[0]
set_property -dict { PACKAGE_PIN R13 IOSTANDARD LVCMOS33 } [get_ports { B[1] }];    # IO_L5N_T0_D07_14 Sch=B[1]
set_property -dict { PACKAGE_PIN T8  IOSTANDARD LVCMOS33 } [get_ports { B[2] }];    # IO_L17N_T2_A13_D29_14 Sch=B[2]
set_property -dict { PACKAGE_PIN U8  IOSTANDARD LVCMOS33 } [get_ports { B[3] }];    # IO_25_34 Sch=B[3]
set_property -dict { PACKAGE_PIN R16 IOSTANDARD LVCMOS33 } [get_ports { B[4] }];    # IO_L15P_T2_DQS_RDWR_B_14 Sch=B[4]
set_property -dict { PACKAGE_PIN T13 IOSTANDARD LVCMOS33 } [get_ports { B[5] }];    # IO_L23P_T3_A03_D19_14 Sch=B[5]

## ALU op (rename from OPERATION -> alu_op)
set_property -dict { PACKAGE_PIN H6  IOSTANDARD LVCMOS33 } [get_ports { alu_op[0] }];
set_property -dict { PACKAGE_PIN U12 IOSTANDARD LVCMOS33 } [get_ports { alu_op[1] }];
set_property -dict { PACKAGE_PIN U11 IOSTANDARD LVCMOS33 } [get_ports { alu_op[2] }];
set_property -dict { PACKAGE_PIN V10 IOSTANDARD LVCMOS33 } [get_ports { alu_op[3] }];

## Clock
set_property -dict { PACKAGE_PIN E3  IOSTANDARD LVCMOS33 } [get_ports { Clk }];
create_clock -name sys_clk -period 10.000 [get_ports { Clk }]

## 7-seg segments
set_property -dict { PACKAGE_PIN T10 IOSTANDARD LVCMOS33 } [get_ports { segment_a }]; # IO_L24N_T3_A00_D16_14
set_property -dict { PACKAGE_PIN R10 IOSTANDARD LVCMOS33 } [get_ports { segment_b }]; # IO_25_14
set_property -dict { PACKAGE_PIN K16 IOSTANDARD LVCMOS33 } [get_ports { segment_c }]; # IO_25_15
set_property -dict { PACKAGE_PIN K13 IOSTANDARD LVCMOS33 } [get_ports { segment_d }]; # IO_L17P_T2_A26_15
set_property -dict { PACKAGE_PIN P15 IOSTANDARD LVCMOS33 } [get_ports { segment_e }]; # IO_L13P_T2_MRCC_14
set_property -dict { PACKAGE_PIN T11 IOSTANDARD LVCMOS33 } [get_ports { segment_f }]; # IO_L19P_T3_A10_D26_14
set_property -dict { PACKAGE_PIN L18 IOSTANDARD LVCMOS33 } [get_ports { segment_g }]; # IO_L4P_T0_D04_14
set_property -dict { PACKAGE_PIN H15 IOSTANDARD LVCMOS33 } [get_ports { segment_dp }];# IO_L19N_T3_A21_VREF_15

## 7-seg anodes
set_property -dict { PACKAGE_PIN J17 IOSTANDARD LVCMOS33 } [get_ports { AN[0] }];
set_property -dict { PACKAGE_PIN J18 IOSTANDARD LVCMOS33 } [get_ports { AN[1] }];
set_property -dict { PACKAGE_PIN T9  IOSTANDARD LVCMOS33 } [get_ports { AN[2] }];
set_property -dict { PACKAGE_PIN J14 IOSTANDARD LVCMOS33 } [get_ports { AN[3] }];
set_property -dict { PACKAGE_PIN P14 IOSTANDARD LVCMOS33 } [get_ports { AN[4] }];
set_property -dict { PACKAGE_PIN T14 IOSTANDARD LVCMOS33 } [get_ports { AN[5] }];
set_property -dict { PACKAGE_PIN K2  IOSTANDARD LVCMOS33 } [get_ports { AN[6] }];
set_property -dict { PACKAGE_PIN U13 IOSTANDARD LVCMOS33 } [get_ports { AN[7] }];
