const std = @import("std");
const input = @embedFile("./input.txt");

pub inline fn parseDigit(char: u8) u8 {
    return char - '0';
}

const none: u32 = std.math.maxInt(u32);

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

    var buf_index: u64 = 0;
    while (index < input.len and input[index] != '\n') : (index += 1) {
        const free_block = index % 2 == 1;
        const id = index / 2;
        const val = parseDigit(input[index]);
        var i: u8 = 0;
        while (i < val) : (i += 1) {
            result_buffer[buf_index + i] = if (free_block) none else @intCast(id);
        }
        buf_index += i;
    }

    for (result_buffer) |val| {
        if (val == none) {
            std.debug.print("|.|", .{});
        } else {
            std.debug.print("|{d}|", .{val});
        }
    }
    std.debug.print("\n", .{});

    var blk_index: u64 = result_buffer.len - 1;
    while (blk_index > 0) {
        while (blk_index > 0 and result_buffer[blk_index] == none) : (blk_index -= 1) {}
        var size: u64 = 0;
        while (blk_index - size > 0 and result_buffer[blk_index - size] == result_buffer[blk_index]) : (size += 1) {}
        var empty_index: u64 = 1;
        var last_empty: u64 = 0;
        while (empty_index < blk_index) : (empty_index += 1) {
            if (result_buffer[empty_index] == none) {
                if (result_buffer[empty_index - 1] != none) {
                    last_empty = empty_index;
                }
                if (empty_index - last_empty + 1 == size) {
                    for (last_empty..empty_index + 1, blk_index - size + 1..blk_index + 1) |i, j| {
                        const temp = result_buffer[j];
                        result_buffer[j] = result_buffer[i];
                        result_buffer[i] = temp;
                    }
                }
            }
        }
        blk_index -= size;
    }

    for (result_buffer, 0..) |val, ind| {
        if (val == none) {
            std.debug.print("|.|", .{});
        } else {
            std.debug.print("|{d}|", .{val});
            result += ind * val;
        }
    }

    std.debug.print("\nresult: {d}\n", .{result});
}
