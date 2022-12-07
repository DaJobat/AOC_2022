const std = @import("std");
const util = @import("util.zig");
const assert = std.debug.assert;

pub fn day7(allocator: std.mem.Allocator, input: []const u8) !void {
    var root = FD{ .dir = FD.Dir.init(allocator, "/") }; //root of tree of files
    defer root.deinit(allocator);

    var nav_stack = std.ArrayList(*FD.Dir).init(allocator);
    defer nav_stack.deinit();
    try nav_stack.append(&root.dir);

    var out_iter = std.mem.tokenize(u8, input, "\n");
    while (out_iter.next()) |line| { //parse file system into our tree
        switch (line[0]) {
            '$' => {
                var cmd = std.mem.tokenize(u8, line, " ");
                while (cmd.next()) |tok| {
                    if (std.mem.eql(u8, tok, "ls")) {
                        break;
                    } else if (std.mem.eql(u8, tok, "cd")) {
                        const arg = cmd.next().?;

                        if (std.mem.eql(u8, arg, "/")) {
                            while (nav_stack.items.len > 1) {
                                _ = nav_stack.pop();
                            }
                        } else if (std.mem.eql(u8, arg, "..")) {
                            assert(nav_stack.items.len > 0);
                            _ = nav_stack.pop();
                        } else {
                            var c_node = nav_stack.items[nav_stack.items.len - 1];
                            var success = false;
                            for (c_node.*.contents.items) |item, i| {
                                switch (item) {
                                    FD.dir => |d| {
                                        if (std.mem.eql(u8, arg, d.name)) {
                                            try nav_stack.append(&c_node.*.contents.items[i].dir);
                                            success = true;
                                            break;
                                        }
                                    },
                                    else => {},
                                }
                            }
                            assert(success);
                        }
                    }
                }
            },
            else => {
                var c_node = nav_stack.items[nav_stack.items.len - 1];
                var out = std.mem.tokenize(u8, line, " ");
                while (out.next()) |tok| {
                    if (std.mem.eql(u8, tok, "dir")) {
                        const name = out.next().?;
                        try c_node.contents.append(FD{ .dir = FD.Dir.init(allocator, name) });
                    } else {
                        const size = tok;
                        const name = out.next().?;
                        try c_node.contents.append(FD{ .file = FD.File.init(allocator, name, size) });
                    }
                }
            },
        }
    }

    var sizes_list = std.ArrayList(usize).init(allocator);
    _ = root.dir.size(&sizes_list);
    var sizes = sizes_list.toOwnedSlice();
    std.sort.sort(usize, sizes, {}, std.sort.asc(usize));

    const max_size = 70_000_000;
    const req_free = 30_000_000;

    const curr_free = max_size - sizes[sizes.len - 1];

    var p1_total: usize = 0;
    var p2_total: usize = 0;
    for (sizes) |size| {
        if (size <= 100_000) p1_total += size;
        if (size >= req_free - curr_free) {
            p2_total = size;
            break;
        }
    }

    std.debug.print("p1_total: {}, p2_total:{}\n", .{ p1_total, p2_total });
}

const FD = union(enum) {
    //this would be nicer with some kind of name => inode hashmap
    file: File,
    dir: Dir,

    fn deinit(fd: FD, allocator: std.mem.Allocator) void {
        switch (fd) {
            FD.dir => |d| {
                for (d.contents.items) |*item| item.deinit(allocator);
                allocator.free(d.name);
            },
            FD.file => |f| allocator.free(f.name),
        }
    }

    const File = struct {
        name: []const u8,
        size: usize,
        fn init(allocator: std.mem.Allocator, name: []const u8, size_str: []const u8) File {
            var buf = allocator.alloc(u8, name.len) catch unreachable; //ignore memory errors for this
            std.mem.copy(u8, buf, name);
            const size = std.fmt.parseInt(usize, size_str, 10) catch unreachable;
            return .{
                .name = buf,
                .size = size,
            };
        }
    };

    const Dir = struct {
        name: []const u8,
        contents: std.ArrayList(FD),
        fn init(allocator: std.mem.Allocator, name: []const u8) Dir {
            var buf = allocator.alloc(u8, name.len) catch unreachable; //ignore memory errors for this
            std.mem.copy(u8, buf, name);
            return .{
                .name = buf,
                .contents = std.ArrayList(FD).init(allocator),
            };
        }

        fn size(dir: Dir, list: *std.ArrayList(usize)) usize {
            var total: usize = 0;
            for (dir.contents.items) |item| {
                switch (item) {
                    .dir => |d| total += d.size(list),
                    .file => |f| total += f.size,
                }
            }

            list.append(total) catch unreachable;
            return total;
        }
    };
};
