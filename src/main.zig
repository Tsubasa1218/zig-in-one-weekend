const std = @import("std");

const aspect_ratio: f32 = 16.0 / 9.0;
const width: i32 = 400;

const height: i32 = @floor(@as(f32, @floatFromInt(width)) / aspect_ratio);

const focal_length: f32 = 1.0;

const viewport_height: f32 = 2.0;
const viewport_width: f32 = viewport_height * (@as(f32, @floatFromInt(width)) / @as(f32, @floatFromInt(height)));

const viewport_u = @Vector(3, f32){ viewport_width, 0.0, 0.0 };
const viewport_v = @Vector(3, f32){ 0.0, -viewport_height, 0.0 };

const width_vec: @Vector(3, f32) = @splat(@floatFromInt(width));
const pixel_delta_u = viewport_u / width_vec;

const height_vec: @Vector(3, f32) = @splat(@floatFromInt(height));
const pixel_delta_v = viewport_v / height_vec;

const camera_center = @Vector(3, f32){ 0.0, 0.0, 0.0 };

const twos: @Vector(3, f32) = @splat(2.0);
const viewport_upper_left = camera_center - @Vector(3, f32){ 0.0, 0.0, focal_length } - (viewport_u / twos) - (viewport_v / twos);

const halfs: @Vector(3, f32) = @splat(0.5);
const pixel_00_loc = viewport_upper_left + halfs * (pixel_delta_u + pixel_delta_v);

const Image = struct {
    pixels: [height][width]@Vector(3, f32),
};

const Ray = struct {
    origin: @Vector(3, f32),
    direction: @Vector(3, f32),

    fn at(self: Ray, t: f32) @Vector(3, f32) {
        const ts: @Vector(3, f32) = @splat(t);
        return self.origin + self.direction * ts;
    }
};

fn render_image(img: *Image) !void {
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    try stdout.print("P3\n{} {}\n255\n", .{ width, height });

    for (img.pixels) |row| {
        for (row) |column| {
            const r = @as(i32, @intFromFloat(column[0] * 255));
            const g = @as(i32, @intFromFloat(column[1] * 255));
            const b = @as(i32, @intFromFloat(column[2] * 255));
            try stdout.print("{} {} {}\n", .{ r, g, b });
        }
    }

    try bw.flush(); // don't forget to flush!
}

fn vec_len(vec: @Vector(3, f32)) @Vector(3, f32) {
    const l: f32 = @sqrt(@reduce(.Add, vec * vec));

    return @Vector(3, f32){ l, l, l };
}

fn normalized(vec: @Vector(3, f32)) @Vector(3, f32) {
    return vec / vec_len(vec);
}

fn dot(a: @Vector(3, f32), b: @Vector(3, f32)) f32 {
    return @reduce(.Add, a * b);
}

fn cross(a: @Vector(3, f32), b: @Vector(3, f32)) @Vector(3, f32) {
    const x = a[1] * b[2] - a[2] * b[1];
    const y = a[2] * b[0] - a[0] * b[2];
    const z = a[0] * b[1] - a[1] * b[0];
    return @Vector(3, f32){ x, y, z };
}

fn generate_dummy_img() Image {
    var image = Image{ .pixels = undefined };

    for (&image.pixels, 0..) |*row, i| {
        for (row, 0..) |*column, j| {
            const r = @as(f32, @floatFromInt(i)) / @as(f32, @floatFromInt(width - 1));
            const g = @as(f32, @floatFromInt(j)) / @as(f32, @floatFromInt(height - 1));
            const b: f32 = 0.0;

            column.* = @Vector(3, f32){ r, g, b };
        }
    }

    return image;
}

fn hit_sphere(center: @Vector(3, f32), radius: f32, ray: *Ray) f32 {
    const oc = center - ray.origin;

    const a = dot(ray.direction, ray.direction);
    const b = -2.0 * dot(ray.direction, oc);
    const c = dot(oc, oc) - radius * radius;

    const discriminant = b * b - 4.0 * a * c;

    if (discriminant < 0.0) {
        return -1.0;
    }

    return (-b - @sqrt(discriminant)) / (2.0 * a);
}

fn ray_color(ray: *Ray) @Vector(3, f32) {
    const center = @Vector(3, f32){ 0.0, 0.0, -1.0 };
    const t = hit_sphere(center, 0.5, ray);
    if (t > 0.0) {
        const normal = normalized(ray.at(t) - center);

        std.debug.print("{}\n", .{vec_len(normal)});

        return halfs * @Vector(3, f32){ normal[0] + 1, normal[1] + 1, normal[2] + 1 };
    }

    const ones: @Vector(3, f32) = @splat(1.0);
    const unit = normalized(ray.direction);

    const a: @Vector(3, f32) = @splat(0.5 * (unit[1] + 1.0));

    return (ones - a) * ones + (a * @Vector(3, f32){ 0.5, 0.7, 1.0 });
}

fn generate_gradient_image() Image {
    var image = Image{ .pixels = undefined };

    for (&image.pixels, 0..) |*row, j| {
        for (row, 0..) |*column, i| {
            const is: @Vector(3, f32) = @splat(@floatFromInt(i));
            const js: @Vector(3, f32) = @splat(@floatFromInt(j));

            const pixel_center = pixel_00_loc + (is * pixel_delta_u) + (js * pixel_delta_v);
            const direction = pixel_center - camera_center;

            var ray = Ray{ .origin = camera_center, .direction = direction };

            column.* = ray_color(&ray);
        }
    }

    return image;
}

pub fn main() !void {
    var img = generate_gradient_image();
    try render_image(&img);
}
