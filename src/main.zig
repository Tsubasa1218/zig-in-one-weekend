const std = @import("std");

const Size = @import("./Types.zig").Size;
const Vec3 = @import("./Types.zig").Vec3;
const WorldSize = @import("./Types.zig").WorldSize;

const Ray = @import("./Ray.zig").Ray;
const Camera = @import("./Camera.zig").Camera;
const Sphere = @import("./Sphere.zig").Sphere;
const Tracer = @import("./Tracer.zig");
const Interval = @import("./Interval.zig").Interval;
const Material = @import("./Material.zig").Material;

const samples_per_pixel: i32 = 20;
const sample_avg_dividend: Vec3 = @splat(1.0 / @as(Size, @floatFromInt(samples_per_pixel)));

const MAX_DEPTH = 10;

fn linear_to_gamma(l: Size) Size {
    if (l > 0) return @sqrt(l);

    return l;
}

fn vec_linear_to_gamma(l: Vec3) Vec3 {
    return Vec3{
        linear_to_gamma(l[0]),
        linear_to_gamma(l[1]),
        linear_to_gamma(l[2]),
    };
}

fn render_world(camera: *Camera, world: [WorldSize]Sphere) !void {
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    try stdout.print("P3\n{} {}\n255\n", .{ camera.width, camera.height });

    const pixel_interval = Interval{ .min = 0.000001, .max = 1.0 };

    for (0..camera.height) |j| {
        for (0..camera.width) |i| {
            const is: Vec3 = @splat(@floatFromInt(i));
            const js: Vec3 = @splat(@floatFromInt(j));

            var color = Vec3{ 0, 0, 0 };
            for (0..samples_per_pixel) |_| {
                var ray = camera.sample_ray(is, js);
                color += Tracer.trace(&ray, world, MAX_DEPTH);
            }

            color = vec_linear_to_gamma(color * sample_avg_dividend);

            const r = @as(i32, @intFromFloat(pixel_interval.clamp(color[0]) * 255));
            const g = @as(i32, @intFromFloat(pixel_interval.clamp(color[1]) * 255));
            const b = @as(i32, @intFromFloat(pixel_interval.clamp(color[2]) * 255));
            try stdout.print("{} {} {}\n", .{ r, g, b });
        }
    }

    try bw.flush(); // don't forget to flush!

}

pub fn main() !void {
    const m_ground = Material{ .lambertian = .{ .color = Vec3{ 0.8, 0.8, 0.0 } } };
    const m_center = Material{ .lambertian = .{ .color = Vec3{ 0.1, 0.2, 0.5 } } };
    const m_left = Material{ .metal = .{ .color = Vec3{ 0.8, 0.8, 0.8 }, .fuzz = 0.3 } };
    const m_right = Material{ .metal = .{ .color = Vec3{ 0.8, 0.6, 0.2 }, .fuzz = 1.0 } };

    const s_center = Sphere{ .center = .{ 0, 0, -1.2 }, .radius = 0.5, .material = m_center };
    const s_ground = Sphere{ .center = .{ 0, -100.5, -1 }, .radius = 100, .material = m_ground };
    const s_left = Sphere{ .center = .{ -1, 0, -1 }, .radius = 0.5, .material = m_left };
    const s_right = Sphere{ .center = .{ 1, 0, -1 }, .radius = 0.5, .material = m_right };

    const world: [WorldSize]Sphere = .{ s_center, s_ground, s_left, s_right };
    var camera = Camera.init(16.0 / 9.0, 400);
    try render_world(&camera, world);
}
