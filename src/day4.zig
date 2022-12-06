const std = @import("std");
const assert = std.debug.assert;

const Range = struct {
    start: usize,
    end: usize,
    fn contains(a: Range, b: Range) bool {
        return a.start <= b.start and a.end >= b.end;
    }

    fn overlap(a: Range, b: Range) bool {
        return a.start <= b.end and b.start <= a.end;
    }
};
pub fn day4(_: std.mem.Allocator, input: []const u8) !void {
    var covered: usize = 0;
    var overlap: usize = 0;
    var lines = std.mem.tokenize(u8, input, "\n");
    while (lines.next()) |line| {
        var shifts = std.mem.tokenize(u8, line, ",");
        var shift_one = parseRange(shifts.next().?);
        var shift_two = parseRange(shifts.next().?);
        if (shift_one.contains(shift_two) or shift_two.contains(shift_one)) covered += 1;
        if (shift_one.overlap(shift_two)) overlap += 1;
    }
    std.debug.print("covered shifts: {}\toverlapped shifts: {}\n", .{ covered, overlap });
}

fn parseRange(input: []const u8) Range {
    var shift = std.mem.tokenize(u8, input, "-");
    return .{
        .start = std.fmt.parseInt(u8, shift.next().?, 10) catch unreachable,
        .end = std.fmt.parseInt(u8, shift.next().?, 10) catch unreachable,
    };
}
