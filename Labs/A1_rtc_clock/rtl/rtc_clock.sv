module rtc_clock (
	// Рабочая частота модуля - 1KHz
	input  wire        clk_i,
	input  wire        srst_i,

	input  wire  [2:0] cmd_type_i,
	input  wire  [9:0] cmd_data_i,
	input  wire        cmd_valid_i,

	output logic [4:0] hours_o,
	output logic [5:0] minutes_o,
	output logic [5:0] seconds_o,
	output logic [9:0] milliseconds_o
);

typedef enum logic [2:0] { RESET_CMD    = 3'b000,
                           SET12H_CMD   = 3'b001,
                           SET_MSEC_CMD = 3'b100,
                           SET_SEC_CMD  = 3'b101,
                           SET_MIN_CMD  = 3'b110,
                           SET_HOUR_CMD = 3'b111  } Cmd_Type;
Cmd_Type cmd_decoded;

assign cmd_decoded = Cmd_Type'(cmd_type_i);


logic [4:0] cnt_hours;
logic [5:0] cnt_minutes;
logic [5:0] cnt_seconds;
logic [9:0] cnt_milliseconds;

logic [4:0] cnt_hours_new;
logic [5:0] cnt_minutes_new;
logic [5:0] cnt_seconds_new;
logic [9:0] cnt_milliseconds_new;


always_ff @(posedge clk_i)
	begin : sync_clock_work
		if( srst_i )
			begin
				cnt_hours        <= '0;
				cnt_minutes      <= '0;
				cnt_seconds      <= '0;
				cnt_milliseconds <= '0;
			end
		else
			begin
				cnt_hours        <= cnt_hours_new;
				cnt_minutes      <= cnt_minutes_new;
				cnt_seconds      <= cnt_seconds_new;
				cnt_milliseconds <= cnt_milliseconds_new;
			end
	end

always_comb
	begin : clock_next_state
		// Clock count and overflow control
		cnt_milliseconds_new = cnt_milliseconds + 1'b1;
		cnt_seconds_new = cnt_seconds;
		cnt_minutes_new = cnt_minutes;
		cnt_hours_new = cnt_hours;

		if( cnt_milliseconds == 'd999 )
			begin
				cnt_milliseconds_new = 0;
				cnt_seconds_new      = cnt_seconds + 1'b1;
				if( cnt_seconds == 'd59 )
					begin
						cnt_seconds_new = 0;
						cnt_minutes_new = cnt_minutes + 1'b1;
						if( cnt_minutes == 'd59 )
							begin
								cnt_minutes_new = 0;
								cnt_hours_new   = cnt_hours + 1'b1;
								if( cnt_hours == 'd23 )
									cnt_hours_new = 0;
							end
					end
			end

		// Command dispatch
		if( cmd_valid_i == 1'b1 )
			begin
				case (cmd_decoded)
					RESET_CMD:
						begin
							cnt_hours_new        = '0;
							cnt_minutes_new      = '0;
							cnt_seconds_new      = '0;
							cnt_milliseconds_new = '0;
						end

					SET12H_CMD:
						begin
							cnt_hours_new        = 'd12;
							cnt_minutes_new      = '0;
							cnt_seconds_new      = '0;
							cnt_milliseconds_new = '0;
						end

					SET_HOUR_CMD:
						cnt_hours_new = cmd_data_i[4:0];

					SET_MIN_CMD:
						cnt_minutes_new = cmd_data_i[5:0];

					SET_SEC_CMD:
						cnt_seconds_new = cmd_data_i[5:0];

					SET_MSEC_CMD:
						cnt_milliseconds_new = cmd_data_i;

				endcase
			end
	end

always_comb
	begin : clock_output_generate
		hours_o        = cnt_hours;
		minutes_o      = cnt_minutes;
		seconds_o      = cnt_seconds;
		milliseconds_o = cnt_milliseconds;
	end

endmodule
