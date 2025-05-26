
// // data_mem.v - synthesizable data memory module

// // data_mem.v - synthesizable data memory module

// module data_mem #(
//     parameter DATA_WIDTH = 32, 
//     parameter ADDR_WIDTH = 32, 
//     parameter MEM_SIZE = 64
// ) (
//     input wire clk,
//     input wire wr_en,
//     input wire [2:0] funct3,
//     input wire [ADDR_WIDTH-1:0] wr_addr,
//     input wire [DATA_WIDTH-1:0] wr_data,
//     output reg [DATA_WIDTH-1:0] rd_data_mem
// );

//     // Memory array declaration
//     reg [DATA_WIDTH-1:0] data_ram [0:MEM_SIZE-1];
    
//     // Address decoding
//     wire [$clog2(MEM_SIZE)-1:0] word_addr;
//     wire [1:0] byte_offset;
//     wire halfword_misaligned;
//     wire word_misaligned;
    
//     assign word_addr = wr_addr[$clog2(MEM_SIZE)+1:2];
//     assign byte_offset = wr_addr[1:0];
//     assign halfword_misaligned = byte_offset[0]; // halfword must be on even byte boundary
//     assign word_misaligned = (byte_offset != 2'b00); // word must be on word boundary
    
//     // Internal signals for read data
//     reg [7:0] byte_data;
//     reg [15:0] half_data;
//     reg [31:0] word_data;
    
//     // Synchronous write logic
//     always @(posedge clk) begin
//         if (wr_en) begin
//             case (funct3)
//                 3'b000: begin // sb (store byte)
//                     case (byte_offset)
//                         2'b00: data_ram[word_addr][7:0]   <= wr_data[7:0];
//                         2'b01: data_ram[word_addr][15:8]  <= wr_data[7:0];
//                         2'b10: data_ram[word_addr][23:16] <= wr_data[7:0];
//                         2'b11: data_ram[word_addr][31:24] <= wr_data[7:0];
//                     endcase
//                 end
//                 3'b001: begin // sh (store halfword)
//                     if (!halfword_misaligned) begin
//                         case (byte_offset[1])
//                             1'b0: data_ram[word_addr][15:0]  <= wr_data[15:0];
//                             1'b1: data_ram[word_addr][31:16] <= wr_data[15:0];
//                         endcase
//                     end
//                 end
//                 3'b010: begin // sw (store word)
//                     if (!word_misaligned) begin
//                         data_ram[word_addr] <= wr_data;
//                     end
//                 end
//                 default: begin
//                     // Do nothing for unsupported store operations
//                 end
//             endcase
//         end
//     end
    
//     // Byte selection for reads
//     always @(*) begin
//         case (byte_offset)
//             2'b00: byte_data = data_ram[word_addr][7:0];
//             2'b01: byte_data = data_ram[word_addr][15:8];
//             2'b10: byte_data = data_ram[word_addr][23:16];
//             2'b11: byte_data = data_ram[word_addr][31:24];
//         endcase
//     end
    
//     // Halfword selection for reads
//     always @(*) begin
//         if (!halfword_misaligned) begin
//             case (byte_offset[1])
//                 1'b0: half_data = data_ram[word_addr][15:0];
//                 1'b1: half_data = data_ram[word_addr][31:16];
//             endcase
//         end else begin
//             half_data = 16'b0; // Return zero for misaligned access
//         end
//     end
    
//     // Word selection for reads
//     always @(*) begin
//         if (!word_misaligned) begin
//             word_data = data_ram[word_addr];
//         end else begin
//             word_data = 32'b0; // Return zero for misaligned access
//         end
//     end
    
//     // Output multiplexer based on funct3
//     always @(*) begin
//         case (funct3)
//             3'b000: begin // lb (load byte signed)
//                 rd_data_mem = {{14{byte_data[7]}}, byte_data};
//             end
//             3'b001: begin // lh (load halfword signed)
//                 rd_data_mem = {{16{half_data[15]}}, half_data};
//             end
//             3'b010: begin // lw (load word)
//                 rd_data_mem = word_data;
//             end
//             3'b100: begin // lbu (load byte unsigned)
//                 rd_data_mem = {24'b0, byte_data};
//             end
//             3'b101: begin // lhu (load halfword unsigned)
//                 rd_data_mem = {16'b0, half_data};
//             end
//             default: begin
//                 rd_data_mem = 32'b0; // Default to zero instead of X
//             end
//         endcase
//     end

