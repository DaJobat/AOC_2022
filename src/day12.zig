const std = @import("std");
const assert = std.debug.assert;
const util = @import("util.zig");
const sr = @import("sliderule");

pub fn day12(allocator: std.mem.Allocator, input: []const u8) !void {
    const G = sr.graph.DirectedGraph(u8);
    var graph = G.init(allocator);
    var lines = std.mem.tokenize(u8, input, "\n");
    const width = lines.peek().?.len;
    const height = util.count(input, '\n');
    try graph.ensureTotalCapacity(width * height);

    //part two
    const lowest = util.count(input, 'a') + 1;
    var low_points = try allocator.alloc(usize, lowest);

    var start_idx: usize = 0;
    var end_idx: usize = 0;
    {
        var i: usize = 0;
        var y: usize = 0;
        while (lines.next()) |line| : (y += 1) {
            for (line) |point, x| {
                switch (point) {
                    'a' => {
                        const idx = try graph.insert(point - 'a');
                        low_points[i] = idx;
                        i += 1;
                    },
                    'b'...'z' => _ = try graph.insert(point - 'a'),
                    'S' => {
                        const idx = try graph.insert(0);
                        start_idx = y * width + x;
                        low_points[i] = idx;
                        i += 1;
                    },
                    'E' => {
                        _ = try graph.insert('z' - 'a');
                        end_idx = y * width + x;
                    },
                    else => unreachable,
                }
            }
        }
        assert(i == low_points.len);
    }

    var vert_iter = graph.iterator();
    while (vert_iter.next()) |vert| {
        const idx = vert_iter.index - 1;
        const x = @mod(idx, width);
        const y = @divFloor(idx, width);

        if (x > 0) {
            const chk_idx = idx - 1;
            const chk_vert = vert_iter.get(chk_idx).?;
            if (chk_vert <= vert + 1) try graph.connect(idx, chk_idx);
        }

        if (x < width - 1) {
            const chk_idx = idx + 1;
            const chk_vert = vert_iter.get(chk_idx).?;
            if (chk_vert <= vert + 1) try graph.connect(idx, chk_idx);
        }

        if (y > 0) {
            const chk_idx = idx - width;
            const chk_vert = vert_iter.get(chk_idx).?;
            if (chk_vert <= vert + 1) try graph.connect(idx, chk_idx);
        }

        if (y < height - 1) {
            const chk_idx = idx + width;
            const chk_vert = vert_iter.get(chk_idx).?;
            if (chk_vert <= vert + 1) try graph.connect(idx, chk_idx);
        }
    }

    { //part 1
        const tree = try graph.breadthFirstSearch(start_idx);
        defer allocator.free(tree);

        std.debug.print("part 1 distance: {?}\n", .{tree[end_idx].distance});
    }

    var min_dist: usize = 1000;
    for (low_points) |pt| {
        const tree = try graph.breadthFirstSearch(pt);
        defer allocator.free(tree);

        if (tree[end_idx].color == .black) {
            min_dist = std.math.min(min_dist, tree[end_idx].distance.?);
        }
    }

    std.debug.print("part 2 min dist: {?}\n", .{min_dist});
}
