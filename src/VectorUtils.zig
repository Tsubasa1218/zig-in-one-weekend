const Size = @import("./Types.zig").Size;
const Vec3 = @import("./Types.zig").Vec3;

pub fn vec_len_squared(vec: Vec3) Size {
    const l: Size = @reduce(.Add, vec * vec);

    return l;
}

pub fn vec_len(vec: Vec3) Size {
    const l: Size = @sqrt(@reduce(.Add, vec * vec));

    return l;
}

pub fn normalized(vec: Vec3) Vec3 {
    const l = vec_len(vec);
    return vec / Vec3{ l, l, l };
}

pub fn dot(a: Vec3, b: Vec3) Size {
    return @reduce(.Add, a * b);
}

pub fn cross(a: Vec3, b: Vec3) Vec3 {
    const x = a[1] * b[2] - a[2] * b[1];
    const y = a[2] * b[0] - a[0] * b[2];
    const z = a[0] * b[1] - a[1] * b[0];
    return Vec3{ x, y, z };
}