// endmodule

// data_mem.v - data memory

module data_mem #(parameter DATA_WIDTH = 32, ADDR_WIDTH = 32, MEM_SIZE = 64) (
    input       clk, wr_en,
    input [2:0] funct3,
    input       [ADDR_WIDTH-1:0] wr_addr, wr_data,
    output reg  [DATA_WIDTH-1:0] rd_data_mem
);

// array of 64 32-bit data
reg [DATA_WIDTH-1:0] data_ram [0:MEM_SIZE-1];

integer i;
initial begin
    for (i = 0; i < MEM_SIZE; i = i + 1) begin
        data_ram[i] = {DATA_WIDTH{1'b0}};
    end
end

// Extract word-aligned address
wire [ADDR_WIDTH-1:0] word_addr = wr_addr[DATA_WIDTH-1:2] % 64;
wire [1:0]add = wr_addr[1:0];

// synchronous write logic
// synchronous write logic
always @(posedge clk) begin
    if (wr_en) begin
        case (funct3)
            3'b000: begin // sb (store byte)
                case (add)
                    2'b00: data_ram[word_addr][7:0]    <= wr_data[7:0];
                    2'b01: data_ram[word_addr][15:8]   <= wr_data[7:0];
                    2'b10: data_ram[word_addr][23:16]  <= wr_data[7:0];
                    2'b11: data_ram[word_addr][31:24]  <= wr_data[7:0];
                endcase
            end
            3'b001: begin // sh (store halfword)
                case (add)
                    2'b00: data_ram[word_addr][15:0]   <= wr_data[15:0];
                    2'b10: data_ram[word_addr][31:16]  <= wr_data[15:0];
                endcase
            end
            3'b010: begin // sw (store word)
                data_ram[word_addr] <= wr_data;
            end
        endcase
    end
end


// asynchronous read logic
always @(*) begin
    case (funct3)
        3'b000: begin // lb (load byte, sign-extended)
            case (add)
                2'b00: rd_data_mem = {{24{data_ram[word_addr][ 7]}}, data_ram[word_addr][ 7: 0]};
                2'b01: rd_data_mem = {{24{data_ram[word_addr][15]}}, data_ram[word_addr][15: 8]};
                2'b10: rd_data_mem = {{24{data_ram[word_addr][23]}}, data_ram[word_addr][23:16]};
                2'b11: rd_data_mem = {{24{data_ram[word_addr][31]}}, data_ram[word_addr][31:24]};
                default: rd_data_mem = 32'bx; 
            endcase
        end
        3'b001: begin // lh (load halfword, sign-extended)
            case (add)
                2'b00: rd_data_mem = {{16{data_ram[word_addr][15]}}, data_ram[word_addr][15: 0]};
                2'b10: rd_data_mem = {{16{data_ram[word_addr][31]}}, data_ram[word_addr][31:16]};
                default: rd_data_mem = 32'bx; 
            endcase
        end
        3'b100: begin // lbu (load byte, zero-extended)
            case (add)
                2'b00: rd_data_mem = {24'b0, data_ram[word_addr][ 7: 0]};
                2'b01: rd_data_mem = {24'b0, data_ram[word_addr][15: 8]};
                2'b10: rd_data_mem = {24'b0, data_ram[word_addr][23:16]};
                2'b11: rd_data_mem = {24'b0, data_ram[word_addr][31:24]};
                default: rd_data_mem = 32'bx; 
            endcase
        end
        3'b101: begin // lhu (load halfword, zero-extended)
            case (add)
                2'b00: rd_data_mem = {16'b0, data_ram[word_addr][15:0]};
                2'b10: rd_data_mem = {16'b0, data_ram[word_addr][31:16]};
                default: rd_data_mem = 32'bx; 
            endcase
        end
        3'b010: rd_data_mem = data_ram[word_addr]; // lw (load word)
        default: rd_data_mem = 32'bx; 
    endcase
end



endmodule
