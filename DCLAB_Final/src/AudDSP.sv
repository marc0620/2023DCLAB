module AudDSP(
	input i_rst_n,
	input i_clk,
	input i_start,
	input i_daclrck,
	input [6:0] i_shift,
    input [10:0] i_bit_test,
	input [15:0] i_sram_data,
    input [15:0] carrier_data,
	output[15:0] o_dac_data
);

    //parameters
    localparam S_IDLE = 0;
    localparam S_PLAY = 1;
    //localparam end_addr = 1024000;

    //registers and wires
    logic [1:0]  state_r, state_w;
    logic signed [15:0] o_dac_data_r, o_dac_data_w;
    logic        prev_daclrck_r, prev_daclrck_w;
	logic signed [15:0] chosen_data,chosen_filter_data,chosen_carrier_filter_data;
	logic signed[15:0] IIR_audio_out_300Hz,IIR_audio_out_350Hz,IIR_audio_out_400Hz,IIR_audio_out_450Hz,IIR_audio_out_500Hz,IIR_audio_out_560Hz,IIR_audio_out_620Hz,IIR_audio_out_680Hz,IIR_audio_out_750Hz,IIR_audio_out_820Hz,IIR_audio_out_888Hz,IIR_audio_out_964Hz,IIR_audio_out_1040Hz,IIR_audio_out_1125Hz,IIR_audio_out_1212Hz,IIR_audio_out_1300Hz,IIR_audio_out_1400Hz,IIR_audio_out_1500Hz,IIR_audio_out_1600Hz,IIR_audio_out_1700Hz,IIR_audio_out_1820Hz,IIR_audio_out_1944Hz,IIR_audio_out_2070Hz,IIR_audio_out_2200Hz,IIR_audio_out_2340Hz,IIR_audio_out_2480Hz,IIR_audio_out_2630Hz,IIR_audio_out_2800Hz,IIR_audio_out_3000Hz,IIR_audio_out_3130Hz,IIR_audio_out_3300Hz,IIR_audio_out_3500Hz;
    logic signed[15:0] carrier_audio_out_300Hz,carrier_audio_out_350Hz,carrier_audio_out_400Hz,carrier_audio_out_450Hz,carrier_audio_out_500Hz,carrier_audio_out_560Hz,carrier_audio_out_620Hz,carrier_audio_out_680Hz,carrier_audio_out_750Hz,carrier_audio_out_820Hz,carrier_audio_out_888Hz,carrier_audio_out_964Hz,carrier_audio_out_1040Hz,carrier_audio_out_1125Hz,carrier_audio_out_1212Hz,carrier_audio_out_1300Hz,carrier_audio_out_1400Hz,carrier_audio_out_1500Hz,carrier_audio_out_1600Hz,carrier_audio_out_1700Hz,carrier_audio_out_1820Hz,carrier_audio_out_1944Hz,carrier_audio_out_2070Hz,carrier_audio_out_2200Hz,carrier_audio_out_2340Hz,carrier_audio_out_2480Hz,carrier_audio_out_2630Hz,carrier_audio_out_2800Hz,carrier_audio_out_3000Hz,carrier_audio_out_3130Hz,carrier_audio_out_3300Hz,carrier_audio_out_3500Hz;
    logic signed[15:0] abs_IIR_audio_out_300Hz,abs_IIR_audio_out_350Hz,abs_IIR_audio_out_400Hz,abs_IIR_audio_out_450Hz,abs_IIR_audio_out_500Hz,abs_IIR_audio_out_560Hz,abs_IIR_audio_out_620Hz,abs_IIR_audio_out_680Hz,abs_IIR_audio_out_750Hz,abs_IIR_audio_out_820Hz,abs_IIR_audio_out_888Hz,abs_IIR_audio_out_964Hz,abs_IIR_audio_out_1040Hz,abs_IIR_audio_out_1125Hz,abs_IIR_audio_out_1212Hz,abs_IIR_audio_out_1300Hz,abs_IIR_audio_out_1400Hz,abs_IIR_audio_out_1500Hz,abs_IIR_audio_out_1600Hz,abs_IIR_audio_out_1700Hz,abs_IIR_audio_out_1820Hz,abs_IIR_audio_out_1944Hz,abs_IIR_audio_out_2070Hz,abs_IIR_audio_out_2200Hz,abs_IIR_audio_out_2340Hz,abs_IIR_audio_out_2480Hz,abs_IIR_audio_out_2630Hz,abs_IIR_audio_out_2800Hz,abs_IIR_audio_out_3000Hz,abs_IIR_audio_out_3130Hz,abs_IIR_audio_out_3300Hz,abs_IIR_audio_out_3500Hz;
    // logic signed [15:0] IIR_lowpass_2000Hz;


    logic lrclk_posedge, lrclk_negedge;
    assign lrclk_posedge = (~prev_daclrck_r) && i_daclrck;
    assign lrclk_negedge = prev_daclrck_r && (~i_daclrck);

	
    //output
    assign o_dac_data=o_dac_data_r;
    assign o_state=state_r;
    //combinational circuit
	
	// always_comb begin
    //     case(i_shift[0])
    //         1'd0:    chosen_data = i_sram_data;
    //         default: chosen_data = chosen_filter_data;
    //     endcase
    // end
    logic signed [15:0] chosen_multi_data;
    logic signed [15:0] chosen_added_all;
    always_comb begin
        case({i_shift[6],i_shift[0]})
            2'd0:    chosen_data = i_sram_data;
            2'd1:    chosen_data = chosen_multi_data;
            2'd2:    chosen_data = chosen_added_all;
            default: chosen_data = chosen_filter_data;
        endcase
    end

    // IIR chosen
    always_comb begin
        case(i_shift[5:1]) 
            5'd0:   chosen_filter_data = IIR_audio_out_300Hz;
            5'd1:   chosen_filter_data = IIR_audio_out_350Hz;
            5'd2:   chosen_filter_data = IIR_audio_out_400Hz;
            5'd3:   chosen_filter_data = IIR_audio_out_450Hz;
            5'd4:   chosen_filter_data = IIR_audio_out_500Hz;
            5'd5:   chosen_filter_data = IIR_audio_out_560Hz;
            5'd6:   chosen_filter_data = IIR_audio_out_620Hz;
            5'd7:   chosen_filter_data = IIR_audio_out_680Hz;
            5'd8:   chosen_filter_data = IIR_audio_out_750Hz;
            5'd9:   chosen_filter_data = IIR_audio_out_820Hz;
            5'd10:  chosen_filter_data = IIR_audio_out_888Hz;
            5'd11:  chosen_filter_data = IIR_audio_out_964Hz;
            5'd12:  chosen_filter_data = IIR_audio_out_1040Hz;
            5'd13:  chosen_filter_data = IIR_audio_out_1125Hz;
            5'd14:  chosen_filter_data = IIR_audio_out_1212Hz;
            5'd15:  chosen_filter_data = IIR_audio_out_1300Hz;
            5'd16:  chosen_filter_data = IIR_audio_out_1400Hz;
            5'd17:  chosen_filter_data = IIR_audio_out_1500Hz;
            5'd18:  chosen_filter_data = IIR_audio_out_1600Hz;
            5'd19:  chosen_filter_data = IIR_audio_out_1700Hz;
            5'd20:  chosen_filter_data = IIR_audio_out_1820Hz;
            5'd21:  chosen_filter_data = IIR_audio_out_1944Hz;
            5'd22:  chosen_filter_data = IIR_audio_out_2070Hz;
            5'd23:  chosen_filter_data = IIR_audio_out_2200Hz;
            5'd24:  chosen_filter_data = IIR_audio_out_2340Hz;
            5'd25:  chosen_filter_data = IIR_audio_out_2480Hz;
            5'd26:  chosen_filter_data = IIR_audio_out_2630Hz;
            5'd27:  chosen_filter_data = IIR_audio_out_2800Hz;
            5'd28:  chosen_filter_data = IIR_audio_out_3000Hz;
            5'd29:  chosen_filter_data = IIR_audio_out_3130Hz;
            5'd30:  chosen_filter_data = IIR_audio_out_3300Hz;
            5'd31:  chosen_filter_data = IIR_audio_out_3500Hz;
            
        endcase
    end

    logic signed [31:0] multi_300, multi_350, multi_400, multi_450, multi_500, multi_560, multi_620, multi_680, multi_750, multi_820, multi_888, multi_964, multi_1040, multi_1125, multi_1212, multi_1300, multi_1400, multi_1500, multi_1600, multi_1700, multi_1820, multi_1944, multi_2070, multi_2200, multi_2340, multi_2480, multi_2630, multi_2800, multi_3000, multi_3130, multi_3300, multi_3500;
    logic signed [15:0] multi_trun_300, multi_trun_350, multi_trun_400, multi_trun_450, multi_trun_500, multi_trun_560, multi_trun_620, multi_trun_680, multi_trun_750, multi_trun_820, multi_trun_888, multi_trun_964, multi_trun_1040, multi_trun_1125, multi_trun_1212, multi_trun_1300, multi_trun_1400, multi_trun_1500, multi_trun_1600, multi_trun_1700, multi_trun_1820, multi_trun_1944, multi_trun_2070, multi_trun_2200, multi_trun_2340, multi_trun_2480, multi_trun_2630, multi_trun_2800, multi_trun_3000, multi_trun_3130, multi_trun_3300, multi_trun_3500;
    assign multi_300 = abs_IIR_audio_out_300Hz * carrier_audio_out_300Hz;
    assign multi_350 = abs_IIR_audio_out_350Hz * carrier_audio_out_350Hz;
    assign multi_400 = abs_IIR_audio_out_400Hz * carrier_audio_out_400Hz;
    assign multi_450 = abs_IIR_audio_out_450Hz * carrier_audio_out_450Hz;
    assign multi_500 = abs_IIR_audio_out_500Hz * carrier_audio_out_500Hz;
    assign multi_560 = abs_IIR_audio_out_560Hz * carrier_audio_out_560Hz;
    assign multi_620 = abs_IIR_audio_out_620Hz * carrier_audio_out_620Hz;
    assign multi_680 = abs_IIR_audio_out_680Hz * carrier_audio_out_680Hz;
    assign multi_750 = abs_IIR_audio_out_750Hz * carrier_audio_out_750Hz;
    assign multi_820 = abs_IIR_audio_out_820Hz * carrier_audio_out_820Hz;
    assign multi_888 = abs_IIR_audio_out_888Hz * carrier_audio_out_888Hz;
    assign multi_964 = abs_IIR_audio_out_964Hz * carrier_audio_out_964Hz;
    assign multi_1040 = abs_IIR_audio_out_1040Hz * carrier_audio_out_1040Hz;
    assign multi_1125 = abs_IIR_audio_out_1125Hz * carrier_audio_out_1125Hz;
    assign multi_1212 = abs_IIR_audio_out_1212Hz * carrier_audio_out_1212Hz;
    assign multi_1300 = abs_IIR_audio_out_1300Hz * carrier_audio_out_1300Hz;
    assign multi_1400 = abs_IIR_audio_out_1400Hz * carrier_audio_out_1400Hz;
    assign multi_1500 = abs_IIR_audio_out_1500Hz * carrier_audio_out_1500Hz;
    assign multi_1600 = abs_IIR_audio_out_1600Hz * carrier_audio_out_1600Hz;
    assign multi_1700 = abs_IIR_audio_out_1700Hz * carrier_audio_out_1700Hz;
    assign multi_1820 = abs_IIR_audio_out_1820Hz * carrier_audio_out_1820Hz;
    assign multi_1944 = abs_IIR_audio_out_1944Hz * carrier_audio_out_1944Hz;
    assign multi_2070 = abs_IIR_audio_out_2070Hz * carrier_audio_out_2070Hz;
    assign multi_2200 = abs_IIR_audio_out_2200Hz * carrier_audio_out_2200Hz;
    assign multi_2340 = abs_IIR_audio_out_2340Hz * carrier_audio_out_2340Hz;
    assign multi_2480 = abs_IIR_audio_out_2480Hz * carrier_audio_out_2480Hz;
    assign multi_2630 = abs_IIR_audio_out_2630Hz * carrier_audio_out_2630Hz;
    assign multi_2800 = abs_IIR_audio_out_2800Hz * carrier_audio_out_2800Hz;
    assign multi_3000 = abs_IIR_audio_out_3000Hz * carrier_audio_out_3000Hz;
    assign multi_3130 = abs_IIR_audio_out_3130Hz * carrier_audio_out_3130Hz;
    assign multi_3300 = abs_IIR_audio_out_3300Hz * carrier_audio_out_3300Hz;
    assign multi_3500 = abs_IIR_audio_out_3500Hz * carrier_audio_out_3500Hz;
    
    // assign multi_trun_350 = {multi_350[31],multi_350[25:11]};
    // assign multi_trun_300 = {multi_300[31],multi_300[25:11]};
    // assign multi_trun_400 = {multi_400[31],multi_400[25:11]};
    // assign multi_trun_450 = {multi_450[31],multi_450[25:11]};
    // assign multi_trun_500 = {multi_500[31],multi_500[25:11]};
    // assign multi_trun_560 = {multi_560[31],multi_560[25:11]};
    // assign multi_trun_620 = {multi_620[31],multi_620[25:11]};
    // assign multi_trun_680 = {multi_680[31],multi_680[25:11]};
    // assign multi_trun_750 = {multi_750[31],multi_750[25:11]};
    // assign multi_trun_820 = {multi_820[31],multi_820[25:11]};
    // assign multi_trun_888 = {multi_888[31],multi_888[25:11]};
    // assign multi_trun_964 = {multi_964[31],multi_964[25:11]};
    // assign multi_trun_1040 = {multi_1040[31],multi_1040[25:11]};
    // assign multi_trun_1125 = {multi_1125[31],multi_1125[25:11]};
    // assign multi_trun_1212 = {multi_1212[31],multi_1212[25:11]};
    // assign multi_trun_1300 = {multi_1300[31],multi_1300[25:11]};
    // assign multi_trun_1400 = {multi_1400[31],multi_1400[25:11]};
    // assign multi_trun_1500 = {multi_1500[31],multi_1500[25:11]};
    // assign multi_trun_1600 = {multi_1600[31],multi_1600[25:11]};
    // assign multi_trun_1700 = {multi_1700[31],multi_1700[25:11]};
    // assign multi_trun_1820 = {multi_1820[31],multi_1820[25:11]};
    // assign multi_trun_1944 = {multi_1944[31],multi_1944[25:11]};
    // assign multi_trun_2070 = {multi_2070[31],multi_2070[25:11]};
    // assign multi_trun_2200 = {multi_2200[31],multi_2200[25:11]};
    // assign multi_trun_2340 = {multi_2340[31],multi_2340[25:11]};
    // assign multi_trun_2480 = {multi_2480[31],multi_2480[25:11]};
    // assign multi_trun_2630 = {multi_2630[31],multi_2630[25:11]};
    // assign multi_trun_2800 = {multi_2800[31],multi_2800[25:11]};
    // assign multi_trun_3000 = {multi_3000[31],multi_3000[25:11]};
    // assign multi_trun_3130 = {multi_3130[31],multi_3130[25:11]};
    // assign multi_trun_3300 = {multi_3300[31],multi_3300[25:11]};
    // assign multi_trun_3500 = {multi_3500[31],multi_3500[25:11]};

    logic signed [36:0] add_all_32;
    logic signed [36:0] added_all_16;
    logic signed [36:0] added_all_8;
    logic signed [36:0] added_all_4;
    logic signed [36:0] added_all_2;

    // //add_all_32 is add all multi_trun
    // assign add_all_32 = multi_trun_300+multi_trun_350+multi_trun_400+multi_trun_450+multi_trun_500+multi_trun_560+multi_trun_620+multi_trun_680+multi_trun_750+multi_trun_820+multi_trun_888+multi_trun_964+multi_trun_1040+multi_trun_1125+multi_trun_1212+multi_trun_1300+multi_trun_1400+multi_trun_1500+multi_trun_1600+multi_trun_1700+multi_trun_1820+multi_trun_1944+multi_trun_2070+multi_trun_2200+multi_trun_2340+multi_trun_2480+multi_trun_2630+multi_trun_2800+multi_trun_3000+multi_trun_3130+multi_trun_3300+multi_trun_3500;
    // //add_all_16 is add all multi_trun
    // assign add_all_16 = multi_trun_300+multi_trun_350+multi_trun_400+multi_trun_450+multi_trun_500+multi_trun_560+multi_trun_620+multi_trun_680+multi_trun_750+multi_trun_820+multi_trun_888+multi_trun_964+multi_trun_1040+multi_trun_1125+multi_trun_1212+multi_trun_1300;
    // //add_all_8 is add all multi_trun
    // assign add_all_8 = multi_trun_300+multi_trun_350+multi_trun_400+multi_trun_450+multi_trun_500+multi_trun_560+multi_trun_620+multi_trun_680;
    // //add_all_4 is add all multi_trun
    // assign add_all_4 = multi_trun_300+multi_trun_350+multi_trun_400+multi_trun_450;
    // //add_all_2 is add all multi_trun
    // assign add_all_2 = multi_trun_300+multi_trun_350;

    assign add_all_32 = multi_300+multi_350+multi_400+multi_450+multi_500+multi_560+multi_620+multi_680+multi_750+multi_820+multi_888+multi_964+multi_1040+multi_1125+multi_1212+multi_1300+multi_1400+multi_1500+multi_1600+multi_1700+multi_1820+multi_1944+multi_2070+multi_2200+multi_2340+multi_2480+multi_2630+multi_2800+multi_3000+multi_3130+multi_3300+multi_3500;


    always_comb begin
        case(i_bit_test)
            11'b00000000001:   chosen_added_all = {add_all_32[36],add_all_32[30:16]};
            11'b00000000010:   chosen_added_all = {add_all_32[36],add_all_32[29:15]};
            11'b00000000100:   chosen_added_all = {add_all_32[36],add_all_32[28:14]};
            11'b00000001000:   chosen_added_all = {add_all_32[36],add_all_32[27:13]};
            11'b00000010000:   chosen_added_all = {add_all_32[36],add_all_32[26:12]};
            11'b00000100000:   chosen_added_all = {add_all_32[36],add_all_32[25:11]};
            11'b00001000000:   chosen_added_all = {add_all_32[36],add_all_32[24:10]};
            11'b00010000000:   chosen_added_all = {add_all_32[36],add_all_32[23:9]};
            11'b00100000000:   chosen_added_all = {add_all_32[36],add_all_32[22:8]};
            11'b01000000000:   chosen_added_all = {add_all_32[36],add_all_32[21:7]};
            11'b10000000000:   chosen_added_all = {add_all_32[36],add_all_32[20:6]};
            default: chosen_added_all = {add_all_32[36],add_all_32[19:5]};  
            // 11'b00000100000:   chosen_added_all = add_all_
            // default: chosen_added_all = multi_trun_300;
        endcase
    end


     always_comb begin
        case(i_shift[5:1]) 
            5'd0:   chosen_multi_data = multi_trun_350 ;
            5'd1:   chosen_multi_data = multi_trun_300 ;
            5'd2:   chosen_multi_data = multi_trun_400 ;
            5'd3:   chosen_multi_data = multi_trun_450 ;
            5'd4:   chosen_multi_data = multi_trun_500 ;
            5'd5:   chosen_multi_data = multi_trun_560 ;
            5'd6:   chosen_multi_data = multi_trun_620 ;
            5'd7:   chosen_multi_data = multi_trun_680 ;
            5'd8:   chosen_multi_data = multi_trun_750 ;
            5'd9:   chosen_multi_data = multi_trun_820 ;
            5'd10:  chosen_multi_data = multi_trun_888 ;
            5'd11:  chosen_multi_data = multi_trun_964 ;
            5'd12:  chosen_multi_data = multi_trun_1040;
            5'd13:  chosen_multi_data = multi_trun_1125;
            5'd14:  chosen_multi_data = multi_trun_1212;
            5'd15:  chosen_multi_data = multi_trun_1300;
            5'd16:  chosen_multi_data = multi_trun_1400;
            5'd17:  chosen_multi_data = multi_trun_1500;
            5'd18:  chosen_multi_data = multi_trun_1600;
            5'd19:  chosen_multi_data = multi_trun_1700;
            5'd20:  chosen_multi_data = multi_trun_1820;
            5'd21:  chosen_multi_data = multi_trun_1944;
            5'd22:  chosen_multi_data = multi_trun_2070;
            5'd23:  chosen_multi_data = multi_trun_2200;
            5'd24:  chosen_multi_data = multi_trun_2340;
            5'd25:  chosen_multi_data = multi_trun_2480;
            5'd26:  chosen_multi_data = multi_trun_2630;
            5'd27:  chosen_multi_data = multi_trun_2800;
            5'd28:  chosen_multi_data = multi_trun_3000;
            5'd29:  chosen_multi_data = multi_trun_3130;
            5'd30:  chosen_multi_data = multi_trun_3300;
            5'd31:  chosen_multi_data = multi_trun_3500;
            
        endcase
    end



     always_comb begin
        case(i_shift[5:1]) 
            5'd0:   chosen_carrier_filter_data = carrier_audio_out_300Hz;   // [15:0]
            5'd1:   chosen_carrier_filter_data = carrier_audio_out_350Hz;  //   [16:1]
            5'd2:   chosen_carrier_filter_data = carrier_audio_out_400Hz;   // [17:2]
            5'd3:   chosen_carrier_filter_data = carrier_audio_out_450Hz;
            5'd4:   chosen_carrier_filter_data = carrier_audio_out_500Hz;
            5'd5:   chosen_carrier_filter_data = carrier_audio_out_560Hz;
            5'd6:   chosen_carrier_filter_data = carrier_audio_out_620Hz;
            5'd7:   chosen_carrier_filter_data = carrier_audio_out_680Hz;
            5'd8:   chosen_carrier_filter_data = carrier_audio_out_750Hz;
            5'd9:   chosen_carrier_filter_data = carrier_audio_out_820Hz;  //  [24:9]
            5'd10:  chosen_carrier_filter_data = carrier_audio_out_888Hz;
            5'd11:  chosen_carrier_filter_data = carrier_audio_out_964Hz;
            5'd12:  chosen_carrier_filter_data = carrier_audio_out_1040Hz;
            5'd13:  chosen_carrier_filter_data = carrier_audio_out_1125Hz;
            5'd14:  chosen_carrier_filter_data = carrier_audio_out_1212Hz;
            5'd15:  chosen_carrier_filter_data = carrier_audio_out_1300Hz;
            5'd16:  chosen_carrier_filter_data = carrier_audio_out_1400Hz;
            5'd17:  chosen_carrier_filter_data = carrier_audio_out_1500Hz;
            5'd18:  chosen_carrier_filter_data = carrier_audio_out_1600Hz;
            5'd19:  chosen_carrier_filter_data = carrier_audio_out_1700Hz;
            5'd20:  chosen_carrier_filter_data = carrier_audio_out_1820Hz;
            5'd21:  chosen_carrier_filter_data = carrier_audio_out_1944Hz;
            5'd22:  chosen_carrier_filter_data = carrier_audio_out_2070Hz;
            5'd23:  chosen_carrier_filter_data = carrier_audio_out_2200Hz;
            5'd24:  chosen_carrier_filter_data = carrier_audio_out_2340Hz;
            5'd25:  chosen_carrier_filter_data = carrier_audio_out_2480Hz;
            5'd26:  chosen_carrier_filter_data = carrier_audio_out_2630Hz;
            5'd27:  chosen_carrier_filter_data = carrier_audio_out_2800Hz;
            5'd28:  chosen_carrier_filter_data = carrier_audio_out_3000Hz;
            5'd29:  chosen_carrier_filter_data = carrier_audio_out_3130Hz;
            5'd30:  chosen_carrier_filter_data = carrier_audio_out_3300Hz;
            5'd31:  chosen_carrier_filter_data = carrier_audio_out_3500Hz;
            
        endcase
    end

    // //carrier chosen
    //     always_comb begin
    //     case(i_shift[5:1]) 
    //         5'd0:   chosen_carrier_filter_data = carrier_audio_out_300Hz;
    //         5'd1:   chosen_carrier_filter_data = carrier_audio_out_350Hz;
    //         5'd2:   chosen_carrier_filter_data = carrier_audio_out_400Hz;
    //         5'd3:   chosen_carrier_filter_data = carrier_audio_out_450Hz;
    //         5'd4:   chosen_carrier_filter_data = carrier_audio_out_500Hz;
    //         5'd5:   chosen_carrier_filter_data = carrier_audio_out_560Hz;
    //         5'd6:   chosen_carrier_filter_data = carrier_audio_out_620Hz;
    //         5'd7:   chosen_carrier_filter_data = carrier_audio_out_680Hz;
    //         5'd8:   chosen_carrier_filter_data = carrier_audio_out_750Hz;
    //         5'd9:   chosen_carrier_filter_data = carrier_audio_out_820Hz;
    //         5'd10:  chosen_carrier_filter_data = carrier_audio_out_888Hz;
    //         5'd11:  chosen_carrier_filter_data = carrier_audio_out_964Hz;
    //         5'd12:  chosen_carrier_filter_data = carrier_audio_out_1040Hz;
    //         5'd13:  chosen_carrier_filter_data = carrier_audio_out_1125Hz;
    //         5'd14:  chosen_carrier_filter_data = carrier_audio_out_1212Hz;
    //         5'd15:  chosen_carrier_filter_data = carrier_audio_out_1300Hz;
    //         5'd16:  chosen_carrier_filter_data = carrier_audio_out_1400Hz;
    //         5'd17:  chosen_carrier_filter_data = carrier_audio_out_1500Hz;
    //         5'd18:  chosen_carrier_filter_data = carrier_audio_out_1600Hz;
    //         5'd19:  chosen_carrier_filter_data = carrier_audio_out_1700Hz;
    //         5'd20:  chosen_carrier_filter_data = carrier_audio_out_1820Hz;
    //         5'd21:  chosen_carrier_filter_data = carrier_audio_out_1944Hz;
    //         5'd22:  chosen_carrier_filter_data = carrier_audio_out_2070Hz;
    //         5'd23:  chosen_carrier_filter_data = carrier_audio_out_2200Hz;
    //         5'd24:  chosen_carrier_filter_data = carrier_audio_out_2340Hz;
    //         5'd25:  chosen_carrier_filter_data = carrier_audio_out_2480Hz;
    //         5'd26:  chosen_carrier_filter_data = carrier_audio_out_2630Hz;
    //         5'd27:  chosen_carrier_filter_data = carrier_audio_out_2800Hz;
    //         5'd28:  chosen_carrier_filter_data = carrier_audio_out_3000Hz;
    //         5'd29:  chosen_carrier_filter_data = carrier_audio_out_3130Hz;
    //         5'd30:  chosen_carrier_filter_data = carrier_audio_out_3300Hz;
    //         5'd31:  chosen_carrier_filter_data = carrier_audio_out_3500Hz;
            
    //     endcase
    // end

    // always_comb begin
    //     case(i_shift[5:1]) 
    //         5'd0:   chosen_carrier_filter_data = abs_IIR_audio_out_300Hz * carrier_audio_out_300Hz;
    //         5'd1:   chosen_carrier_filter_data = -1*IIR_audio_out_350Hz ;
    //         5'd2:   chosen_carrier_filter_data = IIR_audio_out_400Hz * carrier_audio_out_400Hz;
    //         5'd3:   chosen_carrier_filter_data = multi_450[24:9];
    //         5'd4:   chosen_carrier_filter_data = multi_450[30:15];
    //         5'd5:   chosen_carrier_filter_data = multi_450[24:9];
    //         5'd6:   chosen_carrier_filter_data = carrier_audio_out_620Hz;
    //         5'd7:   chosen_carrier_filter_data = carrier_audio_out_680Hz;
    //         5'd8:   chosen_carrier_filter_data = carrier_audio_out_750Hz;
    //         5'd9:   chosen_carrier_filter_data = carrier_audio_out_820Hz;
    //         5'd10:  chosen_carrier_filter_data = carrier_audio_out_888Hz;
    //         5'd11:  chosen_carrier_filter_data = carrier_audio_out_964Hz;
    //         5'd12:  chosen_carrier_filter_data = carrier_audio_out_1040Hz;
    //         5'd13:  chosen_carrier_filter_data = carrier_audio_out_1125Hz;
    //         5'd14:  chosen_carrier_filter_data = carrier_audio_out_1212Hz;
    //         5'd15:  chosen_carrier_filter_data = carrier_audio_out_1300Hz;
    //         5'd16:  chosen_carrier_filter_data = carrier_audio_out_1400Hz;
    //         5'd17:  chosen_carrier_filter_data = carrier_audio_out_1500Hz;
    //         5'd18:  chosen_carrier_filter_data = carrier_audio_out_1600Hz;
    //         5'd19:  chosen_carrier_filter_data = carrier_audio_out_1700Hz;
    //         5'd20:  chosen_carrier_filter_data = carrier_audio_out_1820Hz;
    //         5'd21:  chosen_carrier_filter_data = carrier_audio_out_1944Hz;
    //         5'd22:  chosen_carrier_filter_data = carrier_audio_out_2070Hz;
    //         5'd23:  chosen_carrier_filter_data = carrier_audio_out_2200Hz;
    //         5'd24:  chosen_carrier_filter_data = carrier_audio_out_2340Hz;
    //         5'd25:  chosen_carrier_filter_data = carrier_audio_out_2480Hz;
    //         5'd26:  chosen_carrier_filter_data = carrier_audio_out_2630Hz;
    //         5'd27:  chosen_carrier_filter_data = carrier_audio_out_2800Hz;
    //         5'd28:  chosen_carrier_filter_data = carrier_audio_out_3000Hz;
    //         5'd29:  chosen_carrier_filter_data = carrier_audio_out_3130Hz;
    //         5'd30:  chosen_carrier_filter_data = carrier_audio_out_3300Hz;
    //         5'd31:  chosen_carrier_filter_data = carrier_audio_out_3500Hz;
            
    //     endcase
    // end

