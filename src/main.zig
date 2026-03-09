
const std = @import("std");
const Runtime = @import("runtime.zig").Runtime;

pub fn main() !void {

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var runtime = try Runtime.init(allocator);
    defer runtime.deinit();

    try runtime.start();
}
