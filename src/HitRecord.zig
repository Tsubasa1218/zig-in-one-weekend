const Vec3 = @import("./Types.zig").Vec3;
const Size = @import("./Types.zig").Size;

const Ray = @import("./Ray.zig").Ray;
const dot = @import("./VectorUtils.zig").dot;

pub const HitRecord = struct {
    point: Vec3,
    normal: Vec3,
    t: Size,
    front_face: bool,

    pub fn set_face_normal(self: *HitRecord, ray: *Ray, outward_normal: Vec3) void {
        self.*.front_face = dot(ray.direction, outward_normal) < 0.0;
        if (self.front_face) {
            self.*.normal = outward_normal;
        } else {
            self.*.normal = -outward_normal;
        }
    }
};
