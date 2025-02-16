const Vec3 = @import("./Types.zig").Vec3;
const Size = @import("./Types.zig").Size;
const Ray = @import("./Ray.zig").Ray;
const HitRecord = @import("./HitRecord.zig").HitRecord;
const vec_utils = @import("./VectorUtils.zig");

pub const Lambertian = struct {
    color: Vec3,
};

pub const Metal = struct {
    color: Vec3,
    fuzz: Size,
};

pub const MaterialHitRecord = struct {
    scattered_ray: Ray,
    scattered_color: Vec3,
};

pub const Material = union(enum) {
    lambertian: Lambertian,
    metal: Metal,

    pub fn scatter(self: Material, ray_in: *const Ray, hit_record: *const HitRecord) ?MaterialHitRecord {
        return switch (self) {
            Material.lambertian => |mat| {
                var scatter_direction = hit_record.normal + vec_utils.random_unit_vec();

                if (vec_utils.vec_near_zero(scatter_direction)) {
                    scatter_direction = hit_record.normal;
                }

                const scattered_ray = Ray{ .origin = hit_record.point, .direction = scatter_direction };

                return MaterialHitRecord{
                    .scattered_ray = scattered_ray,
                    .scattered_color = mat.color,
                };
            },
            Material.metal => |mat| {
                var scatter_direction = vec_utils.reflect(ray_in.direction, hit_record.normal);
                scatter_direction = vec_utils.normalized(scatter_direction) + (Vec3{ mat.fuzz, mat.fuzz, mat.fuzz } * vec_utils.random_unit_vec());
                const scattered_ray = Ray{ .origin = hit_record.point, .direction = scatter_direction };

                if (vec_utils.dot(scattered_ray.direction, hit_record.normal) <= 0) {
                    return null;
                }

                return MaterialHitRecord{
                    .scattered_ray = scattered_ray,
                    .scattered_color = mat.color,
                };
            },
        };
    }
};
