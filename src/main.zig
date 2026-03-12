const std = @import("std");
const omniclaw = @import("omniclaw.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var runtime = try omniclaw.Runtime.init(allocator);
    defer runtime.deinit();

    try runtime.start();
}
