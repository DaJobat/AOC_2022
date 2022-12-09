const std = @import("std");
const util = @import("util.zig");
const assert = std.debug.assert;

pub fn day8(allocator: std.mem.Allocator, input: []const u8) !void {
    std.debug.print("{s}\n", .{input});
    const nl_count = util.count(input, '\n');
    var lines = std.mem.tokenize(u8, input, "\n");
    const first = lines.next().?;
    const width = first.len;
    const height = (input.len - nl_count) / width;

    var tree_map = try allocator.alloc(Tree, width * height);

    lines.reset();
    {
        var i: usize = 0;
        while (lines.next()) |line| {
            for (line) |tree, j| {
                tree_map[i * width + j] = .{
                    .height = tree - '0',
                    .vis = DirSet.init(.{ .north = false, .south = false, .east = false, .west = false }),
                    .view = View.initDefault(0, .{}),
                };
            }
            i += 1;
        }
    }

    {
        var x: usize = 1;
        var y: usize = 1;
        //first, check top down
        // zig fmt: off
        while (x < width - 1) : ({ x += 1; y = 1; }) {
        // zig fmt: on
            var tallest = tree_map[x].height; //set initial visible height to first tree
            while (y < height - 1) : (y += 1) {
                const c_idx = y * width + x;
                if (tree_map[c_idx].height > tallest) {
                    tree_map[c_idx].vis.insert(.north);
                    tallest = tree_map[c_idx].height;
                }
            }
        }

        //bottoms up
        x = 1;
        y = height - 2;
        // zig fmt: off
        while (x < width - 1) : ({ x += 1; y = height-2; }) {
        // zig fmt: on
            var tallest = tree_map[((height - 1) * width) + x].height; //set initial visible height to first tree
            while (y > 0) : (y -= 1) {
                const c_idx = y * width + x;
                if (tree_map[c_idx].height > tallest) {
                    tree_map[c_idx].vis.insert(.south);
                    tallest = tree_map[c_idx].height;
                }
            }
        }

        //lefty righty
        x = 1;
        y = 1;
        // zig fmt: off
        while (y < height - 1) : ({ y += 1; x = 1; }) {
        // zig fmt: on
            var tallest = tree_map[y * width].height; //set initial visible height to first tree
            while (x < width - 1) : (x += 1) {
                const c_idx = y * width + x;
                if (tree_map[c_idx].height > tallest) {
                    tree_map[c_idx].vis.insert(.east);
                    tallest = tree_map[c_idx].height;
                }
            }
        }

        //righty lefty
        x = width - 2;
        y = 1;
        // zig fmt: off
        while (y < height - 1) : ({ y += 1; x = width-2; }) {
        // zig fmt: on
            var tallest = tree_map[y * width + (width - 1)].height; //set initial visible height to first tree
            while (x > 0) : (x -= 1) {
                const c_idx = y * width + x;
                if (tree_map[c_idx].height > tallest) {
                    tree_map[c_idx].vis.insert(.west);
                    tallest = tree_map[c_idx].height;
                }
            }
        }
    }

    { //find view dist
        var x: usize = 1;
        var y: usize = 1;
        while (y < height - 1) : (y += 1) {
            while (x < width - 1) : (x += 1) {
                var tree = &tree_map[y * width + x];
                var i: usize = 1;
                //look up
                var chk_y = y - 1;
                while (chk_y > 0) : (chk_y -= 1) {
                    if (tree_map[chk_y * width + x].height >= tree.height) break;
                    i += 1;
                }
                tree.*.view.set(.north, i);

                //look down
                i = 1;
                chk_y = y + 1;
                while (chk_y < height - 1) : (chk_y += 1) {
                    if (tree_map[chk_y * width + x].height >= tree.height) break;
                    i += 1;
                }
                tree.*.view.set(.south, i);

                //look left
                i = 1;
                var chk_x = x - 1;
                while (chk_x > 0) : (chk_x -= 1) {
                    if (tree_map[y * width + chk_x].height >= tree.height) break;
                    i += 1;
                }
                tree.*.view.set(.west, i);

                //look right
                i = 1;
                chk_x = x + 1;
                while (chk_x < width) : (chk_x += 1) {
                    if (tree_map[y * width + chk_x].height >= tree.height) break;
                    i += 1;
                }
                tree.*.view.set(.east, i);
                std.debug.print("{},{}:{any}\n", .{ x, y, tree.view.values });
            }
            x = 1;
        }
    }
    //{ //draw pretty map
    //    var writer = std.io.getStdOut().writer();
    //    var x: usize = 0;
    //    var y: usize = 0;

    //    while (y < height) : ({
    //        y += 1;
    //        x = 0;
    //    }) {
    //        while (x < width) : (x += 1) {
    //            try writer.print("{}", .{@boolToInt(tree_map[y * width + x].vis.count() > 0)});
    //        }
    //        try writer.writeByte('\n');
    //    }
    //}

    var highest_score: usize = 0;
    var total: usize = 0;
    for (tree_map) |tree| {
        if (tree.vis.count() > 0) total += 1;
        const score = tree.view.get(.north) * tree.view.get(.south) * tree.view.get(.east) * tree.view.get(.west);
        if (score > 0) std.debug.print("{}\n", .{score});
        highest_score = std.math.max(score, highest_score);
    }

    total += (2 * width) + (2 * height) - 4;
    std.debug.print("total: {} highest: {}\n", .{ total, highest_score });
}

const Dirs = enum { north, east, south, west };
const DirSet = std.EnumSet(Dirs);
const View = std.EnumArray(Dirs, usize);
const Tree = struct {
    height: usize,
    vis: DirSet,
    view: std.EnumArray(Dirs, usize),
};
