const std = @import("std");

const Size = @import("./Types.zig").Size;
const Vec3 = @import("./Types.zig").Vec3;

const Ray = @import("./Ray.zig").Ray;
const Interval = @import("./Interval.zig").Interval;
const HitRecord = @import("./HitRecord.zig").HitRecord;
const Sphere = @import("./Sphere.zig").Sphere;
const normalized = @import("./VectorUtils.zig").normalized;

const ones = @as(Vec3, @splat(1));
const halfs = @as(Vec3, @splat(0.5));

fn hit_objects(spheres: [2]Sphere, ray: *Ray, interval: Interval) ?HitRecord {
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

pub fn trace(ray: *Ray, world: [2]Sphere) Vec3 {
    if (hit_objects(world, ray, Interval{ .min = 0, .max = std.math.inf(Size) })) |record| {
        return halfs * (record.normal + ones);
    }

    const unit = normalized(ray.direction);

    const a: Vec3 = @splat(0.5 * (unit[1] + 1.0));

    return (ones - a) * ones + (a * Vec3{ 0.5, 0.7, 1.0 });
}
