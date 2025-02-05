const std = @import("std");

const Size = @import("./Types.zig").Size;
const Vec3 = @import("./Types.zig").Vec3;

const Ray = @import("./Ray.zig").Ray;
const Camera = @import("./Camera.zig").Camera;
const Sphere = @import("./Sphere.zig").Sphere;
const Tracer = @import("./Tracer.zig");

fn render_world(camera: *Camera, world: [2]Sphere) !void {
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    try stdout.print("P3\n{} {}\n255\n", .{ camera.width, camera.height });

    for (0..camera.height) |j| {
        for (0..camera.width) |i| {
            const is: Vec3 = @splat(@floatFromInt(i));
            const js: Vec3 = @splat(@floatFromInt(j));

            const pixel_center = camera.pixel_00_loc + (is * camera.pixel_delta_u) + (js * camera.pixel_delta_v);
            const direction = pixel_center - camera.center;

            var ray = Ray{ .origin = camera.center, .direction = direction };

            const color = Tracer.trace(&ray, world);

            const r = @as(i32, @intFromFloat(color[0] * 255));
            const g = @as(i32, @intFromFloat(color[1] * 255));
            const b = @as(i32, @intFromFloat(color[2] * 255));
            try stdout.print("{} {} {}\n", .{ r, g, b });
        }
    }

    try bw.flush(); // don't forget to flush!

}

pub fn main() !void {
    const world: [2]Sphere = .{ .{ .center = .{ 0, 0, -1 }, .radius = 0.5 }, .{ .center = .{ 0, -100.5, -1 }, .radius = 100 } };
    var camera = Camera.init(16.0 / 9.0, 400);
    try render_world(&camera, world);
}
