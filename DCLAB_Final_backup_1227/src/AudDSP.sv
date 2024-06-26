module AudDSP(
	input i_rst_n,
	input i_clk,
	input i_daclrck,
	input [6:0] i_shift,
	input [15:0] i_sram_data,
    input [15:0] i_carrier_data,
    input i_valid,
	output[15:0] o_dac_data,
    output [1:0] o_state,
    output [5:0] o_led
);

    //parameters
    //localparam end_addr = 1024000;

    //registers and wires
    localparam INIT=0;
    localparam ACTIVE=1;
    logic state_r,state_w;
    logic signed [15:0] o_dac_data_r, o_dac_data_w;
    logic signed [15:0] prev_data_r, prev_data_w;
    logic [3:0]  ratio;
    logic        prev_daclrck_r, prev_daclrck_w;
    logic o_fin_next;
	logic signed [15:0] chosen_data,chosen_filter_data,chosen_carrier_filter_data;
	logic signed[15:0] IIR_audio_out_300Hz,IIR_audio_out_350Hz,IIR_audio_out_400Hz,IIR_audio_out_450Hz,IIR_audio_out_500Hz,IIR_audio_out_560Hz,IIR_audio_out_620Hz,IIR_audio_out_680Hz,IIR_audio_out_750Hz,IIR_audio_out_820Hz,IIR_audio_out_888Hz,IIR_audio_out_964Hz,IIR_audio_out_1040Hz,IIR_audio_out_1125Hz,IIR_audio_out_1212Hz,IIR_audio_out_1300Hz,IIR_audio_out_1400Hz,IIR_audio_out_1500Hz,IIR_audio_out_1600Hz,IIR_audio_out_1700Hz,IIR_audio_out_1820Hz,IIR_audio_out_1944Hz,IIR_audio_out_2070Hz,IIR_audio_out_2200Hz,IIR_audio_out_2340Hz,IIR_audio_out_2480Hz,IIR_audio_out_2630Hz,IIR_audio_out_2800Hz,IIR_audio_out_3000Hz,IIR_audio_out_3130Hz,IIR_audio_out_3300Hz,IIR_audio_out_3500Hz;
    logic signed[15:0] carrier_audio_out_300Hz,carrier_audio_out_350Hz,carrier_audio_out_400Hz,carrier_audio_out_450Hz,carrier_audio_out_500Hz,carrier_audio_out_560Hz,carrier_audio_out_620Hz,carrier_audio_out_680Hz,carrier_audio_out_750Hz,carrier_audio_out_820Hz,carrier_audio_out_888Hz,carrier_audio_out_964Hz,carrier_audio_out_1040Hz,carrier_audio_out_1125Hz,carrier_audio_out_1212Hz,carrier_audio_out_1300Hz,carrier_audio_out_1400Hz,carrier_audio_out_1500Hz,carrier_audio_out_1600Hz,carrier_audio_out_1700Hz,carrier_audio_out_1820Hz,carrier_audio_out_1944Hz,carrier_audio_out_2070Hz,carrier_audio_out_2200Hz,carrier_audio_out_2340Hz,carrier_audio_out_2480Hz,carrier_audio_out_2630Hz,carrier_audio_out_2800Hz,carrier_audio_out_3000Hz,carrier_audio_out_3130Hz,carrier_audio_out_3300Hz,carrier_audio_out_3500Hz;
    logic signed[15:0] abs_IIR_audio_out_300Hz,abs_IIR_audio_out_350Hz,abs_IIR_audio_out_400Hz,abs_IIR_audio_out_450Hz,abs_IIR_audio_out_500Hz,abs_IIR_audio_out_560Hz,abs_IIR_audio_out_620Hz,abs_IIR_audio_out_680Hz,abs_IIR_audio_out_750Hz,abs_IIR_audio_out_820Hz,abs_IIR_audio_out_888Hz,abs_IIR_audio_out_964Hz,abs_IIR_audio_out_1040Hz,abs_IIR_audio_out_1125Hz,abs_IIR_audio_out_1212Hz,abs_IIR_audio_out_1300Hz,abs_IIR_audio_out_1400Hz,abs_IIR_audio_out_1500Hz,abs_IIR_audio_out_1600Hz,abs_IIR_audio_out_1700Hz,abs_IIR_audio_out_1820Hz,abs_IIR_audio_out_1944Hz,abs_IIR_audio_out_2070Hz,abs_IIR_audio_out_2200Hz,abs_IIR_audio_out_2340Hz,abs_IIR_audio_out_2480Hz,abs_IIR_audio_out_2630Hz,abs_IIR_audio_out_2800Hz,abs_IIR_audio_out_3000Hz,abs_IIR_audio_out_3130Hz,abs_IIR_audio_out_3300Hz,abs_IIR_audio_out_3500Hz;
    // logic signed [15:0] IIR_lowpass_2000Hz;
    logic lrclk_posedge, lrclk_negedge;
    logic [20:0] init_count_r,init_count_w;
    logic IIR_valid;
    assign IIR_valid = i_valid;
    // assign IIR_valid = (state_r==ACTIVE);
    assign o_led[0] =IIR_valid;
    assign o_led[1]=i_shift[0];
    assign o_led[2]=init_count_r[20];


    assign lrclk_posedge = (~prev_daclrck_r) && i_daclrck;
    assign lrclk_negedge = prev_daclrck_r && (~i_daclrck);
    assign o_dac_data_w = chosen_data;
	assign o_state= state_r;
    //output
    assign o_dac_data=o_dac_data_r;
    //combinational circuit

    // Testing delay sram_data
    logic [15:0] sram_data_D1, sram_data_D2;
    always_comb begin
        case(i_shift[0])
            1'd0: chosen_data=i_sram_data;
            default: chosen_data=chosen_filter_data;
        endcase
    end

    always_ff@(posedge i_clk or negedge i_rst_n) begin
        if(~i_rst_n) begin
            sram_data_D1 <= 16'b0;
            sram_data_D2 <= 16'b0;
        end
        else begin
            sram_data_D1 <= i_sram_data;
            sram_data_D2 <= sram_data_D1;
        end
    end

    always_comb begin
        state_w=state_r;
        if(state_r==INIT) begin
            if(init_count_r[20])
                state_w=ACTIVE;
        end
    end
	always_ff@(posedge i_clk or negedge i_rst_n) begin
        if(~i_rst_n) begin
            state_r<=INIT;
        end
        else begin
            state_r<=ACTIVE;
        end
    end

    always_comb begin
        if(state_r==INIT) begin
            init_count_w=init_count_r+1;
        end
        else begin
            init_count_w=init_count_r;
        end
    end
	always_ff@(posedge i_clk or negedge i_rst_n) begin
        if(~i_rst_n) begin
            init_count_r<=0;
        end
        else begin
            init_count_r<=init_count_w;
        end
    end

	// always_comb begin
    //     case(i_shift[0])
    //         1'd0:    chosen_data = i_sram_data;
    //         default: chosen_data = chosen_filter_data;
    //     endcase
    // end


    // IIR chosen
    always_comb begin
        case(i_shift[5:1]) 
            // 5'd0:   chosen_filter_data = IIR_audio_out_300Hz+IIR_audio_out_350Hz+IIR_audio_out_400Hz+IIR_audio_out_450Hz+IIR_audio_out_500Hz+IIR_audio_out_560Hz+IIR_audio_out_620Hz+IIR_audio_out_680Hz+IIR_audio_out_750Hz+IIR_audio_out_820Hz+IIR_audio_out_888Hz+IIR_audio_out_964Hz+IIR_audio_out_1040Hz+IIR_audio_out_1125Hz+IIR_audio_out_1212Hz+IIR_audio_out_1300Hz+IIR_audio_out_1400Hz+IIR_audio_out_1500Hz+IIR_audio_out_1600Hz+IIR_audio_out_1700Hz+IIR_audio_out_1820Hz+IIR_audio_out_1944Hz+IIR_audio_out_2070Hz+IIR_audio_out_2200Hz+IIR_audio_out_2340Hz+IIR_audio_out_2480Hz+IIR_audio_out_2630Hz+IIR_audio_out_2800Hz+IIR_audio_out_3000Hz+IIR_audio_out_3130Hz+IIR_audio_out_3300Hz+IIR_audio_out_3500Hz;
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
    assign multi_450 = IIR_audio_out_450Hz * carrier_audio_out_450Hz;
    assign multi_500 = abs_IIR_audio_out_300Hz * carrier_audio_out_300Hz;
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
        .audio_in(i_carrier_data),
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
        .audio_in(i_carrier_data),
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
        .audio_in(i_carrier_data),
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
        .audio_in(i_carrier_data),
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
        .audio_in(i_carrier_data),
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
        .audio_in(i_carrier_data),
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
        .audio_in(i_carrier_data),
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
        .audio_in(i_carrier_data),
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
        .audio_in(i_carrier_data),
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
        .audio_in(i_carrier_data),
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
        .audio_in(i_carrier_data),
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
        .audio_in(i_carrier_data),
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
        .audio_in(i_carrier_data),
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
        .audio_in(i_carrier_data),
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
        .audio_in(i_carrier_data),
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
        .audio_in(i_carrier_data),
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
        .audio_in(i_carrier_data),
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
        .audio_in(i_carrier_data),
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
        .audio_in(i_carrier_data),
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
            .audio_in(i_carrier_data),
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
            .audio_in(i_carrier_data),
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
            .audio_in(i_carrier_data),
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
            .audio_in(i_carrier_data),
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
            .audio_in(i_carrier_data),
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
            .audio_in(i_carrier_data),
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
            .audio_in(i_carrier_data),
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
            .audio_in(i_carrier_data),
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
            .audio_in(i_carrier_data),
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
            .audio_in(i_carrier_data),
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
            .audio_in(i_carrier_data),
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
            .audio_in(i_carrier_data),
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
            .audio_in(i_carrier_data),
            .b1 (18'sd521), 
            .b2 (18'sd0), 
            .b3 (-18'sd521), 
            .a2 (18'sd116615),
            .a3 (-18'sd64493),
            .audio_out(carrier_audio_out_3500Hz)
    );
	 
    //sequential circuit
    always_ff@(posedge i_clk or negedge i_rst_n) begin
        if(~i_rst_n) begin
            o_dac_data_r    <= 16'b0;
            prev_data_r     <= 16'b0;
            prev_daclrck_r  <= 1'b0;
        end
        else begin
            o_dac_data_r    <= o_dac_data_w;
            prev_data_r     <= prev_data_w;
            prev_daclrck_r  <= prev_daclrck_w;
        end
    end

endmodule