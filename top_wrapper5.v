`timescale 1ns / 1ps

module top_wrapper5(
  input  wire        aclk,
  input  wire        aresetn,

  // INPUT AXIS
  input  wire [7:0] in_data,
  input  wire        in_valid,
  input  wire        in_last,
  output wire        in_ready,

  // CONFIG AXIS
  input  wire [7:0]  config_data,
  input  wire        config_valid,
  output wire        config_ready,

  // OUTPUT AXIS
  output wire [7:0] out_data,
  output wire        out_valid,
  output wire        out_last,
  input  wire        out_ready
);

  // =======================
  // Internal wires
  // =======================
  wire [15:0] s_axis_data_tdata;
  wire [15:0] m_axis_data_tdata;

  // Pad imaginary part = 0
  assign s_axis_data_tdata = {8'd0, in_data};
  

  wire
  event_frame_started,
  event_tlast_unexpected,
  event_tlast_missing,
  event_status_channel_halt,
  event_data_in_channel_halt,
  event_data_out_channel_halt; // Additional Event Signals
  

  // =======================
  // FFT IP
  // =======================
  FFT5 FFT_IP (
    .aclk(aclk),
    .aresetn(aresetn),

    // CONFIG
    .s_axis_config_tdata (config_data),
    .s_axis_config_tvalid(config_valid),
    .s_axis_config_tready(config_ready),

    // INPUT DATA
    .s_axis_data_tdata (s_axis_data_tdata),
    .s_axis_data_tvalid(in_valid),
    .s_axis_data_tready(in_ready),
    .s_axis_data_tlast (in_last),

    // OUTPUT DATA
    .m_axis_data_tdata (m_axis_data_tdata),
    .m_axis_data_tvalid(out_valid),
    .m_axis_data_tready(out_ready),
    .m_axis_data_tlast (out_last),

    // EVENTS (optional)
    .event_frame_started(),
    .event_tlast_unexpected(),
    .event_tlast_missing(),
    .event_status_channel_halt(),
    .event_data_in_channel_halt(),
    .event_data_out_channel_halt()
  );

  // Real part only
  assign out_data = m_axis_data_tdata[7:0];

endmodule

