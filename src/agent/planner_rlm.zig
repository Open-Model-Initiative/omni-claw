const std = @import("std");

pub const Plan = struct {
    tool: []const u8,
    argument: []const u8,
};

pub const Planner = struct {
    allocator: std.mem.Allocator,
    client: std.http.Client,

    pub fn init(allocator: std.mem.Allocator) Planner {
        return .{
            .allocator = allocator,
            .client = .{ .allocator = allocator },
        };
    }

    pub fn deinit(self: *Planner) void {
        self.client.deinit();
    }

    pub fn plan(self: *Planner, prompt: []const u8) !Plan {
        if (prompt.len == 0) return Plan{ .tool = try self.allocator.dupe(u8, "echo"), .argument = "" };

        if (self.queryOmniRlm(prompt)) |tool| {
            return Plan{ .tool = tool, .argument = prompt };
        } else |_| {}

        const lowered = try std.ascii.allocLowerString(self.allocator, prompt);
        defer self.allocator.free(lowered);

        if (std.mem.indexOf(u8, lowered, "search") != null or std.mem.indexOf(u8, lowered, "find") != null)
            return Plan{ .tool = try self.allocator.dupe(u8, "web_search"), .argument = prompt };

        return Plan{ .tool = try self.allocator.dupe(u8, "echo"), .argument = prompt };
    }

    fn queryOmniRlm(self: *Planner, prompt: []const u8) ![]const u8 {
        const base_url = std.process.getEnvVarOwned(self.allocator, "OMNI_RLM_URL") catch |err| switch (err) {
            error.EnvironmentVariableNotFound => try self.allocator.dupe(u8, "http://127.0.0.1:11435"),
            else => return err,
        };
        defer self.allocator.free(base_url);

        const uri_text = try std.fmt.allocPrint(self.allocator, "{s}/plan", .{base_url});
        defer self.allocator.free(uri_text);

        const body = try std.json.stringifyAlloc(self.allocator, .{ .prompt = prompt }, .{});
        defer self.allocator.free(body);

        const uri = try std.Uri.parse(uri_text);
        var server_header_buf: [2048]u8 = undefined;
        var req = try self.client.open(.POST, uri, .{
            .server_header_buffer = &server_header_buf,
            .headers = .{ .content_type = .{ .override = "application/json" } },
        });
        defer req.deinit();

        req.transfer_encoding = .{ .content_length = body.len };
        try req.send();
        try req.writeAll(body);
        try req.finish();
        try req.wait();

        if (req.response.status != .ok) return error.InvalidOmniRlmResponse;

        const response = try req.reader().readAllAlloc(self.allocator, 32 * 1024);
        defer self.allocator.free(response);

        var parsed = try std.json.parseFromSlice(std.json.Value, self.allocator, response, .{});
        defer parsed.deinit();

        const obj = parsed.value.object;
        const tool_value = obj.get("tool") orelse return error.InvalidOmniRlmResponse;
        if (tool_value != .string) return error.InvalidOmniRlmResponse;

        return self.allocator.dupe(u8, tool_value.string);
    }
};
