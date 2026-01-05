module tb_FFT4();
  
  reg aclk; // Making reg type for inputs
  reg aresetn;
  
  reg [7:0] in_data;
  reg in_valid;
  reg in_last;
  wire in_ready;
  
  reg [7:0] config_data;
  reg config_valid;
  wire config_ready; // Wire for outputs for all Groups of Stream Signals
  
  wire [7:0] out_data;
  wire out_valid;
  wire out_last;
  reg out_ready;
  
  reg [7:0] input_data [15:0]; // Creating a ROM, for the input data to the FFT IP
  
  integer i;
  
  top_wrapper5 tb_in( // Warpper for the Top Module
    .aclk(aclk),
    .aresetn(aresetn),
    
    .in_data(in_data),
    .in_valid(in_valid),
    .in_ready(in_ready),
    .in_last(in_last),
    
    .config_data(config_data),
    .config_valid(config_valid),
    .config_ready(config_ready),
    
    .out_data(out_data),
    .out_valid(out_valid),
    .out_last(out_last),
    .out_ready(out_ready)
  );
  
  always
    begin
      #5 aclk = ~aclk; // CLK with 10 unit period
    end
  
  initial begin
    aclk = 0;
    aresetn = 0;
    
    in_valid = 1'b0;
    in_data = 8'd0;
    in_last = 1'b0;
    
    out_ready = 1'b1;  // Initiating OUT_READY to 1, inorder to tell the FFT that outputs can be generated whenver ready Faiure to do so leads to "back-pressure"
    config_data = 8'd0;
    config_valid = 1'b0;
  end
  
  initial begin
    #70 // As Reset needs to be activated for atleast 2 cycles we have given 70 units of delay 
    aresetn = 1;
    
    input_data[0] = 8'b00000000;
    input_data[1] = 8'b00000111;
    input_data[2] = 8'b00001010;
    input_data[3] = 8'b00000111;
    input_data[4] = 8'b00000000;
    input_data[5] = 8'b11111001;
    input_data[6] = 8'b11110110;
    input_data[7] = 8'b11111001;
    input_data[8] = 8'b00000000;
    input_data[9] = 8'b00000111;
    input_data[10] = 8'b00001010;
    input_data[11] = 8'b00000111;
    input_data[12] = 8'b00000000;
    input_data[13] = 8'b11111001;
    input_data[14] = 8'b11110110;
    input_data[15] = 8'b11111001; // Input Data generated from python
    
  end
  
  initial begin // Config Data initial block
    
    #100
    config_data = 1;
    #5 config_valid = 1;
    
    while (config_ready == 0)
      begin
        config_valid = 1;
      end
    #5 config_valid = 0;
  end
  
  initial begin // Input Post Initial Block
    #100
    for(i = 15; i >= 0; i = i-1)
      begin
        #10
        if(i==0) 
          begin  // Last signal needs to be genrated once the last data is sent 
                 // In this case once we reach the 0th position we can assert last signal to be 1.
            in_last = 1'b1;
          end
        
        in_data = input_data[i]; // Passing data stored in memory to in_data port
        in_valid = 1'b1; // Once data is put on the bus make the valid HIGH.
        
        while (in_ready == 0) begin  // Waiting for AXI Handshake, for the in_ready to be 1.
          in_valid = 1'b1;
        end
      end
    
    #10
    in_valid = 1'b0;
    in_last = 1'b0;
    // Once all the transactions are completed assert the valid and last to 0.
  end
  
  initial begin  // Output Port Initial Block
    #100 // Giving delay so that all the input data can be stored in ROM
    
    wait(out_valid == 1);
    #300 out_ready = 1'b0; // Adding a 300 unit delay so that all the data that needs to be but on the Data Bus
  end

endmodule
