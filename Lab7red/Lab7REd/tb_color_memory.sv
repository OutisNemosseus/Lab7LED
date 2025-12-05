// Testbench for color_memory module
// Tests: color_memory.sv
// Verifies that all 5 color addresses return correct RGB values

`timescale 1ns / 1ps

module tb_color_memory;

    // Signals
    logic [2:0] addr;
    logic [23:0] data_out;

    // Expected colors
    logic [23:0] expected_colors [0:4] = '{
        24'hFF_FF_FF,  // 0: White
        24'h00_00_FF,  // 1: Red
        24'h00_00_00,  // 2: Off
        24'hFF_00_00,  // 3: Green
        24'hFF_FF_00   // 4: Teal
    };

    // Instantiate DUT
    color_memory dut (
        .addr(addr),
        .data_out(data_out)
    );

    // Test procedure
    initial begin
        $display("=== Color Memory Testbench ===");
        $display("Time\tAddr\tData Out\tExpected\tStatus");

        // Test all 5 addresses
        for (int i = 0; i < 5; i++) begin
            addr = i[2:0];
            #10;  // Wait for combinational logic

            if (data_out == expected_colors[i]) begin
                $display("%0t\t%0d\t%h\t%h\tPASS", $time, addr, data_out, expected_colors[i]);
            end else begin
                $display("%0t\t%0d\t%h\t%h\tFAIL", $time, addr, data_out, expected_colors[i]);
                $error("Color mismatch at address %0d", i);
            end
        end

        // Test wrap-around and invalid addresses
        addr = 3'd5;
        #10;
        $display("%0t\t%0d\t%h\t(default)\tInfo", $time, addr, data_out);

        addr = 3'd7;
        #10;
        $display("%0t\t%0d\t%h\t(default)\tInfo", $time, addr, data_out);

        $display("\n=== Color Memory Test Complete ===\n");
        $finish;
    end

endmodule
