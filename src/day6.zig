const std = @import("std");
const util = @import("util.zig");

pub fn day6(_: std.mem.Allocator, input: []const u8) !void {
    //change this to 4 for part 1
    const offset = 14;
    const soc = blk: {
        for (input[0 .. input.len - offset]) |c, i| {
            if (c < 'a' or c > 'z') continue;
            var set = std.StaticBitSet(26).initEmpty();
            for (input[i .. i + offset]) |char| {
                set.set(char - 'a');
            }
            if (set.count() == offset) break :blk i + offset; //this will be wrong if the dupe is in the first 4 chars i think
        }
        unreachable;
    };

    std.debug.print("soc: {}\n", .{soc});
}
