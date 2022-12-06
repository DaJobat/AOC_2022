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

    std.sort.sort(u32, cals, {}, std.sort.desc(u32));
    var stdout = std.io.getStdOut().writer();
    try stdout.print("total:\t\t{}\ntop 3 total:\t{}\n", .{ cals[0], cals[0] + cals[1] + cals[2] });
}
