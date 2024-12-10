const std = @import("std");
const input = @embedFile("./input.txt");

pub inline fn parseDigit(char: u8) u8 {
    return char - '0';
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();

    var result: u64 = 0;
    var new_size: usize = 0;
    var block_size: usize = 0;

    var index: u64 = 0;

    while (index < input.len and input[index] != '\n') : (index += 1) {
        const val = parseDigit(input[index]);
        if (index % 2 == 0) {
            block_size += @intCast(val);
        }
        new_size += @intCast(val);
    }

    var result_buffer = try alloc.alloc(u32, new_size);
    defer alloc.free(result_buffer);

    index = 0;
    var i: u32 = 0;
    var j: u32 = input.len - 1;
    if (j % 2 == 1) {
        j -= 1;
    }
    var cur_free: u8 = 0;
    var val_i = parseDigit(input[i]);
    var val_j = parseDigit(input[j]);
    while (index < new_size) : (index += 1) {
        const free_block = i % 2 == 1;
        if (free_block) {
            if (i + 1 == j) {
                i += 1;
                val_i = val_j;
                index -= 1;
                continue;
            }
            if (cur_free <= 0) {
                i += 1;
                val_i = parseDigit(input[i]);
                index -= 1;
                continue;
            }
            cur_free -= 1;
            if (val_j <= 0) {
                j -= 2;
                val_j = parseDigit(input[j]);
            }
            result_buffer[index] = j / 2;
            val_j -= 1;
        } else {
            if (val_i <= 0) {
                i += 1;
                if (i >= j) break;
                cur_free = parseDigit(input[i]);
                index -= 1;
                continue;
            }
            val_i -= 1;
            result_buffer[index] = i / 2;
        }
    }

    for (result_buffer, 0..) |val, ind| {
        if (ind >= block_size) break;
        std.debug.print("|{d}|", .{val});
        result += ind * val;
    }

    std.debug.print("\nresult: {d}\n", .{result});
}