//absoulute & mac part
    //absolute
    assign abs_IIR_audio_out_300Hz = (IIR_audio_out_300Hz[15]==1)? -1*IIR_audio_out_300Hz : IIR_audio_out_300Hz;
    assign abs_IIR_audio_out_350Hz = (IIR_audio_out_350Hz[15]==1)? -1*IIR_audio_out_350Hz : IIR_audio_out_350Hz;
    assign abs_IIR_audio_out_400Hz = (IIR_audio_out_400Hz[15]==1)? -1*IIR_audio_out_400Hz : IIR_audio_out_400Hz;
    assign abs_IIR_audio_out_450Hz = (IIR_audio_out_450Hz[15]==1)? -1*IIR_audio_out_450Hz : IIR_audio_out_450Hz;
    assign abs_IIR_audio_out_500Hz = (IIR_audio_out_500Hz[15]==1)? -1*IIR_audio_out_500Hz : IIR_audio_out_500Hz;
    assign abs_IIR_audio_out_560Hz = (IIR_audio_out_560Hz[15]==1)? -1*IIR_audio_out_560Hz : IIR_audio_out_560Hz;
    assign abs_IIR_audio_out_620Hz = (IIR_audio_out_620Hz[15]==1)? -1*IIR_audio_out_620Hz : IIR_audio_out_620Hz;
    assign abs_IIR_audio_out_680Hz = (IIR_audio_out_680Hz[15]==1)? -1*IIR_audio_out_680Hz : IIR_audio_out_680Hz;
    assign abs_IIR_audio_out_750Hz = (IIR_audio_out_750Hz[15]==1)? -1*IIR_audio_out_750Hz : IIR_audio_out_750Hz;
    assign abs_IIR_audio_out_820Hz = (IIR_audio_out_820Hz[15]==1)? -1*IIR_audio_out_820Hz : IIR_audio_out_820Hz;
    assign abs_IIR_audio_out_888Hz = (IIR_audio_out_888Hz[15]==1)? -1*IIR_audio_out_888Hz : IIR_audio_out_888Hz;
    assign abs_IIR_audio_out_964Hz = (IIR_audio_out_964Hz[15]==1)? -1*IIR_audio_out_964Hz : IIR_audio_out_964Hz;
    assign abs_IIR_audio_out_1040Hz = (IIR_audio_out_1040Hz[15]==1)? -1*IIR_audio_out_1040Hz : IIR_audio_out_1040Hz;
    assign abs_IIR_audio_out_1125Hz = (IIR_audio_out_1125Hz[15]==1)? -1*IIR_audio_out_1125Hz : IIR_audio_out_1125Hz;
    assign abs_IIR_audio_out_1212Hz = (IIR_audio_out_1212Hz[15]==1)? -1*IIR_audio_out_1212Hz : IIR_audio_out_1212Hz;
    assign abs_IIR_audio_out_1300Hz = (IIR_audio_out_1300Hz[15]==1)? -1*IIR_audio_out_1300Hz : IIR_audio_out_1300Hz;
    assign abs_IIR_audio_out_1400Hz = (IIR_audio_out_1400Hz[15]==1)? -1*IIR_audio_out_1400Hz : IIR_audio_out_1400Hz;
    assign abs_IIR_audio_out_1500Hz = (IIR_audio_out_1500Hz[15]==1)? -1*IIR_audio_out_1500Hz : IIR_audio_out_1500Hz;
    assign abs_IIR_audio_out_1600Hz = (IIR_audio_out_1600Hz[15]==1)? -1*IIR_audio_out_1600Hz : IIR_audio_out_1600Hz;
    assign abs_IIR_audio_out_1700Hz = (IIR_audio_out_1700Hz[15]==1)? -1*IIR_audio_out_1700Hz : IIR_audio_out_1700Hz;
    assign abs_IIR_audio_out_1820Hz = (IIR_audio_out_1820Hz[15]==1)? -1*IIR_audio_out_1820Hz : IIR_audio_out_1820Hz;
    assign abs_IIR_audio_out_1944Hz = (IIR_audio_out_1944Hz[15]==1)? -1*IIR_audio_out_1944Hz : IIR_audio_out_1944Hz;
    assign abs_IIR_audio_out_2070Hz = (IIR_audio_out_2070Hz[15]==1)? -1*IIR_audio_out_2070Hz : IIR_audio_out_2070Hz;
    assign abs_IIR_audio_out_2200Hz = (IIR_audio_out_2200Hz[15]==1)? -1*IIR_audio_out_2200Hz : IIR_audio_out_2200Hz;
    assign abs_IIR_audio_out_2340Hz = (IIR_audio_out_2340Hz[15]==1)? -1*IIR_audio_out_2340Hz : IIR_audio_out_2340Hz;
    assign abs_IIR_audio_out_2480Hz = (IIR_audio_out_2480Hz[15]==1)? -1*IIR_audio_out_2480Hz : IIR_audio_out_2480Hz;
    assign abs_IIR_audio_out_2630Hz = (IIR_audio_out_2630Hz[15]==1)? -1*IIR_audio_out_2630Hz : IIR_audio_out_2630Hz;
    assign abs_IIR_audio_out_2800Hz = (IIR_audio_out_2800Hz[15]==1)? -1*IIR_audio_out_2800Hz : IIR_audio_out_2800Hz;
    assign abs_IIR_audio_out_3000Hz = (IIR_audio_out_3000Hz[15]==1)? -1*IIR_audio_out_3000Hz : IIR_audio_out_3000Hz;
    assign abs_IIR_audio_out_3130Hz = (IIR_audio_out_3130Hz[15]==1)? -1*IIR_audio_out_3130Hz : IIR_audio_out_3130Hz;
    assign abs_IIR_audio_out_3300Hz = (IIR_audio_out_3300Hz[15]==1)? -1*IIR_audio_out_3300Hz : IIR_audio_out_3300Hz;
    assign abs_IIR_audio_out_3500Hz = (IIR_audio_out_3500Hz[15]==1)? -1*IIR_audio_out_3500Hz : IIR_audio_out_3500Hz;


    logic signed [15:0] result;
    assign result = abs_IIR_audio_out_300Hz * carrier_audio_out_300Hz +
                    abs_IIR_audio_out_400Hz * carrier_audio_out_400Hz +
                    abs_IIR_audio_out_450Hz * carrier_audio_out_450Hz +
                    abs_IIR_audio_out_500Hz * carrier_audio_out_500Hz +
                    abs_IIR_audio_out_560Hz * carrier_audio_out_560Hz +
                    abs_IIR_audio_out_620Hz * carrier_audio_out_620Hz +
                    abs_IIR_audio_out_680Hz * carrier_audio_out_680Hz +
                    abs_IIR_audio_out_750Hz * carrier_audio_out_750Hz +
                    abs_IIR_audio_out_820Hz * carrier_audio_out_820Hz +
                    abs_IIR_audio_out_888Hz * carrier_audio_out_888Hz +
                    abs_IIR_audio_out_964Hz * carrier_audio_out_964Hz +
                    abs_IIR_audio_out_1040Hz * carrier_audio_out_1040Hz +
                    abs_IIR_audio_out_1125Hz * carrier_audio_out_1125Hz +
                    abs_IIR_audio_out_1212Hz * carrier_audio_out_1212Hz +
                    abs_IIR_audio_out_1300Hz * carrier_audio_out_1300Hz +
                    abs_IIR_audio_out_1400Hz * carrier_audio_out_1400Hz +
                    abs_IIR_audio_out_1500Hz * carrier_audio_out_1500Hz +
                    abs_IIR_audio_out_1600Hz * carrier_audio_out_1600Hz +
                    abs_IIR_audio_out_1700Hz * carrier_audio_out_1700Hz +
                    abs_IIR_audio_out_1820Hz * carrier_audio_out_1820Hz +
                    abs_IIR_audio_out_1944Hz * carrier_audio_out_1944Hz +
                    abs_IIR_audio_out_2070Hz * carrier_audio_out_2070Hz +
                    abs_IIR_audio_out_2200Hz * carrier_audio_out_2200Hz +
                    abs_IIR_audio_out_2340Hz * carrier_audio_out_2340Hz +
                    abs_IIR_audio_out_2480Hz * carrier_audio_out_2480Hz +
                    abs_IIR_audio_out_2630Hz * carrier_audio_out_2630Hz +
                    abs_IIR_audio_out_2800Hz * carrier_audio_out_2800Hz +
                    abs_IIR_audio_out_3000Hz * carrier_audio_out_3000Hz +
                    abs_IIR_audio_out_3130Hz * carrier_audio_out_3130Hz +
                    abs_IIR_audio_out_3300Hz * carrier_audio_out_3300Hz +
                    abs_IIR_audio_out_3500Hz * carrier_audio_out_3500Hz;



    always_comb begin
        prev_daclrck_w = i_daclrck;
        case(state_r)
            S_IDLE: begin
                if(i_start) begin
                    state_w = S_PLAY;
                    o_dac_data_w = chosen_data;
                end
                else begin
                    state_w = S_IDLE;
                    o_dac_data_w = 16'bZ;
                end
            end
            S_PLAY: begin
                state_w = S_PLAY;
                o_dac_data_w = chosen_data;
            end
            default: begin
                state_w = state_r;
                o_dac_data_w = 16'bZ;
            end
        endcase
    end

    logic IIR_valid;
    always_ff @( posedge i_clk or negedge i_rst_n ) begin
        if(~i_rst_n) begin
            IIR_valid <= 1'b0;
        end
        else begin
            if(i_start) begin
                IIR_valid <= 1'b1;
            end
            else begin
                IIR_valid <= IIR_valid;
            end
        end
    end
    always_ff@(posedge i_clk or negedge i_rst_n) begin
        if(~i_rst_n) begin
            state_r         <= S_IDLE;
            o_dac_data_r    <= 16'bZ;
            prev_daclrck_r  <= 1'b0;
        end
        else begin
            state_r         <= state_w;
            o_dac_data_r    <= o_dac_data_w;
            prev_daclrck_r  <= prev_daclrck_w;
        end
    end
    IIR_300Hz filter_300(
        .clk(i_clk),
        .i_rst_n(i_rst_n),
        .lrclk_negedge(lrclk_negedge),
        .lrclk_posedge(lrclk_posedge),
        .i_valid(IIR_valid),
        .audio_in(i_sram_data),
        .b1 (18'sd67), 
        .b2 (18'sd0), 
        .b3 (-18'sd67), 
        .a2 (18'sd130709), 
        .a3 (-18'sd65400),
        .audio_out(IIR_audio_out_300Hz)
    );

    IIR_300Hz filter_350(
        .clk(i_clk),
        .i_rst_n(i_rst_n),
        .lrclk_negedge(lrclk_negedge),
        .lrclk_posedge(lrclk_posedge),
        .i_valid(IIR_valid),
        .audio_in(i_sram_data),
        .b1 (18'sd78), 
        .b2 (18'sd0), 
        .b3 (-18'sd78), 
        .a2 (18'sd130605), 
        .a3 (-18'sd65378), 
        .audio_out(IIR_audio_out_350Hz)
    );

    IIR_300Hz filter_400(
        .clk(i_clk),
        .i_rst_n(i_rst_n),
        .lrclk_negedge(lrclk_negedge),
        .lrclk_posedge(lrclk_posedge),
        .i_valid(IIR_valid),
        .audio_in(i_sram_data),
        .b1 (18'sd59), 
        .b2 (18'sd0), 
        .b3 (-18'sd59), 
        .a2 (18'sd130776), 
        .a3 (-18'sd65416),  
        .audio_out(IIR_audio_out_400Hz)
    );

    //4
    IIR_300Hz filter_450(
        .clk(i_clk),
        .i_rst_n(i_rst_n),
        .lrclk_negedge(lrclk_negedge),
        .lrclk_posedge(lrclk_posedge),
        .i_valid(IIR_valid),
        .audio_in(i_sram_data),
        .b1 (18'sd67), 
        .b2 (18'sd0), 
        .b3 (-18'sd67), 
        .a2 (18'sd130711), 
        .a3 (-18'sd65401),  
        .audio_out(IIR_audio_out_450Hz)
    );
    //5
    IIR_300Hz filter_500(
        .clk(i_clk),
        .i_rst_n(i_rst_n),
        .lrclk_negedge(lrclk_negedge),
        .lrclk_posedge(lrclk_posedge),
        .i_valid(IIR_valid),
        .audio_in(i_sram_data),
        .b1 (18'sd75), 
        .b2 (18'sd0), 
        .b3 (-18'sd75), 
        .a2 (18'sd130636), 
        .a3 (-18'sd65384),
        .audio_out(IIR_audio_out_500Hz)
    );
    //6
    IIR_300Hz filter_560(
        .clk(i_clk),
        .i_rst_n(i_rst_n),
        .lrclk_negedge(lrclk_negedge),
        .lrclk_posedge(lrclk_posedge),
        .i_valid(IIR_valid),
        .audio_in(i_sram_data),
        .b1 (18'sd84), 
        .b2 (18'sd0), 
        .b3 (-18'sd84), 
        .a2 (18'sd130551), 
        .a3 (-18'sd65367), 
        .audio_out(IIR_audio_out_560Hz)
    );
    //7
    IIR_300Hz filter_620(
        .clk(i_clk),
        .i_rst_n(i_rst_n),
        .lrclk_negedge(lrclk_negedge),
        .lrclk_posedge(lrclk_posedge),
        .i_valid(IIR_valid),
        .audio_in(i_sram_data),
        .b1 (18'sd93), 
        .b2 (18'sd0), 
        .b3 (-18'sd93), 
        .a2 (18'sd130455),
        .a3 (-18'sd65349),
        .audio_out(IIR_audio_out_620Hz)
    );
    //8
    IIR_300Hz filter_680(
        .clk(i_clk),
        .i_rst_n(i_rst_n),
        .lrclk_negedge(lrclk_negedge),
        .lrclk_posedge(lrclk_posedge),
        .i_valid(IIR_valid),
        .audio_in(i_sram_data),
        .b1 (18'sd102), 
        .b2 (18'sd0), 
        .b3 (-18'sd102), 
        .a2 (18'sd130345),
        .a3 (-18'sd65331),
        .audio_out(IIR_audio_out_680Hz)
    );
    //9
    IIR_300Hz filter_750(
        .clk(i_clk),
        .i_rst_n(i_rst_n),
        .lrclk_negedge(lrclk_negedge),
        .lrclk_posedge(lrclk_posedge),
        .i_valid(IIR_valid),
        .audio_in(i_sram_data),
        .b1 (18'sd112), 
        .b2 (18'sd0), 
        .b3 (-18'sd112), 
        .a2 (18'sd130220),
        .a3 (-18'sd65311),
        .audio_out(IIR_audio_out_750Hz)
    );
    //10
    IIR_300Hz filter_820(
        .clk(i_clk),
        .i_rst_n(i_rst_n),
        .lrclk_negedge(lrclk_negedge),
        .lrclk_posedge(lrclk_posedge),
        .i_valid(IIR_valid),
        .audio_in(i_sram_data),
        .b1 (18'sd122), 
        .b2 (18'sd0), 
        .b3 (-18'sd122), 
        .a2 (18'sd130080),
        .a3 (-18'sd65291),
        .audio_out(IIR_audio_out_820Hz)
    );
    //11
    IIR_300Hz filter_888(
        .clk(i_clk),
        .i_rst_n(i_rst_n),
        .lrclk_negedge(lrclk_negedge),
        .lrclk_posedge(lrclk_posedge),
        .i_valid(IIR_valid),
        .audio_in(i_sram_data),
        .b1 (18'sd133), 
        .b2 (18'sd0), 
        .b3 (-18'sd133), 
        .a2 (18'sd129921),
        .a3 (-18'sd65269),
        .audio_out(IIR_audio_out_888Hz)
    );
    //12
    IIR_300Hz filter_964(
        .clk(i_clk),
        .i_rst_n(i_rst_n),
        .lrclk_negedge(lrclk_negedge),
        .lrclk_posedge(lrclk_posedge),
        .i_valid(IIR_valid),
        .audio_in(i_sram_data),
        .b1 (18'sd144), 
        .b2 (18'sd0), 
        .b3 (-18'sd144), 
        .a2 (18'sd129743),
        .a3 (-18'sd65247),
        .audio_out(IIR_audio_out_964Hz)
    );
    //13
    IIR_300Hz filter_1040(
        .clk(i_clk),
        .i_rst_n(i_rst_n),
        .lrclk_negedge(lrclk_negedge),
        .lrclk_posedge(lrclk_posedge),
        .i_valid(IIR_valid),
        .audio_in(i_sram_data),
        .b1 (18'sd156), 
        .b2 (18'sd0), 
        .b3 (-18'sd156), 
        .a2 (18'sd129543),
        .a3 (-18'sd65223),
        .audio_out(IIR_audio_out_1040Hz)
    );
    //14
    IIR_300Hz filter_1125(
        .clk(i_clk),
        .i_rst_n(i_rst_n),
        .lrclk_negedge(lrclk_negedge),
        .lrclk_posedge(lrclk_posedge),
        .i_valid(IIR_valid),
        .audio_in(i_sram_data),
        .b1 (18'sd168), 
        .b2 (18'sd0), 
        .b3 (-18'sd168), 
        .a2 (18'sd129318),
        .a3 (-18'sd65198),
        .audio_out(IIR_audio_out_1125Hz)
    );
    //15
    IIR_300Hz filter_1212(
        .clk(i_clk),
        .i_rst_n(i_rst_n),
        .lrclk_negedge(lrclk_negedge),
        .lrclk_posedge(lrclk_posedge),
        .i_valid(IIR_valid),
        .audio_in(i_sram_data),
        .b1 (18'sd181), 
        .b2 (18'sd0), 
        .b3 (-18'sd181), 
        .a2 (18'sd129067), 
        .a3 (-18'sd65173),
        .audio_out(IIR_audio_out_1212Hz)
    );
    //16
    IIR_300Hz filter_1300(
        .clk(i_clk),
        .i_rst_n(i_rst_n),
        .lrclk_negedge(lrclk_negedge),
        .lrclk_posedge(lrclk_posedge),
        .i_valid(IIR_valid),
        .audio_in(i_sram_data),
        .b1 (18'sd195), 
        .b2 (18'sd0), 
        .b3 (-18'sd195), 
        .a2 (18'sd128787), 
        .a3 (-18'sd65145),
        .audio_out(IIR_audio_out_1300Hz)
    );
    //17
    IIR_300Hz filter_1400(
        .clk(i_clk),
        .i_rst_n(i_rst_n),
        .lrclk_negedge(lrclk_negedge),
        .lrclk_posedge(lrclk_posedge),
        .i_valid(IIR_valid),
        .audio_in(i_sram_data),
        .b1 (18'sd209), 
        .b2 (18'sd0), 
        .b3 (-18'sd209), 
        .a2 (18'sd128473), 
        .a3 (-18'sd65117), 
        .audio_out(IIR_audio_out_1400Hz)
    );
    //18
    IIR_300Hz filter_1500(
        .clk(i_clk),
        .i_rst_n(i_rst_n),
        .lrclk_negedge(lrclk_negedge),
        .lrclk_posedge(lrclk_posedge),
        .i_valid(IIR_valid),
        .audio_in(i_sram_data),
        .b1(18'sd224),
        .b2(18'sd0),
        .b3(-18'sd224),
        .a2(18'sd128113),
        .a3(-18'sd65086),
        .audio_out(IIR_audio_out_1500Hz)
    );
    //19
    IIR_300Hz filter_1600(
        .clk(i_clk),
        .i_rst_n(i_rst_n),
        .lrclk_negedge(lrclk_negedge),
        .lrclk_posedge(lrclk_posedge),
        .i_valid(IIR_valid),
        .audio_in(i_sram_data),
        .b1 (18'sd239), 
        .b2 (18'sd0), 
        .b3 (-18'sd239), 
        .a2 (18'sd127735), 
        .a3 (-18'sd65056),
        .audio_out(IIR_audio_out_1600Hz)
    );
    //20
    IIR_300Hz filter_1700(
            .clk(i_clk),
            .i_rst_n(i_rst_n),
            .lrclk_negedge(lrclk_negedge),
            .lrclk_posedge(lrclk_posedge),
            .i_valid(IIR_valid),
            .audio_in(i_sram_data),
            .b1 (18'sd255), 
            .b2 (18'sd0), 
            .b3 (-18'sd255), 
            .a2 (18'sd127303), 
            .a3 (-18'sd65024), 
            .audio_out(IIR_audio_out_1700Hz)
    );
    //21
    IIR_300Hz filter_1820(
            .clk(i_clk),
            .i_rst_n(i_rst_n),
            .lrclk_negedge(lrclk_negedge),
            .lrclk_posedge(lrclk_posedge),
            .i_valid(IIR_valid),
            .audio_in(i_sram_data),
            .b1 (18'sd272), 
            .b2 (18'sd0), 
            .b3 (-18'sd272), 
            .a2 (18'sd126823),
            .a3 (-18'sd64990),
            .audio_out(IIR_audio_out_1820Hz)
    );
    //22
    IIR_300Hz filter_1944(
            .clk(i_clk),
            .i_rst_n(i_rst_n),
            .lrclk_negedge(lrclk_negedge),
            .lrclk_posedge(lrclk_posedge),
            .i_valid(IIR_valid),
            .audio_in(i_sram_data),
            .b1 (18'sd290), 
            .b2 (18'sd0), 
            .b3 (-18'sd290), 
            .a2 (18'sd126289), 
            .a3 (-18'sd64954),
            .audio_out(IIR_audio_out_1944Hz)
    );
    //23
    IIR_300Hz filter_2070(
            .clk(i_clk),
            .i_rst_n(i_rst_n),
            .lrclk_negedge(lrclk_negedge),
            .lrclk_posedge(lrclk_posedge),
            .i_valid(IIR_valid),
            .audio_in(i_sram_data),
            .b1 (18'sd309), 
            .b2 (18'sd0), 
            .b3 (-18'sd309), 
            .a2 (18'sd125698), 
            .a3 (-18'sd64917),
            .audio_out(IIR_audio_out_2070Hz)
    );
    //24
    IIR_300Hz filter_2200(
            .clk(i_clk),
            .i_rst_n(i_rst_n),
            .lrclk_negedge(lrclk_negedge),
            .lrclk_posedge(lrclk_posedge),
            .i_valid(IIR_valid),
            .audio_in(i_sram_data),
            .b1 (18'sd328), 
            .b2 (18'sd0), 
            .b3 (-18'sd328), 
            .a2 (18'sd125042),
            .a3 (-18'sd64878),
            .audio_out(IIR_audio_out_2200Hz)
    );
    //25
    IIR_300Hz filter_2340(
            .clk(i_clk),
            .i_rst_n(i_rst_n),
            .lrclk_negedge(lrclk_negedge),
            .lrclk_posedge(lrclk_posedge),
            .i_valid(IIR_valid),
            .audio_in(i_sram_data),
            .b1 (18'sd349), 
            .b2 (18'sd0), 
            .b3 (-18'sd349), 
            .a2 (18'sd124317),
            .a3 (-18'sd64837),
            .audio_out(IIR_audio_out_2340Hz)
    );
    //26
    IIR_300Hz filter_2480(
            .clk(i_clk),
            .i_rst_n(i_rst_n),
            .lrclk_negedge(lrclk_negedge),
            .lrclk_posedge(lrclk_posedge),
            .i_valid(IIR_valid),
            .audio_in(i_sram_data),
            .b1 (18'sd370), 
            .b2 (18'sd0), 
            .b3 (-18'sd370), 
            .a2 (18'sd123514),
            .a3 (-18'sd64794),
            .audio_out(IIR_audio_out_2480Hz)
    );
    //27
    IIR_300Hz filter_2630(
            .clk(i_clk),
            .i_rst_n(i_rst_n),
            .lrclk_negedge(lrclk_negedge),
            .lrclk_posedge(lrclk_posedge),
            .i_valid(IIR_valid),
            .audio_in(i_sram_data),
            .b1 (18'sd392), 
            .b2 (18'sd0), 
            .b3 (-18'sd392), 
            .a2 (18'sd122627),
            .a3 (-18'sd64750),
            .audio_out(IIR_audio_out_2630Hz)
    );
    //28
    IIR_300Hz filter_2800(
            .clk(i_clk),
            .i_rst_n(i_rst_n),
            .lrclk_negedge(lrclk_negedge),
            .lrclk_posedge(lrclk_posedge),
            .i_valid(IIR_valid),
            .audio_in(i_sram_data),
            .b1 (18'sd416), 
            .b2 (18'sd0), 
            .b3 (-18'sd416), 
            .a2 (18'sd121647),
            .a3 (-18'sd64703),
            .audio_out(IIR_audio_out_2800Hz)
    );
    //29
    IIR_300Hz filter_3000(
            .clk(i_clk),
            .i_rst_n(i_rst_n),
            .lrclk_negedge(lrclk_negedge),
            .lrclk_posedge(lrclk_posedge),
            .i_valid(IIR_valid),
            .audio_in(i_sram_data),
            .b1 (18'sd440), 
            .b2 (18'sd0), 
            .b3 (-18'sd440), 
            .a2 (18'sd120566), 
            .a3 (-18'sd64654), 
            .audio_out(IIR_audio_out_3000Hz)
    );
    //30
    IIR_300Hz filter_3130(
            .clk(i_clk),
            .i_rst_n(i_rst_n),
            .lrclk_negedge(lrclk_negedge),
            .lrclk_posedge(lrclk_posedge),
            .i_valid(IIR_valid),
            .audio_in(i_sram_data),
            .b1 (18'sd466), 
            .b2 (18'sd0), 
            .b3 (-18'sd466), 
            .a2 (18'sd119374), 
            .a3 (-18'sd64603), 
            .audio_out(IIR_audio_out_3130Hz)
    );
    //31
    IIR_300Hz filter_3300(
            .clk(i_clk),
            .i_rst_n(i_rst_n),
            .lrclk_negedge(lrclk_negedge),
            .lrclk_posedge(lrclk_posedge),
            .i_valid(IIR_valid),
            .audio_in(i_sram_data),
            .b1 (18'sd493), 
            .b2 (18'sd0), 
            .b3 (-18'sd493), 
            .a2 (18'sd118061),
            .a3 (-18'sd64549),
            .audio_out(IIR_audio_out_3300Hz)
    );
    //32
    IIR_300Hz filter_3500(
            .clk(i_clk),
            .i_rst_n(i_rst_n),
            .lrclk_negedge(lrclk_negedge),
            .lrclk_posedge(lrclk_posedge),
            .i_valid(IIR_valid),
            .audio_in(i_sram_data),
            .b1 (18'sd521), 
            .b2 (18'sd0), 
            .b3 (-18'sd521), 
            .a2 (18'sd116615),
            .a3 (-18'sd64493),
            .audio_out(IIR_audio_out_3500Hz)
    );

    //carrier data
    IIR_300Hz carrier_filter_300(
        .clk(i_clk),
        .i_rst_n(i_rst_n),
        .lrclk_negedge(lrclk_negedge),
        .lrclk_posedge(lrclk_posedge),
        .i_valid(IIR_valid),
        .audio_in(carrier_data),
        .b1 (18'sd67), 
        .b2 (18'sd0), 
        .b3 (-18'sd67), 
        .a2 (18'sd130709), 
        .a3 (-18'sd65400),
        .audio_out(carrier_audio_out_300Hz)
    );

    IIR_300Hz carrier_filter_350(
        .clk(i_clk),
        .i_rst_n(i_rst_n),
        .lrclk_negedge(lrclk_negedge),
        .lrclk_posedge(lrclk_posedge),
        .i_valid(IIR_valid),
        .audio_in(carrier_data),
        .b1 (18'sd78), 
        .b2 (18'sd0), 
        .b3 (-18'sd78), 
        .a2 (18'sd130605), 
        .a3 (-18'sd65378), 
        .audio_out(carrier_audio_out_350Hz)
    );

    IIR_300Hz carrier_filter_400(
        .clk(i_clk),
        .i_rst_n(i_rst_n),
        .lrclk_negedge(lrclk_negedge),
        .lrclk_posedge(lrclk_posedge),
        .i_valid(IIR_valid),
        .audio_in(carrier_data),
        .b1 (18'sd59), 
        .b2 (18'sd0), 
        .b3 (-18'sd59), 
        .a2 (18'sd130776), 
        .a3 (-18'sd65416),  
        .audio_out(carrier_audio_out_400Hz)
    );

    //4
    IIR_300Hz carrier_filter_450(
        .clk(i_clk),
        .i_rst_n(i_rst_n),
        .lrclk_negedge(lrclk_negedge),
        .lrclk_posedge(lrclk_posedge),
        .i_valid(IIR_valid),
        .audio_in(carrier_data),
        .b1 (18'sd67), 
        .b2 (18'sd0), 
        .b3 (-18'sd67), 
        .a2 (18'sd130711), 
        .a3 (-18'sd65401),  
        .audio_out(carrier_audio_out_450Hz)
    );
    //5
    IIR_300Hz carrier_filter_500(
        .clk(i_clk),
        .i_rst_n(i_rst_n),
        .lrclk_negedge(lrclk_negedge),
        .lrclk_posedge(lrclk_posedge),
        .i_valid(IIR_valid),
        .audio_in(carrier_data),
        .b1 (18'sd75), 
        .b2 (18'sd0), 
        .b3 (-18'sd75), 
        .a2 (18'sd130636), 
        .a3 (-18'sd65384),
        .audio_out(carrier_audio_out_500Hz)
    );
    //6
    IIR_300Hz carrier_filter_560(
        .clk(i_clk),
        .i_rst_n(i_rst_n),
        .lrclk_negedge(lrclk_negedge),
        .lrclk_posedge(lrclk_posedge),
        .i_valid(IIR_valid),
        .audio_in(carrier_data),
        .b1 (18'sd84), 
        .b2 (18'sd0), 
        .b3 (-18'sd84), 
        .a2 (18'sd130551), 
        .a3 (-18'sd65367), 
        .audio_out(carrier_audio_out_560Hz)
    );
    //7
    IIR_300Hz carrier_filter_620(
        .clk(i_clk),
        .i_rst_n(i_rst_n),
        .lrclk_negedge(lrclk_negedge),
        .lrclk_posedge(lrclk_posedge),
        .i_valid(IIR_valid),
        .audio_in(carrier_data),
        .b1 (18'sd93), 
        .b2 (18'sd0), 
        .b3 (-18'sd93), 
        .a2 (18'sd130455),
        .a3 (-18'sd65349),
        .audio_out(carrier_audio_out_620Hz)
    );
    //8
    IIR_300Hz carrier_filter_680(
        .clk(i_clk),
        .i_rst_n(i_rst_n),
        .lrclk_negedge(lrclk_negedge),
        .lrclk_posedge(lrclk_posedge),
        .i_valid(IIR_valid),
        .audio_in(carrier_data),
        .b1 (18'sd102), 
        .b2 (18'sd0), 
        .b3 (-18'sd102), 
        .a2 (18'sd130345),
        .a3 (-18'sd65331),
        .audio_out(carrier_audio_out_680Hz)
    );
    //9
    IIR_300Hz carrier_filter_750(
        .clk(i_clk),
        .i_rst_n(i_rst_n),
        .lrclk_negedge(lrclk_negedge),
        .lrclk_posedge(lrclk_posedge),
        .i_valid(IIR_valid),
        .audio_in(carrier_data),
        .b1 (18'sd112), 
        .b2 (18'sd0), 
        .b3 (-18'sd112), 
        .a2 (18'sd130220),
        .a3 (-18'sd65311),
        .audio_out(carrier_audio_out_750Hz)
    );
    //10
    IIR_300Hz carrier_filter_820(
        .clk(i_clk),
        .i_rst_n(i_rst_n),
        .lrclk_negedge(lrclk_negedge),
        .lrclk_posedge(lrclk_posedge),
        .i_valid(IIR_valid),
        .audio_in(carrier_data),
        .b1 (18'sd122), 
        .b2 (18'sd0), 
        .b3 (-18'sd122), 
        .a2 (18'sd130080),
        .a3 (-18'sd65291),
        .audio_out(carrier_audio_out_820Hz)
    );
    //11
    IIR_300Hz carrier_filter_888(
        .clk(i_clk),
        .i_rst_n(i_rst_n),
        .lrclk_negedge(lrclk_negedge),
        .lrclk_posedge(lrclk_posedge),
        .i_valid(IIR_valid),
        .audio_in(carrier_data),
        .b1 (18'sd133), 
        .b2 (18'sd0), 
        .b3 (-18'sd133), 
        .a2 (18'sd129921),
        .a3 (-18'sd65269),
        .audio_out(carrier_audio_out_888Hz)
    );
    //12
    IIR_300Hz carrier_filter_964(
        .clk(i_clk),
        .i_rst_n(i_rst_n),
        .lrclk_negedge(lrclk_negedge),
        .lrclk_posedge(lrclk_posedge),
        .i_valid(IIR_valid),
        .audio_in(carrier_data),
        .b1 (18'sd144), 
        .b2 (18'sd0), 
        .b3 (-18'sd144), 
        .a2 (18'sd129743),
        .a3 (-18'sd65247),
        .audio_out(carrier_audio_out_964Hz)
    );
    //13
    IIR_300Hz carrier_filter_1040(
        .clk(i_clk),
        .i_rst_n(i_rst_n),
        .lrclk_negedge(lrclk_negedge),
        .lrclk_posedge(lrclk_posedge),
        .i_valid(IIR_valid),
        .audio_in(carrier_data),
        .b1 (18'sd156), 
        .b2 (18'sd0), 
        .b3 (-18'sd156), 
        .a2 (18'sd129543),
        .a3 (-18'sd65223),
        .audio_out(carrier_audio_out_1040Hz)
    );
    //14
    IIR_300Hz carrier_filter_1125(
        .clk(i_clk),
        .i_rst_n(i_rst_n),
        .lrclk_negedge(lrclk_negedge),
        .lrclk_posedge(lrclk_posedge),
        .i_valid(IIR_valid),
        .audio_in(carrier_data),
        .b1 (18'sd168), 
        .b2 (18'sd0), 
        .b3 (-18'sd168), 
        .a2 (18'sd129318),
        .a3 (-18'sd65198),
        .audio_out(carrier_audio_out_1125Hz)
    );
    //15
    IIR_300Hz carrier_filter_1212(
        .clk(i_clk),
        .i_rst_n(i_rst_n),
        .lrclk_negedge(lrclk_negedge),
        .lrclk_posedge(lrclk_posedge),
        .i_valid(IIR_valid),
        .audio_in(carrier_data),
        .b1 (18'sd181), 
        .b2 (18'sd0), 
        .b3 (-18'sd181), 
        .a2 (18'sd129067), 
        .a3 (-18'sd65173),
        .audio_out(carrier_audio_out_1212Hz)
    );
    //16
    IIR_300Hz carrier_filter_1300(
        .clk(i_clk),
        .i_rst_n(i_rst_n),
        .lrclk_negedge(lrclk_negedge),
        .lrclk_posedge(lrclk_posedge),
        .i_valid(IIR_valid),
        .audio_in(carrier_data),
        .b1 (18'sd195), 
        .b2 (18'sd0), 
        .b3 (-18'sd195), 
        .a2 (18'sd128787), 
        .a3 (-18'sd65145),
        .audio_out(carrier_audio_out_1300Hz)
    );
    //17
    IIR_300Hz carrier_filter_1400(
        .clk(i_clk),
        .i_rst_n(i_rst_n),
        .lrclk_negedge(lrclk_negedge),
        .lrclk_posedge(lrclk_posedge),
        .i_valid(IIR_valid),
        .audio_in(carrier_data),
        .b1 (18'sd209), 
        .b2 (18'sd0), 
        .b3 (-18'sd209), 
        .a2 (18'sd128473), 
        .a3 (-18'sd65117), 
        .audio_out(carrier_audio_out_1400Hz)
    );
    //18
    IIR_300Hz carrier_filter_1500(
        .clk(i_clk),
        .i_rst_n(i_rst_n),
        .lrclk_negedge(lrclk_negedge),
        .lrclk_posedge(lrclk_posedge),
        .i_valid(IIR_valid),
        .audio_in(carrier_data),
        .b1(18'sd224),
        .b2(18'sd0),
        .b3(-18'sd224),
        .a2(18'sd128113),
        .a3(-18'sd65086),
        .audio_out(carrier_audio_out_1500Hz)
    );
    //19
    IIR_300Hz carrier_filter_1600(
        .clk(i_clk),
        .i_rst_n(i_rst_n),
        .lrclk_negedge(lrclk_negedge),
        .lrclk_posedge(lrclk_posedge),
        .i_valid(IIR_valid),
        .audio_in(carrier_data),
        .b1 (18'sd239), 
        .b2 (18'sd0), 
        .b3 (-18'sd239), 
        .a2 (18'sd127735), 
        .a3 (-18'sd65056),
        .audio_out(carrier_audio_out_1600Hz)
    );
    //20
    IIR_300Hz carrier_filter_1700(
            .clk(i_clk),
            .i_rst_n(i_rst_n),
            .lrclk_negedge(lrclk_negedge),
            .lrclk_posedge(lrclk_posedge),
            .i_valid(IIR_valid),
            .audio_in(carrier_data),
            .b1 (18'sd255), 
            .b2 (18'sd0), 
            .b3 (-18'sd255), 
            .a2 (18'sd127303), 
            .a3 (-18'sd65024), 
            .audio_out(carrier_audio_out_1700Hz)
    );
    //21
    IIR_300Hz carrier_filter_1820(
            .clk(i_clk),
            .i_rst_n(i_rst_n),
            .lrclk_negedge(lrclk_negedge),
            .lrclk_posedge(lrclk_posedge),
            .i_valid(IIR_valid),
            .audio_in(carrier_data),
            .b1 (18'sd272), 
            .b2 (18'sd0), 
            .b3 (-18'sd272), 
            .a2 (18'sd126823),
            .a3 (-18'sd64990),
            .audio_out(carrier_audio_out_1820Hz)
    );
    //22
    IIR_300Hz carrier_filter_1944(
            .clk(i_clk),
            .i_rst_n(i_rst_n),
            .lrclk_negedge(lrclk_negedge),
            .lrclk_posedge(lrclk_posedge),
            .i_valid(IIR_valid),
            .audio_in(carrier_data),
            .b1 (18'sd290), 
            .b2 (18'sd0), 
            .b3 (-18'sd290), 
            .a2 (18'sd126289), 
            .a3 (-18'sd64954),
            .audio_out(carrier_audio_out_1944Hz)
    );
    //23
    IIR_300Hz carrier_filter_2070(
            .clk(i_clk),
            .i_rst_n(i_rst_n),
            .lrclk_negedge(lrclk_negedge),
            .lrclk_posedge(lrclk_posedge),
            .i_valid(IIR_valid),
            .audio_in(carrier_data),
            .b1 (18'sd309), 
            .b2 (18'sd0), 
            .b3 (-18'sd309), 
            .a2 (18'sd125698), 
            .a3 (-18'sd64917),
            .audio_out(carrier_audio_out_2070Hz)
    );
    //24
    IIR_300Hz carrier_filter_2200(
            .clk(i_clk),
            .i_rst_n(i_rst_n),
            .lrclk_negedge(lrclk_negedge),
            .lrclk_posedge(lrclk_posedge),
            .i_valid(IIR_valid),
            .audio_in(carrier_data),
            .b1 (18'sd328), 
            .b2 (18'sd0), 
            .b3 (-18'sd328), 
            .a2 (18'sd125042),
            .a3 (-18'sd64878),
            .audio_out(carrier_audio_out_2200Hz)
    );
    //25
    IIR_300Hz carrier_filter_2340(
            .clk(i_clk),
            .i_rst_n(i_rst_n),
            .lrclk_negedge(lrclk_negedge),
            .lrclk_posedge(lrclk_posedge),
            .i_valid(IIR_valid),
            .audio_in(carrier_data),
            .b1 (18'sd349), 
            .b2 (18'sd0), 
            .b3 (-18'sd349), 
            .a2 (18'sd124317),
            .a3 (-18'sd64837),
            .audio_out(carrier_audio_out_2340Hz)
    );
    //26
    IIR_300Hz carrier_filter_2480(
            .clk(i_clk),
            .i_rst_n(i_rst_n),
            .lrclk_negedge(lrclk_negedge),
            .lrclk_posedge(lrclk_posedge),
            .i_valid(IIR_valid),
            .audio_in(carrier_data),
            .b1 (18'sd370), 
            .b2 (18'sd0), 
            .b3 (-18'sd370), 
            .a2 (18'sd123514),
            .a3 (-18'sd64794),
            .audio_out(carrier_audio_out_2480Hz)
    );
    //27
    IIR_300Hz carrier_filter_2630(
            .clk(i_clk),
            .i_rst_n(i_rst_n),
            .lrclk_negedge(lrclk_negedge),
            .lrclk_posedge(lrclk_posedge),
            .i_valid(IIR_valid),
            .audio_in(carrier_data),
            .b1 (18'sd392), 
            .b2 (18'sd0), 
            .b3 (-18'sd392), 
            .a2 (18'sd122627),
            .a3 (-18'sd64750),
            .audio_out(carrier_audio_out_2630Hz)
    );
    //28
    IIR_300Hz carrier_filter_2800(
            .clk(i_clk),
            .i_rst_n(i_rst_n),
            .lrclk_negedge(lrclk_negedge),
            .lrclk_posedge(lrclk_posedge),
            .i_valid(IIR_valid),
            .audio_in(carrier_data),
            .b1 (18'sd416), 
            .b2 (18'sd0), 
            .b3 (-18'sd416), 
            .a2 (18'sd121647),
            .a3 (-18'sd64703),
            .audio_out(carrier_audio_out_2800Hz)
    );
    //29
    IIR_300Hz carrier_filter_3000(
            .clk(i_clk),
            .i_rst_n(i_rst_n),
            .lrclk_negedge(lrclk_negedge),
            .lrclk_posedge(lrclk_posedge),
            .i_valid(IIR_valid),
            .audio_in(carrier_data),
            .b1 (18'sd440), 
            .b2 (18'sd0), 
            .b3 (-18'sd440), 
            .a2 (18'sd120566), 
            .a3 (-18'sd64654), 
            .audio_out(carrier_audio_out_3000Hz)
    );
    //30
    IIR_300Hz carrier_filter_3130(
            .clk(i_clk),
            .i_rst_n(i_rst_n),
            .lrclk_negedge(lrclk_negedge),
            .lrclk_posedge(lrclk_posedge),
            .i_valid(IIR_valid),
            .audio_in(carrier_data),
            .b1 (18'sd466), 
            .b2 (18'sd0), 
            .b3 (-18'sd466), 
            .a2 (18'sd119374), 
            .a3 (-18'sd64603), 
            .audio_out(carrier_audio_out_3130Hz)
    );
    //31
    IIR_300Hz carrier_filter_3300(
            .clk(i_clk),
            .i_rst_n(i_rst_n),
            .lrclk_negedge(lrclk_negedge),
            .lrclk_posedge(lrclk_posedge),
            .i_valid(IIR_valid),
            .audio_in(carrier_data),
            .b1 (18'sd493), 
            .b2 (18'sd0), 
            .b3 (-18'sd493), 
            .a2 (18'sd118061),
            .a3 (-18'sd64549),
            .audio_out(carrier_audio_out_3300Hz)
    );
    //32
    IIR_300Hz carrier_filter_3500(
            .clk(i_clk),
            .i_rst_n(i_rst_n),
            .lrclk_negedge(lrclk_negedge),
            .lrclk_posedge(lrclk_posedge),
            .i_valid(IIR_valid),
            .audio_in(carrier_data),
            .b1 (18'sd521), 
            .b2 (18'sd0), 
            .b3 (-18'sd521), 
            .a2 (18'sd116615),
            .a3 (-18'sd64493),
            .audio_out(carrier_audio_out_3500Hz)
    );
	 
    //sequential circuit


endmodule