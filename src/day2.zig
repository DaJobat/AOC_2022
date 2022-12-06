const std = @import("std");
const util = @import("util.zig");
const assert = std.debug.assert;

pub fn day2(_: std.mem.Allocator, input: []const u8) !void {
    const RPS = struct {
        const ShapeScore = enum(u32) {
            rock = 1,
            paper = 2,
            scissors = 3,
            fn from(in: u8) ShapeScore { //for part 1
                return switch (in) {
                    'A', 'X' => .rock,
                    'B', 'Y' => .paper,
                    'C', 'Z' => .scissors,
                    else => @panic("invalid letter"),
                };
            }

            fn fromOutcome(other: ShapeScore, desired: Outcome) ShapeScore {
                return switch (other) {
                    .rock => switch (desired) {
                        .win => .paper,
                        .draw => .rock,
                        .lose => .scissors,
                    },
                    .paper => switch (desired) {
                        .win => .scissors,
                        .draw => .paper,
                        .lose => .rock,
                    },
                    .scissors => switch (desired) {
                        .win => .rock,
                        .draw => .scissors,
                        .lose => .paper,
                    },
                };
            }
        };

        const Outcome = enum(u32) {
            lose = 0,
            draw = 3,
            win = 6,

            fn from(in: u8) Outcome {
                return switch (in) {
                    'X' => .lose,
                    'Y' => .draw,
                    'Z' => .win,
                    else => @panic("invalid letter"),
                };
            }
        };

        const Battle = struct { l: ShapeScore, r: ShapeScore };

        fn rps(battle: Battle) Outcome {
            return switch (battle.l) {
                .rock => switch (battle.r) {
                    .rock => .draw,
                    .paper => .lose,
                    .scissors => .win,
                },
                .paper => switch (battle.r) {
                    .rock => .win,
                    .paper => .draw,
                    .scissors => .lose,
                },
                .scissors => switch (battle.r) {
                    .rock => .lose,
                    .paper => .win,
                    .scissors => .draw,
                },
            };
        }

        fn part1(buf: []const u8) u32 {
            assert(buf.len == 3);
            const battle = Battle{ .l = ShapeScore.from(buf[2]), .r = ShapeScore.from(buf[0]) };
            return @enumToInt(rps(battle)) + @enumToInt(battle.l);
        }

        fn part2(buf: []const u8) u32 {
            assert(buf.len == 3);
            const r = ShapeScore.from(buf[0]);
            const battle = Battle{ .l = ShapeScore.fromOutcome(r, Outcome.from(buf[2])), .r = r };
            return @enumToInt(rps(battle)) + @enumToInt(battle.l);
        }
    };

    var total: u32 = 0;
    var lines = util.splitLines(input[0 .. input.len - 1]); //get rid of the last newline
    while (lines.next()) |line| {
        total += RPS.part2(line);
    }
    std.debug.print("{}\n", .{total});
}
