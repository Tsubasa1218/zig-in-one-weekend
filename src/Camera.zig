const std = @import("std");

const Size = @import("./Types.zig").Size;
const Vec3 = @import("./Types.zig").Vec3;

const Ray = @import("./Ray.zig").Ray;
const Interval = @import("./Interval.zig").Interval;
const HitRecord = @import("./HitRecord.zig").HitRecord;
const Sphere = @import("./Sphere.zig").Sphere;
const normalized = @import("./VectorUtils.zig").normalized;

const twos: Vec3 = @splat(2.0);
const halfs = @as(Vec3, @splat(0.5));

const DefaultRNG = std.Random.DefaultPrng;
var RNG = DefaultRNG.init(0);

pub const Camera = struct {
    width: usize,
    height: usize,
    center: Vec3,
    pixel_00_loc: Vec3,
    pixel_delta_u: Vec3,
    pixel_delta_v: Vec3,

    pub fn init(aspect_ratio: Size, width: usize) Camera {
        const height: usize = @intFromFloat(@floor(@as(Size, @floatFromInt(width)) / aspect_ratio));
        const focal_length: Size = 1.0;

        const viewport_height: Size = 2.0;
        const viewport_width: Size = viewport_height * (@as(Size, @floatFromInt(width)) / @as(Size, @floatFromInt(height)));

        const viewport_u = Vec3{ viewport_width, 0.0, 0.0 };
        const viewport_v = Vec3{ 0.0, -viewport_height, 0.0 };

        const width_vec: Vec3 = @splat(@floatFromInt(width));
        const pixel_delta_u = viewport_u / width_vec;

        const height_vec: Vec3 = @splat(@floatFromInt(height));
        const pixel_delta_v = viewport_v / height_vec;

        const camera_center = Vec3{ 0.0, 0.0, 0.0 };

        const viewport_upper_left = camera_center - Vec3{ 0.0, 0.0, focal_length } - (viewport_u / twos) - (viewport_v / twos);

        const pixel_00_loc = viewport_upper_left + halfs * (pixel_delta_u + pixel_delta_v);

        return Camera{
            .width = width,
            .height = height,
            .center = camera_center,
            .pixel_00_loc = pixel_00_loc,
            .pixel_delta_u = pixel_delta_u,
            .pixel_delta_v = pixel_delta_v,
        };
    }

    pub fn sample_ray(self: Camera, is: Vec3, js: Vec3) Ray {
        const offset_i = RNG.random().float(Size) - 0.5;
        const offset_j = RNG.random().float(Size) - 0.5;

        const offset_vec_i: Vec3 = @splat(offset_i);
        const offset_vec_j: Vec3 = @splat(offset_j);

        const pixel_center = self.pixel_00_loc +
            ((is + offset_vec_i) * self.pixel_delta_u) +
            ((js + offset_vec_j) * self.pixel_delta_v);

        const direction = pixel_center - self.center;

        return Ray{ .origin = self.center, .direction = direction };
    }
};
