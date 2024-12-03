const std = @import("std");
const input = @embedFile("./input.txt");

const State = enum {
    mul_m,
    mul_u,
    mul_l,
    lp,
    first_digit,
    second_digit,
};

pub fn main() !void {
    var result: u64 = 0;
    var i: u64 = 0;
    var num_index: usize = 0;
    var first_num: u64 = 0;
    var state: State = .mul_m;
    while (input[i] != 0) : (i += 1) {
        const char: u8 = input[i];
        switch (state) {
            .mul_m => switch (char) {
                'm' => state = .mul_u,
                else => {},
            },
            .mul_u => switch (char) {
                'u' => state = .mul_l,
                else => state = .mul_m,
            },
            .mul_l => switch (char) {
                'l' => state = .lp,
                else => state = .mul_m,
            },
            .lp => switch (char) {
                '(' => {
                    num_index = i + 1;
                    state = .first_digit;
                },
                else => state = .mul_m,
            },
            .first_digit => switch (char) {
                '0'...'9' => {},
                ',' => {
                    first_num = try std.fmt.parseInt(u64, input[num_index..i], 10);
                    num_index = i + 1;
                    state = .second_digit;
                },
                else => state = .mul_m,
            },
            .second_digit => switch (char) {
                '0'...'9' => {},
                ')' => {
                    const second_num = try std.fmt.parseInt(u64, input[num_index..i], 10);
                    result += first_num * second_num;
                    state = .mul_m;
                },
                else => state = .mul_m,
            },
        }
    }
    std.debug.print("result: {d}\n", .{result});
}
