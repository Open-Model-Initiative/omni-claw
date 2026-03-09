
const std = @import("std");

pub const Vector = []f32;

pub fn cosine(a: Vector, b: Vector) f32 {

    var dot: f32 = 0;
    var magA: f32 = 0;
    var magB: f32 = 0;

    for (a, b) |x, y| {

        dot += x * y;
        magA += x * x;
        magB += y * y;
    }

    return dot / (std.math.sqrt(magA) * std.math.sqrt(magB));
}
