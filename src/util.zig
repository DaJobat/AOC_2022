const std = @import("std");
pub fn splitLines(buf: []const u8) std.mem.SplitIterator(u8) {
    return std.mem.split(u8, buf, "\n");
}

pub fn splitSpaces(buf: []const u8) std.mem.SplitIterator(u8) {
    return std.mem.split(u8, buf, " ");
}

pub fn count(buf: []const u8, comptime item: u8) usize {
    var total: usize = 0;
    for (buf) |c| {
        if (c == item) total += 1;
    }
    return total;
}

pub fn tokensToSlice(comptime Element: type, allocator: std.mem.Allocator, tokens: []const Element, sep: []const Element) ![][]const Element {
    var iter = std.mem.tokenize(Element, tokens, sep);
    var list = std.ArrayList([]const Element).init(allocator);
    errdefer list.deinit();
    while (iter.next()) |item| {
        try list.append(item);
    }
    return list.toOwnedSlice();
}
