const std = @import("std");
const assert = std.debug.assert;
const util = @import("util.zig");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

const days = [_]*const fn (std.mem.Allocator, []const u8) anyerror!void{
    @import("day1.zig").day1,
    @import("day2.zig").day2,
    @import("day3.zig").day3Part2,
    @import("day4.zig").day4,
    @import("day5.zig").day5,
    @import("day6.zig").day6,
    @import("day7.zig").day7,
    @import("day8.zig").day8,
    @import("day9.zig").day9,
};

pub fn main() !void {
    var args = try std.process.argsWithAllocator(allocator);
    defer args.deinit();

    const skipped = args.skip();
    if (!skipped) {
        std.debug.print("missing argument, expected no of days\n", .{});
        return;
    }

    var day: u32 = 0;
    if (args.next()) |num_str| {
        day = try std.fmt.parseInt(u32, num_str, 10);
        if (day == 0 or days.len < day) {
            return error.InvalidDayError;
        }
    } else return error.MissingDayArgument;

    var is_test = false;
    if (args.next()) |test_str| {
        if (std.mem.eql(u8, test_str, "test")) is_test = true;
    }

    var input_fname: []const u8 = undefined;
    if (is_test) {
        input_fname = try std.fmt.allocPrint(allocator, "{}.test.input", .{day});
    } else {
        input_fname = try std.fmt.allocPrint(allocator, "{}.input", .{day});
    }

    const data = try std.fs.cwd().readFileAlloc(allocator, input_fname, 1_000_000_000);
    defer allocator.free(data);
    allocator.free(input_fname);
    const dayFn = days[day - 1];
    try dayFn(allocator, data);
}
