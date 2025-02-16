const Size = @import("./Types.zig").Size;
const Vec3 = @import("./Types.zig").Vec3;

const Ray = @import("./Ray.zig").Ray;
const Interval = @import("./Interval.zig").Interval;
const HitRecord = @import("./HitRecord.zig").HitRecord;
const Material = @import("./Material.zig").Material;

const vec_utils = @import("./VectorUtils.zig");

pub const Sphere = struct {
    center: Vec3,
    radius: Size,
    material: Material,

    pub fn hit(self: Sphere, ray: *const Ray, interval: Interval) ?HitRecord {
        const oc = self.center - ray.origin;

        const a = vec_utils.vec_len_squared(ray.direction);
        const h = vec_utils.dot(ray.direction, oc);
        const c = vec_utils.vec_len_squared(oc) - self.radius * self.radius;

        const discriminant = h * h - a * c;

        if (discriminant < 0.0) {
            return null;
        }

        const discriminant_sqrt = @sqrt(discriminant);

        var root = (h - discriminant_sqrt) / a;

        if (!interval.surrounds(root)) {
            root = (h + discriminant_sqrt) / a;

            if (!interval.surrounds(root)) {
                return null;
            }
        }

        const hit_point = ray.at(root);
        const outward_normal = (hit_point - self.center) / @as(Vec3, @splat(self.radius));

        var record = HitRecord{
            .t = root,
            .point = hit_point,
            .normal = undefined,
            .front_face = false,
            .material = &self.material,
        };

        record.set_face_normal(ray, outward_normal);

        return record;
    }
};
