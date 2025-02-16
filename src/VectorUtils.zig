const std = @import("std");

const Size = @import("./Types.zig").Size;
const Vec3 = @import("./Types.zig").Vec3;

const DefaultRNG = std.Random.DefaultPrng;
pub var RNG = DefaultRNG.init(0);

pub fn random_float() Size {
    return RNG.random().float(Size);
}

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

pub fn random_vec() Vec3 {
    return Vec3{
        random_float() * 2 - 1,
        random_float() * 2 - 1,
        random_float() * 2 - 1,
    };
}

pub fn random_unit_vec() Vec3 {
    var result = random_vec();
    var l = vec_len_squared(result);

    while (l > 1 or l < std.math.floatMin(Size)) {
        result = random_vec();
        l = vec_len_squared(result);
    }

    return normalized(result);
}

pub fn random_vec_on_hemisphere(normal: Vec3) Vec3 {
    const random = random_unit_vec();

    if (dot(normal, random) > 0) return random;

    return -random;
}
