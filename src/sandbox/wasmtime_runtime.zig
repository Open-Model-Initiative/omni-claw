
const std = @import("std");

pub fn run(module: []const u8) !void {

    std.debug.print("Running WASM tool: {s}\n", .{module});
}
