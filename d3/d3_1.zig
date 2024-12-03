const std = @import("std");
const input = @embedFile("./input.txt");

const State = enum {
    init,
    do_o,
    do_lp,
    do_dont,
    dont_ap,
    dont_t,
    dont_lp,
    dont_rp,
    mul_u,
    mul_l,
    mul_lp,
    first_digit,
    second_digit,
};

pub fn main() !void {
    var result: u64 = 0;
    var i: u64 = 0;
    var num_index: usize = 0;
    var first_num: u64 = 0;
    var dont: bool = false;
    var state: State = .init;
    while (input[i] != 0) : (i += 1) {
        const char: u8 = input[i];

        // std.debug.print("char: {c} state: {}\n", .{ char, state });
        switch (state) {
            .init => switch (char) {
                'm' => {
                    if (!dont) {
                        state = .mul_u;
                    }
                },
                'd' => state = .do_o,
                else => {},
            },
            .do_o => switch (char) {
                'o' => state = .do_dont,
                else => state = .init,
            },
            .do_dont => switch (char) {
                'n' => state = .dont_ap,
                '(' => state = .do_lp,
                else => state = .init,
            },
            .do_lp => switch (char) {
                ')' => {
                    dont = false;
                    std.debug.print("dont false\n", .{});
                    state = .init;
                },
                else => state = .init,
            },
            .dont_ap => switch (char) {
                '\'' => state = .dont_t,
                else => state = .init,
            },
            .dont_t => switch (char) {
                't' => state = .dont_lp,
                else => state = .init,
            },
            .dont_lp => switch (char) {
                '(' => state = .dont_rp,
                else => state = .init,
            },
            .dont_rp => switch (char) {
                ')' => {
                    dont = true;
                    std.debug.print("dont true\n", .{});
                    state = .init;
                },
                else => state = .init,
            },
            .mul_u => switch (char) {
                'u' => state = .mul_l,
                else => state = .init,
            },
            .mul_l => switch (char) {
                'l' => state = .mul_lp,
                else => state = .init,
            },
            .mul_lp => switch (char) {
                '(' => {
                    num_index = i + 1;
                    state = .first_digit;
                },
                else => state = .init,
            },
            .first_digit => switch (char) {
                '0'...'9' => {},
                ',' => {
                    first_num = try std.fmt.parseInt(u64, input[num_index..i], 10);
                    // std.debug.print("first digit: {d}\n", .{first_num});
                    num_index = i + 1;
                    state = .second_digit;
                },
                else => state = .init,
            },
            .second_digit => switch (char) {
                '0'...'9' => {},
                ')' => {
                    const second_num = try std.fmt.parseInt(u64, input[num_index..i], 10);
                    // std.debug.print("second digit: {d}\n", .{second_num});
                    result += first_num * second_num;
                    state = .init;
                },
                else => state = .init,
            },
        }
    }
    std.debug.print("result: {d}\n", .{result});
}
