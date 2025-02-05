const Vec3 = @import("./Types.zig").Vec3;
const Size = @import("./Types.zig").Size;

pub const Ray = struct {
    origin: Vec3,
    direction: Vec3,

    pub fn at(self: Ray, t: Size) Vec3 {
        const ts: Vec3 = @splat(t);
        return self.origin + self.direction * ts;
    }
};
