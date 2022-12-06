const std = @import("std");
const util = @import("util.zig");
const assert = std.debug.assert;

pub fn day3(_: std.mem.Allocator, input: []const u8) !void {
    var lines = util.splitLines(input);
    var prio_total: usize = 0;
    while (lines.next()) |line| {
        if (line.len == 0) continue;
        assert(line.len % 2 == 0);
        const cmpt_size = @divExact(line.len, 2);
        const first_half = line[0..cmpt_size];
        const second_half = line[cmpt_size..];

        const shared_item = outer: {
            for (first_half) |item| {
                for (second_half) |other_item| {
                    if (item == other_item) {
                        break :outer item;
                    }
                }
            }
            unreachable;
        };

        prio_total += switch (shared_item) {
            'a'...'z' => shared_item - 'a' + 1,
            'A'...'Z' => shared_item - 'A' + 27,
            else => unreachable,
        };
        std.debug.print("shared: {c}\ttotal {}\n", .{ shared_item, prio_total });
    }

    std.debug.print("prio total: {}\n", .{prio_total});
}

pub fn day3Part2(_: std.mem.Allocator, input: []const u8) !void {
    var lines = util.splitLines(input);
    var badge_prio_total: usize = 0;

    var num_groups = @divExact(util.count(input, '\n'), 3);
    var i: usize = 0;
    while (i < num_groups) : (i += 1) {
        var elf_group = [_][]const u8{ lines.next().?, lines.next().?, lines.next().? };

        const badge = outer: {
            for (elf_group[0]) |x0| {
                for (elf_group[1]) |x1| {
                    if (x0 == x1) {
                        for (elf_group[2]) |x2| {
                            if (x1 == x2) break :outer x0;
                        }
                    }
                }
            }
            unreachable;
        };
        badge_prio_total += switch (badge) {
            'a'...'z' => badge - 'a' + 1,
            'A'...'Z' => badge - 'A' + 27,
            else => unreachable,
        };
    }

    std.debug.print("badge: {}\n", .{badge_prio_total});
}
