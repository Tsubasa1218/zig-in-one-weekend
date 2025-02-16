const std = @import("std");

const Size = @import("./Types.zig").Size;
const Vec3 = @import("./Types.zig").Vec3;
const WorldSize = @import("./Types.zig").WorldSize;

const Ray = @import("./Ray.zig").Ray;
const Interval = @import("./Interval.zig").Interval;
const HitRecord = @import("./HitRecord.zig").HitRecord;
const Sphere = @import("./Sphere.zig").Sphere;
const vec_utils = @import("./VectorUtils.zig");

const normalized = vec_utils.normalized;

const ones = @as(Vec3, @splat(1));
const black = @as(Vec3, @splat(0));
const halfs = @as(Vec3, @splat(0.5));

fn hit_objects(spheres: [WorldSize]Sphere, ray: *const Ray, interval: Interval) ?HitRecord {
    var final_record: ?HitRecord = null;
    var closest_so_far = interval.max;

    for (spheres) |s| {
        if (s.hit(ray, .{ .min = interval.min, .max = closest_so_far })) |hit| {
            closest_so_far = hit.t;
            final_record = hit;
        }
    }

    return final_record;
}

pub fn trace(ray: *const Ray, world: [WorldSize]Sphere, depth: i32) Vec3 {
    if (depth <= 0) {
        return black;
    }

    if (hit_objects(world, ray, Interval{ .min = 0, .max = std.math.inf(Size) })) |hit_record| {
        if (hit_record.material.scatter(ray, &hit_record)) |material_hit_record| {
            return material_hit_record.scattered_color * trace(&material_hit_record.scattered_ray, world, depth - 1);
        }

        return Vec3{ 0, 0, 0 };
    }

    const unit = normalized(ray.direction);

    const a: Vec3 = @splat(0.5 * (unit[1] + 1.0));

    return (ones - a) * ones + (a * Vec3{ 0.5, 0.7, 1.0 });
}
