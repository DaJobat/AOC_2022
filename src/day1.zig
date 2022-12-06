const std = @import("std");
const util = @import("util.zig");

pub fn day1(allocator: std.mem.Allocator, input: []const u8) !void {
    var calories = std.ArrayList(u32).init(allocator);
    defer calories.deinit();

    var lines = util.splitLines(input);
    try calories.ensureTotalCapacity(input.len / 3);

    var total: u32 = 0;
    while (lines.next()) |line| {
        if (line.len == 0) {
            try calories.append(total);
            total = 0;
        } else {
            total += try std.fmt.parseInt(u32, line, 10);
        }
    }

    var cals = calories.items;
    const S = struct {
        fn lessThan(context: void, a: u32, b: u32) bool {
            _ = context;
            return std.math.order(a, b) == .gt; //invert the normal less than so we get biggest first
        }
    };

    std.sort.sort(u32, cals, {}, S.lessThan);
    var stdout = std.io.getStdOut().writer();
    try stdout.print("total:\t\t{}\ntop 3 total:\t{}\n", .{ cals[0], cals[0] + cals[1] + cals[2] });
}
