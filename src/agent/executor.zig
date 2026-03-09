
const std = @import("std");
const Wasm = @import("../sandbox/wasmtime_runtime.zig");

pub const Executor = struct {

    pub fn init() Executor {
        return .{};
    }

    pub fn execute(self: *Executor, tool: []const u8) !void {

        _ = self;

        std.debug.print("Executing tool: {s}\n", .{tool});

        if (std.mem.eql(u8, tool, "echo")) {

            std.debug.print("Echo tool executed\n", .{});
            return;
        }

        try Wasm.run(tool);
    }
};
